//
//  MainTabView.swift
//  FootballApp
//
//  Modern tab-based navigation with enhanced UX and animations
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var workoutsViewModel: WorkoutsViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @EnvironmentObject var kineViewModel: KineViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel

    @State private var selectedTab: Tab = .workout
    @State private var previousTab: Tab = .workout

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                // Main content area - takes full space with bottom padding for tab bar
                TabContent(
                    selectedTab: selectedTab,
                    previousTab: previousTab,
                    workoutsViewModel: workoutsViewModel,
                    nutritionViewModel: nutritionViewModel,
                    kineViewModel: kineViewModel,
                    profileViewModel: profileViewModel
                )
                .frame(width: geometry.size.width, height: geometry.size.height)

                // Fixed floating tab bar at bottom
                VStack {
                    Spacer()
                    FloatingTabBar(selectedTab: $selectedTab, onTabChange: { newTab in
                        previousTab = selectedTab
                        selectedTab = newTab
                    })
                }
            }
        }
        .ignoresSafeArea(.keyboard)
    }
}

// MARK: - Tab Content

private struct TabContent: View {
    let selectedTab: Tab
    let previousTab: Tab
    @ObservedObject var workoutsViewModel: WorkoutsViewModel
    @ObservedObject var nutritionViewModel: NutritionViewModel
    @ObservedObject var kineViewModel: KineViewModel
    @ObservedObject var profileViewModel: ProfileViewModel

    var body: some View {
        // Use standard TabView-like switching for stability
        Group {
            switch selectedTab {
            case .workout:
                WorkoutView()
                    .environmentObject(workoutsViewModel)
                    .environmentObject(nutritionViewModel)
            case .nutrition:
                NutritionView()
                    .environmentObject(nutritionViewModel)
            case .kine:
                KineView()
                    .environmentObject(kineViewModel)
            case .blog:
                BlogTabView()
            case .profile:
                ProfileView()
                    .environmentObject(profileViewModel)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .transition(.opacity)
        .animation(.easeInOut(duration: 0.15), value: selectedTab)
    }
}

// MARK: - Tab Enum

enum Tab: String, CaseIterable {
    case workout
    case nutrition
    case kine
    case blog
    case profile

    var icon: String {
        switch self {
        case .workout: return "figure.run"
        case .nutrition: return "leaf.fill"
        case .kine: return "waveform.path.ecg"
        case .blog: return "book"
        case .profile: return "person.fill"
        }
    }

    var selectedIcon: String {
        switch self {
        case .workout: return "figure.run"
        case .nutrition: return "leaf.fill"
        case .kine: return "waveform.path.ecg.rectangle.fill"
        case .blog: return "book.fill"
        case .profile: return "person.fill"
        }
    }

    var title: LocalizedStringKey {
        switch self {
        case .workout: return "tab.workout"
        case .nutrition: return "tab.nutrition"
        case .kine: return "tab.kine"
        case .blog: return "tab.blog"
        case .profile: return "tab.profile"
        }
    }

    var color: Color {
        switch self {
        case .workout: return Color(hex: "FF6B6B")
        case .nutrition: return Color(hex: "4ECB71")
        case .kine: return Color(hex: "5E7CE2")
        case .blog: return Color(hex: "FF9F43")
        case .profile: return Color(hex: "A06CD5")
        }
    }
}

// MARK: - Floating Tab Bar

struct FloatingTabBar: View {
    @Binding var selectedTab: Tab
    let onTabChange: (Tab) -> Void

    @Namespace private var animation
    @State private var showGlow = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarItem(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation,
                    onTap: {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                            onTabChange(tab)
                        }
                        generateHaptic()
                    }
                )
            }
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 10)
        .background(
            TabBarBackground(showGlow: showGlow)
        )
        .overlay(
            TabBarBorder()
        )
        .shadow(color: .black.opacity(0.25), radius: 20, x: 0, y: 8)
        .shadow(color: Color.theme.primary.opacity(0.1), radius: 15, x: 0, y: 4)
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
        .onAppear { showGlow = true }
    }

    private func generateHaptic() {
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.prepare()
        generator.impactOccurred()
    }
}

// MARK: - Tab Bar Item

private struct TabBarItem: View {
    let tab: Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let onTap: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: {
            isPressed = true
            onTap()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 6) {
                ZStack {
                    // Selection background
                    if isSelected {
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tab.color.opacity(0.25),
                                        tab.color.opacity(0.1)
                                    ],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
                            )
                            .frame(width: 56, height: 40)
                            .overlay(
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                tab.color.opacity(0.5),
                                                tab.color.opacity(0.2)
                                            ],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        ),
                                        lineWidth: 1
                                    )
                            )
                            .matchedGeometryEffect(id: "tab_bg", in: namespace)
                    }

                    // Icon
                    Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                        .font(.system(size: 20, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected ?
                            LinearGradient(
                                colors: [tab.color, tab.color.opacity(0.8)],
                                startPoint: .top,
                                endPoint: .bottom
                            ) :
                            LinearGradient(
                                colors: [Color.white.opacity(0.5), Color.white.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(isPressed ? 0.85 : (isSelected ? 1.1 : 1.0))
                        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
                }
                .frame(height: 40)

                // Label
                Text(tab.title)
                    .font(.system(size: 10, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? tab.color : .white.opacity(0.4))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tab Bar Background

private struct TabBarBackground: View {
    let showGlow: Bool

    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .fill(.ultraThinMaterial)
            .overlay(
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1A1A2E").opacity(0.8),
                                Color(hex: "0F0F23").opacity(0.9)
                            ],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
            )
            .overlay(
                // Animated top glow
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(showGlow ? 0.1 : 0.02),
                                .clear
                            ],
                            startPoint: .top,
                            endPoint: .center
                        )
                    )
                    .animation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true), value: showGlow)
            )
    }
}

// MARK: - Tab Bar Border

private struct TabBarBorder: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 28, style: .continuous)
            .strokeBorder(
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.2),
                        Color.white.opacity(0.05),
                        Color.white.opacity(0.1)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ),
                lineWidth: 1
            )
    }
}

// MARK: - Preview

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var workoutsVM = WorkoutsViewModel()
    @Previewable @StateObject var nutritionVM = NutritionViewModel()
    @Previewable @StateObject var kineVM = KineViewModel()
    @Previewable @StateObject var profileVM = ProfileViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    ZStack {
        Color(hex: "0A0A1E")
            .ignoresSafeArea()

        MainTabView()
            .environmentObject(authVM)
            .environmentObject(workoutsVM)
            .environmentObject(nutritionVM)
            .environmentObject(kineVM)
            .environmentObject(profileVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
    }
    .preferredColorScheme(.dark)
}
