//
//  TrainingPreferencesView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
struct TrainingPreferencesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    @State private var preferences: [String] = []
    
    private var preferenceOptions: [OnboardingOption] {
        let location = viewModel.data.trainingLocation
        
        // --- FIX: Use 'options?' ---
        if location == "SI MUSCULATION EN SALLE" {
            return viewModel.options?.gym_preferences ?? []
        } else if location == "SI CARDIO EN SALLE" {
            return viewModel.options?.cardio_preferences ?? []
        }
        return []
    }

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.preferences.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: !preferences.isEmpty,
            action: {
                viewModel.data.gymPreferences = preferences
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(preferenceOptions) { option in
                    MultiSelectionButton(
                        title: option.name,
                        isSelected: preferences.contains(option.key),
                        action: {
                            if preferences.contains(option.key) {
                                preferences.removeAll { $0 == option.key }
                            } else {
                                preferences.append(option.key)
                            }
                        }
                    )
                }
            }
        }
        .onAppear {
            self.preferences = viewModel.data.gymPreferences ?? []
        }
    }
}
