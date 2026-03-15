//
//  ContentView.swift
//  FootballApp
//
//  Root view that manages the entire app lifecycle and state transitions
//  Optimized for performance, smooth animations, and polished UX
//

import SwiftUI
import Combine
import os.log

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var languageManager: LanguageManager
    @Environment(\.scenePhase) private var scenePhase

    // Logger for ContentView
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "ContentView")

    // MARK: - View Models (injected from App level to persist across language changes)
    @EnvironmentObject private var workoutsViewModel: WorkoutsViewModel
    @EnvironmentObject private var nutritionViewModel: NutritionViewModel
    @EnvironmentObject private var kineViewModel: KineViewModel
    @EnvironmentObject private var profileViewModel: ProfileViewModel

    // State management
    @State private var hasLoadedMainAppData = false
    @State private var showSplash = true
    @State private var splashOpacity: Double = 1.0
    @State private var contentOpacity: Double = 0.0

    // Track if app has been initialized (persists across language changes via static)
    private static var hasCompletedInitialization = false

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Unified brand background - full screen
                DarkPurpleAnimatedBackground()
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .ignoresSafeArea()

                // Main content with state-based transitions - full screen
                mainContent
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .opacity(contentOpacity)

                // Splash overlay
                if showSplash {
                    SplashView()
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .opacity(splashOpacity)
                        .zIndex(100)
                }
            }
        }
        .ignoresSafeArea()
        .preferredColorScheme(.dark)
        .onAppear { initializeApp() }
        .onChange(of: scenePhase) { _, newValue in
            handleScenePhaseChange(to: newValue)
        }
        .onChange(of: authViewModel.appState) { _, newValue in
            handleAppStateChange(to: newValue)
        }
    }

    // MARK: - Main Content View
    @ViewBuilder
    private var mainContent: some View {
        Group {
            switch authViewModel.appState {
            case .loading:
                LoadingStateView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 0.95)),
                        removal: .opacity
                    ))

            case .authentication:
                AuthView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .opacity.combined(with: .scale(scale: 0.95))
                    ))

            case .onboarding:
                OnboardingFlow()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .updateWorkoutType:
                OnboardingFlow(isUpdateMode: true)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .move(edge: .trailing).combined(with: .opacity),
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))

            case .mainApp:
                // View models are already injected from App level via environment
                MainTabView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .scale(scale: 1.02)),
                        removal: .opacity
                    ))
            }
        }
    }

    // MARK: - Lifecycle Methods

    private func initializeApp() {
        // CRITICAL: Only initialize once - prevents logout on language change
        // When language changes, .id() recreates the view but we don't want to
        // re-fetch user data (which could fail and log the user out)
        guard !Self.hasCompletedInitialization else {
            logger.info("🔄 ContentView: Skipping re-initialization (language change)")
            // Just ensure content is visible after language change
            DispatchQueue.main.async {
                showSplash = false
                splashOpacity = 0
                contentOpacity = 1
            }
            return
        }

        Self.hasCompletedInitialization = true
        logger.info("🚀 ContentView: Initializing app")

        // Show splash briefly then fade to content
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeOut(duration: 0.6)) {
                splashOpacity = 0
                contentOpacity = 1
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                showSplash = false
            }
        }

        // Start loading user data only on first initialization
        authViewModel.fetchUser()
    }

    private func handleScenePhaseChange(to newPhase: ScenePhase) {
        logger.info("📱 ContentView: Scene phase changed to \(String(describing: newPhase))")

        switch newPhase {
        case .active:
            logger.info("✅ ContentView: App became active")
            authViewModel.fetchUser()

            if authViewModel.appState == .mainApp {
                Task { await refreshMainAppData() }
            }
        case .inactive:
            logger.info("⚠️ ContentView: App is inactive")
        case .background:
            logger.info("⏸️ ContentView: App moved to background")
        @unknown default:
            logger.warning("❓ ContentView: Unknown scene phase")
        }
    }

    private func handleAppStateChange(to newState: AppState) {
        logger.info("🔄 ContentView: App state changed to \(String(describing: newState))")

        if newState == .mainApp && !hasLoadedMainAppData {
            logger.info("🎯 ContentView: Entering main app, loading data...")
            hasLoadedMainAppData = true
            Task { await refreshMainAppData() }
        }
    }

    @MainActor
    private func refreshMainAppData() async {
        logger.info("🔄 ContentView: Starting data refresh...")

        // Always fetch workout data to ensure it's up to date
        await workoutsViewModel.fetchWorkoutPlan()

        // Fetch other data
        nutritionViewModel.fetchNutritionPlan()
        kineViewModel.fetchKineData()
        kineViewModel.fetchFavorites()

        logger.info("✅ ContentView: Data refresh completed - Workouts: \(workoutsViewModel.workoutSessions.count)")
    }
}

// MARK: - App Background

private struct AppBackground: View {
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: [
                    Color(hex: "0A0A1E"),
                    Color(hex: "12122A"),
                    Color(hex: "1A1A3E"),
                    Color(hex: "0F0F23")
                ],
                startPoint: animateGradient ? .topLeading : .top,
                endPoint: animateGradient ? .bottomTrailing : .bottom
            )
            .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animateGradient)

            // Subtle mesh gradient effect
            GeometryReader { geo in
                ZStack {
                    // Primary glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.theme.primary.opacity(0.15),
                                    Color.theme.primary.opacity(0.05),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.6
                            )
                        )
                        .frame(width: geo.size.width * 1.2)
                        .offset(x: animateGradient ? -geo.size.width * 0.2 : geo.size.width * 0.1, y: -geo.size.height * 0.2)

                    // Secondary accent glow
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.theme.accent.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: geo.size.width * 0.5
                            )
                        )
                        .frame(width: geo.size.width * 0.8)
                        .offset(x: animateGradient ? geo.size.width * 0.3 : 0, y: geo.size.height * 0.4)
                }
            }

            // Noise texture overlay for depth
            Rectangle()
                .fill(.black.opacity(0.02))
                .background(
                    Image(systemName: "circle.grid.3x3.fill")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundColor(.white.opacity(0.02))
                        .frame(width: 4, height: 4)
                )
        }
        .onAppear { animateGradient = true }
    }
}

// MARK: - Splash View

private struct SplashView: View {
    @State private var logoScale: CGFloat = 0.8
    @State private var logoOpacity: Double = 0
    @State private var ringProgress: CGFloat = 0
    @State private var taglineOpacity: Double = 0

    var body: some View {
        ZStack {
            // Dynamic animated background
            DarkPurpleAnimatedBackground(intensity: 0.7)
                .ignoresSafeArea()

            VStack(spacing: 24) {
                Spacer()

                // Logo with animated ring
                ZStack {
                    // Animated progress ring
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            AngularGradient(
                                colors: [
                                    Color.theme.primary,
                                    Color.theme.accent,
                                    Color.theme.primary.opacity(0.5),
                                    Color.theme.primary
                                ],
                                center: .center
                            ),
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 130, height: 130)
                        .rotationEffect(.degrees(-90))

                    // Logo container
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .frame(width: 110, height: 110)
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color.theme.primary.opacity(0.2),
                                            Color.theme.accent.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 32, style: .continuous)
                                .strokeBorder(
                                    LinearGradient(
                                        colors: [
                                            Color.white.opacity(0.3),
                                            Color.white.opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 1
                                )
                        )
                        .shadow(color: Color.theme.primary.opacity(0.4), radius: 30, x: 0, y: 15)

                    // App logo — dp monogram with white-to-teal gradient
                    Image("DipoddiLogo")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 56, height: 56)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .shadow(color: Color.theme.primary.opacity(0.5), radius: 12)
                }
                .scaleEffect(logoScale)
                .opacity(logoOpacity)

                // App name
                VStack(spacing: 8) {
                    Text("DiPODDI")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.9)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .tracking(6)

                    Image("DipoddiTagline")
                        .renderingMode(.template)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(height: 14)
                        .foregroundColor(.white.opacity(0.6))
                }
                .opacity(taglineOpacity)

                Spacer()

                // Loading indicator
                VStack(spacing: 12) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)

                    Text("loading.please_wait".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
                .opacity(taglineOpacity)
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            // Animate logo entrance
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.1)) {
                logoScale = 1.0
                logoOpacity = 1.0
            }

            // Animate ring progress
            withAnimation(.easeOut(duration: 1.2).delay(0.2)) {
                ringProgress = 1.0
            }

            // Animate tagline
            withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
                taglineOpacity = 1.0
            }
        }
    }
}

// MARK: - Loading State View

private struct LoadingStateView: View {
    @State private var pulse = false
    @State private var dots = ""

    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack(spacing: 32) {
            // Pulsing logo
            ZStack {
                // Outer glow rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.theme.primary.opacity(0.1 - Double(index) * 0.03), lineWidth: 2)
                        .frame(width: 120 + CGFloat(index * 20), height: 120 + CGFloat(index * 20))
                        .scaleEffect(pulse ? 1.1 : 1.0)
                        .animation(
                            .easeInOut(duration: 1.5)
                            .repeatForever(autoreverses: true)
                            .delay(Double(index) * 0.2),
                            value: pulse
                        )
                }

                // Logo container
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 100, height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 28, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.15), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)

                Image("DipoddiLogo")
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: Color.theme.primary.opacity(0.5), radius: 10)
                    .scaleEffect(pulse ? 1.05 : 0.95)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: pulse)
            }

            VStack(spacing: 16) {
                // Custom progress indicator
                HStack(spacing: 8) {
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .fill(Color.theme.primary)
                            .frame(width: 8, height: 8)
                            .scaleEffect(pulse && index == Int(Date().timeIntervalSince1970) % 3 ? 1.3 : 0.7)
                            .animation(.easeInOut(duration: 0.4), value: pulse)
                    }
                }

                Text("\("common.preparing_dashboard".localizedString)\(dots)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .animation(.none, value: dots)
            }
        }
        .padding(40)
        .background(
            RoundedRectangle(cornerRadius: 32, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .fill(Color(hex: "1A1A2E").opacity(0.3))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 32, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 40, x: 0, y: 20)
        .onAppear { pulse = true }
        .onReceive(timer) { _ in
            if dots.count >= 3 {
                dots = ""
            } else {
                dots += "."
            }
        }
    }
}

// MARK: - Preview

/// Simple preview wrapper to avoid Bus error crashes
private struct ContentViewPreviewWrapper: View {
    @StateObject private var authVM = AuthViewModel()
    @StateObject private var langManager = LanguageManager()
    @StateObject private var themeManager = ThemeManager()
    @StateObject private var workoutsVM = WorkoutsViewModel()
    @StateObject private var nutritionVM = NutritionViewModel()
    @StateObject private var kineVM = KineViewModel()
    @StateObject private var profileVM = ProfileViewModel()

    var body: some View {
        ContentView()
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
            .environmentObject(workoutsVM)
            .environmentObject(nutritionVM)
            .environmentObject(kineVM)
            .environmentObject(profileVM)
            .preferredColorScheme(.dark)
    }
}

#Preview("Content View") {
    ContentViewPreviewWrapper()
}
