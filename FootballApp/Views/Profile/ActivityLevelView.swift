//
//  ActivityLevelView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct ActivityLevelView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.activity_level.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.activityLevel != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.activity_level ?? []) { level in
                    SelectionOptionCard(
                        title: level.name,
                        imageName: "flame.fill",
                        isSelected: viewModel.data.activityLevel == level.key,
                        action: {
                            viewModel.data.activityLevel = level.key
                        }
                    )
                }
            }
        }
    }
}
