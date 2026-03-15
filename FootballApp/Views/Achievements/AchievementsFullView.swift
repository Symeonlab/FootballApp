//
//  AchievementsFullView.swift
//  FootballApp
//
//  Full view for displaying all achievements and leaderboard
//

import SwiftUI

struct AchievementsFullView: View {
    @StateObject private var viewModel = AchievementsViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Tab selector
                    HStack(spacing: 0) {
                        TabButton(title: "achievements.all".localizedString, isSelected: selectedTab == 0) {
                            withAnimation { selectedTab = 0 }
                        }
                        TabButton(title: "achievements.leaderboard".localizedString, isSelected: selectedTab == 1) {
                            withAnimation { selectedTab = 1 }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)

                    TabView(selection: $selectedTab) {
                        // All Achievements Tab
                        AchievementsListView(viewModel: viewModel)
                            .tag(0)

                        // Leaderboard Tab
                        LeaderboardView(viewModel: viewModel)
                            .tag(1)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }

                // Loading overlay
                if viewModel.isLoading {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                }
            }
            .navigationTitle("achievements.title".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .task {
                await viewModel.refreshData()
            }
            .refreshable {
                await viewModel.refreshData()
            }
        }
    }
}

// MARK: - Tab Button

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(title)
                    .font(.subheadline.weight(isSelected ? .bold : .medium))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.5))

                Rectangle()
                    .fill(isSelected ? Color(hex: "4A90E2") : Color.clear)
                    .frame(height: 3)
                    .cornerRadius(1.5)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Achievements List View

struct AchievementsListView: View {
    @ObservedObject var viewModel: AchievementsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Summary Card
                AchievementsSummaryCard(viewModel: viewModel)
                    .padding(.horizontal)

                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        CategoryChip(
                            title: "achievements.all".localizedString,
                            icon: "square.grid.2x2.fill",
                            color: "4A90E2",
                            isSelected: viewModel.selectedCategory == nil
                        ) {
                            viewModel.selectedCategory = nil
                        }

                        ForEach(AchievementCategory.allCases, id: \.self) { category in
                            CategoryChip(
                                title: category.rawValue.capitalized,
                                icon: viewModel.categoryIcon(category),
                                color: viewModel.categoryColor(category),
                                isSelected: viewModel.selectedCategory == category
                            ) {
                                viewModel.selectedCategory = category
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Achievements Grid
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                    ForEach(viewModel.filteredAchievements) { achievement in
                        AchievementCard(achievement: achievement, viewModel: viewModel)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .padding(.top, 16)
        }
    }
}

// MARK: - Summary Card

struct AchievementsSummaryCard: View {
    @ObservedObject var viewModel: AchievementsViewModel

    var body: some View {
        VStack(spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("achievements.your_progress".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("\(viewModel.totalEarned) / \(viewModel.totalAvailable) " + "achievements.earned".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                Spacer()

                // Points badge
                HStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("\(viewModel.totalPoints)")
                        .font(.headline.bold())
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(Color.yellow.opacity(0.2))
                )
            }

            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 16)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "4A90E2"), Color(hex: "A06CD5")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * CGFloat(viewModel.earnedPercentage / 100), height: 16)
                }
            }
            .frame(height: 16)

            Text(String(format: "%.0f%% " + "achievements.complete".localizedString, viewModel.earnedPercentage))
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let title: String
    let icon: String
    let color: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.caption)
                Text(title)
                    .font(.caption.weight(.medium))
            }
            .foregroundColor(isSelected ? .white : Color(hex: color))
            .padding(.horizontal, 14)
            .padding(.vertical, 8)
            .background(
                Capsule()
                    .fill(isSelected ? Color(hex: color) : Color(hex: color).opacity(0.2))
            )
        }
    }
}

// MARK: - Achievement Card

struct AchievementCard: View {
    let achievement: Achievement
    @ObservedObject var viewModel: AchievementsViewModel

    var isEarned: Bool {
        achievement.earned ?? false
    }

    var body: some View {
        VStack(spacing: 12) {
            // Icon with celebration ring for earned
            ZStack {
                if isEarned {
                    // Glowing ring for earned achievements
                    Circle()
                        .fill(Color(hex: viewModel.categoryColor(achievement.category)).opacity(0.15))
                        .frame(width: 72, height: 72)

                    Circle()
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: viewModel.categoryColor(achievement.category)),
                                    Color(hex: viewModel.categoryColor(achievement.category)).opacity(0.3)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 2.5
                        )
                        .frame(width: 68, height: 68)
                }

                Circle()
                    .fill(
                        isEarned ?
                        Color(hex: viewModel.categoryColor(achievement.category)).opacity(0.3) :
                        Color.white.opacity(0.08)
                    )
                    .frame(width: 60, height: 60)

                if let icon = achievement.icon {
                    Text(icon)
                        .font(.system(size: 28))
                        .opacity(isEarned ? 1.0 : 0.4)
                } else {
                    Image(systemName: viewModel.categoryIcon(achievement.category))
                        .font(.title)
                        .foregroundColor(
                            isEarned ?
                            Color(hex: viewModel.categoryColor(achievement.category)) :
                            .white.opacity(0.2)
                        )
                }

                if !isEarned {
                    Circle()
                        .fill(Color.black.opacity(0.5))
                        .frame(width: 60, height: 60)

                    Image(systemName: "lock.fill")
                        .font(.body)
                        .foregroundColor(.white.opacity(0.4))
                }

                // Checkmark badge for earned
                if isEarned {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "4ECB71"))
                        .background(Circle().fill(Color(hex: "0F1B3D")).frame(width: 16, height: 16))
                        .offset(x: 24, y: -24)
                }
            }

            // Name
            Text(achievement.name)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(isEarned ? .white : .white.opacity(0.4))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Description
            Text(achievement.description)
                .font(.caption)
                .foregroundColor(isEarned ? .white.opacity(0.6) : .white.opacity(0.3))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            // Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption2)
                Text("\(achievement.points)")
                    .font(.caption.weight(.bold))
            }
            .foregroundColor(isEarned ? .yellow : .white.opacity(0.2))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isEarned ? Color.white.opacity(0.08) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            isEarned ?
                            Color(hex: viewModel.categoryColor(achievement.category)).opacity(0.4) :
                            Color.white.opacity(0.05),
                            lineWidth: 1
                        )
                )
        )
        .opacity(isEarned ? 1.0 : 0.7)
    }
}

// MARK: - Leaderboard View

struct LeaderboardView: View {
    @ObservedObject var viewModel: AchievementsViewModel

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Current user rank
                if let rank = viewModel.currentUserRank {
                    CurrentUserRankCard(rank: rank)
                        .padding(.horizontal)
                }

                // Leaderboard list
                VStack(spacing: 12) {
                    ForEach(Array(viewModel.leaderboard.enumerated()), id: \.element.id) { index, entry in
                        LeaderboardRow(entry: entry, rank: index + 1)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 100)
            }
            .padding(.top, 16)
        }
    }
}

// MARK: - Current User Rank Card

struct CurrentUserRankCard: View {
    let rank: CurrentUserRank

    var body: some View {
        HStack(spacing: 16) {
            // Rank badge
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "4A90E2"), Color(hex: "A06CD5")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                Text("#\(rank.rank)")
                    .font(.title2.bold())
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text("achievements.your_rank".localizedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))

                HStack(spacing: 16) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("\(rank.totalPoints)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }

                    HStack(spacing: 4) {
                        Image(systemName: "trophy.fill")
                            .foregroundColor(Color(hex: "4ECB71"))
                        Text("\(rank.achievementCount)")
                            .font(.headline.bold())
                            .foregroundColor(.white)
                    }
                }
            }

            Spacer()
        }
        .padding()
        .darkBlueCard()
    }
}

// MARK: - Leaderboard Row

struct LeaderboardRow: View {
    let entry: LeaderboardEntry
    let rank: Int

    var rankColor: Color {
        switch rank {
        case 1: return .yellow
        case 2: return Color(hex: "C0C0C0")
        case 3: return Color(hex: "CD7F32")
        default: return Color(hex: "4A90E2")
        }
    }

    var rankIcon: String? {
        switch rank {
        case 1: return "crown.fill"
        case 2, 3: return "medal.fill"
        default: return nil
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Rank
            ZStack {
                if let icon = rankIcon {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(rankColor)
                } else {
                    Text("#\(rank)")
                        .font(.headline.bold())
                        .foregroundColor(rankColor)
                }
            }
            .frame(width: 40)

            // Avatar
            Circle()
                .fill(Color(hex: "4A90E2").opacity(0.3))
                .frame(width: 44, height: 44)
                .overlay(
                    Text(entry.name.prefix(1).uppercased())
                        .font(.headline.bold())
                        .foregroundColor(Color(hex: "4A90E2"))
                )

            // Name
            VStack(alignment: .leading, spacing: 2) {
                Text(entry.name)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Text("\(entry.achievementCount) " + "achievements.achievements".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Points
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
                Text("\(entry.totalPoints)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(rank <= 3 ? rankColor.opacity(0.1) : Color.white.opacity(0.05))
        )
    }
}

// MARK: - AchievementCategory Extension

extension AchievementCategory: CaseIterable {
    public static var allCases: [AchievementCategory] {
        [.workout, .consistency, .milestone, .nutrition, .special]
    }
}

// MARK: - Preview

#Preview {
    AchievementsFullView()
        .preferredColorScheme(.dark)
}
