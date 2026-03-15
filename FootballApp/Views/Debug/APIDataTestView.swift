//
//  APIDataTestView.swift
//  FootballApp
//
//  Debug view to test and display raw API data for Goals and Achievements
//

import SwiftUI
import Combine
import os

struct APIDataTestView: View {
    @StateObject private var viewModel = APIDataTestViewModel()
    @State private var selectedTab = 0
    @State private var showLoginSheet = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                VStack(spacing: 0) {
                    // Auth status banner
                    AuthStatusBanner(viewModel: viewModel, showLoginSheet: $showLoginSheet)

                    // Tab selector
                    HStack(spacing: 0) {
                        ForEach(["Goals", "Achievements", "Leaderboard"], id: \.self) { tab in
                            Button(action: {
                                withAnimation { selectedTab = ["Goals", "Achievements", "Leaderboard"].firstIndex(of: tab) ?? 0 }
                            }) {
                                Text(tab)
                                    .font(.subheadline.weight(selectedTab == ["Goals", "Achievements", "Leaderboard"].firstIndex(of: tab) ? .bold : .medium))
                                    .foregroundColor(selectedTab == ["Goals", "Achievements", "Leaderboard"].firstIndex(of: tab) ? .white : .white.opacity(0.5))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 12)
                                    .background(
                                        selectedTab == ["Goals", "Achievements", "Leaderboard"].firstIndex(of: tab) ?
                                        Color(hex: "4A90E2").opacity(0.3) : Color.clear
                                    )
                            }
                        }
                    }
                    .background(Color.white.opacity(0.05))

                    ScrollView {
                        VStack(spacing: 16) {
                            switch selectedTab {
                            case 0:
                                GoalsDataSection(viewModel: viewModel)
                            case 1:
                                AchievementsDataSection(viewModel: viewModel)
                            case 2:
                                LeaderboardDataSection(viewModel: viewModel)
                            default:
                                EmptyView()
                            }
                        }
                        .padding()
                    }
                }

                if viewModel.isLoading {
                    Color.black.opacity(0.5).ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .navigationTitle("API Data Test")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { showLoginSheet = true }) {
                        HStack(spacing: 4) {
                            Image(systemName: viewModel.isAuthenticated ? "person.fill.checkmark" : "person.fill.xmark")
                            Text(viewModel.isAuthenticated ? "Re-Auth" : "Login")
                                .font(.caption)
                        }
                        .foregroundColor(viewModel.isAuthenticated ? Color(hex: "4ECB71") : .orange)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { Task { await viewModel.refreshAll() } }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                }
            }
            .sheet(isPresented: $showLoginSheet) {
                LoginSheet(viewModel: viewModel, isPresented: $showLoginSheet)
            }
            .task {
                viewModel.checkAuthStatus()
                await viewModel.refreshAll()
            }
        }
    }
}

// MARK: - Auth Status Banner

struct AuthStatusBanner: View {
    @ObservedObject var viewModel: APIDataTestViewModel
    @Binding var showLoginSheet: Bool

    var body: some View {
        HStack {
            Image(systemName: viewModel.isAuthenticated ? "checkmark.shield.fill" : "exclamationmark.shield.fill")
                .foregroundColor(viewModel.isAuthenticated ? Color(hex: "4ECB71") : .orange)

            VStack(alignment: .leading, spacing: 2) {
                Text(viewModel.isAuthenticated ? "Authenticated" : "Not Authenticated")
                    .font(.caption.bold())
                    .foregroundColor(.white)

                if let email = viewModel.currentUserEmail {
                    Text(email)
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                } else if !viewModel.isAuthenticated {
                    Text("Tap Login to authenticate")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()

            if viewModel.isAuthenticated {
                Button(action: { viewModel.logout() }) {
                    Text("Logout")
                        .font(.caption.bold())
                        .foregroundColor(.red)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.2))
                        .cornerRadius(8)
                }
            } else {
                Button(action: { showLoginSheet = true }) {
                    Text("Login")
                        .font(.caption.bold())
                        .foregroundColor(Color(hex: "4A90E2"))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color(hex: "4A90E2").opacity(0.2))
                        .cornerRadius(8)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(viewModel.isAuthenticated ? Color(hex: "4ECB71").opacity(0.1) : Color.orange.opacity(0.1))
    }
}

// MARK: - Login Sheet

struct LoginSheet: View {
    @ObservedObject var viewModel: APIDataTestViewModel
    @Binding var isPresented: Bool

    @State private var email = ""
    @State private var password = ""
    @FocusState private var focusedField: Field?

    enum Field {
        case email, password
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 8) {
                        Image(systemName: "key.fill")
                            .font(.system(size: 50))
                            .foregroundColor(Color(hex: "4A90E2"))

                        Text("API Authentication")
                            .font(.title2.bold())
                            .foregroundColor(.white)

                        Text("Enter your credentials to authenticate API requests")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 20)

                    // Form
                    VStack(spacing: 16) {
                        // Email field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Email")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.7))

                            TextField("your@email.com", text: $email)
                                .textFieldStyle(APITestTextFieldStyle())
                                .textContentType(.emailAddress)
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .focused($focusedField, equals: .email)
                        }

                        // Password field
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Password")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.7))

                            SecureField("Password", text: $password)
                                .textFieldStyle(APITestTextFieldStyle())
                                .textContentType(.password)
                                .focused($focusedField, equals: .password)
                        }

                        // Error message
                        if let error = viewModel.authError {
                            HStack {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(error)
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)

                    // Login button
                    Button(action: {
                        Task {
                            focusedField = nil
                            let success = await viewModel.login(email: email, password: password)
                            if success {
                                isPresented = false
                                await viewModel.refreshAll()
                            }
                        }
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Login & Refresh Data")
                            }
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(canLogin ? Color(hex: "4A90E2") : Color.gray)
                        )
                    }
                    .disabled(!canLogin || viewModel.isLoading)
                    .padding(.horizontal)

                    // Current token status
                    #if DEBUG
                    if APITokenManager.shared.currentToken != nil {
                        VStack(spacing: 4) {
                            Text("Current Token")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.5))
                            Text("••••••••••••••••••••")
                                .font(.caption2.monospaced())
                                .foregroundColor(.white.opacity(0.4))
                        }
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(8)
                        .padding(.horizontal)
                    }
                    #endif

                    Spacer()
                }
            }
            .navigationTitle("Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .foregroundColor(.white.opacity(0.7))
                }
            }
        }
    }

    private var canLogin: Bool {
        !email.isEmpty && !password.isEmpty && email.contains("@")
    }
}

// MARK: - API Test Text Field Style

struct APITestTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(10)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Goals Data Section

struct GoalsDataSection: View {
    @ObservedObject var viewModel: APIDataTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Active Goal
            DataCard(title: "Active Goal", icon: "target") {
                if let goal = viewModel.activeGoal {
                    GoalDataView(goal: goal)
                } else {
                    Text("No active goal")
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // All Goals
            DataCard(title: "All Goals (\(viewModel.allGoals.count))", icon: "list.bullet") {
                if viewModel.allGoals.isEmpty {
                    Text("No goals found")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    ForEach(viewModel.allGoals) { goal in
                        GoalDataView(goal: goal)
                        if goal.id != viewModel.allGoals.last?.id {
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                }
            }

            // Error if any
            if let error = viewModel.goalsError {
                DataCard(title: "Error", icon: "exclamationmark.triangle.fill") {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}

struct GoalDataView: View {
    let goal: Goal

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ID and Type
            HStack {
                DataField(label: "ID", value: "\(goal.id)")
                Spacer()
                DataField(label: "Type", value: goal.goalType.rawValue)
            }

            // Status
            HStack {
                DataField(label: "Status", value: goal.status.rawValue)
                    .foregroundColor(Color(hex: goal.status.color))
                Spacer()
                DataField(label: "Label", value: goal.goalTypeLabel ?? "nil")
            }

            // Progress
            HStack {
                DataField(label: "Progress", value: String(format: "%.1f%%", goal.progress))
                Spacer()
                DataField(label: "Expected", value: goal.expectedProgress != nil ? String(format: "%.1f%%", goal.expectedProgress!) : "nil")
            }

            // On Track
            HStack {
                DataField(label: "Is On Track", value: goal.isOnTrack != nil ? "\(goal.isOnTrack!)" : "nil")
                Spacer()
                DataField(label: "Weeks", value: "\(goal.weeksCompleted ?? 0)/\(goal.totalWeeks ?? 0)")
            }

            // Targets
            VStack(alignment: .leading, spacing: 4) {
                Text("Targets:").font(.caption.bold()).foregroundColor(.white.opacity(0.7))
                HStack {
                    DataField(label: "Weight", value: goal.targetWeight != nil ? String(format: "%.1f", goal.targetWeight!) : "nil")
                    DataField(label: "Waist", value: goal.targetWaist != nil ? String(format: "%.1f", goal.targetWaist!) : "nil")
                    DataField(label: "Workouts/wk", value: goal.targetWorkoutsPerWeek != nil ? "\(goal.targetWorkoutsPerWeek!)" : "nil")
                }
            }

            // Start values
            VStack(alignment: .leading, spacing: 4) {
                Text("Start Values:").font(.caption.bold()).foregroundColor(.white.opacity(0.7))
                HStack {
                    DataField(label: "Weight", value: goal.startWeight != nil ? String(format: "%.1f", goal.startWeight!) : "nil")
                    DataField(label: "Waist", value: goal.startWaist != nil ? String(format: "%.1f", goal.startWaist!) : "nil")
                }
            }

            // Dates
            VStack(alignment: .leading, spacing: 4) {
                Text("Dates:").font(.caption.bold()).foregroundColor(.white.opacity(0.7))
                HStack {
                    DataField(label: "Start", value: goal.startDate ?? "nil")
                    DataField(label: "Target", value: goal.targetDate ?? "nil")
                }
                if let completed = goal.completedAt {
                    DataField(label: "Completed", value: completed)
                }
            }

            // Notes
            if let notes = goal.notes, !notes.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Notes:").font(.caption.bold()).foregroundColor(.white.opacity(0.7))
                    Text(notes)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }
            }

            // Achievements
            if let achievements = goal.achievements, !achievements.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievements:").font(.caption.bold()).foregroundColor(.white.opacity(0.7))
                    Text(achievements.joined(separator: ", "))
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(Color.white.opacity(0.05))
        )
    }
}

// MARK: - Achievements Data Section

struct AchievementsDataSection: View {
    @ObservedObject var viewModel: APIDataTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Summary
            DataCard(title: "Summary", icon: "chart.bar.fill") {
                HStack(spacing: 20) {
                    VStack {
                        Text("\(viewModel.totalEarned)")
                            .font(.title.bold())
                            .foregroundColor(Color(hex: "4ECB71"))
                        Text("Earned")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    VStack {
                        Text("\(viewModel.totalAvailable)")
                            .font(.title.bold())
                            .foregroundColor(.white)
                        Text("Available")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }

                    VStack {
                        Text("\(viewModel.totalPoints)")
                            .font(.title.bold())
                            .foregroundColor(.yellow)
                        Text("Points")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }

            // Earned Achievements
            DataCard(title: "Earned Achievements (\(viewModel.earnedAchievements.count))", icon: "star.fill") {
                if viewModel.earnedAchievements.isEmpty {
                    Text("No achievements earned yet")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    ForEach(viewModel.earnedAchievements) { achievement in
                        AchievementDataView(achievement: achievement, isEarned: true)
                        if achievement.id != viewModel.earnedAchievements.last?.id {
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                }
            }

            // All Achievements
            DataCard(title: "All Achievements (\(viewModel.allAchievements.count))", icon: "list.star") {
                if viewModel.allAchievements.isEmpty {
                    Text("No achievements found")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    ForEach(viewModel.allAchievements) { achievement in
                        AchievementDataView(achievement: achievement, isEarned: achievement.earned ?? false)
                        if achievement.id != viewModel.allAchievements.last?.id {
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                }
            }

            // Error if any
            if let error = viewModel.achievementsError {
                DataCard(title: "Error", icon: "exclamationmark.triangle.fill") {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}

struct AchievementDataView: View {
    let achievement: Achievement
    let isEarned: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // ID, Key, Name
            HStack {
                DataField(label: "ID", value: "\(achievement.id)")
                Spacer()
                DataField(label: "Key", value: achievement.key)
            }

            HStack {
                Text(achievement.name)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                Spacer()
                if isEarned {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "4ECB71"))
                }
            }

            // Description
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))

            // Category and Points
            HStack {
                DataField(label: "Category", value: achievement.category.rawValue)
                Spacer()
                DataField(label: "Points", value: "\(achievement.points)")
            }

            // Icon
            HStack {
                DataField(label: "Icon", value: achievement.icon ?? "nil")
                Spacer()
                DataField(label: "Earned By", value: achievement.earnedByCount != nil ? "\(achievement.earnedByCount!) users" : "nil")
            }

            // Earned date
            if let earnedAt = achievement.earnedAt {
                DataField(label: "Earned At", value: earnedAt)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(isEarned ? Color(hex: "4ECB71").opacity(0.1) : Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isEarned ? Color(hex: "4ECB71").opacity(0.3) : Color.clear, lineWidth: 1)
                )
        )
    }
}

// MARK: - Leaderboard Data Section

struct LeaderboardDataSection: View {
    @ObservedObject var viewModel: APIDataTestViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Current User Rank
            DataCard(title: "Your Rank", icon: "person.fill") {
                if let rank = viewModel.currentUserRank {
                    HStack(spacing: 20) {
                        VStack {
                            Text("#\(rank.rank)")
                                .font(.title.bold())
                                .foregroundColor(Color(hex: "4A90E2"))
                            Text("Rank")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        VStack {
                            Text("\(rank.totalPoints)")
                                .font(.title.bold())
                                .foregroundColor(.yellow)
                            Text("Points")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }

                        VStack {
                            Text("\(rank.achievementCount)")
                                .font(.title.bold())
                                .foregroundColor(Color(hex: "4ECB71"))
                            Text("Achievements")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                } else {
                    Text("No rank data")
                        .foregroundColor(.white.opacity(0.5))
                }
            }

            // Leaderboard
            DataCard(title: "Leaderboard (\(viewModel.leaderboard.count))", icon: "trophy.fill") {
                if viewModel.leaderboard.isEmpty {
                    Text("No leaderboard data")
                        .foregroundColor(.white.opacity(0.5))
                } else {
                    ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                        LeaderboardEntryDataView(entry: entry, rank: index + 1)
                        if index < viewModel.leaderboard.count - 1 {
                            Divider().background(Color.white.opacity(0.2))
                        }
                    }
                }
            }

            // Error if any
            if let error = viewModel.leaderboardError {
                DataCard(title: "Error", icon: "exclamationmark.triangle.fill") {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
        }
    }
}

struct LeaderboardEntryDataView: View {
    let entry: LeaderboardEntry
    let rank: Int

    var body: some View {
        HStack(spacing: 12) {
            // Rank
            Text("#\(rank)")
                .font(.headline.bold())
                .foregroundColor(rank <= 3 ? .yellow : .white)
                .frame(width: 40)

            // User info
            VStack(alignment: .leading, spacing: 2) {
                HStack {
                    DataField(label: "User ID", value: "\(entry.userId)")
                    Spacer()
                    Text(entry.name)
                        .font(.subheadline.bold())
                        .foregroundColor(.white)
                }
                HStack {
                    DataField(label: "Points", value: "\(entry.totalPoints)")
                    Spacer()
                    DataField(label: "Achievements", value: "\(entry.achievementCount)")
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10)
                .fill(rank <= 3 ? Color.yellow.opacity(0.1) : Color.white.opacity(0.05))
        )
    }
}

// MARK: - Helper Views

struct DataCard<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4A90E2"))
                Text(title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
            }

            content
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color(hex: "4A90E2").opacity(0.2), lineWidth: 1)
                )
        )
    }
}

struct DataField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
            Text(value)
                .font(.caption.bold())
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

// MARK: - ViewModel

@MainActor
class APIDataTestViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "APIDataTest")

    // Goals
    @Published var activeGoal: Goal?
    @Published var allGoals: [Goal] = []
    @Published var goalsError: String?

    // Achievements
    @Published var allAchievements: [Achievement] = []
    @Published var earnedAchievements: [Achievement] = []
    @Published var totalPoints: Int = 0
    @Published var totalEarned: Int = 0
    @Published var totalAvailable: Int = 0
    @Published var achievementsError: String?

    // Leaderboard
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var currentUserRank: CurrentUserRank?
    @Published var leaderboardError: String?

    @Published var isLoading = false

    // Authentication
    @Published var isAuthenticated: Bool = false
    @Published var authError: String?
    @Published var currentUserEmail: String?

    func checkAuthStatus() {
        isAuthenticated = APITokenManager.shared.currentToken != nil && !APITokenManager.shared.currentToken!.isEmpty
    }

    func login(email: String, password: String) async -> Bool {
        authError = nil
        isLoading = true

        do {
            let response = try await APIService.shared.login(email: email, password: password)
            APITokenManager.shared.currentToken = response.token
            currentUserEmail = email
            isAuthenticated = true
            logger.info("✅ Login successful for \(email)")
            isLoading = false
            return true
        } catch let error as APIError {
            authError = error.message
            logger.error("❌ Login failed: \(error.message)")
        } catch {
            authError = error.localizedDescription
            logger.error("❌ Login failed: \(error.localizedDescription)")
        }

        isLoading = false
        return false
    }

    func logout() {
        APITokenManager.shared.currentToken = nil
        isAuthenticated = false
        currentUserEmail = nil

        // Clear all data
        activeGoal = nil
        allGoals = []
        allAchievements = []
        earnedAchievements = []
        leaderboard = []
        currentUserRank = nil
        totalPoints = 0
        totalEarned = 0
        totalAvailable = 0

        logger.info("✅ Logged out successfully")
    }

    func refreshAll() async {
        isLoading = true

        await fetchGoals()
        await fetchAchievements()
        await fetchLeaderboard()

        isLoading = false
    }

    func fetchGoals() async {
        goalsError = nil

        do {
            // Fetch all goals
            allGoals = try await APIService.shared.getAllGoals()
            logger.info("Fetched \(self.allGoals.count) goals")

            // Log raw data
            for goal in allGoals {
                logger.debug("""
                Goal ID: \(goal.id)
                  - Type: \(goal.goalType.rawValue)
                  - Status: \(goal.status.rawValue)
                  - Progress: \(goal.progress)%
                  - Expected: \(goal.expectedProgress ?? -1)%
                  - IsOnTrack: \(String(describing: goal.isOnTrack))
                  - WeeksCompleted: \(goal.weeksCompleted ?? -1)/\(goal.totalWeeks ?? -1)
                """)
            }
        } catch {
            logger.error("Failed to fetch all goals: \(error.localizedDescription)")
            goalsError = "All Goals: \(error.localizedDescription)"
        }

        do {
            // Fetch active goal
            activeGoal = try await APIService.shared.getActiveGoal()
            if let goal = activeGoal {
                logger.info("Active goal: \(goal.id) - \(goal.goalType.rawValue)")
            } else {
                logger.info("No active goal")
            }
        } catch {
            logger.error("Failed to fetch active goal: \(error.localizedDescription)")
            if goalsError != nil {
                goalsError! += "\nActive Goal: \(error.localizedDescription)"
            } else {
                goalsError = "Active Goal: \(error.localizedDescription)"
            }
        }
    }

    func fetchAchievements() async {
        achievementsError = nil

        do {
            // Fetch all achievements
            let data = try await APIService.shared.getAllAchievements()
            allAchievements = data.achievements
            totalPoints = data.totalPoints
            totalEarned = data.totalEarned
            totalAvailable = data.totalAvailable

            logger.info("""
            Achievements Summary:
              - Total: \(data.totalAvailable)
              - Earned: \(data.totalEarned)
              - Points: \(data.totalPoints)
            """)

            // Log each achievement
            for achievement in allAchievements {
                logger.debug("""
                Achievement ID: \(achievement.id)
                  - Key: \(achievement.key)
                  - Name: \(achievement.name)
                  - Category: \(achievement.category.rawValue)
                  - Points: \(achievement.points)
                  - Earned: \(achievement.earned ?? false)
                  - Icon: \(achievement.icon ?? "nil")
                """)
            }
        } catch {
            logger.error("Failed to fetch all achievements: \(error.localizedDescription)")
            achievementsError = "All Achievements: \(error.localizedDescription)"
        }

        do {
            // Fetch earned achievements
            earnedAchievements = try await APIService.shared.getEarnedAchievements()
            logger.info("Fetched \(self.earnedAchievements.count) earned achievements")
        } catch {
            logger.error("Failed to fetch earned achievements: \(error.localizedDescription)")
            if achievementsError != nil {
                achievementsError! += "\nEarned: \(error.localizedDescription)"
            } else {
                achievementsError = "Earned: \(error.localizedDescription)"
            }
        }
    }

    func fetchLeaderboard() async {
        leaderboardError = nil

        do {
            let data = try await APIService.shared.getLeaderboard(limit: 10)
            leaderboard = data.leaderboard
            currentUserRank = data.currentUser

            logger.info("""
            Leaderboard:
              - Entries: \(data.leaderboard.count)
              - Your Rank: #\(data.currentUser.rank)
              - Your Points: \(data.currentUser.totalPoints)
            """)

            // Log each entry
            for (index, entry) in leaderboard.enumerated() {
                logger.debug("""
                #\(index + 1): \(entry.name)
                  - User ID: \(entry.userId)
                  - Points: \(entry.totalPoints)
                  - Achievements: \(entry.achievementCount)
                """)
            }
        } catch {
            logger.error("Failed to fetch leaderboard: \(error.localizedDescription)")
            leaderboardError = error.localizedDescription
        }
    }
}

// MARK: - Preview

#Preview {
    APIDataTestView()
        .preferredColorScheme(.dark)
}
