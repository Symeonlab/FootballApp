//
//  TrainingLocationView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
struct TrainingLocationView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.location.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.trainingLocation != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.location ?? []) { location in
                    SelectionOptionCard(
                        title: location.name,
                        imageName: "house.fill",
                        isSelected: viewModel.data.trainingLocation == location.key,
                        action: {
                            viewModel.data.trainingLocation = location.key
                        }
                    )
                }
            }
        }
    }
}
