//
//  OnboardingIntroView.swift
//  FootballApp
//
//  Enhanced introduction explaining the comprehensive onboarding process
//

import SwiftUI

struct OnboardingIntroView: View {
    @Binding var selection: Int
    @State private var animateContent = false
    @State private var currentFeature = 0
    
    let features = [
        OnboardingFeature(
            icon: "figure.run",
            title: "Programme d'Entraînement",
            description: "Créez votre plan personnalisé basé sur votre discipline, niveau et objectifs",
            color: Color(hex: "4338CA")
        ),
        OnboardingFeature(
            icon: "leaf.fill",
            title: "Nutrition Prophétique",
            description: "Recevez des conseils nutritionnels basés sur la médecine prophétique adaptés à votre métabolisme",
            color: Color(hex: "7C3AED")
        ),
        OnboardingFeature(
            icon: "heart.text.square.fill",
            title: "Suivi Personnalisé",
            description: "Vos antécédents médicaux et familiaux pour des recommandations sur-mesure",
            color: Color(hex: "DB2777")
        ),
        OnboardingFeature(
            icon: "sparkles",
            title: "Objectifs Réalisables",
            description: "Définissez et atteignez vos objectifs avec un plan adapté à votre morphologie",
            color: Color(hex: "BE185D")
        )
    ]
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                Spacer()
                
                // App Logo/Icon
                ZStack {
                    // Animated rings
                    ForEach(0..<3, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        features[currentFeature].color.opacity(0.6),
                                        features[currentFeature].color.opacity(0.2),
                                        Color.clear
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 2
                            )
                            .frame(width: 140 + CGFloat(index * 30), height: 140 + CGFloat(index * 30))
                            .scaleEffect(animateContent ? 1.0 : 0.8)
                            .opacity(animateContent ? 0.6 - Double(index) * 0.2 : 0)
                            .animation(
                                .easeInOut(duration: 2)
                                    .repeatForever(autoreverses: true)
                                    .delay(Double(index) * 0.2),
                                value: animateContent
                            )
                    }
                    
                    // Center icon
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 100, height: 100)
                            .overlay {
                                Circle()
                                    .stroke(.white.opacity(0.3), lineWidth: 2)
                            }
                        
                        Image(systemName: features[currentFeature].icon)
                            .font(.system(size: 40, weight: .semibold))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [.white, features[currentFeature].color],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .symbolEffect(.bounce, value: currentFeature)
                    }
                }
                .scaleEffect(animateContent ? 1 : 0.5)
                .opacity(animateContent ? 1 : 0)
                .padding(.bottom, 60)
                
                // Title
                VStack(spacing: 16) {
                    Text("Bienvenue dans")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Text("Votre Parcours Santé")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .opacity(animateContent ? 1 : 0)
                .offset(y: animateContent ? 0 : 20)
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                
                // Feature cards carousel
                TabView(selection: $currentFeature) {
                    ForEach(features.indices, id: \.self) { index in
                        FeatureCard(feature: features[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .frame(height: 200)
                .opacity(animateContent ? 1 : 0)
                
                // Page indicator
                HStack(spacing: 8) {
                    ForEach(features.indices, id: \.self) { index in
                        Circle()
                            .fill(currentFeature == index ? .white : .white.opacity(0.3))
                            .frame(width: currentFeature == index ? 10 : 6, height: currentFeature == index ? 10 : 6)
                            .animation(.spring(response: 0.3), value: currentFeature)
                    }
                }
                .padding(.vertical, 20)
                
                // Info about questions
                VStack(spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: "clock.fill")
                            .font(.caption)
                        Text("5-7 minutes")
                            .font(.caption.weight(.semibold))
                    }
                    .foregroundColor(.white.opacity(0.7))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background {
                        Capsule()
                            .fill(.ultraThinMaterial)
                    }
                    
                    Text("Nous allons vous poser quelques questions pour personnaliser votre expérience")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(animateContent ? 1 : 0)
                
                Spacer()
                
                // Start button
                Button(action: {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.85)) {
                        selection += 1
                    }
                }) {
                    HStack(spacing: 12) {
                        Text("Commencer")
                            .font(.headline.bold())
                        
                        Image(systemName: "arrow.right")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        features[currentFeature].color.opacity(0.8),
                                        features[currentFeature].color.opacity(0.6)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .overlay {
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .stroke(.white.opacity(0.3), lineWidth: 1)
                            }
                    }
                    .shadow(color: features[currentFeature].color.opacity(0.5), radius: 20, x: 0, y: 10)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
                .opacity(animateContent ? 1 : 0)
                .scaleEffect(animateContent ? 1 : 0.9)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.75).delay(0.2)) {
                animateContent = true
            }
            
            // Auto-rotate features
            Timer.scheduledTimer(withTimeInterval: 3.5, repeats: true) { _ in
                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                    currentFeature = (currentFeature + 1) % features.count
                }
            }
        }
    }
}

// MARK: - Feature Card
struct FeatureCard: View {
    let feature: OnboardingFeature
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                Image(systemName: feature.icon)
                    .font(.title2)
                    .foregroundColor(feature.color)
                
                Text(feature.title)
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            Text(feature.description)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.leading)
                .lineLimit(3)
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    feature.color.opacity(0.5),
                                    feature.color.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - Onboarding Feature Model
struct OnboardingFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

// MARK: - Preview
#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return ZStack {
        OnboardingBackground(currentStep: 0, totalSteps: 35)
            .ignoresSafeArea()
        
        OnboardingIntroView(selection: .constant(0))
    }
    .environmentObject(authVM)
    .environmentObject(langManager)
    .environmentObject(themeManager)
    .preferredColorScheme(.dark)
}
