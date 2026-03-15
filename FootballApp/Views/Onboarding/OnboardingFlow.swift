//
//  OnboardingFlow.swift
//  FootballApp
//
//  INSTRUCTIONS: Remove these duplicate declarations from your OnboardingFlow.swift:
//
//  1. DELETE lines 461-530 (ModernOnboardingQuestionView) - it's duplicated in OnboardingEnhancements.swift
//  2. DELETE lines 694-780 (OnboardingIntroView) - use OnboardingIntroView.swift instead
//
//  Keep only ONE of each type in your entire project!
//

import SwiftUI

struct OnboardingFlow: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var viewModel = OnboardingViewModel()

    /// When true, skips Welcome + About You steps (personal info is locked)
    var isUpdateMode: Bool = false

    @State private var selection = 0
    @State private var dragOffset: CGFloat = 0

    private var totalSteps: Int {
        isUpdateMode ? 5 : 7 // Update mode: Sport, Goals, Nutrition, Health, Summary
    }

    var body: some View {
        ZStack {
            // Dynamic animated background
            OnboardingBackground(currentStep: selection, totalSteps: totalSteps)
                .ignoresSafeArea()

            if viewModel.isLoading && viewModel.options == nil {
                OnboardingLoadingView()
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))

            } else if viewModel.options != nil {
                VStack(spacing: 0) {
                    OnboardingProgressHeader(
                        currentStep: selection + 1,
                        totalSteps: totalSteps,
                        onBack: {
                            if selection > 0 {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                    selection -= 1
                                }
                            }
                        },
                        onSkip: {
                            // Skip to final step
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                                selection = totalSteps - 1
                            }
                        }
                    )

                    if isUpdateMode {
                        // Update mode: skip Welcome + About You (personal info locked)
                        TabView(selection: $selection) {
                            // Step 0: Sport & Level
                            SportAndLevelView(viewModel: viewModel, selection: $selection).tag(0)

                            // Step 1: Goals & Training
                            GoalsAndTrainingView(viewModel: viewModel, selection: $selection).tag(1)

                            // Step 2: Nutrition
                            NutritionHabitsView(viewModel: viewModel, selection: $selection).tag(2)

                            // Step 3: Health
                            HealthOverviewView(viewModel: viewModel, selection: $selection).tag(3)

                            // Step 4: Summary & Finish
                            GoalAchievementView(viewModel: viewModel, selection: $selection).tag(4)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    } else {
                        // Full onboarding flow
                        TabView(selection: $selection) {
                            // Step 0: Welcome
                            OnboardingIntroView(selection: $selection).tag(0)

                            // Step 1: About You (Gender + Height + Weight)
                            AboutYouView(viewModel: viewModel, selection: $selection).tag(1)

                            // Step 2: Sport & Level (Discipline + Player Profile + Fitness Level)
                            SportAndLevelView(viewModel: viewModel, selection: $selection).tag(2)

                            // Step 3: Goals & Training (Goal + Ideal Weight + Location + Days)
                            GoalsAndTrainingView(viewModel: viewModel, selection: $selection).tag(3)

                            // Step 4: Nutrition (Diet + Habits + Food Grid)
                            NutritionHabitsView(viewModel: viewModel, selection: $selection).tag(4)

                            // Step 5: Health (Medical + Conditions)
                            HealthOverviewView(viewModel: viewModel, selection: $selection).tag(5)

                            // Step 6: Summary & Finish
                            GoalAchievementView(viewModel: viewModel, selection: $selection).tag(6)
                        }
                        .tabViewStyle(.page(indexDisplayMode: .never))
                    }
                }
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .scale(scale: 0.95)),
                    removal: .opacity
                ))

            } else if let errorMessage = viewModel.errorMessage {
                OnboardingErrorView(
                    errorMessage: errorMessage,
                    onRetry: { viewModel.fetchOnboardingData() }
                )
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .onAppear {
            viewModel.isUpdateMode = isUpdateMode
            if isUpdateMode, let user = authViewModel.currentUser {
                viewModel.loadCurrentProfile(from: user)
            }
            viewModel.fetchOnboardingData()
        }
        .onChange(of: selection) { oldValue, newSelection in
            let generator = UIImpactFeedbackGenerator(style: .soft)
            generator.impactOccurred()
        }
    }
}

// MARK: - Onboarding Background
struct OnboardingBackground: View {
    let currentStep: Int
    let totalSteps: Int
    @State private var animateGradient = false
    @State private var particlePositions: [(x: CGFloat, y: CGFloat)] = []
    
    var gradientColors: [Color] {
        let progress = Double(currentStep) / Double(max(totalSteps, 1))
        
        if progress < 0.33 {
            return [
                Color(hex: "1E1B4B") as Color,
                Color(hex: "312E81") as Color,
                Color(hex: "4338CA") as Color
            ]
        } else if progress < 0.66 {
            return [
                Color(hex: "4C1D95") as Color,
                Color(hex: "6D28D9") as Color,
                Color(hex: "7C3AED") as Color
            ]
        } else {
            return [
                Color(hex: "831843") as Color,
                Color(hex: "BE185D") as Color,
                Color(hex: "DB2777") as Color
            ]
        }
    }
    
    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            GeometryReader { geometry in
                ForEach(0..<8, id: \.self) { index in
                    Circle()
                        .fill(.ultraThinMaterial)
                        .frame(width: CGFloat.random(in: 80...200))
                        .blur(radius: 40)
                        .offset(
                            x: particlePositions.count > index ? particlePositions[index].x : 0,
                            y: particlePositions.count > index ? particlePositions[index].y : 0
                        )
                        .opacity(0.4)
                }
            }
            
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.05)
        }
        .onAppear {
            animateGradient = true
            particlePositions = (0..<8).map { _ in
                (x: CGFloat.random(in: -100...500), y: CGFloat.random(in: -100...900))
            }
            
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                particlePositions = (0..<8).map { _ in
                    (x: CGFloat.random(in: -100...500), y: CGFloat.random(in: -100...900))
                }
            }
        }
    }
}

// MARK: - Progress Header
struct OnboardingProgressHeader: View {
    let currentStep: Int
    let totalSteps: Int
    let onBack: () -> Void
    let onSkip: () -> Void
    
    var progress: Double {
        Double(currentStep) / Double(max(totalSteps, 1))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 16) {
                if currentStep > 1 {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.white)
                            .frame(width: 44, height: 44)
                            .background {
                                Circle()
                                    .fill(.ultraThinMaterial)
                                    .overlay {
                                        Circle()
                                            .stroke(.white.opacity(0.2), lineWidth: 1)
                                    }
                            }
                    }
                    .transition(.opacity.combined(with: .scale))
                } else {
                    Color.clear.frame(width: 44, height: 44)
                }
                
                Spacer()
                
                StepIndicator(current: currentStep, total: totalSteps)
                
                Spacer()
                
                Button(action: onSkip) {
                    Text("common.skip".localizedString)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white.opacity(0.8))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background {
                            Capsule()
                                .fill(.ultraThinMaterial)
                        }
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)
            .padding(.bottom, 16)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(
                            LinearGradient(
                                colors: [.white, .white.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geometry.size.width * progress, height: 4)
                        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: progress)
                    
                    Capsule()
                        .fill(.white.opacity(0.5))
                        .frame(width: geometry.size.width * progress, height: 4)
                        .blur(radius: 8)
                }
            }
            .frame(height: 4)
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - Step Indicator
struct StepIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(current)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
            
            Text("/")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
            
            Text("\(total)")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background {
            Capsule()
                .fill(.ultraThinMaterial)
                .overlay {
                    Capsule()
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Loading View
struct OnboardingLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(.white.opacity(pulseOpacity - Double(index) * 0.15), lineWidth: 2)
                        .frame(width: 100 + CGFloat(index * 40), height: 100 + CGFloat(index * 40))
                        .scaleEffect(scale)
                }
                
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [.white, .white.opacity(0.3), .clear],
                            center: .center
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                
                Image(systemName: "figure.run")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("onboarding.preparing_journey".localizedString)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("onboarding.setting_up_experience".localizedString)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                scale = 1.1
                pulseOpacity = 0.8
            }
        }
    }
}

// MARK: - Error View
struct OnboardingErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    @State private var shake = false
    
    var body: some View {
        VStack(spacing: 32) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 120, height: 120)
                    .overlay {
                        Circle()
                            .stroke(.white.opacity(0.2), lineWidth: 2)
                    }
                
                Image(systemName: "wifi.exclamationmark")
                    .font(.system(size: 50))
                    .foregroundColor(.white)
            }
            .modifier(ShakeEffect(shakes: shake ? 2 : 0))
            
            VStack(spacing: 12) {
                Text("onboarding.connection_error".localizedString)
                    .font(.title.bold())
                    .foregroundColor(.white)
                
                Text(errorMessage)
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.white.opacity(0.8))
                    .padding(.horizontal, 40)
            }
            
            Button(action: {
                shake.toggle()
                onRetry()
            }) {
                HStack(spacing: 12) {
                    Image(systemName: "arrow.clockwise")
                    Text("onboarding.try_again".localizedString)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 40)
        }
    }
}

// MARK: - Shake Effect
struct ShakeEffect: GeometryEffect {
    var shakes: CGFloat
    
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 10, y: 0))
    }
}

// NOTE: OnboardingIntroView is defined in OnboardingIntroView.swift
// NOTE: ModernOnboardingQuestionView is defined in OnboardingEnhancements.swift
// DO NOT duplicate them here!

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return OnboardingFlow()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}

