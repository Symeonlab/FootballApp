//
//  AppIntroductionView.swift
//  FootballApp
//
//  Created by AI Assistant on 16/11/2025.
//

import SwiftUI

// MARK: - Main Introduction Flow
struct AppIntroductionView: View {
    @Binding var showIntro: Bool
    @Binding var hasSeenIntro: Bool
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var currentPage = 0
    @State private var animateContent = false
    
    private let totalPages = 4 // Welcome, Features, Language, Ready
    
    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color.theme.primary,
                    Color.theme.accent,
                    Color.theme.primary.opacity(0.8)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Content
            TabView(selection: $currentPage) {
                WelcomePage()
                    .tag(0)
                
                FeaturesPage()
                    .tag(1)
                
                LanguageSelectionPage()
                    .tag(2)
                
                ReadyPage(onGetStarted: {
                    completeIntro()
                })
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .ignoresSafeArea()
            
            // Custom Page Indicator & Skip Button
            VStack {
                // Skip Button
                if currentPage < totalPages - 1 {
                    HStack {
                        Spacer()
                        Button {
                            completeIntro()
                        } label: {
                            Text("intro.skip")
                                .font(.subheadline.bold())
                                .foregroundColor(.white.opacity(0.9))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.2))
                                )
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 50)
                    }
                }
                
                Spacer()
                
                // Page Indicator
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Capsule()
                            .fill(currentPage == index ? Color.white : Color.white.opacity(0.4))
                            .frame(width: currentPage == index ? 24 : 8, height: 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                animateContent = true
            }
        }
    }
    
    private func completeIntro() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            hasSeenIntro = true
            showIntro = false
        }
    }
}

// MARK: - Welcome Page
struct WelcomePage: View {
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Logo & App Name
            VStack(spacing: 24) {
                // Animated Logo
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 160, height: 160)
                        .blur(radius: 30)
                        .scaleEffect(animate ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 140, height: 140)
                        .shadow(color: .black.opacity(0.3), radius: 40, x: 0, y: 20)
                    
                    Text("D")
                        .font(.system(size: 70, weight: .bold, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .scaleEffect(animate ? 1.0 : 0.8)
                .opacity(animate ? 1.0 : 0.0)
                
                VStack(spacing: 12) {
                    Text("intro.welcome.title")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("intro.welcome.subtitle")
                        .font(.title3.weight(.medium))
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                }
                .opacity(animate ? 1.0 : 0.0)
                .offset(y: animate ? 0 : 20)
            }
            
            Spacer()
            
            // Swipe Hint
            VStack(spacing: 12) {
                Image(systemName: "chevron.left")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.7))
                    .rotationEffect(.degrees(-90))
                
                Text("intro.swipe")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            .opacity(animate ? 1.0 : 0.0)
            .padding(.bottom, 80)
        }
        .padding(.horizontal, 40)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animate = true
            }
        }
    }
}

// MARK: - Features Page
struct FeaturesPage: View {
    @State private var animate = false
    
    private let features = [
        AppIntroFeature(
            icon: "figure.run",
            title: "intro.features.training.title",
            description: "intro.features.training.description",
            color: Color.green
        ),
        AppIntroFeature(
            icon: "fork.knife",
            title: "intro.features.nutrition.title",
            description: "intro.features.nutrition.description",
            color: Color.orange
        ),
        AppIntroFeature(
            icon: "heart.fill",
            title: "intro.features.recovery.title",
            description: "intro.features.recovery.description",
            color: Color.red
        ),
        AppIntroFeature(
            icon: "chart.line.uptrend.xyaxis",
            title: "intro.features.progress.title",
            description: "intro.features.progress.description",
            color: Color.blue
        )
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 16) {
                Text("intro.features.header")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("intro.features.subheader")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 80)
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : -20)
            
            // Features Grid
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                ForEach(Array(features.enumerated()), id: \.element.id) { index, feature in
                    AppIntroFeatureCard(feature: feature)
                        .opacity(animate ? 1.0 : 0.0)
                        .offset(y: animate ? 0 : 30)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                                .delay(Double(index) * 0.1 + 0.3),
                            value: animate
                        )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .onAppear {
            animate = true
        }
    }
}

struct AppIntroFeature: Identifiable {
    let id = UUID()
    let icon: String
    let title: String
    let description: String
    let color: Color
}

struct AppIntroFeatureCard: View {
    let feature: AppIntroFeature
    
    var body: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 80, height: 80)
                
                Image(systemName: feature.icon)
                    .font(.system(size: 36))
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 8) {
                Text(LocalizedStringKey(feature.title))
                    .font(.headline.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text(LocalizedStringKey(feature.description))
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.15))
        )
    }
}

// MARK: - Language Selection Page
struct LanguageSelectionPage: View {
    @EnvironmentObject var languageManager: LanguageManager
    @State private var animate = false
    
    private let languages: [(AppLanguage, String, String)] = [
        (.english, "English", "🇬🇧"),
        (.french, "Français", "🇫🇷"),
        (.arabic, "العربية", "🇸🇦")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "globe")
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .scaleEffect(animate ? 1.0 : 0.8)
                    .opacity(animate ? 1.0 : 0.0)
                
                Text("intro.language.title")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("intro.language.subtitle")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 80)
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : -20)
            
            // Language Options
            VStack(spacing: 16) {
                ForEach(Array(languages.enumerated()), id: \.element.0.id) { index, language in
                    LanguageButton(
                        language: language.0,
                        name: language.1,
                        flag: language.2,
                        isSelected: languageManager.selected == language.0
                    ) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                            languageManager.selected = language.0
                        }
                    }
                    .opacity(animate ? 1.0 : 0.0)
                    .offset(x: animate ? 0 : -30)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1 + 0.3),
                        value: animate
                    )
                }
            }
            .padding(.horizontal, 24)
            
            Spacer()
        }
        .onAppear {
            animate = true
        }
    }
}

struct LanguageButton: View {
    let language: AppLanguage
    let name: String
    let flag: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(flag)
                    .font(.system(size: 40))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    
                    Text(language.rawValue.uppercased())
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(isSelected ? Color.white.opacity(0.3) : Color.white.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                isSelected ? Color.white.opacity(0.5) : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Ready Page
struct ReadyPage: View {
    let onGetStarted: () -> Void
    @State private var animate = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Success Icon
            ZStack {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 180, height: 180)
                    .blur(radius: 30)
                    .scaleEffect(animate ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: animate)
                
                Circle()
                    .fill(Color.white)
                    .frame(width: 140, height: 140)
                    .shadow(color: .black.opacity(0.3), radius: 40, x: 0, y: 20)
                
                Image(systemName: "checkmark")
                    .font(.system(size: 60, weight: .bold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .scaleEffect(animate ? 1.0 : 0.8)
            .opacity(animate ? 1.0 : 0.0)
            
            // Text
            VStack(spacing: 16) {
                Text("intro.ready.title")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("intro.ready.subtitle")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : 20)
            
            Spacer()
            
            // Get Started Button
            Button(action: onGetStarted) {
                HStack(spacing: 12) {
                    Text("intro.ready.button")
                        .font(.headline.bold())
                    
                    Image(systemName: "arrow.right")
                        .font(.headline)
                }
                .foregroundColor(Color.theme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                )
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 60)
            .opacity(animate ? 1.0 : 0.0)
            .offset(y: animate ? 0 : 30)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.3)) {
                animate = true
            }
        }
    }
}

// MARK: - Preview
#Preview {
    AppIntroductionView(
        showIntro: .constant(true),
        hasSeenIntro: .constant(false)
    )
    .environmentObject(LanguageManager())
}
