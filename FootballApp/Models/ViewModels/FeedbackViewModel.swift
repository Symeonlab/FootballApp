//
//  FeedbackViewModel.swift
//  FootballApp
//
//  ViewModel for managing feedback questions and user responses
//  Based on DIPODDI PROGRAMME FEED BACK sheet structure
//
import Foundation
import Combine
import os.log
import SwiftUI

@MainActor
class FeedbackViewModel: ObservableObject {
    // MARK: - Published Properties

    /// Available feedback categories for the user
    @Published var availableCategories: [FeedbackCategory] = []

    /// Currently selected category
    @Published var selectedCategory: FeedbackCategory?

    /// Questions for the selected category
    @Published var questions: [FeedbackQuestion] = []

    /// Current answers being collected
    @Published var currentAnswers: [Int: String] = [:] // questionId -> answer

    /// Feedback history/summaries
    @Published var feedbackHistory: [FeedbackSummary] = []

    /// Loading state
    @Published var isLoading: Bool = false

    /// Error message
    @Published var errorMessage: String?

    /// Current question index for paginated view
    @Published var currentQuestionIndex: Int = 0

    /// Session ID for grouping answers
    @Published var sessionId: String = UUID().uuidString

    // MARK: - Private Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "Feedback")
    private let api = APIService.shared
    private var cancellables = Set<AnyCancellable>()

    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Computed Properties

    var currentQuestion: FeedbackQuestion? {
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }

    var progress: Double {
        guard !questions.isEmpty else { return 0 }
        return Double(currentAnswers.count) / Double(questions.count)
    }

    var isComplete: Bool {
        !questions.isEmpty && currentAnswers.count == questions.count
    }

    var answeredCount: Int {
        currentAnswers.count
    }

    var totalQuestions: Int {
        questions.count
    }

    // MARK: - Initialization

    init() {
        logger.info("📋 FeedbackViewModel initialized")

        if isPreview {
            loadMockData()
        }
    }

    // MARK: - Public Methods

    /// Load categories from the API (filtered by user's profile on the server)
    func loadCategoriesFromAPI() async {
        logger.info("📂 Loading feedback categories from API")
        isLoading = true

        if isPreview {
            loadMockData()
            isLoading = false
            return
        }

        do {
            let response: FeedbackCategoriesResponse = try await api.request(
                endpoint: APIEndpoints.feedbackCategories,
                method: "GET"
            )

            // Map API categories to local FeedbackCategory enum
            availableCategories = response.data.compactMap { apiCategory in
                FeedbackCategory(rawValue: apiCategory.key)
            }
            logger.info("✅ Loaded \(self.availableCategories.count) feedback categories from API")
        } catch {
            logger.error("❌ Failed to load categories from API: \(error.localizedDescription)")
            // Fall back to local filtering
            loadMockData()
        }

        isLoading = false
    }

    /// Load categories relevant to the user's profile (local fallback)
    func loadCategories(discipline: String?, goal: String?, position: String?, hasInjury: Bool?, gender: String?) {
        logger.info("📂 Loading feedback categories locally for discipline: \(discipline ?? "nil"), goal: \(goal ?? "nil")")

        var categories = FeedbackCategory.relevantCategories(
            discipline: discipline,
            goal: goal,
            position: position,
            hasInjury: hasInjury
        )

        // Add gender-specific fitness categories
        if discipline != "football" {
            if gender?.lowercased() == "female" || gender?.lowercased() == "femme" {
                if !categories.contains(.fitnessWomen) {
                    categories.insert(.fitnessWomen, at: 0)
                }
            } else {
                if !categories.contains(.fitnessMen) {
                    categories.insert(.fitnessMen, at: 0)
                }
            }
        }

        availableCategories = categories
        logger.info("✅ Loaded \(categories.count) feedback categories locally")
    }

    /// Load questions for a specific category
    func loadQuestions(for category: FeedbackCategory) async {
        logger.info("📝 Loading questions for category: \(category.rawValue)")

        selectedCategory = category
        isLoading = true
        errorMessage = nil
        currentQuestionIndex = 0
        currentAnswers = [:]
        sessionId = UUID().uuidString

        if isPreview {
            loadMockQuestions(for: category)
            isLoading = false
            return
        }

        do {
            let response: FeedbackQuestionsResponse = try await api.request(
                endpoint: "/feedback/questions/\(category.rawValue)",
                method: "GET"
            )

            questions = response.data.sorted { ($0.sortOrder ?? 0) < ($1.sortOrder ?? 0) }
            logger.info("✅ Loaded \(self.questions.count) questions")
        } catch {
            logger.error("❌ Failed to load questions: \(error.localizedDescription)")
            errorMessage = "feedback.error.load_questions".localizedString

            // Fall back to mock data if API fails
            loadMockQuestions(for: category)
        }

        isLoading = false
    }

    /// Record an answer for the current question
    func recordAnswer(_ value: String, for questionId: Int) {
        logger.info("💬 Recording answer for question \(questionId): \(value)")
        currentAnswers[questionId] = value
    }

    /// Move to next question
    func nextQuestion() {
        guard currentQuestionIndex < questions.count - 1 else { return }
        currentQuestionIndex += 1
    }

    /// Move to previous question
    func previousQuestion() {
        guard currentQuestionIndex > 0 else { return }
        currentQuestionIndex -= 1
    }

    /// Submit all answers
    func submitFeedback() async -> Bool {
        guard let category = selectedCategory else {
            logger.error("❌ No category selected for submission")
            return false
        }

        logger.info("📤 Submitting feedback for category: \(category.rawValue)")
        isLoading = true
        errorMessage = nil

        let answers = currentAnswers.map { FeedbackAnswerInput(questionId: $0.key, value: $0.value) }
        let request = SubmitFeedbackRequest(
            categoryKey: category.rawValue,
            answers: answers,
            sessionId: sessionId
        )

        if isPreview {
            // Simulate submission
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            isLoading = false
            return true
        }

        do {
            let response: SubmitFeedbackResponse = try await api.request(
                endpoint: "/feedback/submit",
                method: "POST",
                body: request
            )

            if response.success {
                logger.info("✅ Feedback submitted successfully")
                if let summary = response.data {
                    feedbackHistory.insert(summary, at: 0)
                }
                // Reset for next session
                resetSession()
                isLoading = false
                return true
            } else {
                errorMessage = response.message ?? "feedback.error.submit".localizedString
                isLoading = false
                return false
            }
        } catch {
            logger.error("❌ Failed to submit feedback: \(error.localizedDescription)")
            errorMessage = "feedback.error.submit".localizedString
            isLoading = false
            return false
        }
    }

    /// Load feedback history
    func loadHistory() async {
        logger.info("📜 Loading feedback history")
        isLoading = true

        if isPreview {
            loadMockHistory()
            isLoading = false
            return
        }

        do {
            let response: FeedbackHistory = try await api.request(
                endpoint: "/feedback/history",
                method: "GET"
            )

            feedbackHistory = response.data
            logger.info("✅ Loaded \(self.feedbackHistory.count) history items")
        } catch {
            logger.error("❌ Failed to load history: \(error.localizedDescription)")
            loadMockHistory()
        }

        isLoading = false
    }

    /// Reset the current session
    func resetSession() {
        currentAnswers = [:]
        currentQuestionIndex = 0
        sessionId = UUID().uuidString
    }

    // MARK: - Mock Data

    private func loadMockData() {
        availableCategories = [
            .footballGoalkeeper,
            .footballAfterMatch,
            .nutritionWeightLoss,
            .nutritionProphetic,
            .cognitive
        ]
    }

    private func loadMockQuestions(for category: FeedbackCategory) {
        // Sample questions based on the Excel FEED BACK sheet
        switch category {
        case .footballGoalkeeper:
            questions = [
                FeedbackQuestion(id: 1, category: category, questionFr: "Ta poussée a-t-elle permis d'atteindre la lucarne ?", questionEn: "Did your push allow you to reach the top corner?", questionAr: nil, answerType: .scale, sortOrder: 1),
                FeedbackQuestion(id: 2, category: category, questionFr: "Ta jambe d'appui a-t-elle tremblé à l'impact ?", questionEn: "Did your support leg shake on impact?", questionAr: nil, answerType: .yesNo, sortOrder: 2),
                FeedbackQuestion(id: 3, category: category, questionFr: "As-tu ressenti une lourdeur au 2ème saut ?", questionEn: "Did you feel heaviness on the 2nd jump?", questionAr: nil, answerType: .yesNo, sortOrder: 3),
                FeedbackQuestion(id: 4, category: category, questionFr: "Ta capacité à \"voler\" est-elle intacte ?", questionEn: "Is your ability to 'fly' intact?", questionAr: nil, answerType: .scale, sortOrder: 4),
                FeedbackQuestion(id: 5, category: category, questionFr: "Ton temps de suspension était-il suffisant ?", questionEn: "Was your suspension time sufficient?", questionAr: nil, answerType: .scale, sortOrder: 5)
            ]

        case .footballDefender:
            questions = [
                FeedbackQuestion(id: 10, category: category, questionFr: "Ta gestion de la distance avec l'attaquant ?", questionEn: "Your distance management with the attacker?", questionAr: nil, answerType: .scale, sortOrder: 1),
                FeedbackQuestion(id: 11, category: category, questionFr: "Ta coordination avec ton gardien de but ?", questionEn: "Your coordination with your goalkeeper?", questionAr: nil, answerType: .scale, sortOrder: 2),
                FeedbackQuestion(id: 12, category: category, questionFr: "Ta capacité à \"serrer\" l'attaquant au contact ?", questionEn: "Your ability to 'press' the attacker in contact?", questionAr: nil, answerType: .scale, sortOrder: 3)
            ]

        case .footballAfterMatch:
            questions = [
                FeedbackQuestion(id: 20, category: category, questionFr: "As-tu eu peur de te blesser ?", questionEn: "Were you afraid of getting injured?", questionAr: nil, answerType: .yesNo, sortOrder: 1),
                FeedbackQuestion(id: 21, category: category, questionFr: "Ton niveau d'énergie pour la suite de la journée est-il correct ?", questionEn: "Is your energy level for the rest of the day okay?", questionAr: nil, answerType: .scale, sortOrder: 2),
                FeedbackQuestion(id: 22, category: category, questionFr: "As-tu fini la séance sur une note positive ?", questionEn: "Did you finish the session on a positive note?", questionAr: nil, answerType: .yesNo, sortOrder: 3)
            ]

        case .nutritionWeightLoss:
            questions = [
                FeedbackQuestion(id: 30, category: category, questionFr: "Ton envie de grignoter était-elle liée à une fatigue physique ?", questionEn: "Was your urge to snack related to physical fatigue?", questionAr: nil, answerType: .yesNo, sortOrder: 1),
                FeedbackQuestion(id: 31, category: category, questionFr: "As-tu réussi à ne pas grignoter pendant que tu cuisinais ?", questionEn: "Did you manage not to snack while cooking?", questionAr: nil, answerType: .yesNo, sortOrder: 2),
                FeedbackQuestion(id: 32, category: category, questionFr: "Ta résistance aux commentaires des autres sur ta consommation ?", questionEn: "Your resistance to others' comments about your consumption?", questionAr: nil, answerType: .scale, sortOrder: 3)
            ]

        case .nutritionMuscleGain:
            questions = [
                FeedbackQuestion(id: 40, category: category, questionFr: "Ton apport en protéines était-il suffisant ?", questionEn: "Was your protein intake sufficient?", questionAr: nil, answerType: .scale, sortOrder: 1),
                FeedbackQuestion(id: 41, category: category, questionFr: "As-tu mangé dans les 30 minutes après l'entraînement ?", questionEn: "Did you eat within 30 minutes after training?", questionAr: nil, answerType: .yesNo, sortOrder: 2)
            ]

        case .cognitive:
            questions = [
                FeedbackQuestion(id: 50, category: category, questionFr: "Ressens-tu une clarté soudaine sur une décision difficile ?", questionEn: "Do you feel sudden clarity on a difficult decision?", questionAr: nil, answerType: .yesNo, sortOrder: 1),
                FeedbackQuestion(id: 51, category: category, questionFr: "Ton feedback technique personnel est-il encourageant ?", questionEn: "Is your personal technical feedback encouraging?", questionAr: nil, answerType: .scale, sortOrder: 2),
                FeedbackQuestion(id: 52, category: category, questionFr: "Ta résistance mentale face à un exercice difficile ?", questionEn: "Your mental resistance when facing a difficult exercise?", questionAr: nil, answerType: .scale, sortOrder: 3)
            ]

        default:
            questions = [
                FeedbackQuestion(id: 100, category: category, questionFr: "Comment évalues-tu ta séance aujourd'hui ?", questionEn: "How do you rate your session today?", questionAr: nil, answerType: .scale, sortOrder: 1),
                FeedbackQuestion(id: 101, category: category, questionFr: "As-tu ressenti de la fatigue excessive ?", questionEn: "Did you feel excessive fatigue?", questionAr: nil, answerType: .yesNo, sortOrder: 2)
            ]
        }

        logger.info("📦 Loaded \(self.questions.count) mock questions for \(category.rawValue)")
    }

    private func loadMockHistory() {
        feedbackHistory = [
            FeedbackSummary(
                id: 1,
                category: .footballGoalkeeper,
                totalQuestions: 10,
                answeredQuestions: 10,
                averageScore: 7.5,
                completedAt: "2024-01-15T14:30:00Z",
                insights: ["Bonne performance globale", "Travaille la détente verticale"]
            ),
            FeedbackSummary(
                id: 2,
                category: .nutritionWeightLoss,
                totalQuestions: 8,
                answeredQuestions: 8,
                averageScore: 6.2,
                completedAt: "2024-01-14T10:00:00Z",
                insights: ["Attention au grignotage", "Bonne hydratation"]
            )
        ]
    }
}

// MARK: - Preview Helper
extension FeedbackViewModel {
    static var preview: FeedbackViewModel {
        let vm = FeedbackViewModel()
        vm.loadMockData()
        return vm
    }
}
