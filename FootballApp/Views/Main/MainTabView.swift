//
//  MainTabView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

//
//  MainTabView.swift
//  FootballApp
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    // Create the ViewModels for each tab
    // They will be passed down to their respective views
    @StateObject private var workoutsViewModel = WorkoutsViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    @StateObject private var kineViewModel = KineViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    // For your custom tab bar
    @State private var selectedTab: Tab = .workout

    var body: some View {
        VStack(spacing: 0) {
            // This is the main content area
            ZStack {
                switch selectedTab {
                case .workout:
                    // The Workout tab - Using Modern Workout View
                    WorkoutView()
                        .environmentObject(workoutsViewModel)
                case .nutrition:
                    // The Nutrition tab
                    NutritionView()
                        .environmentObject(nutritionViewModel)
                case .kine:
                    // The Kine tab
                    KineView()
                        .environmentObject(kineViewModel)
                case .profile:
                    // The Profile/Settings tab
                    ProfileView() //
                        .environmentObject(profileViewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // This is your custom Tab Bar view
            CustomTabBarView(selectedTab: $selectedTab)
        }
    }
}

// MARK: - Custom Tab Bar
enum Tab: String, CaseIterable {
    case workout = "figure.walk"
    case nutrition = "leaf.fill"
    case kine = "plus.circle.fill"
    case profile = "person.fill"
    
    var title: LocalizedStringKey {
        switch self {
        case .workout: return "tab.workout"
        case .nutrition: return "tab.nutrition"
        case .kine: return "tab.kine"
        case .profile: return "tab.profile"
        }
    }
}

struct CustomTabBarView: View {
    @Binding var selectedTab: Tab
    @Namespace private var animation
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                TabBarButton(
                    tab: tab,
                    isSelected: selectedTab == tab,
                    namespace: animation,
                    action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                        // Haptic feedback
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                    }
                )
            }
        }
        .padding(.horizontal, 16)
        .padding(.top, 20)
        .padding(.bottom, 40) // More space at bottom
        .background {
            ZStack {
                // Glass effect with blur
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Subtle gradient overlay
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.1),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            // Top border with glass effect
            Rectangle()
                .fill(.ultraThinMaterial)
                .frame(height: 0.5)
                .opacity(0.3)
        }
        .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: -10)
    }
}

struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 6) {
                ZStack {
                    if isSelected {
                        // Glass effect background for selected tab
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(width: 64, height: 40)
                            .overlay {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.purple.opacity(0.3),
                                                Color.pink.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .shadow(color: .purple.opacity(0.3), radius: 8, x: 0, y: 4)
                            .matchedGeometryEffect(id: "tab_selection", in: namespace)
                    }
                    
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected ? 
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                colors: [Color.secondary, Color.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isSelected ? 1.1 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                }
                .frame(height: 40)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .semibold : .regular))
                    .foregroundStyle(isSelected ? Color.purple : Color.secondary)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return MainTabView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}

