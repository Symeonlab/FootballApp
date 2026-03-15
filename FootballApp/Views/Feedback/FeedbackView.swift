//
//  FeedbackView.swift
//  FootballApp
//
//  View for displaying and collecting user feedback
//  Based on DIPODDI PROGRAMME FEED BACK sheet
//

import SwiftUI

struct FeedbackView: View {
    @StateObject private var viewModel = FeedbackViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                if viewModel.selectedCategory == nil {
                    // Category selection view
                    CategorySelectionView(viewModel: viewModel)
                } else {
                    // Questions view
                    QuestionsView(viewModel: viewModel)
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
            .navigationTitle("feedback.title".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        if viewModel.selectedCategory != nil {
                            // Go back to categories
                            viewModel.selectedCategory = nil
                            viewModel.questions = []
                        } else {
                            dismiss()
                        }
                    }) {
                        Image(systemName: viewModel.selectedCategory != nil ? "chevron.left" : "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .task {
                await loadCategories()
            }
            .alert("common.error".localizedString, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("common.ok".localizedString) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }

    private func loadCategories() async {
        // Try to load from API first, fall back to local filtering
        await viewModel.loadCategoriesFromAPI()

        // If API failed or returned empty, use local filtering as fallback
        if viewModel.availableCategories.isEmpty {
            let profile = authViewModel.currentUser?.profile
            viewModel.loadCategories(
                discipline: profile?.discipline,
                goal: profile?.goal,
                position: profile?.position,
                hasInjury: profile?.has_injury,
                gender: profile?.gender
            )
        }
    }
}

// MARK: - Category Selection View

struct CategorySelectionView: View {
    @ObservedObject var viewModel: FeedbackViewModel

    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("feedback.select_category".localizedString)
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)

                    Text("feedback.select_category_subtitle".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                .padding(.horizontal)

                // Categories Grid
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.availableCategories) { category in
                        CategoryCard(category: category) {
                            Task {
                                await viewModel.loadQuestions(for: category)
                            }
                        }
                    }
                }
                .padding(.horizontal)

                // History section
                if !viewModel.feedbackHistory.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("feedback.history".localizedString)
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal)

                        ForEach(viewModel.feedbackHistory) { summary in
                            FeedbackHistoryCard(summary: summary)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.top, 20)
                }
            }
            .padding(.top, 10)
            .padding(.bottom, 100)
        }
        .task {
            await viewModel.loadHistory()
        }
    }
}

// MARK: - Category Card

struct CategoryCard: View {
    let category: FeedbackCategory
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.system(size: 32))
                    .foregroundColor(Color(hex: "4A90E2"))

                Text(category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 120)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color.white.opacity(0.08))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Questions View

struct QuestionsView: View {
    @ObservedObject var viewModel: FeedbackViewModel
    @State private var showingCompletion = false

    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            ProgressBar(progress: viewModel.progress)
                .padding(.horizontal)
                .padding(.top, 10)

            // Question counter
            Text("\(viewModel.answeredCount)/\(viewModel.totalQuestions) " + "feedback.questions_answered".localizedString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .padding(.top, 8)

            if let question = viewModel.currentQuestion {
                ScrollView {
                    VStack(spacing: 24) {
                        // Category indicator
                        if let category = viewModel.selectedCategory {
                            HStack {
                                Image(systemName: category.icon)
                                Text(category.displayName)
                            }
                            .font(.caption)
                            .foregroundColor(Color(hex: "4A90E2"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(Color(hex: "4A90E2").opacity(0.2))
                            )
                        }

                        // Question Card
                        QuestionCard(
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
                QuestionNavigationBar(
                    canGoPrevious: viewModel.currentQuestionIndex > 0,
                    canGoNext: viewModel.currentQuestionIndex < viewModel.questions.count - 1,
                    isLastQuestion: viewModel.currentQuestionIndex == viewModel.questions.count - 1,
                    canSubmit: viewModel.isComplete,
                    onPrevious: { viewModel.previousQuestion() },
                    onNext: { viewModel.nextQuestion() },
                    onSubmit: {
                        Task {
                            if await viewModel.submitFeedback() {
                                showingCompletion = true
                            }
                        }
                    }
                )
            }
        }
        .sheet(isPresented: $showingCompletion) {
            FeedbackCompletionView {
                showingCompletion = false
                viewModel.selectedCategory = nil
                viewModel.questions = []
            }
        }
    }
}

// MARK: - Question Card

struct QuestionCard: View {
    let question: FeedbackQuestion
    let answer: String?
    let onAnswer: (String) -> Void

    @State private var sliderValue: Double = 5
    @State private var textAnswer: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Question text
            Text(question.localizedQuestion)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            // Answer input based on type
            Group {
                switch question.answerType {
                case .scale:
                    ScaleAnswerView(
                        value: Binding(
                            get: { Double(answer ?? "5") ?? 5 },
                            set: { onAnswer(String(Int($0))) }
                        )
                    )

                case .yesNo:
                    YesNoAnswerView(
                        selectedAnswer: answer,
                        onSelect: onAnswer
                    )

                case .text:
                    TextAnswerView(
                        text: Binding(
                            get: { answer ?? "" },
                            set: { onAnswer($0) }
                        )
                    )

                case .multiChoice:
                    // Multi choice would need options from the question
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
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}

// MARK: - Scale Answer View (1-10)

struct ScaleAnswerView: View {
    @Binding var value: Double

    var body: some View {
        VStack(spacing: 16) {
            // Value display
            Text("\(Int(value))")
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundColor(scaleColor)

            // Slider
            Slider(value: $value, in: 1...10, step: 1)
                .tint(scaleColor)

            // Labels
            HStack {
                Text("1")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("feedback.scale_low".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("feedback.scale_high".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Spacer()
                Text("10")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }

    var scaleColor: Color {
        switch Int(value) {
        case 1...3: return Color(hex: "FF6B6B")
        case 4...6: return Color(hex: "FF9F43")
        case 7...8: return Color(hex: "4A90E2")
        case 9...10: return Color(hex: "4ECB71")
        default: return Color(hex: "4A90E2")
        }
    }
}

// MARK: - Yes/No Answer View

struct YesNoAnswerView: View {
    let selectedAnswer: String?
    let onSelect: (String) -> Void

    var body: some View {
        HStack(spacing: 16) {
            AnswerButton(
                title: "feedback.answer.yes".localizedString,
                isSelected: selectedAnswer == "yes",
                color: Color(hex: "4ECB71")
            ) {
                onSelect("yes")
            }

            AnswerButton(
                title: "feedback.answer.no".localizedString,
                isSelected: selectedAnswer == "no",
                color: Color(hex: "FF6B6B")
            ) {
                onSelect("no")
            }
        }
    }
}

struct AnswerButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(isSelected ? .white : color)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(isSelected ? color : color.opacity(0.15))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color, lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Text Answer View

struct TextAnswerView: View {
    @Binding var text: String

    var body: some View {
        TextField("feedback.type_answer".localizedString, text: $text, axis: .vertical)
            .textFieldStyle(.plain)
            .foregroundColor(.white)
            .padding()
            .frame(minHeight: 100, alignment: .topLeading)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Progress Bar

struct ProgressBar: View {
    let progress: Double

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.1))
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 5)
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A90E2"), Color(hex: "4ECB71")],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: max(0, geometry.size.width * CGFloat(progress)), height: 10)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 10)
    }
}

// MARK: - Question Navigation Bar

struct QuestionNavigationBar: View {
    let canGoPrevious: Bool
    let canGoNext: Bool
    let isLastQuestion: Bool
    let canSubmit: Bool
    let onPrevious: () -> Void
    let onNext: () -> Void
    let onSubmit: () -> Void

    var body: some View {
        HStack(spacing: 16) {
            // Previous button - minimum 44pt touch target
            Button(action: onPrevious) {
                HStack(spacing: 6) {
                    Image(systemName: "chevron.left")
                    Text("feedback.previous".localizedString)
                }
                .font(.subheadline.weight(.medium))
                .foregroundColor(canGoPrevious ? .white : .white.opacity(0.3))
                .padding(.horizontal, 20)
                .padding(.vertical, 14)
                .background(
                    Capsule()
                        .fill(Color.white.opacity(0.1))
                )
            }
            .disabled(!canGoPrevious)

            Spacer()

            // Next / Submit button
            if isLastQuestion && canSubmit {
                Button(action: onSubmit) {
                    HStack(spacing: 8) {
                        Text("feedback.submit".localizedString)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4ECB71"), Color(hex: "2ECC71")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                    .shadow(color: Color(hex: "4ECB71").opacity(0.3), radius: 8, x: 0, y: 4)
                }
            } else {
                Button(action: onNext) {
                    HStack(spacing: 6) {
                        Text("feedback.next".localizedString)
                        Image(systemName: "chevron.right")
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(canGoNext ? .white : .white.opacity(0.3))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(
                        Capsule()
                            .fill(canGoNext ? Color(hex: "4A90E2") : Color.white.opacity(0.1))
                    )
                }
                .disabled(!canGoNext)
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

// MARK: - Feedback History Card

struct FeedbackHistoryCard: View {
    let summary: FeedbackSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: summary.category.icon)
                    .foregroundColor(Color(hex: "4A90E2"))

                Text(summary.category.displayName)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)

                Spacer()

                if let score = summary.averageScore {
                    Text(String(format: "%.1f", score))
                        .font(.headline)
                        .foregroundColor(scoreColor(score))
                }
            }

            HStack {
                Text("\(summary.answeredQuestions)/\(summary.totalQuestions) " + "feedback.questions".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))

                Spacer()

                if let date = summary.completedAt {
                    Text(formatDate(date))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            if let insights = summary.insights, !insights.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    ForEach(insights, id: \.self) { insight in
                        HStack(alignment: .top, spacing: 6) {
                            Image(systemName: "lightbulb.fill")
                                .font(.caption2)
                                .foregroundColor(Color(hex: "FF9F43"))
                            Text(insight)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }

    func scoreColor(_ score: Double) -> Color {
        switch score {
        case 0..<4: return Color(hex: "FF6B6B")
        case 4..<7: return Color(hex: "FF9F43")
        case 7..<9: return Color(hex: "4A90E2")
        default: return Color(hex: "4ECB71")
        }
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

// MARK: - Feedback Completion View

struct FeedbackCompletionView: View {
    let onDismiss: () -> Void
    @State private var showCheckmark = false
    @State private var showContent = false

    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Success animation with glow
                ZStack {
                    Circle()
                        .fill(Color(hex: "4ECB71").opacity(0.15))
                        .frame(width: 120, height: 120)
                        .scaleEffect(showCheckmark ? 1.0 : 0.5)
                        .opacity(showCheckmark ? 1.0 : 0.0)

                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4ECB71"), Color(hex: "2ECC71")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(showCheckmark ? 1.0 : 0.3)
                        .opacity(showCheckmark ? 1.0 : 0.0)
                }
                .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showCheckmark)

                VStack(spacing: 12) {
                    Text("feedback.completion.title".localizedString)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("feedback.completion.message".localizedString)
                        .font(.body)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(showContent ? 1.0 : 0.0)
                .offset(y: showContent ? 0 : 20)
                .animation(.easeOut(duration: 0.4).delay(0.3), value: showContent)

                Spacer()

                Button(action: onDismiss) {
                    Text("feedback.completion.done".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                        )
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(showContent ? 1.0 : 0.0)
                .animation(.easeOut(duration: 0.4).delay(0.5), value: showContent)
            }
        }
        .onAppear {
            showCheckmark = true
            showContent = true
        }
    }
}

// MARK: - Preview

struct FeedbackView_Previews: PreviewProvider {
    static var previews: some View {
        FeedbackView()
            .environmentObject(AuthViewModel())
    }
}
