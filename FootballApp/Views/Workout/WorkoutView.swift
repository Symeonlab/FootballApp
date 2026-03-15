//
//  WorkoutView.swift
//  FootballApp
//
//  Modern workout view matching iOS Fitness design
//

import SwiftUI
import Combine
import os.log

struct WorkoutView: View {
    @EnvironmentObject var viewModel: WorkoutsViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @State private var showNewPlanSheet = false
    @State private var selectedDay: Int? = nil
    @State private var selectedStory: DailyStory?

    // Logger for WorkoutView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "WorkoutView")

    // Localized day names mapping
    private var dayNames: [String] {
        [
            "day.monday".localizedString,
            "day.tuesday".localizedString,
            "day.wednesday".localizedString,
            "day.thursday".localizedString,
            "day.friday".localizedString,
            "day.saturday".localizedString,
            "day.sunday".localizedString
        ]
    }

    private var dayAbbrevs: [String] {
        [
            "day.mon".localizedString,
            "day.tue".localizedString,
            "day.wed".localizedString,
            "day.thu".localizedString,
            "day.fri".localizedString,
            "day.sat".localizedString,
            "day.sun".localizedString
        ]
    }

    // Get today's index (Monday = 0)
    private var todayIndex: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }

    // Get today's workout
    private var todayWorkout: WorkoutSession? {
        guard viewModel.weeklySchedule.indices.contains(todayIndex) else { return nil }
        return viewModel.weeklySchedule[todayIndex]
    }

    // Check if today's workout is a rest day
    private var isTodayRestDay: Bool {
        guard let session = todayWorkout else { return true }
        return session.isRestDay
    }

    // Generate daily stories for the week - always show 7 days
    // Uses real data from NutritionViewModel when available
    private var dailyStories: [DailyStory] {
        // Get nutrition data from the viewmodel
        let caloriesTarget = nutritionViewModel.dailyCalories > 0 ? nutritionViewModel.dailyCalories : 2000
        let caloriesConsumed = nutritionViewModel.caloriesConsumed
        let nutritionProgress = caloriesTarget > 0 ? min(Double(caloriesConsumed) / Double(caloriesTarget), 1.0) : 0.0
        let waterGlasses = nutritionViewModel.waterGlasses
        let waterTarget = nutritionViewModel.waterTarget > 0 ? nutritionViewModel.waterTarget : 8

        // Ensure we always have 7 days even if weeklySchedule is empty
        return (0..<7).map { index in
            let session = viewModel.weeklySchedule.indices.contains(index) ? viewModel.weeklySchedule[index] : nil
            return DailyStory(
                dayIndex: index,
                dayName: dayNames[safe: index] ?? "workout.day".localizedString + " \(index + 1)",
                dayAbbrev: dayAbbrevs[safe: index] ?? "D\(index + 1)",
                isToday: index == todayIndex,
                workout: session,
                workoutCompleted: session != nil && viewModel.completedWorkouts.contains(session!.id),
                nutritionProgress: nutritionProgress,
                caloriesConsumed: caloriesConsumed,
                caloriesTarget: caloriesTarget,
                waterGlasses: waterGlasses,
                waterTarget: waterTarget
            )
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Dynamic animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    ModernWorkoutLoadingView()
                        .onAppear {
                            logger.debug("⏳ WorkoutView: Loading state - showing loading view")
                        }
                } else if viewModel.workoutSessions.isEmpty {
                    VStack(spacing: 20) {
                        Spacer()

                        if let errorMessage = viewModel.errorMessage {
                            // Error state with retry
                            VStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(Color.orange.opacity(0.1))
                                        .frame(width: 80, height: 80)
                                        .blur(radius: 15)
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .font(.system(size: 36))
                                        .foregroundColor(.orange)
                                }

                                Text("error.connection".localizedString)
                                    .font(.title3.bold())
                                    .foregroundColor(.white)

                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.6))
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal, 32)

                                Button {
                                    let generator = UIImpactFeedbackGenerator(style: .medium)
                                    generator.impactOccurred()
                                    Task { await viewModel.fetchWorkoutPlan() }
                                } label: {
                                    HStack(spacing: 8) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("common.retry".localizedString)
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 28)
                                    .padding(.vertical, 14)
                                    .frame(minHeight: 44)
                                    .background(
                                        Capsule().fill(
                                            LinearGradient(
                                                colors: [Color.appTheme.primary, Color.appTheme.primary.opacity(0.7)],
                                                startPoint: .leading,
                                                endPoint: .trailing
                                            )
                                        )
                                    )
                                }
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 24, style: .continuous)
                                    .fill(Color.white.opacity(0.04))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                                            .strokeBorder(Color.orange.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        } else {
                            // Empty state — no plan yet
                            ModernWorkoutEmptyStateView {
                                let generator = UIImpactFeedbackGenerator(style: .medium)
                                generator.impactOccurred()
                                Task { await viewModel.fetchWorkoutPlan() }
                            }
                        }

                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            // SECTION 1: Weekly Progress Strip (replaces stories + stats)
                            WeeklyProgressStrip(
                                stories: dailyStories,
                                completedCount: viewModel.completedWorkoutsCount,
                                totalWorkouts: viewModel.workoutSessions.filter { !$0.isRestDay }.count,
                                onDayTap: { story in
                                    logger.info("📖 Day tapped: \(story.dayName)")
                                    selectedStory = story
                                }
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // SECTION 2: Today Hero Card
                            VStack(alignment: .leading, spacing: 12) {
                                HStack {
                                    HStack(spacing: 6) {
                                        Circle()
                                            .fill(Color.green)
                                            .frame(width: 8, height: 8)
                                        Text("common.today".localizedString.uppercased())
                                            .font(.caption.bold())
                                            .foregroundColor(.green)
                                    }
                                    Spacer()
                                    Text(formattedDate)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                                .padding(.horizontal)

                                TodayHeroCard(
                                    workout: todayWorkout,
                                    isCompleted: todayWorkout != nil && viewModel.completedWorkouts.contains(todayWorkout!.id),
                                    completionPercentage: viewModel.completionPercentage,
                                    onTap: {
                                        if let session = todayWorkout, !isTodayRestDay {
                                            viewModel.activeSession = session
                                        }
                                    }
                                )
                                .padding(.horizontal)
                            }

                            // SECTION 3: Weekly Schedule (compact list only)
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    HStack(alignment: .firstTextBaseline) {
                                        Text("workout.this_week".localizedString)
                                            .font(.title3.bold())
                                            .foregroundColor(.white)
                                        Spacer()
                                        Text("workout.rpe_explanation".localizedString)
                                            .font(.caption2)
                                            .foregroundColor(.white.opacity(0.4))
                                    }
                                    Text("tooltip.weekly_schedule".localizedString)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.horizontal)

                                VStack(spacing: 8) {
                                    ForEach(Array(viewModel.weeklySchedule.enumerated()), id: \.element.id) { index, session in
                                        CompactWorkoutRow(
                                            dayAbbrev: dayAbbrevs[safe: index] ?? "D\(index + 1)",
                                            session: session,
                                            isToday: index == todayIndex,
                                            isCompleted: viewModel.completedWorkouts.contains(session.id),
                                            onTap: {
                                                if !session.isRestDay {
                                                    viewModel.activeSession = session
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Spacer(minLength: 100)
                        }
                    }
                    .refreshable {
                        await viewModel.fetchWorkoutPlan()
                    }
                    .onAppear {
                        logger.info("✅ WorkoutView: Displaying \(viewModel.workoutSessions.count) workout sessions")
                    }
                    .fullScreenCover(item: $selectedStory) { story in
                        StoryDetailView(
                            story: story,
                            onClose: {
                                selectedStory = nil
                            },
                            onStartWorkout: {
                                selectedStory = nil
                                if let workout = story.workout, !workout.isRestDay {
                                    viewModel.activeSession = workout
                                }
                            }
                        )
                    }
                }
            }
            .navigationTitle("workout.title".localizedString)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task { await viewModel.fetchWorkoutPlan() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .font(.title3)
                            .foregroundColor(Color.appTheme.primary)
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
        .task {
            if viewModel.workoutSessions.isEmpty {
                logger.info("📥 WorkoutView: Task triggered - fetching workout plan")
                await viewModel.fetchWorkoutPlan()
                
                // Log the result after fetch
                if !viewModel.workoutSessions.isEmpty {
                    logger.info("✅ WorkoutView: Successfully loaded \(viewModel.workoutSessions.count) workout sessions")
                    
                    // Log details of each session
                    for session in viewModel.workoutSessions {
                        logger.debug("   - \(session.day): \(session.theme) (\(session.exercises?.count ?? 0) exercises)")
                    }
                } else if let error = viewModel.errorMessage {
                    logger.error("❌ WorkoutView: Failed to load workout sessions - \(error)")
                } else {
                    logger.warning("⚠️ WorkoutView: No workout sessions loaded (no error)")
                }
            } else {
                logger.info("✅ WorkoutView: Workout sessions already loaded (\(viewModel.workoutSessions.count) sessions)")
            }
        }
    }

    // MARK: - Helper Methods
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: Date())
    }
}

// MARK: - Quick Stat Pill
struct QuickStatPill: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }
}

// MARK: - Compact Workout Row
struct CompactWorkoutRow: View {
    let dayAbbrev: String
    let session: WorkoutSession
    let isToday: Bool
    let isCompleted: Bool
    let onTap: () -> Void

    private var isRestDay: Bool { session.isRestDay }

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            onTap()
        }) {
            HStack(spacing: 12) {
                // Zone color indicator (color = training intensity zone)
                RoundedRectangle(cornerRadius: 3)
                    .fill(isRestDay ? Color.purple.opacity(0.4) : session.sessionZoneColor)
                    .frame(width: 4, height: 36)
                    .help("tooltip.zone_color".localizedString)

                // Day badge
                Text(dayAbbrev)
                    .font(.caption.bold())
                    .foregroundColor(isToday ? .white : .white.opacity(0.6))
                    .frame(width: 38)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(isToday ? Color.appTheme.primary : Color.white.opacity(0.08))
                    )

                // Theme + icon for rest days
                HStack(spacing: 6) {
                    if isRestDay {
                        Image(systemName: "moon.zzz.fill")
                            .font(.system(size: 12))
                            .foregroundColor(.purple.opacity(0.6))
                    }
                    Text(session.displayThemeName)
                        .font(.subheadline.weight(isToday ? .bold : .medium))
                        .foregroundColor(isRestDay ? .white.opacity(0.35) : .white)
                }

                Spacer()

                // Status/Exercise count
                if !isRestDay {
                    HStack(spacing: 6) {
                        HStack(spacing: 3) {
                            Text("\(session.exercises?.count ?? 0)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                            Image(systemName: "figure.run")
                                .font(.caption2)
                                .foregroundColor(.white.opacity(0.4))
                        }

                        if let rpe = session.metadata?.rpe {
                            Text("workout.rpe".localizedString + " \(rpe)")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.5))
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(
                                    Capsule().fill(Color.white.opacity(0.06))
                                )
                                .help("tooltip.rpe_short".localizedString)
                        }
                    }
                }

                // Completion indicator
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(.green)
                } else if !isRestDay {
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .frame(minHeight: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(
                        isToday
                            ? Color.appTheme.primary.opacity(0.12)
                            : (isRestDay ? Color.white.opacity(0.015) : Color.white.opacity(0.03))
                    )
                    .overlay(
                        isToday ?
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(Color.appTheme.primary.opacity(0.25), lineWidth: 1)
                        : nil
                    )
            )
            .opacity(isRestDay ? 0.7 : 1.0)
        }
        .buttonStyle(.plain)
        .disabled(isRestDay)
    }
}

// MARK: - Safe Array Access
extension Array {
    subscript(safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

// Preview-only Auth VM to ensure app state allows access to WorkoutView
@MainActor
class PreviewAuthViewModel: AuthViewModel {
    override init() {
        super.init()
        self.appState = .mainApp
    }
}

// MARK: - Preview
#Preview {
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()

    NavigationStack {
        WorkoutView()
            .environmentObject(workoutsVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
    }
    .preferredColorScheme(.dark)
}

#Preview("Workout Screen") {
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()

    NavigationStack {
        WorkoutView()
            .environmentObject(workoutsVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
    }
    .preferredColorScheme(.dark)
}

// MARK: - Mock ViewModel for Previews
@MainActor
final class MockWorkoutsViewModel: WorkoutsViewModel {
    override init() {
        super.init()
        self.workoutSessions = [
            WorkoutSession(
                id: 1,
                day: "LUNDI",
                theme: "Strength",
                warmup: "5 min jog",
                finisher: "Cool down stretches",
                exercises: [
                    WorkoutExercise(id: 1, name: "Squats", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=aclHkVaku9U", is_completed: false),
                    WorkoutExercise(id: 2, name: "Push-ups", sets: "3 sets", reps: "15 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=IODxDxX7oi4", is_completed: false),
                    WorkoutExercise(id: 3, name: "Lunges", sets: "3 sets", reps: "10 per leg", recovery: "60s", video_url: "https://www.youtube.com/watch?v=QOVaHwm-Q6U", is_completed: false)
                ],
                is_completed: false,
                completion_date: nil
            ),
            WorkoutSession(
                id: 2,
                day: "MARDI",
                theme: "Cardio",
                warmup: "Dynamic stretches",
                finisher: "Walking",
                exercises: [
                    WorkoutExercise(id: 4, name: "Burpees", sets: "4 sets", reps: "10 reps", recovery: "30s", video_url: "https://www.youtube.com/watch?v=dZgVxmf6jkA", is_completed: false),
                    WorkoutExercise(id: 5, name: "Mountain Climbers", sets: "3 sets", reps: "20 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=nmwgirgXLYM", is_completed: false)
                ],
                is_completed: true,
                completion_date: nil
            ),
            WorkoutSession(
                id: 3,
                day: "MERCREDI",
                theme: "Repos",
                warmup: nil,
                finisher: nil,
                exercises: nil,
                is_completed: false,
                completion_date: nil
            ),
            WorkoutSession(
                id: 4,
                day: "JEUDI",
                theme: "Upper Body",
                warmup: "Arm circles",
                finisher: "Shoulder stretches",
                exercises: [
                    WorkoutExercise(id: 6, name: "Bench Press", sets: "4 sets", reps: "8 reps", recovery: "90s", video_url: "https://www.youtube.com/watch?v=rT7DgCr-3pg", is_completed: false),
                    WorkoutExercise(id: 7, name: "Pull-ups", sets: "3 sets", reps: "8 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=eGo4IYlbE5g", is_completed: false)
                ],
                is_completed: false,
                completion_date: nil
            ),
            WorkoutSession(
                id: 5,
                day: "VENDREDI",
                theme: "Core",
                warmup: "Cat-cow stretch",
                finisher: "Child's pose",
                exercises: [
                    WorkoutExercise(id: 8, name: "Plank", sets: "3 sets", reps: "60 sec", recovery: "60s", video_url: "https://www.youtube.com/watch?v=ASdvN_XEl_c", is_completed: false),
                    WorkoutExercise(id: 9, name: "Russian Twists", sets: "3 sets", reps: "20 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=wkD8rjkodUI", is_completed: false)
                ],
                is_completed: true,
                completion_date: nil
            ),
            WorkoutSession(
                id: 6,
                day: "SAMEDI",
                theme: "Lower Body",
                warmup: "Leg swings",
                finisher: "Hip stretches",
                exercises: [
                    WorkoutExercise(id: 10, name: "Deadlifts", sets: "4 sets", reps: "10 reps", recovery: "90s", video_url: "https://www.youtube.com/watch?v=op9kVnSso6Q", is_completed: false),
                    WorkoutExercise(id: 11, name: "Leg Press", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=IZxyjW7MPJQ", is_completed: false)
                ],
                is_completed: false,
                completion_date: nil
            ),
            WorkoutSession(
                id: 7,
                day: "DIMANCHE",
                theme: "Repos",
                warmup: nil,
                finisher: nil,
                exercises: nil,
                is_completed: false,
                completion_date: nil
            )
        ]
        self.weeklySchedule = self.workoutSessions
        self.completedWorkouts = [2, 5]
        self.isLoading = false
    }
}

