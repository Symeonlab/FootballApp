//
//  HormonalIssuesView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
struct HormonalIssuesView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.hormonal_issues.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.hormonalIssues != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 15) {
                ForEach(viewModel.options?.hormonal_issues ?? []) { option in
                    SelectionOptionCard(
                        title: option.name,
                        imageName: "exclamationmark.triangle.fill",
                        isSelected: viewModel.data.hormonalIssues == option.key,
                        action: {
                            viewModel.data.hormonalIssues = option.key
                        }
                    )
                }
            }
        }
    }
}
