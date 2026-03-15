//
//  OnboardingEnhancements.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 29/11/2025.
//

//
//  OnboardingEnhancements.swift
//  FootballApp
//
//  Modern onboarding UI components - works alongside existing OnboardingFlow
//

import SwiftUI

// MARK: - Onboarding Background
struct ModernOnboardingBackground: View {
    let currentStep: Int
    let totalSteps: Int
    @State private var animateGradient = false
    @State private var particlePositions: [(x: CGFloat, y: CGFloat)] = []
    
    var gradientColors: [Color] {
        let progress = Double(currentStep) / Double(max(totalSteps, 1))
        
        if progress < 0.33 {
            return [
                Color(red: 0.12, green: 0.11, blue: 0.29),
                Color(red: 0.19, green: 0.18, blue: 0.51),
                Color(red: 0.26, green: 0.22, blue: 0.79)
            ]
        } else if progress < 0.66 {
            return [
                Color(red: 0.30, green: 0.11, blue: 0.58),
                Color(red: 0.43, green: 0.16, blue: 0.85),
                Color(red: 0.49, green: 0.23, blue: 0.93)
            ]
        } else {
            return [
                Color(red: 0.51, green: 0.09, blue: 0.26),
                Color(red: 0.74, green: 0.09, blue: 0.36),
                Color(red: 0.86, green: 0.16, blue: 0.47)
            ]
        }
    }
    
    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: gradientColors,
                startPoint: animateGradient ? .topLeading : .bottomLeading,
                endPoint: animateGradient ? .bottomTrailing : .topTrailing
            )
            .animation(.easeInOut(duration: 5).repeatForever(autoreverses: true), value: animateGradient)
            
            // Floating orbs
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
            
            // Noise texture overlay
            Rectangle()
                .fill(.ultraThinMaterial)
                .opacity(0.05)
        }
        .onAppear {
            animateGradient = true
            
            // Generate random particle positions
            particlePositions = (0..<8).map { _ in
                (x: CGFloat.random(in: -100...500), y: CGFloat.random(in: -100...900))
            }
            
            // Animate particles
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                particlePositions = (0..<8).map { _ in
                    (x: CGFloat.random(in: -100...500), y: CGFloat.random(in: -100...900))
                }
            }
        }
    }
}

// MARK: - Progress Header
struct ModernOnboardingProgressHeader: View {
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
                // Back button
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
                
                // Step indicator
                OnboardingStepIndicator(current: currentStep, total: totalSteps)
                
                Spacer()
                
                // Skip button
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
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .frame(height: 4)
                    
                    // Progress
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
                    
                    // Glow
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
struct OnboardingStepIndicator: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Text("\(current)")
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
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
struct ModernOnboardingLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    @State private var pulseOpacity: Double = 0.5
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                // Pulse rings
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(.white.opacity(pulseOpacity - Double(index) * 0.15), lineWidth: 2)
                        .frame(width: 100 + CGFloat(index * 40), height: 100 + CGFloat(index * 40))
                        .scaleEffect(scale)
                }
                
                // Rotating ring
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
                
                // Center icon
                Image(systemName: "figure.run")
                    .font(.system(size: 36, weight: .semibold))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 12) {
                Text("common.preparing_journey".localizedString)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                Text("loading.processing".localizedString)
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
struct ModernOnboardingErrorView: View {
    let errorMessage: String
    let onRetry: () -> Void
    
    @State private var shake = false
    
    var body: some View {
        VStack(spacing: 32) {
            // Error icon
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
            .modifier(OnboardingShakeEffect(shakes: shake ? 2 : 0))
            
            VStack(spacing: 12) {
                Text("error.connection".localizedString)
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
                    Text("common.retry".localizedString)
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
struct OnboardingShakeEffect: GeometryEffect {
    var shakes: CGFloat
    
    var animatableData: CGFloat {
        get { shakes }
        set { shakes = newValue }
    }
    
    func effectValue(size: CGSize) -> ProjectionTransform {
        ProjectionTransform(CGAffineTransform(translationX: sin(shakes * .pi * 4) * 10, y: 0))
    }
}

// MARK: - Modern Question View
struct ModernOnboardingQuestionView<Content: View>: View {
    let title: LocalizedStringKey
    let subtitle: LocalizedStringKey?
    let buttonTitle: LocalizedStringKey
    let action: () -> Void
    @ViewBuilder let content: () -> Content
    
    @State private var animateContent = false
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            
            // Content
            VStack(spacing: 24) {
                // Title section
                VStack(spacing: 12) {
                    Text(title)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                    }
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                
                // Custom content
                content()
                    .opacity(animateContent ? 1 : 0)
                    .offset(y: animateContent ? 0 : 30)
            }
            .padding(.horizontal, 24)
            
            Spacer()
            
            // Continue button
            Button(action: action) {
                HStack(spacing: 12) {
                    Text(buttonTitle)
                        .font(.headline.bold())
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(.white.opacity(0.2))
                        .overlay {
                            RoundedRectangle(cornerRadius: 20, style: .continuous)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        }
                }
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 40)
            .opacity(animateContent ? 1 : 0)
            .offset(y: animateContent ? 0 : 40)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                animateContent = true
            }
        }
    }
}

// MARK: - Selection Card
struct OnboardingSelectionCardView: View {
    let icon: String
    let title: String
    let subtitle: String?
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                // Icon
                ZStack {
                    Circle()
                        .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(.white)
                }
                
                // Text
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                // Selection indicator
                ZStack {
                    Circle()
                        .stroke(.white.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 16, height: 16)
                            .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? .white.opacity(0.2) : .white.opacity(0.1))
                    .overlay {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .stroke(
                                isSelected ? .white.opacity(0.5) : .white.opacity(0.2),
                                lineWidth: isSelected ? 2 : 1
                            )
                    }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.02 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Multi-Selection Chip
struct OnboardingChipView: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundColor(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background {
                    Capsule()
                        .fill(isSelected ? .white.opacity(0.3) : .white.opacity(0.1))
                        .overlay {
                            Capsule()
                                .stroke(
                                    isSelected ? .white.opacity(0.5) : .white.opacity(0.2),
                                    lineWidth: isSelected ? 2 : 1
                                )
                        }
                }
        }
        .buttonStyle(.plain)
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Slider View
struct OnboardingSliderView: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let unit: String
    let icon: String
    
    var body: some View {
        VStack(spacing: 20) {
            // Value display
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.8))
                
                Text("\(Int(value))")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(unit)
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // Slider
            Slider(value: $value, in: range, step: step)
                .tint(.white)
            
            // Range labels
            HStack {
                Text("\(Int(range.lowerBound)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                
                Spacer()
                
                Text("\(Int(range.upperBound)) \(unit)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(.white.opacity(0.2), lineWidth: 1)
                }
        }
    }
}

// MARK: - Preview
#Preview("Onboarding Enhancements") {
    ZStack {
        ModernOnboardingBackground(currentStep: 5, totalSteps: 18)
            .ignoresSafeArea()
        
        VStack {
            ModernOnboardingProgressHeader(
                currentStep: 5,
                totalSteps: 18,
                onBack: {},
                onSkip: {}
            )
            
            Spacer()
            
            VStack(spacing: 16) {
                OnboardingSelectionCardView(
                    icon: "person.fill",
                    title: "Male",
                    subtitle: "Select your gender",
                    isSelected: true,
                    action: {}
                )
                
                OnboardingSelectionCardView(
                    icon: "person.fill",
                    title: "Female",
                    subtitle: nil,
                    isSelected: false,
                    action: {}
                )
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
    }
}
