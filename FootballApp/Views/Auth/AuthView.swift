import SwiftUI

struct AuthView: View {
    @State private var isRegistering = false

    var body: some View {
        NavigationStack {
            LoginView(isRegistering: $isRegistering)
                .navigationDestination(isPresented: $isRegistering) {
                    RegisterView(isRegistering: $isRegistering)
                }
        }
        .animation(.easeInOut(duration: 0.35), value: isRegistering)
    }
}

// --- FIX: All other structs (LoginView, RegisterView, PrimaryButton) are REMOVED ---
// --- They must live in their own files (e.g., LoginView.swift, ButtonStyles.swift) ---

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return AuthView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}
