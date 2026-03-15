//
//  GoalsViewModel.swift
//  FootballApp
//
//  ViewModel for managing user goals
//

import Foundation
import Combine
import os

@MainActor
class GoalsViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "GoalsViewModel")

    // MARK: - Published Properties
    @Published var goals: [Goal] = []
    @Published var activeGoal: Goal?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingCreateGoal = false

    // MARK: - Create Goal Form
    @Published var selectedGoalType: GoalType = .weightLoss
    @Published var targetWeight: String = ""
    @Published var targetWaist: String = ""
    @Published var targetWorkoutsPerWeek: Int = 3
    @Published var totalWeeks: Int = 12
    @Published var notes: String = ""

    // MARK: - Computed Properties
    var completedGoals: [Goal] {
        goals.filter { $0.status == .completed }
    }

    var pausedGoals: [Goal] {
        goals.filter { $0.status == .paused }
    }

    var hasActiveGoal: Bool {
        activeGoal != nil
    }

    // MARK: - Fetch Methods

    func fetchAllGoals() async {
        isLoading = true
        errorMessage = nil

        do {
            goals = try await APIService.shared.getAllGoals()
            logger.info("Fetched \(self.goals.count) goals")
        } catch {
            logger.error("Failed to fetch goals: \(error.localizedDescription)")
            errorMessage = "goals.error.fetch_failed".localizedString
        }

        isLoading = false
    }

    func fetchActiveGoal() async {
        do {
            activeGoal = try await APIService.shared.getActiveGoal()
            if let goal = activeGoal {
                logger.info("Active goal: \(goal.goalType.rawValue) at \(goal.progress)%")
            } else {
                logger.info("No active goal found")
            }
        } catch {
            logger.error("Failed to fetch active goal: \(error.localizedDescription)")
        }
    }

    func refreshData() async {
        await fetchAllGoals()
        await fetchActiveGoal()
    }

    // MARK: - Create Goal

    func createGoal() async -> Bool {
        isLoading = true
        errorMessage = nil

        let request = CreateGoalRequest(
            goalType: selectedGoalType.rawValue,
            targetWeight: Double(targetWeight),
            targetWaist: Double(targetWaist),
            targetChest: nil,
            targetHips: nil,
            targetWorkoutsPerWeek: targetWorkoutsPerWeek,
            totalWeeks: totalWeeks,
            targetDate: nil,
            notes: notes.isEmpty ? nil : notes
        )

        do {
            let newGoal = try await APIService.shared.createGoal(request)
            goals.insert(newGoal, at: 0)
            activeGoal = newGoal
            logger.info("Created new goal: \(newGoal.id)")
            resetForm()
            isLoading = false
            return true
        } catch {
            logger.error("Failed to create goal: \(error.localizedDescription)")
            errorMessage = "goals.error.create_failed".localizedString
            isLoading = false
            return false
        }
    }

    // MARK: - Update Goal

    func updateGoalProgress(goalId: Int) async {
        do {
            let progressData = try await APIService.shared.updateGoalProgress(goalId: goalId)

            // Update local state if goal exists
            if goals.contains(where: { $0.id == goalId }) {
                // Refresh the goal from the server
                await fetchAllGoals()
            }

            if activeGoal?.id == goalId {
                await fetchActiveGoal()
            }

            // Check for new achievements
            if let newAchievements = progressData.newAchievements, !newAchievements.isEmpty {
                logger.info("New achievements earned: \(newAchievements.joined(separator: ", "))")
            }

            logger.info("Updated goal progress: \(progressData.progress)%")
        } catch {
            logger.error("Failed to update goal progress: \(error.localizedDescription)")
            errorMessage = "goals.error.update_failed".localizedString
        }
    }

    func updateGoalStatus(goalId: Int, status: GoalStatus) async {
        do {
            try await APIService.shared.updateGoalStatus(goalId: goalId, status: status)

            // Update local state if goal exists
            if goals.contains(where: { $0.id == goalId }) {
                await fetchAllGoals()
            }

            if activeGoal?.id == goalId && status != .active {
                activeGoal = nil
            }

            logger.info("Updated goal \(goalId) status to \(status.rawValue)")
        } catch {
            logger.error("Failed to update goal status: \(error.localizedDescription)")
            errorMessage = "goals.error.status_update_failed".localizedString
        }
    }

    func pauseGoal(_ goal: Goal) async {
        await updateGoalStatus(goalId: goal.id, status: .paused)
    }

    func resumeGoal(_ goal: Goal) async {
        await updateGoalStatus(goalId: goal.id, status: .active)
    }

    func abandonGoal(_ goal: Goal) async {
        await updateGoalStatus(goalId: goal.id, status: .abandoned)
    }

    // MARK: - Form Helpers

    func resetForm() {
        selectedGoalType = .weightLoss
        targetWeight = ""
        targetWaist = ""
        targetWorkoutsPerWeek = 3
        totalWeeks = 12
        notes = ""
    }
}
