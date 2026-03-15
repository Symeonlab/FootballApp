//
//  HeightAndWeightView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct HeightAndWeightView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int // Binds to the main OnboardingFlow
    
    var body: some View {
        // Use the viewModel's internal step
        TabView(selection: $viewModel.heightWeightStep) {
            WeightSelectionView(viewModel: viewModel).tag(0)
            HeightSelectionView(viewModel: viewModel, mainSelection: $selection).tag(1)
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.easeInOut, value: viewModel.heightWeightStep)
    }
}

fileprivate struct WeightSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    
    private var weightBinding: Binding<Double> {
        Binding(
            get: { viewModel.data.weight ?? 70.0 },
            set: { viewModel.data.weight = $0 }
        )
    }
    
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.weight.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next"
        ) {
            withAnimation { viewModel.heightWeightStep += 1 }
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

fileprivate struct HeightSelectionView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var mainSelection: Int // Binds to the main onboarding selection
    
    private var heightBinding: Binding<Double> {
        Binding(
            get: { viewModel.data.height ?? 170.0 },
            set: { viewModel.data.height = $0 }
        )
    }
    
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.height.title",
            subtitleKey: "onboarding.common.subtitle",
            buttonTitleKey: "common.next"
        ) {
            withAnimation { mainSelection += 1 } // Advances the main flow
        } content: {
            VStack {
                Text(String(format: "%.0f cm", heightBinding.wrappedValue))
                    .font(.system(size: 48, weight: .bold))
                Picker("onboarding.height.picker".localized, selection: heightBinding) {
                    ForEach(100...250, id: \.self) { h in
                        Text("\(h) cm").tag(Double(h))
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
            }
        }
    }
}
