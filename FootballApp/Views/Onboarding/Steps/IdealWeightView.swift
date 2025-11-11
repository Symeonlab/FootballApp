//
//  IdealWeightView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
struct IdealWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    private var weightBinding: Binding<Double> {
        Binding(
            get: { viewModel.data.idealWeight ?? 70.0 },
            set: { viewModel.data.idealWeight = $0 }
        )
    }
    var body: some View {
        OnboardingQuestionView(titleKey: "onboarding.ideal_weight.title", subtitleKey: "onboarding.common.subtitle", buttonTitleKey: "common.next") {
            withAnimation { selection += 1 }
        } content: {
            VStack {
                Text(String(format: "%.1f kg", weightBinding.wrappedValue))
                    .font(.system(size: 48, weight: .bold))
                Slider(value: weightBinding, in: 40...150, step: 0.1)
                    .tint(Color.theme.primary)
            }
        }
    }
}
