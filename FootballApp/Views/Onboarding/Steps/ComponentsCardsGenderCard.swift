#if false
//
//  GenderCard.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 13/11/2025.
//

import SwiftUI

struct GenderCard: View {
    let genderKey: String
    let imageName: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // Use SF Symbol as fallback if image doesn't exist
                Group {
                    if let _ = UIImage(named: imageName) {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                    } else {
                        // Fallback to SF Symbols
                        Image(systemName: genderKey == "HOMME" ? "person.fill" : "person.fill")
                            .resizable()
                            .scaledToFit()
                    }
                }
                .frame(width: 80, height: 80)
                .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textSecondary)
                
                Text(genderKey.localized)
                    .font(.headline)
                    .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 30)
            .background(isSelected ? Color.theme.primary.opacity(0.1) : Color.theme.surface)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? Color.theme.primary.opacity(0.3) : .clear, radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    HStack(spacing: 20) {
        GenderCard(genderKey: "HOMME", imageName: "male-icon", isSelected: true) {
            print("Male selected")
        }
        GenderCard(genderKey: "FEMME", imageName: "female-icon", isSelected: false) {
            print("Female selected")
        }
    }
    .padding()
    .background(Color.theme.background)
}

#endif
