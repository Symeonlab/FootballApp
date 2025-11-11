//
//  RegisterView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
import LocalAuthentication

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss
    
    @Binding var isRegistering: Bool // This binding is used to dismiss
    
    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var enableBiometrics = false

    var body: some View {
        ZStack {
            Color.theme.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 16) {
                
                Text(LocalizedStringKey("register.title"))
                    .font(.largeTitle.bold())
                    .foregroundColor(Color.theme.textPrimary)

                Text(LocalizedStringKey("register.subtitle"))
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)

                // --- Form Fields ---
                VStack(spacing: 16) {
                    TextField(LocalizedStringKey("register.full_name_placeholder"), text: $fullName)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .textContentType(.name)

                    TextField(LocalizedStringKey("register.email_placeholder"), text: $email)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                        .textContentType(.emailAddress)

                    SecureField(LocalizedStringKey("register.password_placeholder"), text: $password)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .textContentType(.newPassword)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.theme.surface)
                        .cornerRadius(12)
                        .textContentType(.newPassword)
                    
                    if authViewModel.canUseBiometrics() {
                        Toggle(isOn: $enableBiometrics) {
                            Label(LocalizedStringKey(authViewModel.biometryDisplayKey()), systemImage: authViewModel.biometrySystemImageName())
                        }
                        .tint(Color.theme.primary)
                    }
                }
                .padding(.top, 20)
                
                // Show error message from AuthViewModel
                if let errorMessage = authViewModel.errorMessage {
                    Text(errorMessage)
                        .font(.footnote)
                        .foregroundColor(.red)
                        .padding(.top, 5)
                }

                Spacer()

                // --- Sign Up Button ---
                Button(action: {
                    authViewModel.register(
                        name: fullName,
                        email: email,
                        password: password,
                        confirmation: confirmPassword
                    )
                    
                    if enableBiometrics {
                        // You need to implement the save logic inside AuthViewModel
                        // authViewModel.enableBiometricLogin(true)
                    }
                }) {
                    Text(LocalizedStringKey("register.signup_button"))
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.primary)
                        .cornerRadius(12)
                }
                .disabled(authViewModel.isLoading)
                .overlay(alignment: .trailing) {
                    if authViewModel.isLoading { ProgressView().tint(.white).padding(.trailing, 16) }
                }
                .padding(.bottom, 8)

                // --- Footer Navigation to Sign In ---
                HStack {
                    Spacer()
                    Text(LocalizedStringKey("register.already_have_account"))
                        .foregroundColor(Color.theme.textSecondary)
                    Button(LocalizedStringKey("register.signin_button")) {
                        isRegistering = false // This pops the view
                    }
                    .foregroundColor(Color.theme.primary)
                    .fontWeight(.bold)
                    Spacer()
                }
            }
            .padding(.horizontal, 24)
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarItems(leading: Button(action: {
            isRegistering = false // This pops the view
        }) {
            Image(systemName: "chevron.left")
                .foregroundColor(Color.theme.textPrimary)
                .font(.title2.bold())
        })
        .onAppear {
            authViewModel.errorMessage = nil // Clear errors when view appears
        }
    }
}

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return RegisterView(isRegistering: .constant(false))
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}
