//
//  WorkoutViewEnhanced.swift
//  FootballApp
//
//  Enhanced workout view with modern UI/UX improvements
//  Demonstrates usage of new Liquid Glass components
//

import SwiftUI
import Combine
import os.log

struct WorkoutViewEnhanced: View {
    @EnvironmentObject var viewModel: WorkoutsViewModel
    @State private var showNewPlanSheet = false
    @State private var selectedDay: Int? = nil
    
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "WorkoutViewEnhanced")
    
    var body: some View {
        NavigationView {
            ZStack {
                // Dark background with gradient
                LinearGradient(
                    colors: [
                        Color(hex: "0A0A1E"),
                        Color(hex: "1A1A2E"),
                        Color(hex: "0F0F23")
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.isLoading {
                    // ✨ Enhanced loading with skeleton loaders
                    EnhancedLoadingState()
                } else if viewModel.workoutSessions.isEmpty {
                    // ✨ Enhanced empty state
                    EnhancedEmptyState(
                        icon: "figure.strengthtraining.functional",
                        title: "No Workout Plan Yet",
                        subtitle: "Let's create your personalized training program to reach your fitness goals",
                        actionTitle: "Generate Workout Plan",
                        action: {
                            Task {
                                await viewModel.generateNewPlan()
                            }
                        }
                    )
                    
                    if let errorMessage = viewModel.errorMessage {
                        VStack(spacing: 16) {
                            LiquidGlassCard(cornerRadius: 20, tintColor: .orange) {
                                VStack(spacing: 12) {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 40))
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.orange, .yellow],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                    
                                    Text("Connection Error")
                                        .font(.headline.bold())
                                        .foregroundColor(.white)
                                    
                                    Text(errorMessage)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.8))
                                        .multilineTextAlignment(.center)
                                }
                            }
                            
                            LiquidGlassButton(
                                "Retry",
                                icon: "arrow.clockwise",
                                style: .secondary,
                                action: {
                                    Task {
                                        await viewModel.fetchWorkoutPlan()
                                    }
                                }
                            )
                        }
                        .padding(.horizontal, 24)
                    }
                } else {
                    // ✨ Enhanced content view
                    ScrollView {
                        VStack(spacing: 24) {
                            // Enhanced stats header
                            EnhancedWorkoutStatsHeader(viewModel: viewModel)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            // Weekly calendar with liquid glass
                            EnhancedWeeklyCalendar(
                                days: generateWeeklyCalendarData(),
                                onDayTap: { index in
                                    if index < viewModel.weeklySchedule.count {
                                        let session = viewModel.weeklySchedule[index]
                                        if session.theme != "Repos" {
                                            viewModel.activeSession = session
                                        }
                                    }
                                }
                            )
                            .padding(.horizontal)

                            // Enhanced workout list
                            VStack(spacing: 16) {
                                ForEach(viewModel.weeklySchedule) { session in
                                    if session.theme != "Repos" {
                                        EnhancedWorkoutCard(
                                            session: session,
                                            isCompleted: viewModel.completedWorkouts.contains(session.id),
                                            onStart: {
                                                viewModel.activeSession = session
                                            }
                                        )
                                    } else {
                                        RestDayCard(day: session.day)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.top, 8)
                    }
                    .refreshable {
                        await viewModel.fetchWorkoutPlan()
                    }
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button {
                            Task { await viewModel.fetchWorkoutPlan() }
                        } label: {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }
                        Button {
                            Task { await viewModel.generateNewPlan() }
                        } label: {
                            Label("Generate New Plan", systemImage: "wand.and.stars")
                        }
                    } label: {
                        ZStack {
                            Circle()
                                .fill(.ultraThinMaterial)
                                .frame(width: 36, height: 36)
                            
                            Image(systemName: "ellipsis.circle.fill")
                                .font(.title3)
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.primary, Color.theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                }
            }
            .fullScreenCover(item: $viewModel.activeSession) { (session: WorkoutSession) in
                WorkoutSessionReelsView(
                    viewModel: WorkoutDetailViewModel(session: session),
                    onComplete: {
                        Task { await viewModel.logWorkoutCompleted(session: session, date: Date()) }
                        viewModel.activeSession = nil
                    }
                )
            }
        }
    }
    
    // MARK: - Helper Methods
    private func generateWeeklyCalendarData() -> [(String, Bool, Bool, Bool)] {
        let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let todayIndex = (weekday + 5) % 7

        return daysOfWeek.enumerated().map { index, day in
            let session = viewModel.weeklySchedule.indices.contains(index) ? viewModel.weeklySchedule[index] : nil
            let isToday = index == todayIndex
            let isCompleted = session != nil && viewModel.completedWorkouts.contains(session!.id)
            let isRestDay = session?.theme == "Repos" || session?.theme.lowercased().contains("rest") ?? false
            return (day, isToday, isCompleted, isRestDay)
        }
    }
}

// MARK: - Enhanced Loading State
private struct EnhancedLoadingState: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Stats skeleton
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(0..<4) { _ in
                            SkeletonView(height: 120, cornerRadius: 20)
                                .frame(width: 160)
                        }
                    }
                    .padding(.horizontal)
                }
                
                // Calendar skeleton
                HStack(spacing: 8) {
                    ForEach(0..<7) { _ in
                        SkeletonView(height: 60, cornerRadius: 16)
                    }
                }
                .padding(.horizontal)
                
                // Workout cards skeleton
                VStack(spacing: 16) {
                    ForEach(0..<5) { _ in
                        WorkoutCardSkeleton()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 8)
        }
    }
}

// MARK: - Enhanced Stats Header
private struct EnhancedWorkoutStatsHeader: View {
    @ObservedObject var viewModel: WorkoutsViewModel
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                EnhancedStatCard(
                    icon: "figure.strengthtraining.functional",
                    value: "\(viewModel.workoutSessions.count)",
                    label: "Workouts",
                    color: Color.theme.primary,
                    trend: nil
                )
                .frame(width: 160)
                
                EnhancedStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.completedWorkoutsCount)",
                    label: "Completed",
                    color: .green,
                    trend: viewModel.completedWorkoutsCount > 0 ? .up : nil
                )
                .frame(width: 160)
                
                EnhancedStatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.totalExercises)",
                    label: "Exercises",
                    color: .orange,
                    trend: nil
                )
                .frame(width: 160)
                
                EnhancedStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(viewModel.completionPercentage * 100))%",
                    label: "Progress",
                    color: .blue,
                    trend: viewModel.completionPercentage >= 0.5 ? .up : .neutral
                )
                .frame(width: 160)
            }
            .padding(.horizontal, 4)
        }
    }
}

// MARK: - Enhanced Weekly Calendar
private struct EnhancedWeeklyCalendar: View {
    let days: [(String, Bool, Bool, Bool)] // (day, isToday, isCompleted, isRestDay)
    let onDayTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                Button {
                    if !day.3 { // Not a rest day
                        onDayTap(index)
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(day.0)
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white.opacity(day.1 ? 1.0 : 0.6))
                        
                        ZStack {
                            if day.2 { // Completed
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 24))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.green, .green.opacity(0.7)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            } else if day.3 { // Rest day
                                Image(systemName: "moon.zzz.fill")
                                    .font(.system(size: 20))
                                    .foregroundColor(.gray)
                            } else {
                                Circle()
                                    .fill(day.1 ? Color.theme.primary : Color.white.opacity(0.2))
                                    .frame(width: 8, height: 8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background {
                        ZStack {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .fill(.ultraThinMaterial)
                            
                            if day.1 {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.theme.primary.opacity(0.3),
                                                Color.theme.accent.opacity(0.1)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1.5
                                    )
                            }
                        }
                    }
                    .shadow(color: day.1 ? Color.theme.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
                }
            }
        }
    }
}

// MARK: - Enhanced Workout Card
private struct EnhancedWorkoutCard: View {
    let session: WorkoutSession
    let isCompleted: Bool
    let onStart: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            onStart()
        } label: {
            VStack(alignment: .leading, spacing: 16) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(session.day.capitalized)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.7))
                            .tracking(1)
                        
                        Text(session.theme)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.green, .green.opacity(0.7)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    } else {
                        Image(systemName: "play.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
                
                HStack(spacing: 16) {
                    Label("\(session.exercises?.count ?? 0) exercises", systemImage: "figure.run")
                        .font(.caption.weight(.medium))
                        .foregroundColor(.white.opacity(0.8))
                    
                    if let warmup = session.warmup, !warmup.isEmpty {
                        Label("Warmup", systemImage: "flame.fill")
                            .font(.caption.weight(.medium))
                            .foregroundColor(.orange.opacity(0.8))
                    }
                }
                
                if let exercises = session.exercises, !exercises.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        ForEach(exercises.prefix(3), id: \.id) { exercise in
                            HStack(spacing: 8) {
                                Circle()
                                    .fill(Color.theme.primary)
                                    .frame(width: 6, height: 6)
                                
                                Text(exercise.name)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.9))
                                
                                Spacer()
                                
                                Text("\(exercise.sets) × \(exercise.reps)")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        if exercises.count > 3 {
                            Text("+ \(exercises.count - 3) more")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }
                    }
                }
            }
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    isCompleted ? Color.green.opacity(0.15) : Color.theme.primary.opacity(0.15),
                                    isCompleted ? Color.green.opacity(0.05) : Color.theme.primary.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(
                color: isCompleted ? Color.green.opacity(0.3) : Color.theme.primary.opacity(0.2),
                radius: 15,
                x: 0,
                y: 8
            )
        }
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Rest Day Card
private struct RestDayCard: View {
    let day: String
    
    var body: some View {
        HStack {
            Image(systemName: "moon.zzz.fill")
                .font(.system(size: 28))
                .foregroundColor(.gray)
                .frame(width: 50)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(day.capitalized)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
                
                Text("Rest & Recovery")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.9))
            }
            
            Spacer()
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                }
        }
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Preview
#Preview {
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()
    
    return WorkoutViewEnhanced()
        .environmentObject(workoutsVM)
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}
