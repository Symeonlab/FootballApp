//
//  WorkoutsViewModel.swift
//  FootballApp
//
//  ViewModel for managing workout data and progress tracking
//
import Foundation
import Combine
import os.log
import SwiftUI

class WorkoutsViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var workoutSessions: [WorkoutSession] = [] // API response (sessions only)
    @Published var completedWorkouts: Set<Int> = [] // IDs of completed workouts (Persist this via user defaults/API later)
    @Published var completedExercises: Set<Int> = [] // IDs of completed exercises
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // UI Properties
    @Published var activeSession: WorkoutSession? // Triggers the detail view
    @Published var weeklySchedule: [WorkoutSession] = [] // Full 7-day schedule (including Rest days)

    // MARK: - Private Properties
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "Workouts")
    private let api = APIService.shared
    private var cancellables = Set<AnyCancellable>()
    private static let completedWorkoutsKey = "completedWorkouts"
    
    // Preview detection
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }
    
    // MARK: - Computed Properties
    var totalExercises: Int {
        workoutSessions.reduce(0) { $0 + ($1.exercises?.count ?? 0) }
    }
    var completedWorkoutsCount: Int { completedWorkouts.count }
    var completionPercentage: Double {
        Double(completedWorkouts.count) / Double(max(workoutSessions.filter { !$0.isRestDay }.count, 1))
    }

    // MARK: - Initialization
    @MainActor
    init() {
        // Load persisted completed workouts from UserDefaults
        let savedIDs = UserDefaults.standard.array(forKey: Self.completedWorkoutsKey) as? [Int] ?? []
        self.completedWorkouts = Set(savedIDs)

        logger.info("🏋️ WorkoutsViewModel initialized (Preview: \(self.isPreview), completed: \(savedIDs.count))")

        // Don't make API calls in preview mode
        if isPreview {
            logger.info("⚠️ Running in preview mode - skipping API initialization")
            loadMockData()
        }
    }

    // MARK: - Mock Data for Testing/Preview
    @MainActor
    func loadMockData() {
        logger.info("📦 Loading mock workout data")

        // Real YouTube fitness video URLs for each exercise type
        let mockExercises1: [WorkoutExercise] = [
            WorkoutExercise(id: 1, name: "Squats", sets: "4 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=aclHkVaku9U", is_completed: false),
            WorkoutExercise(id: 2, name: "Lunges", sets: "3 sets", reps: "10 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=QOVaHwm-Q6U", is_completed: false),
            WorkoutExercise(id: 3, name: "Leg Press", sets: "4 sets", reps: "15 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=IZxyjW7MPJQ", is_completed: false),
            WorkoutExercise(id: 4, name: "Calf Raises", sets: "3 sets", reps: "20 reps", recovery: "30s", video_url: "https://www.youtube.com/watch?v=gwLzBJYoWlI", is_completed: false)
        ]

        let mockExercises2: [WorkoutExercise] = [
            WorkoutExercise(id: 5, name: "Bench Press", sets: "4 sets", reps: "10 reps", recovery: "90s", video_url: "https://www.youtube.com/watch?v=rT7DgCr-3pg", is_completed: false),
            WorkoutExercise(id: 6, name: "Incline Dumbbell Press", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=8iPEnn-ltC8", is_completed: false),
            WorkoutExercise(id: 7, name: "Tricep Dips", sets: "3 sets", reps: "15 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=0326dy_-CzM", is_completed: false),
            WorkoutExercise(id: 8, name: "Push-ups", sets: "3 sets", reps: "20 reps", recovery: "30s", video_url: "https://www.youtube.com/watch?v=IODxDxX7oi4", is_completed: false)
        ]

        let mockExercises3: [WorkoutExercise] = [
            WorkoutExercise(id: 9, name: "Pull-ups", sets: "4 sets", reps: "8 reps", recovery: "90s", video_url: "https://www.youtube.com/watch?v=eGo4IYlbE5g", is_completed: false),
            WorkoutExercise(id: 10, name: "Bent Over Rows", sets: "4 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=FWJR5Ve8bnQ", is_completed: false),
            WorkoutExercise(id: 11, name: "Bicep Curls", sets: "3 sets", reps: "15 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=ykJmrZ5v0Oo", is_completed: false),
            WorkoutExercise(id: 12, name: "Face Pulls", sets: "3 sets", reps: "15 reps", recovery: "30s", video_url: "https://www.youtube.com/watch?v=rep-qVOkqgk", is_completed: false)
        ]

        let mockExercises4: [WorkoutExercise] = [
            WorkoutExercise(id: 13, name: "Deadlifts", sets: "4 sets", reps: "8 reps", recovery: "120s", video_url: "https://www.youtube.com/watch?v=op9kVnSso6Q", is_completed: false),
            WorkoutExercise(id: 14, name: "Romanian Deadlifts", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=JCXUYuzwNrM", is_completed: false),
            WorkoutExercise(id: 15, name: "Hamstring Curls", sets: "3 sets", reps: "15 reps", recovery: "45s", video_url: "https://www.youtube.com/watch?v=1Tq3QdYUuHs", is_completed: false),
            WorkoutExercise(id: 16, name: "Hip Thrusts", sets: "3 sets", reps: "12 reps", recovery: "60s", video_url: "https://www.youtube.com/watch?v=SEdqd1n0cvg", is_completed: false)
        ]

        let mockSessions: [WorkoutSession] = [
            WorkoutSession(id: 1, day: "LUNDI", theme: "Jambes", warmup: "5 min cardio léger", finisher: "10 min étirements", exercises: mockExercises1, is_completed: false, completion_date: nil),
            WorkoutSession(id: 2, day: "MARDI", theme: "Poitrine & Triceps", warmup: "5 min échauffement haut du corps", finisher: "Pompes max", exercises: mockExercises2, is_completed: false, completion_date: nil),
            WorkoutSession(id: 3, day: "MERCREDI", theme: "Repos", warmup: nil, finisher: nil, exercises: nil, is_completed: false, completion_date: nil),
            WorkoutSession(id: 4, day: "JEUDI", theme: "Dos & Biceps", warmup: "5 min rameur", finisher: "Gainage 3x1min", exercises: mockExercises3, is_completed: false, completion_date: nil),
            WorkoutSession(id: 5, day: "VENDREDI", theme: "Jambes & Fessiers", warmup: "5 min vélo", finisher: "Cardio HIIT 10 min", exercises: mockExercises4, is_completed: false, completion_date: nil),
            WorkoutSession(id: 6, day: "SAMEDI", theme: "Repos", warmup: nil, finisher: nil, exercises: nil, is_completed: false, completion_date: nil),
            WorkoutSession(id: 7, day: "DIMANCHE", theme: "Repos", warmup: nil, finisher: nil, exercises: nil, is_completed: false, completion_date: nil)
        ]

        self.workoutSessions = mockSessions.filter { !$0.isRestDay }
        self.weeklySchedule = mockSessions

        logger.info("✅ Loaded \(self.workoutSessions.count) mock workout sessions")
    }
    
    // MARK: - API Methods

    /// Fetch workout plan from API
    func fetchWorkoutPlan() async {
        // Skip API calls in preview - use mock data instead
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchWorkoutPlan() - running in preview mode")
            await MainActor.run { loadMockData() }
            return
        }

        logger.info("💪 Fetching workout plan from API")

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let plan: [WorkoutSession] = try await api.getWorkoutPlan()

            await MainActor.run {
                self.workoutSessions = plan
                self.weeklySchedule = fillRestDays(plan: plan)
                self.isLoading = false

                if plan.isEmpty {
                    logger.info("ℹ️ API returned empty plan - user needs to generate a workout plan")
                } else {
                    logger.info("✅ Successfully fetched \(plan.count) workout sessions")
                }
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            logger.error("❌ Failed to fetch workout plan: \(error.localizedDescription)")
        }
    }
    
    // Note: generateNewPlan() was removed — workout plan regeneration is now handled
    // through the "Update Workout Type" flow (re-onboarding) in ProfileView.
    
    // MARK: - API Progress Logging
    
    /// Log workout completion to API
    func logWorkoutCompleted(session: WorkoutSession, date: Date) async {
        logger.info("📤 Logging workout completion to API for: \(session.day)")
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        
        let progress = UserProgress(
            id: 0, user_id: 0, // Server assigns these
            date: formatter.string(from: date),
            workout_completed: session.theme
        )
        
        do {
            _ = try await APIService.shared.logProgress(progress)
            logger.info("Workout progress logged to API")
            // Update local UI state and persist
            await MainActor.run {
                markWorkoutCompleted(session.id)
            }
        } catch {
            logger.error("Failed to log progress to API: \(error.localizedDescription)")
            // Still mark locally so user sees progress, but show error
            await MainActor.run {
                markWorkoutCompleted(session.id)
                self.errorMessage = "error.save_progress".localizedString
            }
        }
    }

    // MARK: - Persistence

    /// Mark a workout as completed and persist to UserDefaults
    @MainActor
    func markWorkoutCompleted(_ workoutId: Int) {
        completedWorkouts.insert(workoutId)
        saveCompletedWorkouts()
        logger.info("💾 Marked workout \(workoutId) as completed (total: \(self.completedWorkouts.count))")
    }

    /// Save completedWorkouts set to UserDefaults
    private func saveCompletedWorkouts() {
        let ids = Array(completedWorkouts)
        UserDefaults.standard.set(ids, forKey: Self.completedWorkoutsKey)
    }

    // MARK: - Helpers
    
    /// Helper to map the API response to a 7-day week for the UI calendar
    /// This ensures we always show 7 days (Monday-Sunday) with proper rest day handling
    private func fillRestDays(plan: [WorkoutSession]) -> [WorkoutSession] {
        // Define days in order (API typically uses French day names)
        let daysOfWeek = ["LUNDI", "MARDI", "MERCREDI", "JEUDI", "VENDREDI", "SAMEDI", "DIMANCHE"]
        
        // Map each day
        return daysOfWeek.enumerated().map { index, day in
            // Try to find a workout session for this day from the API
            if let session = plan.first(where: { $0.day.uppercased() == day }) {
                return session
            } else {
                // Create a rest day placeholder
                return WorkoutSession(
                    id: 10000 + index, // Use high ID to avoid conflicts
                    day: day,
                    theme: "Repos", // "Rest" in French
                    warmup: nil,
                    finisher: nil,
                    exercises: nil,
                    is_completed: false,
                    completion_date: nil
                )
            }
        }
    }
}
