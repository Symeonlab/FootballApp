import SwiftUI

struct AuthView: View {
    @State private var isRegistering = false
    
    var body: some View {
        NavigationView {
            ZStack {
                LoginView(isRegistering: $isRegistering)
                
                NavigationLink(
                    destination: RegisterView(isRegistering: $isRegistering),
                    isActive: $isRegistering
                ) {
                    EmptyView()
                }
            }
        }
        .navigationViewStyle(.stack)
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
