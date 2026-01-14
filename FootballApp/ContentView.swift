//
//  ContentView.swift
//  FootballApp
//
//  Root view that manages the entire app lifecycle and state transitions
//

import SwiftUI
import Combine
import os.log

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase
    
    // Logger for ContentView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ContentView")
    
    // MARK: - View Models
    // Create view models at the root level to ensure data persistence across tab switches
    @StateObject private var workoutsViewModel = WorkoutsViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    @StateObject private var kineViewModel = KineViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    
    // Track if we've already loaded main app data
    @State private var hasLoadedMainAppData = false

    var body: some View {
        ZStack {
            // ✅ One consistent brand background across the whole app
            AppRootPurpleBackground()

            // ✅ Main content with smooth transitions
            Group {
                switch authViewModel.appState {
                case .loading:
                    LoadingView()
                        .transition(.opacity.combined(with: .scale(scale: 0.98)))

                case .authentication:
                    AuthView()
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .bottom)),
                            removal: .opacity
                        ))

                case .onboarding:
                    OnboardingFlow()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)
                        ))

                case .mainApp:
                    MainTabView()
                        // ✅ Inject view models from ContentView so data persists
                        .environmentObject(workoutsViewModel)
                        .environmentObject(nutritionViewModel)
                        .environmentObject(kineViewModel)
                        .environmentObject(profileViewModel)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity
                        ))
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .animation(.easeInOut(duration: 0.35), value: authViewModel.appState)
        }
        .preferredColorScheme(.dark) // Force dark mode for consistent branding
        .onAppear { setupApp() }
        .onChange(of: scenePhase) { oldValue, newValue in
            handleScenePhaseChange(to: newValue)
        }
        .onChange(of: authViewModel.appState) { oldValue, newValue in
            handleAppStateChange(to: newValue)
        }
    }

    // MARK: - Lifecycle Methods

    /// Setup app on initial launch
    private func setupApp() {
        logger.info("🚀 ContentView: Setting up app")
        print("🔵 PRINT TEST: ContentView setupApp called - if you see this, logging should work!")
        authViewModel.fetchUser()
    }

    /// Handle app lifecycle changes (background, foreground, etc.)
    private func handleScenePhaseChange(to newPhase: ScenePhase) {
        logger.info("📱 ContentView: Scene phase changed to \(String(describing: newPhase))")
        
        switch newPhase {
        case .active:
            logger.info("✅ ContentView: App became active")
            // App became active - refresh user data
            authViewModel.fetchUser()
            
            // Refresh data when app becomes active
            if authViewModel.appState == .mainApp {
                logger.info("🔄 ContentView: Refreshing main app data (app state = mainApp)")
                Task {
                    await refreshMainAppData()
                }
            }
        case .inactive:
            logger.info("⚠️ ContentView: App is inactive")
            // App is inactive (e.g., during transition)
            break
        case .background:
            logger.info("⏸️ ContentView: App moved to background")
            // App moved to background - save state if needed
            break
        @unknown default:
            logger.warning("❓ ContentView: Unknown scene phase")
            break
        }
    }
    
    /// Handle app state transitions
    private func handleAppStateChange(to newState: AppState) {
        logger.info("🔄 ContentView: App state changed to \(String(describing: newState))")
        
        // When entering main app, fetch all data (only once)
        if newState == .mainApp && !hasLoadedMainAppData {
            logger.info("🎯 ContentView: Entering main app for first time, loading data...")
            hasLoadedMainAppData = true
            Task {
                await refreshMainAppData()
            }
        } else if newState == .mainApp {
            logger.info("✅ ContentView: Already in main app, data already loaded")
        }
    }
    
    /// Refresh all main app data
    @MainActor
    private func refreshMainAppData() async {
        logger.info("🔄 ContentView: Starting main app data refresh...")
        
        // Fetch workout plan (only if not already loaded)
        if workoutsViewModel.workoutSessions.isEmpty {
            logger.info("📥 ContentView: Fetching workout plan (empty)...")
            await workoutsViewModel.fetchWorkoutPlan()
            
            // Log result
            if !workoutsViewModel.workoutSessions.isEmpty {
                logger.info("✅ ContentView: Workout plan loaded successfully - \(workoutsViewModel.workoutSessions.count) sessions")
            } else if let error = workoutsViewModel.errorMessage {
                logger.error("❌ ContentView: Workout plan fetch failed - \(error)")
            } else {
                logger.warning("⚠️ ContentView: Workout plan is still empty (no error)")
            }
        } else {
            logger.info("✅ ContentView: Workout plan already loaded (\(workoutsViewModel.workoutSessions.count) sessions), skipping fetch")
        }
        
        // Fetch nutrition plan (uses Combine, not async)
        logger.info("📥 ContentView: Fetching nutrition plan...")
        nutritionViewModel.fetchNutritionPlan()
        
        // Give it a moment to complete and log result
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        if let plan = nutritionViewModel.nutritionPlan {
            logger.info("✅ ContentView: Nutrition plan loaded successfully")
            logger.info("   - Daily calories: \(plan.daily_calorie_intake)")
            logger.info("   - Meals: \(plan.daily_meals?.count ?? 0)")
            logger.info("   - Advice items: \(plan.advice?.count ?? 0)")
        } else if let error = nutritionViewModel.errorMessage {
            logger.error("❌ ContentView: Nutrition plan fetch failed - \(error)")
        } else {
            logger.warning("⚠️ ContentView: Nutrition plan is still nil (may still be loading)")
        }
        
        // Fetch kine data (uses Combine, not async)
        logger.info("📥 ContentView: Fetching kine data...")
        kineViewModel.fetchKineData()
        kineViewModel.fetchFavorites()
        
        // Give it a moment to complete and log result
        try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        if !kineViewModel.allExercises.isEmpty {
            logger.info("✅ ContentView: Kine data loaded successfully")
            logger.info("   - Categories: \(kineViewModel.categories.count)")
            logger.info("   - Exercises: \(kineViewModel.allExercises.count)")
            logger.info("   - Favorites: \(kineViewModel.favoriteIDs.count)")
        } else if let error = kineViewModel.errorMessage {
            logger.error("❌ ContentView: Kine data fetch failed - \(error)")
        } else {
            logger.warning("⚠️ ContentView: Kine data is still empty (may still be loading)")
        }
        
        // Profile data is fetched by ProfileViewModel automatically
        logger.info("📥 ContentView: Profile view model manages its own data")
        
        logger.info("✅ ContentView: Main app data refresh complete")
    }
}

// MARK: - Root Background Wrapper

private struct AppRootPurpleBackground: View {
    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            // ✅ Legibility veil (keeps text readable without washing out purple)
            LinearGradient(
                colors: [
                    Color.black.opacity(0.30),
                    Color.black.opacity(0.10),
                    Color.black.opacity(0.35)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Optional: faint “spotlight” to center the UI
            RadialGradient(
                colors: [
                    Color.lightPurple.opacity(0.18),
                    .clear
                ],
                center: .center,
                startRadius: 30,
                endRadius: 520
            )
            .ignoresSafeArea()
        }
    }
}

// MARK: - Loading View (Brand-Aligned)

private struct LoadingView: View {
    @State private var pulse = false

    var body: some View {
        ZStack {
            // Background is already provided by ContentView; keep this transparent
            Color.clear

            VStack(spacing: 18) {
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 108, height: 108)
                        .overlay(
                            RoundedRectangle(cornerRadius: 28, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                        )
                        .shadow(color: .black.opacity(0.35), radius: 24, x: 0, y: 14)

                    Text("D")
                        .font(.system(size: 52, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(pulse ? 1.06 : 0.96)
                        .animation(.easeInOut(duration: 1.1).repeatForever(autoreverses: true), value: pulse)
                }

                VStack(spacing: 10) {
                    ProgressView()
                        .tint(.white)

                    Text("Loading…")
                        .font(.headline)
                        .foregroundColor(.white)

                    Text("Preparing your training dashboard")
                        .font(.footnote)
                        .foregroundColor(.white.opacity(0.75))
                }
            }
            .padding(.vertical, 22)
            .padding(.horizontal, 22)
            .background(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 26, style: .continuous)
                            .fill(Color.deepPurple.opacity(0.14))
                    )
            )
            .overlay(
                RoundedRectangle(cornerRadius: 26, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.35), radius: 26, x: 0, y: 14)
            .padding(.horizontal, 24)
        }
        .onAppear { pulse = true }
    }
}

#Preview("ContentView - Loading State") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    ContentView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
        .onAppear {
            print("🔵 Preview: ContentView appeared with loading state")
            authVM.appState = .loading
        }
}

#Preview("ContentView - Main App (Run Simulator for Data)") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    ContentView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
        .onAppear {
            print("🔵 Preview: ContentView main app state")
            print("⚠️ Preview: No data will show - press Cmd+R to run on simulator!")
            authVM.appState = .mainApp
        }
}

#Preview("ContentView - Authentication") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    ContentView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
        .onAppear {
            print("🔵 Preview: ContentView appeared with authentication state")
            authVM.appState = .authentication
        }
}

// Note: For previews with mock data, see individual tab views (WorkoutView.swift, etc.)
// To test with real data and full logging, press Cmd+R to run on simulator



