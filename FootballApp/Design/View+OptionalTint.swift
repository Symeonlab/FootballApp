import SwiftUI

extension View {
    /// Applies a tint color if provided; otherwise returns self unchanged.
    func applyOptionalTint(_ color: Color?) -> some View {
        if let color = color {
            return AnyView(self.tint(color))
        } else {
            return AnyView(self)
        }
    }
}
