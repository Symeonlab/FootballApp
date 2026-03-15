//
//  ProfileView.swift
//  FootballApp - DiPODDI
//
//  Dark blue themed profile with improved UI
//

import SwiftUI
import os.log

struct ProfileView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @EnvironmentObject var themeManager: ThemeManager
    
    // Logger for ProfileView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ProfileView")
    
    @State private var showingLogMeasurement = false
    @State private var showingReminders = false
    @State private var showingBlog = false
    @State private var showingEditProfile = false
    @State private var showingAchievements = false
    @State private var showingGoals = false
    @State private var showingAPITest = false
    @State private var showingFeedback = false
    @State private var showingSleep = false
    @State private var showingPropheticMedicine = false
    @State private var showingPrivacyPolicy = false
    @State private var showingDeleteAccount = false
    @State private var showingExportConfirmation = false

    var body: some View {
        NavigationStack {
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
                        
                        // Active Goal Section
                        ActiveGoalCard(onViewAll: { showingGoals = true })
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
                            onOpenBlog: { showingBlog = true },
                            onOpenFeedback: { showingFeedback = true }
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
                        
                        // Recovery & Wellness Section
                        RecoveryWellnessCard(
                            onOpenSleep: { showingSleep = true },
                            onOpenPropheticMedicine: { showingPropheticMedicine = true }
                        )
                        .padding(.horizontal)

                        // Settings Section
                        SettingsCard(
                            languageManager: languageManager,
                            themeManager: themeManager
                        )
                        .padding(.horizontal)

                        // Debug Section (for development)
                        #if DEBUG
                        DebugCard(onAPITest: { showingAPITest = true })
                            .padding(.horizontal)
                        #endif

                        // Privacy & Data Section (GDPR)
                        PrivacyDataCard(
                            onPrivacyPolicy: { showingPrivacyPolicy = true },
                            onExportData: { showingExportConfirmation = true },
                            onDeleteAccount: { showingDeleteAccount = true }
                        )
                        .padding(.horizontal)

                        // Sign Out Button
                        SignOutButton(authViewModel: authViewModel)
                        .padding(.horizontal)
                        .padding(.bottom, 100)
                    }
                    .padding(.top, 10)
                }
            }
            .navigationTitle("profile.dipodi".localized)
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
            .sheet(isPresented: $showingGoals) {
                GoalsView()
            }
            .sheet(isPresented: $showingFeedback) {
                FeedbackView()
                    .environmentObject(authViewModel)
            }
            .sheet(isPresented: $showingSleep) {
                SleepView()
            }
            .sheet(isPresented: $showingPropheticMedicine) {
                PropheticMedicineView()
            }
            .sheet(isPresented: $showingPrivacyPolicy) {
                PrivacyPolicyView()
            }
            .sheet(isPresented: $showingDeleteAccount) {
                DeleteAccountView()
                    .environmentObject(authViewModel)
            }
            .alert("profile.export_data".localizedString, isPresented: $showingExportConfirmation) {
                Button("common.ok".localizedString, role: .cancel) {}
            } message: {
                Text("profile.export_data_message".localizedString)
            }
            #if DEBUG
            .sheet(isPresented: $showingAPITest) {
                APIDataTestView()
            }
            #endif
            .task {
                logger.info("👁️ ProfileView: Task triggered")

                // Log current user info
                if let user = authViewModel.currentUser {
                    logger.info("👤 ProfileView: User loaded")
                    let userName = user.name ?? "Unknown"
                    logger.info("   - Name: \(userName)")
                    logger.info("   - Email: \(user.email)")
                    if let profile = user.profile {
                        let goal = profile.goal ?? "N/A"
                        let activityLevel = profile.activity_level ?? "N/A"
                        logger.debug("   - Profile exists: goal=\(goal), activity=\(activityLevel)")
                    } else {
                        logger.warning("   - No profile data available")
                    }
                } else {
                    logger.warning("⚠️ ProfileView: No user data available")
                }

                // Fetch data using async
                logger.info("📥 ProfileView: Fetching profile data...")
                await profileViewModel.fetchAllDataAsync()

                // Log after fetch
                logger.info("📊 ProfileView: Profile data state:")
                logger.info("   - Progress logs: \(profileViewModel.progressLogs.count)")
                logger.info("   - Steps today: \(profileViewModel.stepsToday ?? 0)")
                logger.info("   - Calories today: \(profileViewModel.caloriesToday ?? 0)")
                logger.info("   - Latest weight: \(profileViewModel.latestWeight ?? 0.0)")

                if let error = profileViewModel.errorMessage {
                    logger.error("❌ ProfileView: Error - \(error)")
                } else {
                    logger.info("✅ ProfileView: Data loaded successfully")
                }
            }
            .refreshable {
                logger.info("🔄 ProfileView: Pull-to-refresh triggered")
                await profileViewModel.fetchAllDataAsync()
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
                    Text(user?.name ?? "profile.guest".localizedString)
                        .font(.title2.bold())
                        .foregroundColor(.white)

                    Text(user?.email ?? "profile.no_email".localizedString)
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
                    Text("profile.edit_profile".localizedString)
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

// MARK: - Active Goal Card (Profile)
struct ActiveGoalCard: View {
    let onViewAll: () -> Void
    @StateObject private var goalsVM = GoalsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "target")
                    .font(.title3)
                    .foregroundColor(Color(hex: "4ECB71"))
                Text("goals.current".localizedString)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
                Button(action: onViewAll) {
                    Text("common.view_all".localizedString)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }

            if let goal = goalsVM.activeGoal {
                VStack(alignment: .leading, spacing: 12) {
                    // Goal type and status
                    HStack {
                        Text(goal.goalType.displayName)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)

                        Spacer()

                        // On track indicator
                        HStack(spacing: 4) {
                            Circle()
                                .fill(goal.isOnTrack == true ? Color.green : Color.orange)
                                .frame(width: 6, height: 6)
                            Text(goal.isOnTrack == true ? "goals.on_track".localizedString : "goals.behind".localizedString)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(goal.isOnTrack == true ? .green : .orange)
                        }
                    }

                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.white.opacity(0.1))
                                .frame(height: 8)

                            RoundedRectangle(cornerRadius: 4)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "4A90E2"), Color(hex: "4ECB71")],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geometry.size.width * CGFloat(goal.progress / 100), height: 8)
                        }
                    }
                    .frame(height: 8)

                    // Stats
                    HStack {
                        Text("\(Int(goal.progress))% " + "goals.complete_short".localizedString)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))

                        Spacer()

                        if let weeks = goal.weeksCompleted, let total = goal.totalWeeks {
                            Text("\(weeks)/\(total) " + "goals.weeks".localizedString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                        }
                    }
                }
            } else {
                // No active goal
                VStack(spacing: 12) {
                    Image(systemName: "target")
                        .font(.system(size: 32))
                        .foregroundColor(.white.opacity(0.3))

                    Text("goals.no_active".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))

                    Button(action: onViewAll) {
                        Text("goals.set_goal".localizedString)
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(hex: "4A90E2"))
                            )
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
            }
        }
        .padding()
        .darkBlueCard()
        .task {
            await goalsVM.fetchActiveGoal()
        }
    }
}

// MARK: - Achievements Card
struct AchievementsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    let onViewAll: () -> Void
    @StateObject private var achievementsVM = AchievementsViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title3)
                    .foregroundColor(.yellow)
                Text("achievements.title".localizedString)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()

                // Points badge
                if achievementsVM.totalPoints > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundColor(.yellow)
                        Text("\(achievementsVM.totalPoints)")
                            .font(.caption.bold())
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.yellow.opacity(0.2)))
                }

                Button(action: onViewAll) {
                    Text("common.view_all".localizedString)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }

            if achievementsVM.recentlyEarned.isEmpty {
                // Placeholder achievements when none earned yet
                HStack(spacing: 12) {
                    ForEach(0..<3, id: \.self) { _ in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(width: 60, height: 60)

                                Image(systemName: "lock.fill")
                                    .font(.title3)
                                    .foregroundColor(.white.opacity(0.3))
                            }

                            Text("achievements.locked".localizedString)
                                .font(.caption2.weight(.medium))
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
            } else {
                // Show recently earned achievements
                HStack(spacing: 12) {
                    ForEach(achievementsVM.recentlyEarned.prefix(3)) { achievement in
                        VStack(spacing: 8) {
                            ZStack {
                                Circle()
                                    .fill(Color(hex: achievementsVM.categoryColor(achievement.category)).opacity(0.2))
                                    .frame(width: 60, height: 60)

                                if let icon = achievement.icon {
                                    Text(icon)
                                        .font(.title2)
                                } else {
                                    Image(systemName: achievementsVM.categoryIcon(achievement.category))
                                        .font(.title2)
                                        .foregroundColor(Color(hex: achievementsVM.categoryColor(achievement.category)))
                                }
                            }

                            Text(achievement.name)
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

            // Progress indicator
            if achievementsVM.totalAvailable > 0 {
                HStack {
                    Text("\(achievementsVM.totalEarned)/\(achievementsVM.totalAvailable) " + "achievements.unlocked".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
            }
        }
        .padding()
        .darkBlueCard()
        .task {
            await achievementsVM.fetchAllAchievements()
            await achievementsVM.fetchEarnedAchievements()
        }
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
                Text("profile.todays_activity".localizedString)
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
                    label: "profile.steps".localizedString,
                    color: Color(hex: "4A90E2")
                )

                ActivityStatItem(
                    icon: "flame.fill",
                    value: viewModel.caloriesToday != nil ? "\(viewModel.caloriesToday!)" : "–",
                    label: "profile.kcal".localizedString,
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
    let onOpenFeedback: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("profile.quick_actions".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // First row
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "square.and.pencil",
                    title: "profile.log".localizedString,
                    color: Color(hex: "4A90E2"),
                    action: onLogMeasurement
                )

                QuickActionButton(
                    icon: "bell.fill",
                    title: "profile.reminders".localizedString,
                    color: Color(hex: "9D4EDD"),
                    action: onSetReminder
                )
            }

            // Second row
            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "book.fill",
                    title: "tab.blog".localizedString,
                    color: Color(hex: "7EC8E3"),
                    action: onOpenBlog
                )

                QuickActionButton(
                    icon: "text.bubble.fill",
                    title: "feedback.title".localizedString,
                    color: Color(hex: "4ECB71"),
                    action: onOpenFeedback
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
            Text("profile.weight_progress".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)

            if recentLogs.isEmpty {
                Text("profile.no_progress_data".localizedString)
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
            Text("profile.recent_measurements".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)

            if viewModel.progressLogs.isEmpty {
                Text("profile.no_measurements".localizedString)
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
        case updateWorkoutType, nutrition

        var title: String {
            switch self {
            case .updateWorkoutType: return "profile.update_workout_type".localizedString
            case .nutrition: return "profile.regenerate_nutrition".localizedString
            }
        }

        var message: String {
            switch self {
            case .updateWorkoutType: return "profile.update_workout_type_confirm".localizedString
            case .nutrition: return "profile.regenerate_nutrition_confirm".localizedString
            }
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            Text("profile.plan_management".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Update Workout Type (re-do onboarding without personal info)
            Button(action: {
                selectedAction = .updateWorkoutType
                showingConfirmation = true
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("profile.update_workout_type".localizedString)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)

                        Text("profile.update_workout_type_desc".localizedString)
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
                        Text("profile.regenerate_nutrition".localizedString)
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)

                        Text("profile.regenerate_nutrition_desc".localizedString)
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
        }
        .padding()
        .darkBlueCard()
        .alert("profile.confirm_action".localizedString, isPresented: $showingConfirmation, presenting: selectedAction) { action in
            Button("common.cancel".localizedString, role: .cancel) { }
            Button("common.confirm".localizedString, role: .destructive) {
                performAction(action)
            }
        } message: { action in
            Text(action.message)
        }
    }

    private func performAction(_ action: PlanAction) {
        switch action {
        case .updateWorkoutType:
            withAnimation(.spring(response: 0.6, dampingFraction: 0.85)) {
                authViewModel.appState = .updateWorkoutType
            }

        case .nutrition:
            print("Regenerating nutrition plan...")
        }
    }
}

// MARK: - Recovery & Wellness Card
struct RecoveryWellnessCard: View {
    let onOpenSleep: () -> Void
    let onOpenPropheticMedicine: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            Text("profile.recovery_wellness".localizedString)
                .font(.headline.bold())
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)

            Text("tooltip.recovery_wellness".localizedString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                QuickActionButton(
                    icon: "moon.zzz.fill",
                    title: "sleep.title".localizedString,
                    color: Color(hex: "6C5CE7"),
                    action: onOpenSleep
                )

                QuickActionButton(
                    icon: "leaf.fill",
                    title: "prophetic.title".localizedString,
                    color: Color(hex: "00B894"),
                    action: onOpenPropheticMedicine
                )
            }
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Settings Card
struct SettingsCard: View {
    @ObservedObject var languageManager: LanguageManager
    @ObservedObject var themeManager: ThemeManager
    @State private var showLanguageSheet = false

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "gearshape.fill")
                    .font(.title3)
                    .foregroundColor(Color(hex: "4A90E2"))
                Text("settings.title".localizedString)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            // Language Picker - Tap to show sheet
            Button(action: { showLanguageSheet = true }) {
                HStack {
                    Image(systemName: "globe")
                        .foregroundColor(Color(hex: "4A90E2"))
                        .frame(width: 30)
                    Text("settings.language".localizedString)
                        .foregroundColor(.white)
                    Spacer()
                    Text(languageManager.selected.localizedDisplayNameWithFlag)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)

            // Theme Picker
            HStack {
                Image(systemName: "paintbrush.fill")
                    .foregroundColor(Color(hex: "9D4EDD"))
                    .frame(width: 30)
                Text("settings.appearance".localizedString)
                    .foregroundColor(.white)
                Spacer()
                Text("profile.dark".localizedString)
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
        .sheet(isPresented: $showLanguageSheet) {
            LanguageSelectionSheet(languageManager: languageManager)
        }
    }
}

// MARK: - Language Selection Sheet
struct LanguageSelectionSheet: View {
    @ObservedObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedLanguage: AppLanguage?

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "0A1628").ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("settings.select_language".localizedString)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                        .padding(.top, 20)

                    ForEach(AppLanguage.allCases) { language in
                        Button(action: {
                            // Visual feedback
                            selectedLanguage = language

                            // Apply language change with animation
                            withAnimation(.easeInOut(duration: 0.2)) {
                                languageManager.selected = language
                            }

                            // Dismiss after brief delay to show selection feedback
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                dismiss()
                            }
                        }) {
                            HStack {
                                Text(language.localizedDisplayNameWithFlag)
                                    .font(.body.weight(.medium))
                                    .foregroundColor(.white)

                                Spacer()

                                if languageManager.selected == language || selectedLanguage == language {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(Color(hex: "4A90E2"))
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(
                                        (languageManager.selected == language || selectedLanguage == language) ?
                                        Color(hex: "4A90E2").opacity(0.2) :
                                        Color(hex: "1C2951").opacity(0.6)
                                    )
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .stroke(
                                        (languageManager.selected == language || selectedLanguage == language) ?
                                        Color(hex: "4A90E2") : Color.clear,
                                        lineWidth: 2
                                    )
                            )
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Text("settings.language_note".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.bottom, 20)
                }
                .padding(.horizontal)
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                            .font(.title2)
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            selectedLanguage = languageManager.selected
        }
    }
}

// MARK: - Debug Card (Development Only)
#if DEBUG
struct DebugCard: View {
    let onAPITest: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "ladybug.fill")
                    .font(.title3)
                    .foregroundColor(.orange)
                Text("profile.developer_tools".localizedString)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                Spacer()
            }

            Button(action: onAPITest) {
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.2))
                            .frame(width: 44, height: 44)

                        Image(systemName: "antenna.radiowaves.left.and.right")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                    }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("API Data Test")
                            .font(.subheadline.weight(.semibold))
                            .foregroundColor(.white)

                        Text("profile.view_raw_api".localizedString)
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
    }
}
#endif

// MARK: - Supporting Views (simplified)
struct EditProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                Image(systemName: "person.crop.circle.badge.clock")
                    .font(.system(size: 60))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )

                Text("profile.edit_coming_soon".localizedString)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("profile.edit_coming_soon_desc".localizedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Spacer()
            }
        }
        .navigationTitle("profile.edit".localizedString)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AchievementsView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        AchievementsFullView()
    }
}

// MARK: - Privacy & Data Card (GDPR)
struct PrivacyDataCard: View {
    let onPrivacyPolicy: () -> Void
    let onExportData: () -> Void
    let onDeleteAccount: () -> Void

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: "lock.shield.fill")
                    .font(.title3)
                    .foregroundColor(Color(hex: "4A90E2").opacity(0.7))
                Text("profile.privacy_data".localizedString)
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
            }

            Text("tooltip.privacy_data".localizedString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

            // Privacy Policy
            Button(action: onPrivacyPolicy) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "hand.raised.fill")
                            .foregroundColor(Color(hex: "4A90E2"))
                            .frame(width: 30)
                        Text("profile.privacy_policy".localizedString)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text("tooltip.privacy_policy".localizedString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 34)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)

            // Export My Data
            Button(action: onExportData) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(Color(hex: "4ECB71"))
                            .frame(width: 30)
                        Text("profile.export_data".localizedString)
                            .foregroundColor(.white)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text("tooltip.export_data".localizedString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 34)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color(hex: "0F1B3D").opacity(0.6))
                )
            }
            .buttonStyle(.plain)

            // Delete Account
            Button(action: onDeleteAccount) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "trash.fill")
                            .foregroundColor(.red)
                            .frame(width: 30)
                        Text("profile.delete_account".localizedString)
                            .foregroundColor(.red)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    Text("tooltip.delete_account".localizedString)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .padding(.leading, 34)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(Color.red.opacity(0.08))
                )
            }
            .buttonStyle(.plain)
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Sign Out Button
struct SignOutButton: View {
    @ObservedObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @State private var showingConfirmation = false
    @State private var isSigningOut = false

    var body: some View {
        Button(role: .destructive, action: {
            showingConfirmation = true
        }) {
            HStack(spacing: 10) {
                if isSigningOut {
                    ProgressView()
                        .tint(.red)
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "rectangle.portrait.and.arrow.right")
                    Text("profile.sign_out".localizedString)
                }
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(Color.red.opacity(0.15))
            )
            .foregroundColor(.red)
        }
        .disabled(isSigningOut)
        .alert(
            "profile.sign_out_confirm_title".localizedString,
            isPresented: $showingConfirmation
        ) {
            Button("common.cancel".localizedString, role: .cancel) { }
            Button("profile.sign_out".localizedString, role: .destructive) {
                performSignOut()
            }
        } message: {
            Text("profile.sign_out_confirm_message".localizedString)
        }
    }

    private func performSignOut() {
        isSigningOut = true

        // Clear language settings first to avoid race conditions
        languageManager.clearLanguageSettings()

        // Perform sign out directly on main thread
        authViewModel.signOut()

        // Reset state after transition completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            isSigningOut = false
        }
    }
}


