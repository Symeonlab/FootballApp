//
//  GoalsView.swift
//  FootballApp
//
//  View for displaying and managing user goals
//

import SwiftUI

struct GoalsView: View {
    @StateObject private var viewModel = GoalsViewModel()
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Active Goal Card
                        if let activeGoal = viewModel.activeGoal {
                            ActiveGoalDetailCard(goal: activeGoal, viewModel: viewModel)
                                .padding(.horizontal)
                        } else {
                            NoActiveGoalCard(onCreateGoal: {
                                viewModel.showingCreateGoal = true
                            })
                            .padding(.horizontal)
                        }

                        // Goal History
                        if !viewModel.goals.isEmpty {
                            GoalHistorySection(
                                goals: viewModel.goals,
                                viewModel: viewModel
                            )
                            .padding(.horizontal)
                        }
                    }
                    .padding(.top, 10)
                    .padding(.bottom, 100)
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
            .navigationTitle("goals.title".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { viewModel.showingCreateGoal = true }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .sheet(isPresented: $viewModel.showingCreateGoal) {
                CreateGoalSheet(viewModel: viewModel)
            }
            .task {
                await viewModel.refreshData()
            }
            .refreshable {
                await viewModel.refreshData()
            }
            .alert("common.error".localizedString, isPresented: .constant(viewModel.errorMessage != nil)) {
                Button("common.ok".localizedString) { viewModel.errorMessage = nil }
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
        }
    }
}

// MARK: - Active Goal Detail Card

struct ActiveGoalDetailCard: View {
    let goal: Goal
    @ObservedObject var viewModel: GoalsViewModel
    @State private var showingActions = false

    var statusColor: Color {
        goal.isOnTrack == true ? Color(hex: "4ECB71") : Color(hex: "FF9F43")
    }

    var progressDifference: Double {
        guard let expected = goal.expectedProgress else { return 0 }
        return goal.progress - expected
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header with status badge
            HStack {
                // Goal type icon
                ZStack {
                    Circle()
                        .fill(Color(hex: goal.status.color).opacity(0.2))
                        .frame(width: 50, height: 50)

                    Image(systemName: goalTypeIcon)
                        .font(.title2)
                        .foregroundColor(Color(hex: goal.status.color))
                }

                VStack(alignment: .leading, spacing: 4) {
                    // Status badge
                    HStack(spacing: 4) {
                        Circle()
                            .fill(statusColor)
                            .frame(width: 8, height: 8)
                        Text(goal.status.displayName)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(statusColor)
                    }

                    Text(goal.goalType.displayName)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                // Circular progress ring with on-track indicator
                VStack(spacing: 4) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 5)
                            .frame(width: 56, height: 56)

                        Circle()
                            .trim(from: 0, to: CGFloat(min(goal.progress / 100, 1.0)))
                            .stroke(
                                LinearGradient(
                                    colors: goal.isOnTrack == true
                                        ? [Color(hex: "4A90E2"), Color(hex: "4ECB71")]
                                        : [Color(hex: "FF9F43"), Color(hex: "FF6B6B")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 5, lineCap: .round)
                            )
                            .frame(width: 56, height: 56)
                            .rotationEffect(.degrees(-90))

                        Text("\(Int(goal.progress))%")
                            .font(.system(size: 14, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }

                    Text(goal.isOnTrack == true ? "goals.on_track".localizedString : "goals.behind".localizedString)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(statusColor)
                }
            }

            // Progress section
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("goals.progress".localizedString)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()

                    // Progress vs expected
                    if goal.expectedProgress != nil {
                        HStack(spacing: 4) {
                            Image(systemName: progressDifference >= 0 ? "arrow.up.right" : "arrow.down.right")
                                .font(.caption2)
                            Text(String(format: "%+.0f%%", progressDifference))
                                .font(.caption.weight(.bold))
                        }
                        .foregroundColor(progressDifference >= 0 ? Color(hex: "4ECB71") : Color(hex: "FF9F43"))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(
                            Capsule()
                                .fill((progressDifference >= 0 ? Color(hex: "4ECB71") : Color(hex: "FF9F43")).opacity(0.2))
                        )
                    }

                    Text("\(Int(goal.progress))%")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }

                // Enhanced progress bar with expected marker
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // Background
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 16)

                        // Progress fill
                        RoundedRectangle(cornerRadius: 8)
                            .fill(
                                LinearGradient(
                                    colors: goal.isOnTrack == true ?
                                        [Color(hex: "4A90E2"), Color(hex: "4ECB71")] :
                                        [Color(hex: "FF9F43"), Color(hex: "FF6B6B")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: max(0, min(geometry.size.width * CGFloat(goal.progress / 100), geometry.size.width)), height: 16)

                        // Expected progress marker
                        if let expected = goal.expectedProgress, expected > 0 {
                            Rectangle()
                                .fill(Color.white.opacity(0.6))
                                .frame(width: 2, height: 20)
                                .offset(x: geometry.size.width * CGFloat(expected / 100) - 1)
                        }
                    }
                }
                .frame(height: 16)

                // Expected progress label
                if let expected = goal.expectedProgress {
                    Text("goals.expected".localizedString + ": \(Int(expected))%")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Stats row
            HStack(spacing: 12) {
                if let weeksCompleted = goal.weeksCompleted, let totalWeeks = goal.totalWeeks {
                    GoalStatItem(
                        icon: "calendar.badge.clock",
                        value: "\(weeksCompleted)/\(totalWeeks)",
                        label: "goals.weeks".localizedString,
                        color: Color(hex: "4A90E2")
                    )
                }

                if let targetWeight = goal.targetWeight {
                    GoalStatItem(
                        icon: "scalemass.fill",
                        value: String(format: "%.1f", targetWeight),
                        label: "goals.target_kg".localizedString,
                        color: Color(hex: "9D4EDD")
                    )
                }

                if let targetWorkouts = goal.targetWorkoutsPerWeek {
                    GoalStatItem(
                        icon: "figure.run",
                        value: "\(targetWorkouts)x",
                        label: "goals.per_week".localizedString,
                        color: Color(hex: "4ECB71")
                    )
                }
            }

            // Start/target info
            if let startDate = goal.startDate, let targetDate = goal.targetDate {
                HStack {
                    Label(startDate, systemImage: "flag.fill")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))

                    Spacer()

                    Image(systemName: "arrow.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))

                    Spacer()

                    Label(targetDate, systemImage: "flag.checkered")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding(.horizontal, 8)
            }

            // Action buttons
            HStack(spacing: 12) {
                Button(action: {
                    Task { await viewModel.updateGoalProgress(goalId: goal.id) }
                }) {
                    HStack(spacing: 8) {
                        Image(systemName: "arrow.clockwise")
                        Text("goals.update_progress".localizedString)
                    }
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(
                                LinearGradient(
                                    colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                    )
                }

                Button(action: { showingActions = true }) {
                    Image(systemName: "ellipsis")
                        .font(.title3)
                        .foregroundColor(.white)
                        .frame(width: 48, height: 48)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                        )
                }
            }
        }
        .padding()
        .darkBlueCard()
        .confirmationDialog("goals.actions".localizedString, isPresented: $showingActions) {
            Button("goals.pause".localizedString) {
                Task { await viewModel.pauseGoal(goal) }
            }
            Button("goals.abandon".localizedString, role: .destructive) {
                Task { await viewModel.abandonGoal(goal) }
            }
            Button("common.cancel".localizedString, role: .cancel) { }
        }
    }

    var goalTypeIcon: String {
        switch goal.goalType {
        case .weightLoss: return "arrow.down.circle.fill"
        case .muscleGain: return "arrow.up.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .custom: return "star.circle.fill"
        }
    }
}

struct GoalStatItem: View {
    let icon: String
    let value: String
    let label: String
    var color: Color = Color(hex: "4A90E2")

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 36, height: 36)

                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }

            Text(value)
                .font(.headline.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.6))
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - No Active Goal Card

struct NoActiveGoalCard: View {
    let onCreateGoal: () -> Void
    @State private var pulseAnimation = false

    var body: some View {
        VStack(spacing: 20) {
            // Animated target icon
            ZStack {
                Circle()
                    .stroke(Color(hex: "4A90E2").opacity(0.15), lineWidth: 2)
                    .frame(width: 100, height: 100)
                    .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                    .opacity(pulseAnimation ? 0.0 : 0.6)
                    .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: false), value: pulseAnimation)

                Circle()
                    .fill(Color(hex: "4A90E2").opacity(0.1))
                    .frame(width: 80, height: 80)

                Image(systemName: "target")
                    .font(.system(size: 36))
                    .foregroundColor(Color(hex: "4A90E2").opacity(0.6))
            }

            Text("goals.no_active".localizedString)
                .font(.title3.bold())
                .foregroundColor(.white)

            Text("goals.no_active_description".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)

            Button(action: onCreateGoal) {
                Label("goals.create".localizedString, systemImage: "plus.circle.fill")
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
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
            .padding(.horizontal, 16)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .darkBlueCard()
        .onAppear { pulseAnimation = true }
    }
}

// MARK: - Goal History Section

struct GoalHistorySection: View {
    let goals: [Goal]
    @ObservedObject var viewModel: GoalsViewModel

    var pastGoals: [Goal] {
        goals.filter { $0.status != .active }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("goals.history".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)

            if pastGoals.isEmpty {
                Text("goals.no_history".localizedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                ForEach(pastGoals) { goal in
                    GoalHistoryRow(goal: goal, viewModel: viewModel)
                }
            }
        }
        .padding()
        .darkBlueCard()
    }
}

struct GoalHistoryRow: View {
    let goal: Goal
    @ObservedObject var viewModel: GoalsViewModel

    var statusColor: Color {
        Color(hex: goal.status.color)
    }

    var body: some View {
        HStack(spacing: 12) {
            // Status icon with colored background
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: goal.status.icon)
                    .font(.title3)
                    .foregroundColor(statusColor)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(goal.goalType.displayName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                HStack(spacing: 8) {
                    // Status badge
                    Text(goal.status.displayName)
                        .font(.caption2.weight(.medium))
                        .foregroundColor(statusColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(
                            Capsule()
                                .fill(statusColor.opacity(0.2))
                        )

                    // Date
                    if let startDate = goal.startDate {
                        Text(startDate)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 6) {
                // Progress
                HStack(spacing: 4) {
                    Text("\(Int(goal.progress))%")
                        .font(.subheadline.bold())
                        .foregroundColor(.white)

                    // Mini progress circle
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.2), lineWidth: 3)
                            .frame(width: 24, height: 24)

                        Circle()
                            .trim(from: 0, to: CGFloat(goal.progress / 100))
                            .stroke(statusColor, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                            .frame(width: 24, height: 24)
                            .rotationEffect(.degrees(-90))
                    }
                }

                // Resume button for paused goals
                if goal.status == .paused {
                    Button(action: {
                        Task { await viewModel.resumeGoal(goal) }
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "play.fill")
                                .font(.caption2)
                            Text("goals.resume".localizedString)
                                .font(.caption.weight(.semibold))
                        }
                        .foregroundColor(Color(hex: "4A90E2"))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color(hex: "4A90E2").opacity(0.2))
                        )
                    }
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(statusColor.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Create Goal Sheet

struct CreateGoalSheet: View {
    @ObservedObject var viewModel: GoalsViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 24) {
                        // Goal Type Selection
                        VStack(alignment: .leading, spacing: 12) {
                            Text("goals.select_type".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(GoalType.allCases, id: \.self) { type in
                                GoalTypeOption(
                                    type: type,
                                    isSelected: viewModel.selectedGoalType == type,
                                    onSelect: { viewModel.selectedGoalType = type }
                                )
                            }
                        }

                        // Target Weight
                        VStack(alignment: .leading, spacing: 8) {
                            Text("goals.target_weight".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("goals.weight_placeholder".localizedString, text: $viewModel.targetWeight)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(DarkTextFieldStyle())
                        }

                        // Target Waist
                        VStack(alignment: .leading, spacing: 8) {
                            Text("goals.target_waist".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("goals.waist_placeholder".localizedString, text: $viewModel.targetWaist)
                                .keyboardType(.decimalPad)
                                .textFieldStyle(DarkTextFieldStyle())
                        }

                        // Workouts per week
                        VStack(alignment: .leading, spacing: 8) {
                            Text("goals.workouts_per_week".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            Stepper(value: $viewModel.targetWorkoutsPerWeek, in: 1...7) {
                                Text("\(viewModel.targetWorkoutsPerWeek) " + "goals.times".localizedString)
                                    .foregroundColor(.white)
                            }
                            .tint(Color(hex: "4A90E2"))
                        }

                        // Duration
                        VStack(alignment: .leading, spacing: 8) {
                            Text("goals.duration".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            Stepper(value: $viewModel.totalWeeks, in: 4...52) {
                                Text("\(viewModel.totalWeeks) " + "goals.weeks".localizedString)
                                    .foregroundColor(.white)
                            }
                            .tint(Color(hex: "4A90E2"))
                        }

                        // Notes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("goals.notes".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            TextField("goals.notes_placeholder".localizedString, text: $viewModel.notes, axis: .vertical)
                                .lineLimit(3...6)
                                .textFieldStyle(DarkTextFieldStyle())
                        }

                        // Create Button
                        Button(action: {
                            Task {
                                if await viewModel.createGoal() {
                                    dismiss()
                                }
                            }
                        }) {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("goals.create".localizedString)
                                    .font(.headline.bold())
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            RoundedRectangle(cornerRadius: 14)
                                .fill(Color(hex: "4A90E2"))
                        )
                        .disabled(viewModel.isLoading)
                    }
                    .padding()
                }
            }
            .navigationTitle("goals.new".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localizedString) {
                        viewModel.resetForm()
                        dismiss()
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }
}

struct GoalTypeOption: View {
    let type: GoalType
    let isSelected: Bool
    let onSelect: () -> Void

    var icon: String {
        switch type {
        case .weightLoss: return "arrow.down.circle.fill"
        case .muscleGain: return "arrow.up.circle.fill"
        case .maintain: return "equal.circle.fill"
        case .custom: return "star.circle.fill"
        }
    }

    var color: Color {
        switch type {
        case .weightLoss: return .orange
        case .muscleGain: return .green
        case .maintain: return Color(hex: "4A90E2")
        case .custom: return .purple
        }
    }

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)

                Text(type.displayName)
                    .font(.subheadline.weight(.medium))
                    .foregroundColor(.white)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color(hex: "4A90E2").opacity(0.2) : Color.white.opacity(0.05))
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(isSelected ? Color(hex: "4A90E2") : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Dark TextField Style

struct DarkTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.white.opacity(0.05))
            )
            .foregroundColor(.white)
    }
}

// MARK: - Preview

#Preview {
    GoalsView()
        .preferredColorScheme(.dark)
}
