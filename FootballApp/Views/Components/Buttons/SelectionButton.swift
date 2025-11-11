//
//  SelectionButton.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct SelectionButton: View {
    let title: String
    @Binding var selection: String?
    let tag: String

    var body: some View {
        Button(role: .none, action: {
            selection = tag
        }) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selection == tag ? Color.theme.primary.opacity(0.1) : Color.theme.surface)
                .foregroundColor(selection == tag ? Color.theme.primary : Color.theme.textPrimary)
                .cornerRadius(12)
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(selection == tag ? Color.theme.primary : Color.clear, lineWidth: 2)
                )
        }
    }
}

