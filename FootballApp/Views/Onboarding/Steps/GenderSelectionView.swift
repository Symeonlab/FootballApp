//
//  GenderSelectionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct GenderSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.gender.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next"
        ) {
            withAnimation {
                selection += 1
            }
        } content: {
            HStack(spacing: 20) {
                GenderCard(
                    genderKey: "HOMME",
                    imageName: "male-icon", // Use an image from your Assets
                    isSelected: viewModel.data.gender == "HOMME"
                ) {
                    viewModel.data.gender = "HOMME"
                }
                GenderCard(
                    genderKey: "FEMME",
                    imageName: "female-icon", // Use an image from your Assets
                    isSelected: viewModel.data.gender == "FEMME"
                ) {
                    viewModel.data.gender = "FEMME"
                }
            }
        }
    }
}

#Preview {
    GenderSelectionView(
        viewModel: OnboardingViewModel(),
        selection: .constant(0)
    )
}
