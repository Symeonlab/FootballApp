import SwiftUI

struct MultiSelectionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(role: .none, action: action) {
            HStack {
                Text(title)
                    .font(.body.weight(.semibold))
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(isSelected ? Color.theme.primary.opacity(0.12) : Color.theme.surface)
            .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textPrimary)
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
        }
    }
}

