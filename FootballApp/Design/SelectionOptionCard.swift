import SwiftUI

struct SelectionOptionCard: View {
    let title: String
    let imageName: String?
    let isSelected: Bool
    let action: () -> Void
    
    init(title: String, imageName: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.imageName = imageName
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(role: .none, action: action) {
            HStack(spacing: 12) {
                if let imageName = imageName {
                    Image(systemName: imageName)
                        .foregroundColor(isSelected ? Color.theme.primary : Color.theme.textPrimary)
                        .frame(width: 24, height: 24)
                }
                Text(title)
                    .foregroundColor(Color.theme.textPrimary)
                    .fontWeight(.medium)
                Spacer()
            }
            .padding()
            .background(isSelected ? Color.theme.surface.opacity(0.3) : Color.theme.surface)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isSelected ? Color.theme.primary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SelectionOptionCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            SelectionOptionCard(title: "Option 1", imageName: "star.fill", isSelected: true) {
                // action
            }
            SelectionOptionCard(title: "Option 2", imageName: "star", isSelected: false) {
                // action
            }
            SelectionOptionCard(title: "male", imageName: "person.fill", isSelected: false) {
                // action
            }
            SelectionOptionCard(title: "female", imageName: nil, isSelected: true) {
                // action
            }
        }
        .padding()
        .background(Color.theme.surface)
        .previewLayout(.sizeThatFits)
    }
}
