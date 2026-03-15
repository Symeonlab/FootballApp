//
//  AgeSelectionView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct AgeSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    private var ageBinding: Binding<Int> {
        Binding(
            get: { viewModel.data.age ?? 25 },
            set: { viewModel.data.age = $0 }
        )
    }

    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.age.title",
            subtitleKey: "onboarding.age.subtitle",
            buttonTitleKey: "common.next"
        ) {
            withAnimation {
                selection += 1
            }
        } content: {
            Picker("onboarding.age.picker".localized, selection: ageBinding) {
                ForEach(16...100, id: \.self) { age in
                    Text("\(age)").tag(age)
                }
            }
            .pickerStyle(.wheel)
            .frame(height: 150)
            .padding(.horizontal)
        }
    }
}
