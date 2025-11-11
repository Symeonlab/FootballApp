//
//  VegetarianView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
struct VegetarianView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.vegetarian.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.isVegetarian != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                SelectionOptionCard(
                    title: String(localized: "common.yes"),
                    imageName: "checkmark.circle.fill",
                    isSelected: viewModel.data.isVegetarian == true,
                    action: {
                        viewModel.data.isVegetarian = true
                    }
                )
                SelectionOptionCard(
                    title: String(localized: "common.no"),
                    imageName: "xmark.circle.fill",
                    isSelected: viewModel.data.isVegetarian == false,
                    action: {
                        viewModel.data.isVegetarian = false
                    }
                )
            }
        }
    }
}
#Preview {
    VegetarianView(
        viewModel: OnboardingViewModel(),
        selection: .constant(0)
    )
}

