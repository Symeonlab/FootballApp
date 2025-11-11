//
//  DisciplineSelectionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI
struct DisciplineSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.discipline.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.discipline != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.discipline ?? []) { discipline in
                    SelectionOptionCard(
                        title: discipline.name,
                        imageName: "sportscourt.fill",
                        isSelected: viewModel.data.discipline == discipline.key,
                        action: {
                            viewModel.data.discipline = discipline.key
                        }
                    )
                }
            }
        }
    }
}
