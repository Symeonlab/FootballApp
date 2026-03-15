//
//  HealthAssessmentView.swift
//  FootballApp
//
//  View for displaying and collecting health assessment questionnaire
//  Based on DIPODDI PROGRAMME QUESTIONNAIRE sheet
//

import SwiftUI

struct HealthAssessmentView: View {
    @StateObject private var viewModel = HealthAssessmentViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var showingAssessment = false
    @State private var showingCompletion = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                if showingAssessment {
                    AssessmentQuestionsView(
                        viewModel: viewModel,
                        onComplete: {
                            showingCompletion = true
                        },
                        onExit: {
                            showingAssessment = false
                        }
                    )
                } else {
                    AssessmentHomeView(
                        viewModel: viewModel,
                        onStartAssessment: {
                            showingAssessment = true
                        }
                    )
                }

                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .navigationTitle("health_assessment.title".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if showingAssessment {
                            showingAssessment = false
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: showingAssessment ? "chevron.left" : "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .task {
                let discipline = authViewModel.currentUser?.profile?.discipline
                await viewModel.loadFullAssessment(discipline: discipline)
                await viewModel.loadInsights()
                await viewModel.loadHistory()
            }
            .alert("common.error".localizedString, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("common.ok".localizedString) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
        .sheet(isPresented: $showingCompletion) {
            HealthAssessmentCompletionView(
                insights: viewModel.currentSession?.insights,
                recommendations: viewModel.currentSession?.recommendations,
                onDismiss: {
                    showingCompletion = false
                    showingAssessment = false
                    viewModel.reset()
                    Task {
                        await viewModel.loadInsights()
                        await viewModel.loadHistory()
                    }
                }
            )
        }
    }
}

// MARK: - Assessment Home View

struct AssessmentHomeView: View {
    @ObservedObject var viewModel: HealthAssessmentViewModel
    let onStartAssessment: () -> Void

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Header card with insights
                if let insights = viewModel.insights, insights.hasAssessment {
                    InsightsSummaryCard(insights: insights)
                        .padding(.horizontal)
                } else {
                    // Welcome card
                    WelcomeCard()
                        .padding(.horizontal)
                }

                // Start assessment button
                Button(action: {
                    Task {
                        if await viewModel.startSession() {
                            await viewModel.loadFullAssessment()
                            onStartAssessment()
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: "heart.text.square.fill")
                            .font(.title2)
                        Text(viewModel.hasInProgressSession
                             ? "health_assessment.continue".localizedString
                             : "health_assessment.start".localizedString)
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4A90E2"), Color(hex: "6B5CE7")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }
                .padding(.horizontal)

                // Description of what the assessment covers
                Text("health_assessment.description".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .padding(.horizontal)
                    .fixedSize(horizontal: false, vertical: true)

                // Categories overview
                CategoriesOverviewSection(categories: viewModel.categories)

                // History section
                if !viewModel.assessmentHistory.isEmpty {
                    HistorySection(history: viewModel.assessmentHistory)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
    }
}

// MARK: - Welcome Card

struct WelcomeCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "waveform.path.ecg")
                    .font(.system(size: 40))
                    .foregroundColor(Color(hex: "4A90E2"))

                Spacer()

                Image(systemName: "questionmark.circle")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.5))
            }

            Text("health_assessment.welcome.title".localizedString)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)

            Text("health_assessment.welcome.description".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)

            HStack(spacing: 20) {
                InfoBadge(icon: "clock", text: "~15 min")
                InfoBadge(icon: "list.bullet", text: "144 questions")
                InfoBadge(icon: "shield.checkered", text: "private_data".localizedString)
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "4A90E2").opacity(0.5), Color.clear],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
    }
}

struct InfoBadge: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
            Text(text)
                .font(.caption)
        }
        .foregroundColor(.white.opacity(0.6))
    }
}

// MARK: - Insights Summary Card

struct InsightsSummaryCard: View {
    let insights: HealthAssessmentInsights

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "heart.text.square.fill")
                    .font(.title2)
                    .foregroundColor(Color(hex: "4ECB71"))

                Text("health_assessment.your_health".localizedString)
                    .font(.headline)
                    .foregroundColor(.white)

                Spacer()

                if let date = insights.completedAt {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Stats row
            HStack(spacing: 24) {
                StatItem(
                    value: "\(insights.totalQuestions ?? 0)",
                    label: "health_assessment.questions".localizedString,
                    color: Color(hex: "4A90E2")
                )

                StatItem(
                    value: "\(insights.concernsCount ?? 0)",
                    label: "health_assessment.concerns".localizedString,
                    color: (insights.concernsCount ?? 0) > 5 ? Color(hex: "FF6B6B") : Color(hex: "4ECB71")
                )
            }

            // Insights list
            if let insightsList = insights.insights, !insightsList.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(insightsList.prefix(3), id: \.self) { insight in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption)
                                .foregroundColor(Color(hex: "FF9F43"))
                            Text(insight)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
            }

            // Critical concerns warning
            if let critical = insights.criticalConcerns, !critical.isEmpty {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(Color(hex: "FF6B6B"))
                    Text("health_assessment.critical_concerns".localizedString + " (\(critical.count))")
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(Color(hex: "FF6B6B"))
                }
                .padding(10)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(hex: "FF6B6B").opacity(0.15))
                )
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color(hex: "4ECB71").opacity(0.3), lineWidth: 1)
        )
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .medium
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct StatItem: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
    }
}

// MARK: - Categories Overview Section

struct CategoriesOverviewSection: View {
    let categories: [HealthAssessmentCategoryWithQuestions]

    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("health_assessment.categories".localizedString)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(categories) { category in
                    CategoryBadge(category: category)
                }
            }
            .padding(.horizontal)
        }
    }
}

struct CategoryBadge: View {
    let category: HealthAssessmentCategoryWithQuestions

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(Color(hex: "4A90E2").opacity(0.15))
                    .frame(width: 44, height: 44)

                Image(systemName: category.icon ?? "questionmark.circle")
                    .font(.title3)
                    .foregroundColor(Color(hex: "4A90E2"))
            }

            Text(category.localizedName)
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
                .minimumScaleFactor(0.7)

            Text("\(category.questions.count) Q")
                .font(.caption2.weight(.semibold))
                .foregroundColor(.white.opacity(0.5))
                .padding(.horizontal, 8)
                .padding(.vertical, 2)
                .background(Capsule().fill(Color.white.opacity(0.08)))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .padding(.horizontal, 8)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.08), lineWidth: 1)
                )
        )
    }
}

// MARK: - History Section

struct HistorySection: View {
    let history: [HealthAssessmentSession]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("health_assessment.history".localizedString)
                .font(.headline)
                .foregroundColor(.white)
                .padding(.horizontal)

            ForEach(history) { session in
                AssessmentHistoryCard(session: session)
                    .padding(.horizontal)
            }
        }
    }
}

struct AssessmentHistoryCard: View {
    let session: HealthAssessmentSession

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Image(systemName: session.isComplete ? "checkmark.circle.fill" : "clock.fill")
                        .foregroundColor(session.isComplete ? Color(hex: "4ECB71") : Color(hex: "FF9F43"))

                    Text(session.isComplete
                         ? "health_assessment.completed".localizedString
                         : "health_assessment.in_progress".localizedString)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                }

                Text("\(session.answeredQuestions)/\(session.totalQuestions) " + "health_assessment.questions".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            if let date = session.completedAt ?? session.startedAt {
                Text(formatDate(date))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            // Progress circle
            CircularProgressView(progress: session.progressPercentage / 100)
                .frame(width: 40, height: 40)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
    }

    func formatDate(_ dateString: String) -> String {
        let formatter = ISO8601DateFormatter()
        if let date = formatter.date(from: dateString) {
            let displayFormatter = DateFormatter()
            displayFormatter.dateStyle = .short
            return displayFormatter.string(from: date)
        }
        return dateString
    }
}

struct CircularProgressView: View {
    let progress: Double

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.white.opacity(0.1), lineWidth: 4)

            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color(hex: "4A90E2"),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.white)
        }
    }
}

// MARK: - Assessment Questions View

struct AssessmentQuestionsView: View {
    @ObservedObject var viewModel: HealthAssessmentViewModel
    let onComplete: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressBar(progress: viewModel.progress)
                .padding(.horizontal)
                .padding(.top, 10)

            // Question counter and category
            HStack {
                if let category = viewModel.currentCategory {
                    HStack(spacing: 6) {
                        Image(systemName: category.icon ?? "questionmark.circle")
                        Text(category.localizedName)
                    }
                    .font(.caption)
                    .foregroundColor(Color(hex: "4A90E2"))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color(hex: "4A90E2").opacity(0.2))
                    )
                }

                Spacer()

                Text("\(viewModel.overallQuestionIndex + 1)/\(viewModel.totalQuestions)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(.horizontal)
            .padding(.top, 12)

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 24) {
                        // Question Card
                        HealthQuestionCard(
                            question: question,
                            answer: viewModel.currentAnswers[question.id],
                            onAnswer: { value in
                                viewModel.recordAnswer(value, for: question.id)
                            }
                        )
                        .padding(.horizontal)
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 120)
                }

                // Navigation buttons
                HealthAssessmentNavigationBar(
                    viewModel: viewModel,
                    onSubmit: {
                        Task {
                            if await viewModel.submitAnswers(isComplete: true) {
                                onComplete()
                            }
                        }
                    },
                    onSaveAndExit: {
                        Task {
                            _ = await viewModel.submitAnswers(isComplete: false)
                            onExit()
                        }
                    }
                )
            }
        }
    }
}

// MARK: - Health Question Card

struct HealthQuestionCard: View {
    let question: HealthAssessmentQuestion
    let answer: String?
    let onAnswer: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Critical indicator
            if question.isCritical {
                HStack(spacing: 6) {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text("health_assessment.important_question".localizedString)
                }
                .font(.caption)
                .foregroundColor(Color(hex: "FF9F43"))
            }

            // Question text
            Text(question.localizedQuestion)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            // Answer input based on type
            Group {
                switch question.answerType {
                case "yes_no":
                    YesNoAnswerView(
                        selectedAnswer: answer,
                        onSelect: onAnswer
                    )

                case "scale":
                    ScaleAnswerView(
                        value: Binding(
                            get: { Double(answer ?? "5") ?? 5 },
                            set: { onAnswer(String(Int($0))) }
                        )
                    )

                case "text":
                    TextAnswerView(
                        text: Binding(
                            get: { answer ?? "" },
                            set: { onAnswer($0) }
                        )
                    )

                case "multiple_choice":
                    if let options = question.answerOptions {
                        MultipleChoiceView(
                            options: options,
                            selectedAnswer: answer,
                            onSelect: onAnswer
                        )
                    }

                default:
                    YesNoAnswerView(selectedAnswer: answer, onSelect: onAnswer)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(
                    question.isCritical
                        ? Color(hex: "FF9F43").opacity(0.5)
                        : Color.white.opacity(0.1),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Multiple Choice View

struct MultipleChoiceView: View {
    let options: [String: String]
    let selectedAnswer: String?
    let onSelect: (String) -> Void

    var body: some View {
        VStack(spacing: 12) {
            ForEach(Array(options.keys.sorted()), id: \.self) { key in
                Button(action: { onSelect(key) }) {
                    HStack {
                        Text(options[key] ?? key)
                            .foregroundColor(selectedAnswer == key ? .white : .white.opacity(0.8))

                        Spacer()

                        if selectedAnswer == key {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(Color(hex: "4ECB71"))
                        }
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(selectedAnswer == key
                                  ? Color(hex: "4A90E2").opacity(0.3)
                                  : Color.white.opacity(0.05))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(
                                selectedAnswer == key
                                    ? Color(hex: "4A90E2")
                                    : Color.white.opacity(0.1),
                                lineWidth: 1
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Health Assessment Navigation Bar

struct HealthAssessmentNavigationBar: View {
    @ObservedObject var viewModel: HealthAssessmentViewModel
    let onSubmit: () -> Void
    let onSaveAndExit: () -> Void

    var isLastQuestion: Bool {
        viewModel.overallQuestionIndex == viewModel.totalQuestions - 1
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Previous button
                Button(action: { _ = viewModel.previousQuestion() }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("feedback.previous".localizedString)
                    }
                    .font(.subheadline)
                    .foregroundColor(viewModel.overallQuestionIndex > 0 ? .white : .white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 12)
                    .background(
                        Capsule()
                            .fill(Color.white.opacity(0.1))
                    )
                }
                .disabled(viewModel.overallQuestionIndex <= 0)

                Spacer()

                // Next / Submit button
                if isLastQuestion && viewModel.isComplete {
                    Button(action: onSubmit) {
                        HStack {
                            Text("health_assessment.complete".localizedString)
                            Image(systemName: "checkmark.circle.fill")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(hex: "4ECB71"))
                        )
                    }
                } else {
                    Button(action: { _ = viewModel.nextQuestion() }) {
                        HStack {
                            Text("feedback.next".localizedString)
                            Image(systemName: "chevron.right")
                        }
                        .font(.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            Capsule()
                                .fill(Color(hex: "4A90E2"))
                        )
                    }
                    .disabled(isLastQuestion)
                }
            }

            // Save and exit button
            Button(action: onSaveAndExit) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.down.doc")
                        .font(.caption2)
                    Text("health_assessment.save_exit".localizedString)
                        .font(.caption.weight(.medium))
                }
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(.ultraThinMaterial)
                .ignoresSafeArea()
        )
    }
}

// MARK: - Completion View

struct HealthAssessmentCompletionView: View {
    let insights: [String]?
    let recommendations: [String]?
    let onDismiss: () -> Void
    @State private var showIcon = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 24) {
                    Spacer(minLength: 40)

                    // Success animation with glow
                    ZStack {
                        Circle()
                            .fill(Color(hex: "4ECB71").opacity(0.12))
                            .frame(width: 120, height: 120)
                            .scaleEffect(showIcon ? 1.0 : 0.5)
                            .opacity(showIcon ? 1.0 : 0.0)

                        Image(systemName: "heart.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color(hex: "4ECB71"), Color(hex: "4A90E2")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .scaleEffect(showIcon ? 1.0 : 0.3)
                            .opacity(showIcon ? 1.0 : 0.0)
                    }
                    .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showIcon)

                    VStack(spacing: 12) {
                        Text("health_assessment.completion.title".localizedString)
                            .font(.title.bold())
                            .foregroundColor(.white)

                        Text("health_assessment.completion.message".localizedString)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .opacity(showContent ? 1.0 : 0.0)
                    .offset(y: showContent ? 0 : 20)
                    .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

                    // Insights
                    if let insightsList = insights, !insightsList.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("health_assessment.insights".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(insightsList, id: \.self) { insight in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "lightbulb.fill")
                                        .foregroundColor(Color(hex: "FF9F43"))
                                    Text(insight)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                        )
                        .padding(.horizontal, 24)
                    }

                    // Recommendations
                    if let recommendationsList = recommendations, !recommendationsList.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("health_assessment.recommendations".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(recommendationsList, id: \.self) { rec in
                                HStack(alignment: .top, spacing: 10) {
                                    Image(systemName: "checkmark.seal.fill")
                                        .foregroundColor(Color(hex: "4ECB71"))
                                    Text(rec)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                        )
                        .padding(.horizontal, 24)
                    }

                    Spacer(minLength: 20)

                    Button(action: onDismiss) {
                        Text("health_assessment.completion.done".localizedString)
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color(hex: "4A90E2"))
                            )
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear {
            showIcon = true
            showContent = true
        }
    }
}

// MARK: - Preview

struct HealthAssessmentView_Previews: PreviewProvider {
    static var previews: some View {
        HealthAssessmentView()
            .environmentObject(AuthViewModel())
    }
}
