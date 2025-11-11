//
//  MorphologyView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//
import SwiftUI
import Combine

struct MorphologyView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.morphology.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.morphology != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.morphology ?? []) { morph in
                    SelectionOptionCard(
                        title: morph.name,
                        imageName: "person.fill",
                        isSelected: viewModel.data.morphology == morph.key,
                        action: {
                            viewModel.data.morphology = morph.key
                        }
                    )
                }
            }
        }
    }
}
