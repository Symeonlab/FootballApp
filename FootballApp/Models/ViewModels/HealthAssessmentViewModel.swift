//
//  HealthAssessmentViewModel.swift
//  FootballApp
//
//  ViewModel for managing health assessment questionnaire
//  Based on DIPODDI PROGRAMME QUESTIONNAIRE sheet structure
//
import Foundation
import Combine
import os.log
import SwiftUI

@MainActor
class HealthAssessmentViewModel: ObservableObject {
    // MARK: - Published Properties

    /// All categories with their questions (full assessment)
    @Published var categories: [HealthAssessmentCategoryWithQuestions] = []

    /// Current session
    @Published var currentSession: HealthAssessmentSession?

    /// Current answers being collected (questionId -> answer)
    @Published var currentAnswers: [Int: String] = [:]

    /// Assessment history
    @Published var assessmentHistory: [HealthAssessmentSession] = []

    /// Latest insights from completed assessment
    @Published var insights: HealthAssessmentInsights?

    /// Loading state
    @Published var isLoading: Bool = false

    /// Error message
    @Published var errorMessage: String?

    /// Current category index for navigation
    @Published var currentCategoryIndex: Int = 0

    /// Current question index within category
    @Published var currentQuestionIndex: Int = 0

    // MARK: - Private Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "HealthAssessment")
    private let api = APIService.shared
    private var cancellables = Set<AnyCancellable>()

    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Computed Properties

    var currentCategory: HealthAssessmentCategoryWithQuestions? {
        guard currentCategoryIndex < categories.count else { return nil }
        return categories[currentCategoryIndex]
    }

    var currentQuestion: HealthAssessmentQuestion? {
        guard let category = currentCategory,
              currentQuestionIndex < category.questions.count else { return nil }
        return category.questions[currentQuestionIndex]
    }

    var totalQuestions: Int {
        categories.reduce(0) { $0 + $1.questions.count }
    }

    var answeredCount: Int {
        currentAnswers.count
    }

    var progress: Double {
        guard totalQuestions > 0 else { return 0 }
        return Double(answeredCount) / Double(totalQuestions)
    }

    var isComplete: Bool {
        totalQuestions > 0 && answeredCount == totalQuestions
    }

    var hasInProgressSession: Bool {
        currentSession?.isInProgress == true
    }

    var overallQuestionIndex: Int {
        var index = 0
        for i in 0..<currentCategoryIndex {
            if i < categories.count {
                index += categories[i].questions.count
            }
        }
        return index + currentQuestionIndex
    }

    // MARK: - Initialization

    init() {
        logger.info("Health Assessment ViewModel initialized")

        if isPreview {
            loadMockData()
        }
    }

    // MARK: - Public Methods

    /// Load the full assessment (all categories with questions)
    func loadFullAssessment(discipline: String? = nil) async {
        logger.info("Loading full health assessment, discipline: \(discipline ?? "all")")
        isLoading = true
        errorMessage = nil

        if isPreview {
            loadMockData()
            isLoading = false
            return
        }

        do {
            var endpoint = "/health-assessment/full"
            if let discipline = discipline {
                endpoint += "?discipline=\(discipline)"
            }

            let response: HealthAssessmentFullResponse = try await api.request(
                endpoint: endpoint,
                method: "GET"
            )

            categories = response.data
            logger.info("Loaded \(self.categories.count) categories with \(self.totalQuestions) total questions")
        } catch {
            logger.error("Failed to load assessment: \(error.localizedDescription)")
            errorMessage = "health_assessment.error.load".localizedString
            loadMockData()
        }

        isLoading = false
    }

    /// Start a new assessment session
    func startSession() async -> Bool {
        logger.info("Starting health assessment session")
        isLoading = true
        errorMessage = nil

        if isPreview {
            currentSession = HealthAssessmentSession(
                id: 1,
                status: "started",
                totalQuestions: totalQuestions,
                answeredQuestions: 0,
                progressPercentage: 0,
                insights: nil,
                recommendations: nil,
                startedAt: ISO8601DateFormatter().string(from: Date()),
                completedAt: nil
            )
            isLoading = false
            return true
        }

        do {
            let response: HealthAssessmentStartResponse = try await api.request(
                endpoint: "/health-assessment/start",
                method: "POST"
            )

            currentSession = response.data
            currentAnswers = [:]
            currentCategoryIndex = 0
            currentQuestionIndex = 0
            logger.info("Session started with ID: \(response.data.id)")
            isLoading = false
            return true
        } catch {
            logger.error("Failed to start session: \(error.localizedDescription)")
            errorMessage = "health_assessment.error.start".localizedString
            isLoading = false
            return false
        }
    }

    /// Record an answer for a question
    func recordAnswer(_ value: String, for questionId: Int) {
        logger.info("Recording answer for question \(questionId): \(value)")
        currentAnswers[questionId] = value
    }

    /// Move to next question
    func nextQuestion() -> Bool {
        guard let category = currentCategory else { return false }

        if currentQuestionIndex < category.questions.count - 1 {
            currentQuestionIndex += 1
            return true
        } else if currentCategoryIndex < categories.count - 1 {
            currentCategoryIndex += 1
            currentQuestionIndex = 0
            return true
        }
        return false
    }

    /// Move to previous question
    func previousQuestion() -> Bool {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            return true
        } else if currentCategoryIndex > 0 {
            currentCategoryIndex -= 1
            if let prevCategory = categories[safe: currentCategoryIndex] {
                currentQuestionIndex = max(0, prevCategory.questions.count - 1)
            }
            return true
        }
        return false
    }

    /// Submit answers (can be partial or complete)
    func submitAnswers(isComplete: Bool = false) async -> Bool {
        guard let session = currentSession else {
            logger.error("No active session to submit answers")
            return false
        }

        logger.info("Submitting \(self.currentAnswers.count) answers, isComplete: \(isComplete)")
        isLoading = true
        errorMessage = nil

        if isPreview {
            if isComplete {
                currentSession = HealthAssessmentSession(
                    id: session.id,
                    status: "completed",
                    totalQuestions: totalQuestions,
                    answeredQuestions: currentAnswers.count,
                    progressPercentage: 100,
                    insights: ["Mock insight 1", "Mock insight 2"],
                    recommendations: ["Mock recommendation 1"],
                    startedAt: session.startedAt,
                    completedAt: ISO8601DateFormatter().string(from: Date())
                )
            }
            isLoading = false
            return true
        }

        let answers = currentAnswers.map { HealthAssessmentAnswerInput(questionId: $0.key, answerValue: $0.value) }
        let request = SubmitHealthAssessmentRequest(
            sessionId: session.id,
            answers: answers,
            isComplete: isComplete
        )

        do {
            let response: HealthAssessmentSubmitResponse = try await api.request(
                endpoint: "/health-assessment/submit",
                method: "POST",
                body: request
            )

            currentSession = response.data
            logger.info("Answers submitted successfully, status: \(response.data.status)")

            if isComplete {
                await loadInsights()
            }

            isLoading = false
            return true
        } catch {
            logger.error("Failed to submit answers: \(error.localizedDescription)")
            errorMessage = "health_assessment.error.submit".localizedString
            isLoading = false
            return false
        }
    }

    /// Load assessment history
    func loadHistory() async {
        logger.info("Loading assessment history")
        isLoading = true

        if isPreview {
            assessmentHistory = [
                HealthAssessmentSession(
                    id: 1,
                    status: "completed",
                    totalQuestions: 144,
                    answeredQuestions: 144,
                    progressPercentage: 100,
                    insights: ["Good overall health"],
                    recommendations: ["Continue healthy habits"],
                    startedAt: "2024-01-15T10:00:00Z",
                    completedAt: "2024-01-15T10:30:00Z"
                )
            ]
            isLoading = false
            return
        }

        do {
            let response: HealthAssessmentHistoryResponse = try await api.request(
                endpoint: "/health-assessment/history",
                method: "GET"
            )

            assessmentHistory = response.data
            logger.info("Loaded \(self.assessmentHistory.count) history items")
        } catch {
            logger.error("Failed to load history: \(error.localizedDescription)")
        }

        isLoading = false
    }

    /// Load insights from latest completed assessment
    func loadInsights() async {
        logger.info("Loading health assessment insights")

        if isPreview {
            insights = HealthAssessmentInsights(
                hasAssessment: true,
                message: nil,
                completedAt: "2024-01-15T10:30:00Z",
                totalQuestions: 144,
                concernsCount: 5,
                criticalConcerns: [],
                insights: ["Good recovery patterns", "Watch hydration levels"],
                recommendations: ["Increase water intake", "Consider adding stretching routine"]
            )
            return
        }

        do {
            let response: HealthAssessmentInsightsResponse = try await api.request(
                endpoint: "/health-assessment/insights",
                method: "GET"
            )

            insights = response.data
            logger.info("Loaded insights, has assessment: \(response.data.hasAssessment)")
        } catch {
            logger.error("Failed to load insights: \(error.localizedDescription)")
        }
    }

    /// Reset for a new assessment
    func reset() {
        currentAnswers = [:]
        currentCategoryIndex = 0
        currentQuestionIndex = 0
        currentSession = nil
        errorMessage = nil
    }

    // MARK: - Mock Data

    private func loadMockData() {
        categories = [
            HealthAssessmentCategoryWithQuestions(
                id: 1,
                key: "energy_recovery",
                nameFr: "Energie et Récupération",
                nameEn: "Energy and Recovery",
                nameAr: nil,
                icon: "bolt.fill",
                discipline: nil,
                questions: [
                    HealthAssessmentQuestion(id: 1, questionFr: "Tu ressens une fatigue excessive ?", questionEn: "Do you feel excessive fatigue?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 1),
                    HealthAssessmentQuestion(id: 2, questionFr: "Tu as une sensation de jambes lourdes ?", questionEn: "Do you have a feeling of heavy legs?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 2),
                    HealthAssessmentQuestion(id: 3, questionFr: "Tu es plus irritable que d'habitude ?", questionEn: "Are you more irritable than usual?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 3)
                ]
            ),
            HealthAssessmentCategoryWithQuestions(
                id: 2,
                key: "injuries_muscles",
                nameFr: "Blessures et Muscles",
                nameEn: "Injuries and Muscles",
                nameAr: nil,
                icon: "bandage.fill",
                discipline: nil,
                questions: [
                    HealthAssessmentQuestion(id: 10, questionFr: "Tu as des crampes nocturnes récentes ?", questionEn: "Have you had recent night cramps?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: true, sortOrder: 1),
                    HealthAssessmentQuestion(id: 11, questionFr: "Tu ressens des tensions persistantes ?", questionEn: "Do you feel persistent tensions?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 2)
                ]
            ),
            HealthAssessmentCategoryWithQuestions(
                id: 3,
                key: "psychology",
                nameFr: "Psychologie",
                nameEn: "Psychology",
                nameAr: nil,
                icon: "brain.head.profile",
                discipline: nil,
                questions: [
                    HealthAssessmentQuestion(id: 20, questionFr: "Tu as des difficultés à te concentrer ?", questionEn: "Do you have difficulty concentrating?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 1),
                    HealthAssessmentQuestion(id: 21, questionFr: "Tu ressens du stress avant les entraînements ?", questionEn: "Do you feel stress before training?", questionAr: nil, answerType: "yes_no", answerOptions: nil, isCritical: false, sortOrder: 2)
                ]
            )
        ]
    }
}

// MARK: - Preview Helper
extension HealthAssessmentViewModel {
    static var preview: HealthAssessmentViewModel {
        let vm = HealthAssessmentViewModel()
        vm.loadMockData()
        return vm
    }
}
