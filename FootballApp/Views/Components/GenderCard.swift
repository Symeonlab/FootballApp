//
//  GenderCard.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct GenderCard: View {
    let genderKey: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(role: .none, action: action) {
            VStack {
                Image(systemName: "person.fill") // Placeholder icon
                    .font(.system(size: 80))
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textSecondary)

                Text(LocalizedStringKey(genderKey == "HOMME" ? "onboarding.gender.male" : "onboarding.gender.female"))
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textSecondary)
            }
            .frame(width: 150, height: 160)
            .background(Color.theme.surface)
            .cornerRadius(20)
            .shadow(color: isSelected ? Color.theme.primary.opacity(0.3) : .clear, radius: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}
