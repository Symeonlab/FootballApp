//
//  PlayerProfileSelectionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI
import Combine

struct PlayerProfileSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int

    private var profileGroups: [String] {
        viewModel.options?.player_profiles?.keys.sorted() ?? []
    }

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.position.title", 
            subtitleKey: "onboarding.position.subtitle", 
            buttonTitleKey: "common.next",
            isButtonEnabled: viewModel.data.position != nil,
            action: {
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 20) {
                ForEach(profileGroups, id: \.self) { groupName in
                    VStack(alignment: .leading, spacing: 10) {
                        Text(groupName)
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal, 4)
                        
                        ForEach(viewModel.options?.player_profiles?[groupName] ?? []) { profile in
                            SelectionOptionCard(
                                title: profile.name,
                                imageName: "figure.soccer",
                                isSelected: viewModel.data.position == profile.key,
                                action: {
                                    viewModel.data.position = profile.key
                                }
                            )
                        }
                    }
                }
            }
            .padding(.vertical, 8)
        }
    }
}
