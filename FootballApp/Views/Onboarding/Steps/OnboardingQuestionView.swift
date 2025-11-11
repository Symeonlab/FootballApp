//
//  OnboardingQuestionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct OnboardingQuestionView<Content: View>: View {
    let titleKey: LocalizedStringKey
    let subtitleKey: LocalizedStringKey?
    let buttonTitleKey: LocalizedStringKey
    var isButtonEnabled: Bool
    let action: () -> Void
    @ViewBuilder let content: () -> Content

    init(
        titleKey: LocalizedStringKey,
        subtitleKey: LocalizedStringKey? = nil,
        buttonTitleKey: LocalizedStringKey,
        isButtonEnabled: Bool = true,
        action: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.titleKey = titleKey
        self.subtitleKey = subtitleKey
        self.buttonTitleKey = buttonTitleKey
        self.isButtonEnabled = isButtonEnabled
        self.action = action
        self.content = content
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header Section
            VStack(spacing: 12) {
                Text(titleKey)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.theme.textPrimary)
                
                if let subtitleKey = subtitleKey {
                    Text(subtitleKey)
                        .font(.body)
                        .foregroundColor(Color.theme.textSecondary)
                        .multilineTextAlignment(.center)
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 20)
            
            // Content Section
            ScrollView {
                VStack(spacing: 16) {
                    content()
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            
            // Bottom Button Section
            VStack(spacing: 0) {
                Divider()
                    .background(Color.theme.textSecondary.opacity(0.1))
                
                PrimaryActionButton(
                    title: buttonTitleKey,
                    isEnabled: isButtonEnabled,
                    action: action
                )
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 24)
            }
            .background(Color.theme.surface)
        }
        .background(Color.theme.background.ignoresSafeArea())
    }
}

#Preview {
    OnboardingQuestionView(
        titleKey: "What's your goal?",
        subtitleKey: "Help us personalize your experience",
        buttonTitleKey: "Continue",
        isButtonEnabled: true
    ) {
        print("Continue tapped")
    } content: {
        VStack(spacing: 12) {
            OptionCard(
                title: "Build Muscle",
                subtitle: "Gain strength and size",
                icon: "figure.strengthtraining.traditional",
                isSelected: true
            ) {
                print("Selected")
            }
            
            OptionCard(
                title: "Lose Weight",
                subtitle: "Burn fat and get lean",
                icon: "flame.fill",
                isSelected: false
            ) {
                print("Selected")
            }
            
            OptionCard(
                title: "Stay Fit",
                subtitle: "Maintain your current fitness",
                icon: "heart.fill",
                isSelected: false
            ) {
                print("Selected")
            }
        }
    }
}
