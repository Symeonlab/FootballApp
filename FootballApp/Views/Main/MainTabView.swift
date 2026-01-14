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
    
    // Receive view models from ContentView (injected via environment)
    // This ensures data persists across the entire app lifecycle
    @EnvironmentObject var workoutsViewModel: WorkoutsViewModel
    @EnvironmentObject var nutritionViewModel: NutritionViewModel
    @EnvironmentObject var kineViewModel: KineViewModel
    @EnvironmentObject var profileViewModel: ProfileViewModel
    
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
    @State private var tabBarGlow = false
    
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
                        // Enhanced haptic feedback
                        #if !targetEnvironment(simulator)
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        #endif
                    }
                )
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 20)
        .padding(.bottom, 40)
        .background {
            ZStack {
                // Enhanced glass effect with blur
                Rectangle()
                    .fill(.ultraThinMaterial)
                
                // Dynamic gradient overlay
                LinearGradient(
                    colors: [
                        Color.white.opacity(0.15),
                        Color.theme.primary.opacity(0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                
                // Subtle animated glow at the top
                LinearGradient(
                    colors: [
                        Color.theme.primary.opacity(tabBarGlow ? 0.15 : 0.05),
                        Color.clear
                    ],
                    startPoint: .top,
                    endPoint: .center
                )
                .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true), value: tabBarGlow)
            }
            .ignoresSafeArea(edges: .bottom)
        }
        .overlay(alignment: .top) {
            // Enhanced top border with gradient
            LinearGradient(
                colors: [
                    Color.white.opacity(0.5),
                    Color.white.opacity(0.2),
                    Color.clear
                ],
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(height: 1)
            .blur(radius: 0.5)
        }
        .shadow(color: .black.opacity(0.2), radius: 30, x: 0, y: -10)
        .shadow(color: Color.theme.primary.opacity(0.1), radius: 20, x: 0, y: -5)
        .onAppear {
            tabBarGlow = true
        }
    }
}

struct TabBarButton: View {
    let tab: Tab
    let isSelected: Bool
    let namespace: Namespace.ID
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
                isPressed = true
            }
            action()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
        }) {
            VStack(spacing: 8) {
                ZStack {
                    if isSelected {
                        // Enhanced glass effect background for selected tab
                        Capsule()
                            .fill(.thinMaterial)
                            .frame(width: 70, height: 44)
                            .overlay {
                                Capsule()
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.theme.primary.opacity(0.4),
                                                Color.theme.accent.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                            .overlay {
                                Capsule()
                                    .strokeBorder(
                                        LinearGradient(
                                            colors: [
                                                Color.white.opacity(0.5),
                                                Color.white.opacity(0.2)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            }
                            .shadow(color: Color.theme.primary.opacity(0.4), radius: 12, x: 0, y: 6)
                            .matchedGeometryEffect(id: "tab_selection", in: namespace)
                    }
                    
                    Image(systemName: tab.rawValue)
                        .font(.system(size: 24, weight: isSelected ? .semibold : .regular))
                        .foregroundStyle(
                            isSelected ? 
                            LinearGradient(
                                colors: [Color.white, Color.white.opacity(0.9)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ) : 
                            LinearGradient(
                                colors: [Color.secondary.opacity(0.8), Color.secondary.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(isSelected ? 1.15 : 1.0)
                        .scaleEffect(isPressed ? 0.95 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isSelected)
                        .animation(.spring(response: 0.2, dampingFraction: 0.5), value: isPressed)
                }
                .frame(height: 44)
                
                Text(tab.title)
                    .font(.system(size: 11, weight: isSelected ? .bold : .medium))
                    .foregroundStyle(
                        isSelected ? 
                        Color.white : 
                        Color.secondary.opacity(0.8)
                    )
                    .animation(.easeInOut(duration: 0.2), value: isSelected)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var workoutsVM = WorkoutsViewModel()
    @Previewable @StateObject var nutritionVM = NutritionViewModel()
    @Previewable @StateObject var kineVM = KineViewModel()
    @Previewable @StateObject var profileVM = ProfileViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return MainTabView()
        .environmentObject(authVM)
        .environmentObject(workoutsVM)
        .environmentObject(nutritionVM)
        .environmentObject(kineVM)
        .environmentObject(profileVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}

