//
//  AchievementsViewModel.swift
//  FootballApp
//
//  ViewModel for managing user achievements and leaderboard
//

import Foundation
import Combine
import os

@MainActor
class AchievementsViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "AchievementsViewModel")

    // MARK: - Published Properties
    @Published var achievements: [Achievement] = []
    @Published var earnedAchievements: [Achievement] = []
    @Published var achievementsByCategory: [String: [Achievement]] = [:]
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var currentUserRank: CurrentUserRank?
    @Published var totalPoints: Int = 0
    @Published var totalEarned: Int = 0
    @Published var totalAvailable: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedCategory: AchievementCategory?

    // MARK: - Computed Properties
    var earnedPercentage: Double {
        guard totalAvailable > 0 else { return 0 }
        return Double(totalEarned) / Double(totalAvailable) * 100
    }

    var filteredAchievements: [Achievement] {
        if let category = selectedCategory {
            return achievements.filter { $0.category == category }
        }
        return achievements
    }

    var recentlyEarned: [Achievement] {
        earnedAchievements
            .sorted { ($0.earnedAt ?? "") > ($1.earnedAt ?? "") }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Fetch Methods

    func fetchAllAchievements() async {
        isLoading = true
        errorMessage = nil

        do {
            let data = try await APIService.shared.getAllAchievements()
            achievements = data.achievements
            achievementsByCategory = data.byCategory ?? [:]
            totalPoints = data.totalPoints
            totalEarned = data.totalEarned
            totalAvailable = data.totalAvailable

            logger.info("Fetched \(data.achievements.count) achievements, \(data.totalEarned) earned")
        } catch {
            logger.error("Failed to fetch achievements: \(error.localizedDescription)")
            errorMessage = "achievements.error.fetch_failed".localizedString
        }

        isLoading = false
    }

    func fetchEarnedAchievements() async {
        do {
            earnedAchievements = try await APIService.shared.getEarnedAchievements()
            logger.info("Fetched \(self.earnedAchievements.count) earned achievements")
        } catch {
            logger.error("Failed to fetch earned achievements: \(error.localizedDescription)")
        }
    }

    func fetchLeaderboard(limit: Int = 10) async {
        do {
            let data = try await APIService.shared.getLeaderboard(limit: limit)
            leaderboard = data.leaderboard
            currentUserRank = data.currentUser
            logger.info("Fetched leaderboard with \(self.leaderboard.count) entries")
        } catch {
            logger.error("Failed to fetch leaderboard: \(error.localizedDescription)")
        }
    }

    func refreshData() async {
        await fetchAllAchievements()
        await fetchEarnedAchievements()
        await fetchLeaderboard()
    }

    // MARK: - Helpers

    func categoryIcon(_ category: AchievementCategory) -> String {
        switch category {
        case .workout: return "figure.run"
        case .consistency: return "flame.fill"
        case .milestone: return "flag.fill"
        case .nutrition: return "leaf.fill"
        case .special: return "star.fill"
        }
    }

    func categoryColor(_ category: AchievementCategory) -> String {
        switch category {
        case .workout: return "FF6B6B"
        case .consistency: return "FF9F43"
        case .milestone: return "4ECB71"
        case .nutrition: return "4A90E2"
        case .special: return "A06CD5"
        }
    }
}
