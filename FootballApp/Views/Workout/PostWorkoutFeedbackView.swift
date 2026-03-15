//
//  PostWorkoutFeedbackView.swift
//  FootballApp - DiPODDI
//
//  Post-workout feedback popup that loads questions dynamically from the
//  backend API (`/workout-feedback/questions`).
//  Each question is rendered according to its `answer_type`:
//    scale → 1-5 dot selector
//    yes_no → Yes/No toggle chips
//    multi  → option chips from `answer_options`
//    text   → free-form TextEditor
//
//  Answers are submitted as an array of {question_id, value} so the
//  backend can cross-link them to the questionnaire system and produce
//  workout adjustment recommendations.
//

import SwiftUI
import os.log

// MARK: - Main View

struct PostWorkoutFeedbackView: View {
    // Workout context
    let sessionDay: String
    let sessionTheme: String
    let totalExercises: Int
    let elapsedSeconds: Int
    let onDismiss: () -> Void

    // State
    @State private var questions: [PostWorkoutQuestion] = []
    @State private var answers: [Int: String] = [:]          // questionId → value
    @State private var currentPage: Int = 0
    @State private var isLoadingQuestions = true
    @State private var isSubmitting = false
    @State private var showThankYou = false
    @State private var recommendation: String? = nil
    @State private var adjustments: WorkoutAdjustmentsData? = nil
    @State private var appearAnimation = false
    @State private var loadError = false

    private let api = APIService.shared
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "WorkoutFeedback")

    /// Questions per page
    private let questionsPerPage = 3

    /// Total pages
    private var totalPages: Int {
        max(1, Int(ceil(Double(questions.count) / Double(questionsPerPage))))
    }

    /// Questions for the current page
    private var currentQuestions: [PostWorkoutQuestion] {
        let start = currentPage * questionsPerPage
        let end = min(start + questionsPerPage, questions.count)
        guard start < questions.count else { return [] }
        return Array(questions[start..<end])
    }

    /// Progress fraction
    private var progress: CGFloat {
        guard totalPages > 0 else { return 0 }
        return CGFloat(currentPage + 1) / CGFloat(totalPages)
    }

    var body: some View {
        ZStack {
            Color.black.opacity(0.001)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Drag indicator
                Capsule()
                    .fill(Color.white.opacity(0.3))
                    .frame(width: 40, height: 5)
                    .padding(.top, 12)

                // Header
                feedbackHeader

                // Progress bar
                progressBar
                    .padding(.horizontal, 24)
                    .padding(.top, 8)

                // Content
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        if showThankYou {
                            thankYouView
                        } else if isLoadingQuestions {
                            loadingView
                        } else if loadError {
                            errorView
                        } else {
                            questionsView
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }

                // Navigation buttons
                if !showThankYou && !isLoadingQuestions && !loadError {
                    navigationButtons
                        .padding(.horizontal, 24)
                        .padding(.bottom, 16)
                }
            }
            .background(
                RoundedRectangle(cornerRadius: 32, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1A1A3E"),
                                Color(hex: "12122A"),
                                Color(hex: "0F0F23")
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 32, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: .black.opacity(0.5), radius: 40, y: -10)
            )
            .offset(y: appearAnimation ? 0 : 400)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                appearAnimation = true
            }
            Task { await loadQuestions() }
        }
    }

    // MARK: - Header

    private var feedbackHeader: some View {
        VStack(spacing: 6) {
            HStack {
                Image(systemName: "clipboard.fill")
                    .foregroundStyle(Color.theme.accent)
                    .font(.title3)

                Text("workout_feedback.title".localizedString)
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.4))
                }
            }

            Text("workout_feedback.subtitle".localizedString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 4)

                Capsule()
                    .fill(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.spring(response: 0.4), value: progress)
            }
        }
        .frame(height: 4)
    }

    // MARK: - Loading State

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(Color.theme.accent)
                .scaleEffect(1.2)
            Text("workout_feedback.loading".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.5))
        }
        .padding(.top, 40)
    }

    // MARK: - Error State

    private var errorView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)

            Text("workout_feedback.error_loading".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            Button {
                Task { await loadQuestions() }
            } label: {
                Text("common.retry".localizedString)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 10)
                    .background(Color.theme.primary.opacity(0.3))
                    .clipShape(Capsule())
            }
        }
        .padding(.top, 30)
    }

    // MARK: - Questions View (Dynamic)

    private var questionsView: some View {
        VStack(spacing: 28) {
            ForEach(currentQuestions) { question in
                questionCard(for: question)
            }
        }
    }

    @ViewBuilder
    private func questionCard(for question: PostWorkoutQuestion) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            // Question text
            Text(question.localizedQuestion)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)

            // Answer input based on type
            switch question.answerType {
            case "scale":
                scaleInput(for: question)
            case "yes_no":
                yesNoInput(for: question)
            case "multi":
                multiChoiceInput(for: question)
            case "text":
                textInput(for: question)
            default:
                scaleInput(for: question) // fallback
            }
        }
    }

    // MARK: - Scale Input (1-5 dots)

    private func scaleInput(for question: PostWorkoutQuestion) -> some View {
        let currentValue = Int(answers[question.id] ?? "0") ?? 0
        let color = scaleColor(value: currentValue)

        return VStack(spacing: 8) {
            HStack(spacing: 8) {
                ForEach(1...5, id: \.self) { i in
                    Button {
                        withAnimation(.spring(response: 0.2)) {
                            answers[question.id] = "\(i)"
                        }
                    } label: {
                        Circle()
                            .fill(i <= currentValue ? color : Color.white.opacity(0.1))
                            .frame(width: i <= currentValue ? 36 : 30, height: i <= currentValue ? 36 : 30)
                            .overlay(
                                Text("\(i)")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(i <= currentValue ? .white : .white.opacity(0.3))
                            )
                            .overlay(
                                Circle()
                                    .strokeBorder(Color.white.opacity(i <= currentValue ? 0.3 : 0.1), lineWidth: 1)
                            )
                    }
                    .buttonStyle(.plain)

                    if i < 5 { Spacer() }
                }
            }

            if currentValue > 0 {
                Text("\(currentValue)/5")
                    .font(.caption.weight(.bold).monospacedDigit())
                    .foregroundColor(color)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 3)
                    .background(color.opacity(0.15))
                    .clipShape(Capsule())
                    .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
    }

    // MARK: - Yes/No Input

    private func yesNoInput(for question: PostWorkoutQuestion) -> some View {
        let current = answers[question.id]

        return HStack(spacing: 12) {
            DynamicToggleChip(
                label: "feedback.answer.yes".localizedString,
                isSelected: current == "yes"
            ) {
                answers[question.id] = "yes"
            }

            DynamicToggleChip(
                label: "feedback.answer.no".localizedString,
                isSelected: current == "no"
            ) {
                answers[question.id] = "no"
            }
        }
    }

    // MARK: - Multi Choice Input

    private func multiChoiceInput(for question: PostWorkoutQuestion) -> some View {
        let options = question.answerOptions ?? WorkoutAdjustment.defaultOptions
        let current = answers[question.id]

        return DynamicFlowLayout(spacing: 8) {
            ForEach(Array(options.keys.sorted()), id: \.self) { key in
                let label = localizedOptionLabel(options[key] ?? key)
                DynamicToggleChip(
                    label: label,
                    isSelected: current == key,
                    compact: true
                ) {
                    answers[question.id] = key
                }
            }
        }
    }

    // MARK: - Text Input

    private func textInput(for question: PostWorkoutQuestion) -> some View {
        let binding = Binding<String>(
            get: { answers[question.id] ?? "" },
            set: { answers[question.id] = $0.isEmpty ? nil : $0 }
        )

        return TextEditor(text: binding)
            .frame(height: 80)
            .padding(12)
            .scrollContentBackground(.hidden)
            .background(Color.white.opacity(0.06))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
            .overlay(alignment: .topLeading) {
                if (answers[question.id] ?? "").isEmpty {
                    Text("workout_feedback.notes_placeholder".localizedString)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.25))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 20)
                        .allowsHitTesting(false)
                }
            }
    }

    // MARK: - Thank You

    private var thankYouView: some View {
        VStack(spacing: 20) {
            Image(systemName: "checkmark.seal.fill")
                .font(.system(size: 60))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .padding(.top, 20)

            Text("workout_feedback.thank_you".localizedString)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text("workout_feedback.feedback_helps".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)

            if let rec = recommendation {
                recommendationBadge(rec)
                    .padding(.top, 8)
            }

            // Show adjustment confidence if available
            if let adj = adjustments, let confidence = adj.confidence, confidence > 0.3 {
                adjustmentSummary(adj)
                    .padding(.top, 4)
            }

            Button(action: onDismiss) {
                Text("common.done".localizedString)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.top, 12)
        }
        .transition(.opacity.combined(with: .scale(scale: 0.9)))
    }

    private func recommendationBadge(_ rec: String) -> some View {
        let displayText: String = {
            switch rec {
            case "increase_intensity": return "workout_feedback.rec.increase".localizedString
            case "decrease_intensity": return "workout_feedback.rec.decrease".localizedString
            case "more_rest": return "workout_feedback.rec.rest".localizedString
            case "more_variety": return "workout_feedback.rec.variety".localizedString
            case "fewer_exercises": return "workout_feedback.rec.fewer".localizedString
            default: return "workout_feedback.rec.keep".localizedString
            }
        }()

        return HStack(spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundColor(Color.theme.accent)
            Text(displayText)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.theme.primary.opacity(0.15))
        .clipShape(Capsule())
        .overlay(
            Capsule().strokeBorder(Color.theme.primary.opacity(0.3), lineWidth: 1)
        )
    }

    private func adjustmentSummary(_ adj: WorkoutAdjustmentsData) -> some View {
        VStack(spacing: 6) {
            Text("workout_feedback.plan_evolving".localizedString)
                .font(.caption.weight(.medium))
                .foregroundColor(Color.theme.accent.opacity(0.8))

            HStack(spacing: 16) {
                if let intensity = adj.intensityModifier, intensity != 1.0 {
                    adjustmentChip(
                        icon: intensity > 1.0 ? "arrow.up" : "arrow.down",
                        label: "workout_feedback.intensity".localizedString
                    )
                }
                if let delta = adj.exerciseCountDelta, delta != 0 {
                    adjustmentChip(
                        icon: delta > 0 ? "plus" : "minus",
                        label: "workout_feedback.exercises".localizedString
                    )
                }
                if let rest = adj.restTimeModifier, rest != 1.0 {
                    adjustmentChip(
                        icon: "clock",
                        label: "workout_feedback.rest".localizedString
                    )
                }
            }
        }
    }

    private func adjustmentChip(icon: String, label: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .font(.caption2)
            Text(label)
                .font(.caption2)
        }
        .foregroundColor(.white.opacity(0.6))
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(Color.white.opacity(0.06))
        .clipShape(Capsule())
    }

    // MARK: - Navigation Buttons

    private var navigationButtons: some View {
        HStack(spacing: 12) {
            if currentPage > 0 {
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        currentPage -= 1
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("common.back".localizedString)
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white.opacity(0.7))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }

            Button {
                if currentPage >= totalPages - 1 {
                    Task { await submitFeedback() }
                } else {
                    withAnimation(.spring(response: 0.3)) {
                        currentPage += 1
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    if isSubmitting {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.8)
                    } else {
                        Text(currentPage >= totalPages - 1
                            ? "workout_feedback.submit".localizedString
                            : "common.next".localizedString)
                        if currentPage < totalPages - 1 {
                            Image(systemName: "chevron.right")
                        }
                    }
                }
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.accent],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(isSubmitting)
        }
    }

    // MARK: - Helpers

    private func scaleColor(value: Int) -> Color {
        switch value {
        case 1...2: return .red
        case 3: return .yellow
        case 4...5: return .green
        default: return .gray
        }
    }

    /// Parse bilingual option label: "French text / English text" → localized
    private func localizedOptionLabel(_ raw: String) -> String {
        let parts = raw.components(separatedBy: " / ")
        let language = LanguageManager.shared.selected
        switch language {
        case .french:
            return parts.first ?? raw
        case .english, .system:
            return parts.count > 1 ? parts[1] : raw
        case .arabic:
            return parts.first ?? raw
        }
    }

    // MARK: - API Calls

    private func loadQuestions() async {
        isLoadingQuestions = true
        loadError = false

        do {
            let response: PostWorkoutQuestionsResponse = try await api.request(
                endpoint: APIEndpoints.workoutFeedbackQuestions,
                method: "GET"
            )

            if response.success, let data = response.data {
                questions = data.questions.sorted { $0.sortOrder < $1.sortOrder }
                logger.info("Loaded \(self.questions.count) post-workout questions from API")
            } else {
                logger.warning("API returned success=false, using fallback")
                loadFallbackQuestions()
            }
        } catch {
            logger.error("Failed to load questions: \(error.localizedDescription)")
            loadFallbackQuestions()
        }

        isLoadingQuestions = false
    }

    /// Fallback questions if API is unreachable
    private func loadFallbackQuestions() {
        questions = [
            PostWorkoutQuestion(id: -1, category: "post_workout", questionFr: "Comment évalues-tu la difficulté ?", questionEn: "How would you rate the difficulty?", questionAr: "كيف تقيّم الصعوبة؟", answerType: "scale", answerOptions: nil, sortOrder: 1),
            PostWorkoutQuestion(id: -2, category: "post_workout", questionFr: "Ton niveau d'énergie ?", questionEn: "Your energy level?", questionAr: "مستوى طاقتك؟", answerType: "scale", answerOptions: nil, sortOrder: 2),
            PostWorkoutQuestion(id: -3, category: "post_workout", questionFr: "As-tu apprécié la séance ?", questionEn: "Did you enjoy the session?", questionAr: "هل استمتعت؟", answerType: "scale", answerOptions: nil, sortOrder: 3),
            PostWorkoutQuestion(id: -4, category: "post_workout", questionFr: "As-tu complété toutes les séries ?", questionEn: "Did you complete all sets?", questionAr: "هل أكملت جميع المجموعات؟", answerType: "yes_no", answerOptions: nil, sortOrder: 4),
            PostWorkoutQuestion(id: -5, category: "post_workout", questionFr: "Des douleurs musculaires ?", questionEn: "Any muscle soreness?", questionAr: "ألم عضلي؟", answerType: "scale", answerOptions: nil, sortOrder: 5),
        ]
        logger.info("Using \(self.questions.count) fallback questions")
    }

    private func submitFeedback() async {
        isSubmitting = true

        // Build answers array from collected responses
        let answerInputs: [WorkoutFeedbackAnswerInput] = answers.compactMap { (questionId, value) in
            guard questionId > 0 else { return nil } // Skip fallback question IDs
            return WorkoutFeedbackAnswerInput(questionId: questionId, value: value)
        }

        let request = WorkoutFeedbackRequest(
            sessionDay: sessionDay,
            sessionTheme: sessionTheme,
            exercisesCompleted: totalExercises,
            elapsedSeconds: elapsedSeconds,
            answers: answerInputs.isEmpty ? nil : answerInputs,
            // Also include legacy flat fields for backward compatibility
            difficultyRating: answers.first(where: { questionHasSortOrder($0.key, order: 1) }).flatMap { Int($0.value) },
            energyLevel: answers.first(where: { questionHasSortOrder($0.key, order: 2) }).flatMap { Int($0.value) },
            enjoymentRating: answers.first(where: { questionHasSortOrder($0.key, order: 3) }).flatMap { Int($0.value) },
            muscleSoreness: answers.first(where: { questionHasSortOrder($0.key, order: 5) }).flatMap { Int($0.value) },
            soreAreas: nil,
            completedAllSets: answers.first(where: { questionHasSortOrder($0.key, order: 4) }).map { $0.value == "yes" },
            skippedReason: nil,
            notes: answers.first(where: { questionHasSortOrder($0.key, order: 9) })?.value,
            preferredAdjustment: answers.first(where: { questionHasSortOrder($0.key, order: 8) })?.value
        )

        do {
            let response: WorkoutFeedbackResponse = try await api.request(
                endpoint: APIEndpoints.workoutFeedbackSubmit,
                method: "POST",
                body: request
            )

            if response.success {
                recommendation = response.data?.recommendation
                adjustments = response.data?.adjustments
                logger.info("Workout feedback submitted successfully")
            }
        } catch {
            logger.error("Failed to submit workout feedback: \(error.localizedDescription)")
        }

        isSubmitting = false

        withAnimation(.spring(response: 0.4)) {
            showThankYou = true
        }

        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }

    /// Check if a question ID maps to a specific sort order in the loaded questions
    private func questionHasSortOrder(_ questionId: Int, order: Int) -> Bool {
        questions.first(where: { $0.id == questionId })?.sortOrder == order
    }
}

// MARK: - Toggle Chip (Dynamic)

private struct DynamicToggleChip: View {
    let label: String
    let isSelected: Bool
    var compact: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(compact ? .caption.weight(.medium) : .subheadline.weight(.medium))
                .foregroundColor(isSelected ? .white : .white.opacity(0.6))
                .padding(.horizontal, compact ? 12 : 16)
                .padding(.vertical, compact ? 8 : 10)
                .background(
                    isSelected
                        ? AnyShapeStyle(LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .leading,
                            endPoint: .trailing
                          ))
                        : AnyShapeStyle(Color.white.opacity(0.08))
                )
                .clipShape(Capsule())
                .overlay(
                    Capsule()
                        .strokeBorder(isSelected ? Color.clear : Color.white.opacity(0.15), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout

private struct DynamicFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = arrange(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = arrange(proposal: ProposedViewSize(width: bounds.width, height: bounds.height), subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y), proposal: .unspecified)
        }
    }

    private func arrange(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var x: CGFloat = 0
        var y: CGFloat = 0
        var rowHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if x + size.width > maxWidth && x > 0 {
                x = 0
                y += rowHeight + spacing
                rowHeight = 0
            }
            positions.append(CGPoint(x: x, y: y))
            rowHeight = max(rowHeight, size.height)
            x += size.width + spacing
            totalHeight = y + rowHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}

// MARK: - Default Options Extension

extension WorkoutAdjustment {
    static var defaultOptions: [String: String] {
        [
            "increase_intensity": "Augmenter l'intensité / Increase intensity",
            "decrease_intensity": "Diminuer l'intensité / Decrease intensity",
            "more_rest": "Plus de repos / More rest",
            "fewer_exercises": "Moins d'exercices / Fewer exercises",
            "more_variety": "Plus de variété / More variety",
            "keep_same": "Garder la même chose / Keep same",
        ]
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()

        PostWorkoutFeedbackView(
            sessionDay: "Monday",
            sessionTheme: "Upper Body",
            totalExercises: 8,
            elapsedSeconds: 2400,
            onDismiss: {}
        )
    }
}
