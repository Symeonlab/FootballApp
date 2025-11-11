//
//  GoalSelectionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI
struct GoalSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.goal.title",
            subtitleKey: "onboarding.goal.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.goal != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.goal ?? []) { goal in
                    SelectionOptionCard(
                        title: goal.name,
                        imageName: "flag.checkered",
                        isSelected: viewModel.data.goal == goal.key,
                        action: {
                            viewModel.data.goal = goal.key
                        }
                    )
                }
            }
        }
    }
}
#Preview {
    GoalSelectionView(
        viewModel: OnboardingViewModel(),
        selection: .constant(0)
    )
}
