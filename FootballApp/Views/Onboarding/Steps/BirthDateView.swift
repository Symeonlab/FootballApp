//
//  BirthDateView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct BirthDateView: View {
    @ObservedObject var viewModel: OnboardingViewModel
    @Binding var selection: Int
    
    @State private var selectedDate = Date()
    
    // Calculate age range (14-80 years old)
    private var dateRange: ClosedRange<Date> {
        let calendar = Calendar.current
        let endDate = calendar.date(byAdding: .year, value: -14, to: Date()) ?? Date()
        let startDate = calendar.date(byAdding: .year, value: -80, to: Date()) ?? Date()
        return startDate...endDate
    }
    
    var body: some View {
        OnboardingQuestionView(
            titleKey: "onboarding.birthdate.title",
            subtitleKey: "onboarding.birthdate.subtitle",
            buttonTitleKey: "common.next",
            isButtonEnabled: true,
            action: {
                viewModel.data.birthDate = selectedDate
                withAnimation {
                    selection += 1
                }
            }
        ) {
            VStack(spacing: 20) {
                // Date Picker Card
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "calendar")
                            .font(.title2)
                            .foregroundColor(Color.theme.primary)
                        
                        Text("onboarding.birthdate.select")
                            .font(.headline)
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Spacer()
                    }
                    
                    DatePicker(
                        "",
                        selection: $selectedDate,
                        in: dateRange,
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    .padding(.horizontal)
                    
                    // Age Display
                    HStack {
                        Image(systemName: "person.fill")
                            .foregroundColor(Color.theme.accent)
                        Text(String(format: NSLocalizedString("onboarding.birthdate.age_display", comment: ""), calculateAge(from: selectedDate)))
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .background(Color.theme.primary.opacity(0.1))
                    .clipShape(Capsule())
                }
                .padding(20)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .lightShadow()
                
                // Info Card
                InfoCard(
                    title: NSLocalizedString("onboarding.birthdate.info_title", comment: ""),
                    description: NSLocalizedString("onboarding.birthdate.info_description", comment: ""),
                    icon: "info.circle.fill",
                    iconColor: Color.theme.primary
                )
            }
        }
        .onAppear {
            if let birthDate = viewModel.data.birthDate {
                selectedDate = birthDate
            } else {
                // Default to 25 years ago
                selectedDate = Calendar.current.date(byAdding: .year, value: -25, to: Date()) ?? Date()
            }
        }
    }
    
    private func calculateAge(from date: Date) -> Int {
        let calendar = Calendar.current
        let ageComponents = calendar.dateComponents([.year], from: date, to: Date())
        return ageComponents.year ?? 0
    }
}

#Preview {
    BirthDateView(
        viewModel: OnboardingViewModel(),
        selection: .constant(12)
    )
}
