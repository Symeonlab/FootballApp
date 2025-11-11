//
//  ProfileView.swift
//  FootballApp - Dipodi
//
//  Dark blue themed profile with improved UI
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    @State private var showingLogMeasurement = false
    @State private var showingReminders = false
    @State private var showingBlog = false
    @State private var showingEditProfile = false
    @State private var showingAchievements = false

    var body: some View {
        NavigationView {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Enhanced User Header with Edit
                        EnhancedProfileHeaderCard(
                            user: authViewModel.currentUser,
                            profileViewModel: profileViewModel,
                            onEditProfile: { showingEditProfile = true }
                        )
                        .padding(.horizontal)
                        
                        // Achievements Section
                        AchievementsCard(
                            viewModel: profileViewModel,
                            onViewAll: { showingAchievements = true }
                        )
                        .padding(.horizontal)
                        
                        // Today's Activity from HealthKit
                        ActivityStatsCard(viewModel: profileViewModel)
                            .padding(.horizontal)
                        
                        // Quick Actions
                        QuickActionsCard(
                            onLogMeasurement: { showingLogMeasurement = true },
                            onSetReminder: { showingReminders = true },
                            onOpenBlog: { showingBlog = true }
                        )
                        .padding(.horizontal)
                        
                        // Progress Chart
                        ProgressChartCard(viewModel: profileViewModel)
                            .padding(.horizontal)
                        
                        // Recent Progress Logs
                        RecentProgressCard(viewModel: profileViewModel)
                            .padding(.horizontal)
                        
                        // Plan Management Section
                        PlanManagementCard(authViewModel: authViewModel)
                            .padding(.horizontal)
                        
                        // Settings Section
                        SettingsCard(
                            languageManager: languageManager,
                            themeManager: themeManager
                        )
                        .padding(.horizontal)
                        
                        // Sign Out Button
                        Button(role: .destructive, action: {
                            authViewModel.signOut()
                        }) {
                            Label("profile.sign_out", systemImage: "rectangle.portrait.and.arrow.right")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                                        .fill(Color.red.opacity(0.15))
                                )
                                .foregroundColor(.red)
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("Profile - Dipodi")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingLogMeasurement) {
                MeasurementLogView(viewModel: profileViewModel)
            }
            .sheet(isPresented: $showingReminders) {
                if let settings = profileViewModel.reminderSettings {
                    ReminderSettingsView(viewModel: profileViewModel, settings: settings)
                }
            }
            .sheet(isPresented: $showingBlog) {
                BlogPostListView()
            }
            .sheet(isPresented: $showingEditProfile) {
                EditProfileView(viewModel: profileViewModel)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView(viewModel: profileViewModel)
            }
            .onAppear {
                profileViewModel.fetchProgressLogs()
                profileViewModel.fetchHealthData()
            }
            .refreshable {
                profileViewModel.fetchProgressLogs()
                profileViewModel.fetchHealthData()
            }
        }
    }
}

// MARK: - Dark Card Background Style
extension View {
    func darkBlueCard() -> some View {
        self
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1C2951").opacity(0.7) as Color,
                                Color(hex: "0F1B3D").opacity(0.8) as Color
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "4A90E2").opacity(0.3),
                                        Color(hex: "357ABD").opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
                    .shadow(color: Color.black.opacity(0.3), radius: 15, x: 0, y: 8)
            )
    }
}

// MARK: - Enhanced Profile Header Card
struct EnhancedProfileHeaderCard: View {
    let user: APIUser?
    @ObservedObject var profileViewModel: ProfileViewModel
    let onEditProfile: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Avatar with gradient border
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color(hex: "4A90E2"),
                                    Color(hex: "357ABD")
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 88, height: 88)
                    
                    Circle()
                        .fill(Color(hex: "1C2951"))
                        .frame(width: 84, height: 84)
                    
                    Text(user?.name?.prefix(1).uppercased() ?? "?")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "7EC8E3")],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                
                // User Info
                VStack(alignment: .leading, spacing: 6) {
                    Text(user?.name ?? "Guest")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    
                    Text(user?.email ?? "No email")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(1)
                    
                    if let weight = profileViewModel.latestWeight {
                        HStack(spacing: 4) {
                            Image(systemName: "figure.stand")
                                .font(.caption)
                            Text(String(format: "%.1f kg", weight))
                                .font(.caption.bold())
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
                
                Spacer()
            }
            
            // Edit Profile Button
            Button(action: onEditProfile) {
                HStack {
                    Image(systemName: "pencil")
                    Text("Edit Profile")
                        .font(.subheadline.weight(.semibold))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "357ABD")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                )
            }
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Achievements Card
struct AchievementsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onViewAll: () -> Void
    
    let achievements = [
        ("flame.fill", "7 Day Streak", Color.orange),
        ("trophy.fill", "10 Workouts", Color.yellow),
        ("star.fill", "Goal Master", Color.purple)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                Text("Achievements")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
                Button(action: onViewAll) {
                    Text("View All")
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }
            
            HStack(spacing: 12) {
                ForEach(achievements, id: \.1) { achievement in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(achievement.2.opacity(0.2))
                                .frame(width: 60, height: 60)
                            
                            Image(systemName: achievement.0)
                                .font(.title2)
                                .foregroundColor(achievement.2)
                        }
                        
                        Text(achievement.1)
                            .font(.caption2.weight(.medium))
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Activity Stats Card
struct ActivityStatsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "heart.circle.fill")
                    .font(.title3)
                    .foregroundColor(.red)
                Text("Today's Activity")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
                Image(systemName: "applelogo")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 12) {
                ActivityStatItem(
                    icon: "figure.walk",
                    value: viewModel.stepsToday != nil ? "\(viewModel.stepsToday!)" : "–",
                    label: "Steps",
                    color: Color(hex: "4A90E2")
                )
                
                ActivityStatItem(
                    icon: "flame.fill",
                    value: viewModel.caloriesToday != nil ? "\(viewModel.caloriesToday!)" : "–",
                    label: "kcal",
                    color: .orange
                )
            }
        }
        .padding()
        .darkBlueCard()
    }
}

struct ActivityStatItem: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(.white)
                Text(label)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(hex: "0F1B3D").opacity(0.6))
        )
    }
}

// MARK: - Quick Actions Card
struct QuickActionsCard: View {
    let onLogMeasurement: () -> Void
    let onSetReminder: () -> Void
    let onOpenBlog: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "square.and.pencil",
                    title: "Log",
                    color: Color(hex: "4A90E2"),
                    action: onLogMeasurement
                )
                
                QuickActionButton(
                    icon: "bell.fill",
                    title: "Reminders",
                    color: Color(hex: "9D4EDD"),
                    action: onSetReminder
                )
                
                QuickActionButton(
                    icon: "book.fill",
                    title: "Blog",
                    color: Color(hex: "7EC8E3"),
                    action: onOpenBlog
                )
            }
        }
        .padding()
        .darkBlueCard()
    }
}

struct QuickActionButton: View {
    let icon: String
    let title: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                Text(title)
                    .font(.caption.bold())
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color(hex: "0F1B3D").opacity(0.6))
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Chart Card
struct ProgressChartCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var recentLogs: [UserProgress] {
        Array(viewModel.progressLogs.prefix(7).reversed())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Weight Progress (7 Days)")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            if recentLogs.isEmpty {
                Text("No progress data yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            } else {
                SimpleLineChart(data: recentLogs.compactMap { $0.weight })
                    .frame(height: 120)
            }
        }
        .padding()
        .darkBlueCard()
    }
}

// Simple line chart for weight progress
struct SimpleLineChart: View {
    let data: [Double]
    
    var body: some View {
        GeometryReader { geometry in
            let maxValue = data.max() ?? 100
            let minValue = data.min() ?? 0
            let range = maxValue - minValue
            let step = geometry.size.width / CGFloat(max(data.count - 1, 1))
            
            ZStack {
                // Grid lines
                ForEach(0..<5) { i in
                    Path { path in
                        let y = geometry.size.height * CGFloat(i) / 4
                        path.move(to: CGPoint(x: 0, y: y))
                        path.addLine(to: CGPoint(x: geometry.size.width, y: y))
                    }
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
                
                // Line chart
                Path { path in
                    for (index, value) in data.enumerated() {
                        let x = CGFloat(index) * step
                        let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                        let y = geometry.size.height * (1 - normalizedValue)
                        
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(
                    LinearGradient(
                        colors: [Color(hex: "4A90E2"), Color(hex: "7EC8E3")],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round)
                )
                
                // Data points
                ForEach(Array(data.enumerated()), id: \.offset) { index, value in
                    let x = CGFloat(index) * step
                    let normalizedValue = range > 0 ? (value - minValue) / range : 0.5
                    let y = geometry.size.height * (1 - normalizedValue)
                    
                    Circle()
                        .fill(Color(hex: "4A90E2"))
                        .frame(width: 8, height: 8)
                        .position(x: x, y: y)
                }
            }
        }
    }
}

// MARK: - Recent Progress Card
struct RecentProgressCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Measurements")
                .font(.headline.bold())
                .foregroundColor(.white)
            
            if viewModel.progressLogs.isEmpty {
                Text("No measurements yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(viewModel.progressLogs.prefix(3)) { log in
                        ProgressLogRow(log: log)
                    }
                }
            }
        }
        .padding()
        .darkBlueCard()
    }
}

struct ProgressLogRow: View {
    let log: UserProgress
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(log.date)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
                
                HStack(spacing: 12) {
                    if let weight = log.weight {
                        Label("\(weight, specifier: "%.1f") kg", systemImage: "figure.stand")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    if let waist = log.waist {
                        Label("\(waist, specifier: "%.0f") cm", systemImage: "ruler")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            if let mood = log.mood, !mood.isEmpty {
                Text(mood)
                    .font(.title3)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color(hex: "0F1B3D").opacity(0.6))
        )
    }
}

// MARK: - Plan Management Card
struct PlanManagementCard: View {
    @ObservedObject var authViewModel: AuthViewModel
    @State private var showingConfirmation = false
    @State private var selectedAction: PlanAction?
    
    enum PlanAction {
        case workout, nutrition, onboarding
        
        var title: String {
            switch self {
            case .workout: return "Regenerate Workout Plan"
            case .nutrition: return "Regenerate Nutrition Plan"
            case .onboarding: return "Restart Onboarding"
            }
        }
        
        var message: String {
            switch self {
            case .workout: return "This will create a new personalized workout plan based on your current profile."
            case .nutrition: return "This will create a new personalized nutrition plan based on your current goals."
            case .onboarding: return "This will reset your profile and take you through the setup process again."
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Plan Management")
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Regenerate Workout Plan
            Button(action: {
                selectedAction = .workout
                showingConfirmation = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Regenerate Workout Plan")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Get a fresh workout routine")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(hex: "4A90E2"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)
            
            // Regenerate Nutrition Plan
            Button(action: {
                selectedAction = .nutrition
                showingConfirmation = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.green.opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.green)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Regenerate Nutrition Plan")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Get personalized meal recommendations")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "arrow.clockwise")
                        .foregroundColor(Color(hex: "4A90E2"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)
            
            // Restart Onboarding
            Button(action: {
                selectedAction = .onboarding
                showingConfirmation = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color(hex: "4A90E2").opacity(0.2))
                            .frame(width: 44, height: 44)
                        
                        Image(systemName: "arrow.counterclockwise")
                            .font(.system(size: 20))
                            .foregroundColor(Color(hex: "4A90E2"))
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Restart Onboarding")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)
                        
                        Text("Update your profile & preferences")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .foregroundColor(Color(hex: "4A90E2"))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .darkBlueCard()
        .alert("Confirm Action", isPresented: $showingConfirmation, presenting: selectedAction) { action in
            Button("Cancel", role: .cancel) { }
            Button("Confirm", role: .destructive) {
                performAction(action)
            }
        } message: { action in
            Text(action.message)
        }
    }
    
    private func performAction(_ action: PlanAction) {
        switch action {
        case .workout:
            Task {
                do {
                    let _: APIResponseMessage = try await APIService.shared.generateWorkoutPlan()
                } catch {
                    print("Error generating workout plan: \(error)")
                }
            }
            
        case .nutrition:
            print("Regenerating nutrition plan...")
            
        case .onboarding:
            Task {
                if let _ = authViewModel.currentUser?.id {
                    authViewModel.appState = .onboarding
                }
            }
        }
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    @ObservedObject var languageManager: LanguageManager
    @ObservedObject var themeManager: ThemeManager
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Settings")
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // Language Picker
            HStack {
                Image(systemName: "globe")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .frame(width: 30)
                Text("Language")
                    .foregroundColor(.white)
                Spacer()
                Picker("", selection: $languageManager.selected) {
                    ForEach(AppLanguage.allCases) { language in
                        Text(language.localizedDisplayNameWithFlag).tag(language)
                    }
                }
                .pickerStyle(.menu)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: "0F1B3D").opacity(0.6))
            )
            
            // Theme Picker
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(Color(hex: "4A90E2"))
                    .frame(width: 30)
                Text("Appearance")
                    .foregroundColor(.white)
                Spacer()
                Text("Dark")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color(hex: "0F1B3D").opacity(0.6))
            )
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Supporting Views (simplified)
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("Edit Profile Coming Soon")
    }
}

struct AchievementsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Text("All Achievements Coming Soon")
    }
}


