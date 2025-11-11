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
        Double(completedWorkouts.count) / Double(max(workoutSessions.filter { $0.theme != "Repos" }.count, 1))
    }

    // MARK: - Initialization
    @MainActor
    init() {
        logger.info("🏋️ WorkoutsViewModel initialized (Preview: \(self.isPreview))")
        
        // Don't make API calls in preview mode
        if isPreview {
            logger.info("⚠️ Running in preview mode - skipping API initialization")
        }
        
        // NOTE: Load completedWorkouts from UserDefaults/API here later
    }
    
    // MARK: - API Methods
    
    /// Fetch workout plan from API
    func fetchWorkoutPlan() async {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchWorkoutPlan() - running in preview mode")
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
            }
            
            logger.info("✅ Successfully fetched \(plan.count) workout sessions")
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            logger.error("❌ Failed to fetch workout plan: \(error.localizedDescription)")
        }
    }
    
    /// Generate new workout plan via API
    func generateNewPlan() async {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping generateNewPlan() - running in preview mode")
            return
        }
        
        logger.info("🎲 Requesting new workout plan generation")
        
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            _ = try await api.generateWorkoutPlan()
            logger.info("✅ Workout plan generation requested")
            
            // Fetch the newly generated plan
            await fetchWorkoutPlan()
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            logger.error("❌ Failed to generate workout plan: \(error.localizedDescription)")
        }
    }
    
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
            logger.info("✅ Workout progress logged to API")
            // Update local UI state
            await MainActor.run {
                self.completedWorkouts.insert(session.id)
            }
        } catch {
            logger.error("❌ Failed to log progress to API: \(error.localizedDescription)")
        }
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
