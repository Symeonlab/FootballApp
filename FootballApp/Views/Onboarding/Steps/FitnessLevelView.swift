//
//  FitnessLevelView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct FitnessLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.fitness_level.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.level != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.level ?? []) { level in
                    SelectionOptionCard(
                        title: level.name,
                        imageName: "chart.bar.fill",
                        isSelected: viewModel.data.level == level.key,
                        action: {
                            viewModel.data.level = level.key
                        }
                    )
                }
            }
        }
    }
}
