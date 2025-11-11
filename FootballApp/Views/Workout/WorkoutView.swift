//
//  WorkoutView.swift
//  FootballApp
//
//  Modern workout list view with enhanced UI
//

import SwiftUI

struct WorkoutView: View {
    @EnvironmentObject var viewModel: WorkoutsViewModel
    @State private var showNewPlanSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                if viewModel.isLoading {
                    // Use modern loading view
                    ModernWorkoutLoadingView()
                } else if viewModel.workoutSessions.isEmpty {
                    // Use modern empty state
                    VStack(spacing: 20) {
                        ModernWorkoutEmptyStateView {
                            Task {
                                await viewModel.generateNewPlan()
                            }
                        }

                        // Show error message if there is one
                        if let errorMessage = viewModel.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.system(size: 40))
                                    .foregroundColor(.orange)

                                Text("Connection Error")
                                    .font(.headline)
                                    .foregroundColor(.white)

                                Text(errorMessage)
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)

                                Button {
                                    Task {
                                        await viewModel.fetchWorkoutPlan()
                                    }
                                } label: {
                                    HStack {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Retry")
                                    }
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 24)
                                    .padding(.vertical, 12)
                                    .background(Color.appTheme.primary)
                                    .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color(hex: "1E1E2E"))
                                    .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
                            )
                            .padding(.horizontal)
                        }
                    }
                } else {
                    // Workout list with modern components
                    ScrollView {
                        VStack(spacing: 24) {
                            // Modern Stats Header with progress
                            ModernWorkoutStatsHeader(viewModel: viewModel)
                                .padding(.horizontal)
                                .padding(.top, 8)

                            // Modern Weekly Calendar
                            ModernWorkoutWeeklyCalendar(
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

                            // Weekly schedule with modern session cards
                            VStack(spacing: 16) {
                                ForEach(viewModel.weeklySchedule) { session in
                                    if session.theme != "Repos" {
                                        ModernWorkoutSessionCard(
                                            theme: session.theme,
                                            exerciseCount: session.exercises?.count ?? 0,
                                            isCompleted: viewModel.completedWorkouts.contains(session.id),
                                            isRestDay: false,
                                            exercises: session.exercises?.map { $0.name } ?? [],
                                            onStart: {
                                                viewModel.activeSession = session
                                            }
                                        )
                                    } else {
                                        // Rest day card
                                        ModernWorkoutListRow(
                                            day: session.day,
                                            theme: "Rest Day",
                                            exerciseCount: 0,
                                            isCompleted: false,
                                            isRestDay: true
                                        )
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 100)
                        }
                        .padding(.top, 8)
                    }
                }
            }
            .navigationTitle("Workouts - Dipodi")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: {
                            Task {
                                await viewModel.fetchWorkoutPlan()
                            }
                        }) {
                            Label("Refresh", systemImage: "arrow.clockwise")
                        }

                        Button(action: {
                            Task {
                                await viewModel.generateNewPlan()
                            }
                        }) {
                            Label("Generate New Plan", systemImage: "wand.and.stars")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.title3)
                            .foregroundColor(Color.appTheme.primary)
                    }
                }
            }
            .fullScreenCover(item: $viewModel.activeSession) { session in
                WorkoutSessionReelsView(
                    viewModel: WorkoutDetailViewModel(session: session),
                    onComplete: {
                        Task {
                            await viewModel.logWorkoutCompleted(session: session, date: Date())
                        }
                        viewModel.activeSession = nil
                    }
                )
            }
        }
        .task {
            if viewModel.workoutSessions.isEmpty {
                await viewModel.fetchWorkoutPlan()
            }
        }
    }

    // MARK: - Helper Methods

    /// Generate calendar data for the weekly calendar component
    private func generateWeeklyCalendarData() -> [(String, Bool, Bool, Bool)] {
        let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]

        // Get current day of week (1 = Sunday, 2 = Monday, etc.)
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)

        // Convert to 0-indexed Monday-first (0 = Monday, 6 = Sunday)
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

// MARK: - Modern Stats Header
struct ModernWorkoutStatsHeader: View {
    @ObservedObject var viewModel: WorkoutsViewModel

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ModernWorkoutStatCard(
                    icon: "figure.strengthtraining.functional",
                    value: "\(viewModel.workoutSessions.count)",
                    label: "Workouts",
                    color: Color.appTheme.primary,
                    progress: Double(viewModel.workoutSessions.count) / 7.0
                )

                ModernWorkoutStatCard(
                    icon: "checkmark.circle.fill",
                    value: "\(viewModel.completedWorkoutsCount)",
                    label: "Completed",
                    color: .green,
                    progress: viewModel.completionPercentage
                )

                ModernWorkoutStatCard(
                    icon: "flame.fill",
                    value: "\(viewModel.totalExercises)",
                    label: "Exercises",
                    color: .orange,
                    progress: Double(viewModel.completedWorkoutsCount) / Double(max(viewModel.workoutSessions.count, 1))
                )

                ModernWorkoutStatCard(
                    icon: "chart.line.uptrend.xyaxis",
                    value: "\(Int(viewModel.completionPercentage * 100))%",
                    label: "Progress",
                    color: .blue,
                    progress: viewModel.completionPercentage
                )
            }
            .padding(.horizontal, 4)
        }
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
    // IMPORTANT: Type-erase to the base class so SwiftUI registers the correct EnvironmentObject key.
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()

    return NavigationView {
        WorkoutView()
            .environmentObject(workoutsVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
    }
    .preferredColorScheme(.dark)
}

#Preview("Workout Screen") {
    // IMPORTANT: Type-erase to the base class so SwiftUI registers the correct EnvironmentObject key.
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()

    return NavigationView {
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

        // Add mock workout sessions - all assignments happen synchronously during init
        self.workoutSessions = [
            WorkoutSession(
                id: 1,
                day: "LUNDI",
                theme: "Strength",
                warmup: "5 min jog",
                finisher: "Cool down stretches",
                exercises: [
                    WorkoutExercise(id: 1, name: "Squats", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 2, name: "Push-ups", sets: "3 sets", reps: "15 reps", recovery: "45s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 3, name: "Lunges", sets: "3 sets", reps: "10 per leg", recovery: "60s", video_url: nil, is_completed: false)
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
                    WorkoutExercise(id: 4, name: "Burpees", sets: "4 sets", reps: "10 reps", recovery: "30s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 5, name: "Mountain Climbers", sets: "3 sets", reps: "20 reps", recovery: "45s", video_url: nil, is_completed: false)
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
                    WorkoutExercise(id: 6, name: "Bench Press", sets: "4 sets", reps: "8 reps", recovery: "90s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 7, name: "Pull-ups", sets: "3 sets", reps: "8 reps", recovery: "60s", video_url: nil, is_completed: false)
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
                    WorkoutExercise(id: 8, name: "Plank", sets: "3 sets", reps: "60 sec", recovery: "60s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 9, name: "Russian Twists", sets: "3 sets", reps: "20 reps", recovery: "45s", video_url: nil, is_completed: false)
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
                    WorkoutExercise(id: 10, name: "Deadlifts", sets: "4 sets", reps: "10 reps", recovery: "90s", video_url: nil, is_completed: false),
                    WorkoutExercise(id: 11, name: "Leg Press", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: nil, is_completed: false)
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

        // Populate weekly schedule
        self.weeklySchedule = self.workoutSessions

        // Mark some as completed
        self.completedWorkouts = [2, 5]

        // Not loading
        self.isLoading = false
    }

    override func fetchWorkoutPlan() async {
        // Do nothing in preview - mock is already populated
    }

    override func generateNewPlan() async {
        // Do nothing in preview - mock is already populated
    }

    override func logWorkoutCompleted(session: WorkoutSession, date: Date) async {
        // Mock implementation - just update local state
        await MainActor.run {
            self.completedWorkouts.insert(session.id)
        }
    }
}
