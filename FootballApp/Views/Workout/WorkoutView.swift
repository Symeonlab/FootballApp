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
    @State private var showNewPlanSheet = false
    @State private var selectedDay: Int? = nil
    
    // Logger for WorkoutView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "WorkoutView")
    
    // Get today's workout
    private var todayWorkout: WorkoutSession? {
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let todayIndex = (weekday + 5) % 7 // Convert to Monday-first (0 = Monday)
        
        guard viewModel.weeklySchedule.indices.contains(todayIndex) else { return nil }
        let session = viewModel.weeklySchedule[todayIndex]
        return session.theme != "Repos" ? session : nil
    }

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
                    ModernWorkoutLoadingView()
                        .onAppear {
                            logger.debug("⏳ WorkoutView: Loading state - showing loading view")
                        }
                } else if viewModel.workoutSessions.isEmpty {
                    VStack(spacing: 20) {
                        ModernWorkoutEmptyStateView {
                            Task { await viewModel.generateNewPlan() }
                        }

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
                                    Task { await viewModel.fetchWorkoutPlan() }
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
                    ScrollView {
                        VStack(spacing: 24) {
                            ModernWorkoutStatsHeader(viewModel: viewModel)
                                .padding(.horizontal)
                                .padding(.top, 8)

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

                            VStack(spacing: 16) {
                                ForEach(viewModel.weeklySchedule) { session in
                                    if session.theme != "Repos" {
                                        ModernWorkoutSessionCard(
                                            theme: session.theme,
                                            exerciseCount: session.exercises?.count ?? 0,
                                            isCompleted: viewModel.completedWorkouts.contains(session.id),
                                            isRestDay: false,
                                            exercises: session.exercises?.map { $0.name } ?? [],
                                            onStart: { viewModel.activeSession = session }
                                        )
                                    } else {
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
                    .refreshable {
                        await viewModel.fetchWorkoutPlan()
                    }
                    .onAppear {
                        logger.info("✅ WorkoutView: Displaying \(viewModel.workoutSessions.count) workout sessions")
                    }
                }
            }
            .navigationTitle("Workouts - Dipodi")
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
                        Image(systemName: "ellipsis.circle")
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
    private func generateWeeklyCalendarData() -> [(String, Bool, Bool, Bool)] {
        let daysOfWeek = ["M", "T", "W", "T", "F", "S", "S"]
        let calendar = Calendar.current
        let today = Date()
        let weekday = calendar.component(.weekday, from: today)
        let todayIndex = (weekday + 5) % 7 // Monday-first index

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
    let workoutsVM: WorkoutsViewModel = MockWorkoutsViewModel()
    let authVM: AuthViewModel = PreviewAuthViewModel()
    let langManager = LanguageManager()
    let themeManager = ThemeManager()

    NavigationView {
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

    NavigationView {
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
        self.weeklySchedule = self.workoutSessions
        self.completedWorkouts = [2, 5]
        self.isLoading = false
    }
}

