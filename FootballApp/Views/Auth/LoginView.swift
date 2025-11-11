//
//  LoginView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageManager: LanguageManager
    
    @State private var email = ""
    @State private var password = ""
    @State private var showPassword = false
    @State private var animateLogo = false
    
    @Binding var isRegistering: Bool

    var body: some View {
        ZStack {
            // Animated gradient background
            LinearGradient(
                colors: [
                    Color.theme.primary.opacity(0.1),
                    Color.theme.accent.opacity(0.05),
                    Color.theme.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Floating circles for visual interest
            GeometryReader { geometry in
                Circle()
                    .fill(Color.theme.primary.opacity(0.1))
                    .frame(width: 200, height: 200)
                    .blur(radius: 60)
                    .offset(x: -50, y: 100)
                
                Circle()
                    .fill(Color.theme.accent.opacity(0.15))
                    .frame(width: 250, height: 250)
                    .blur(radius: 80)
                    .offset(x: geometry.size.width - 100, y: geometry.size.height - 200)
            }

            ScrollView {
                VStack(spacing: 32) {
                    Spacer()
                        .frame(height: 60)
                    
                    // --- App Logo with Animation ---
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.theme.primary, Color.theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                                .opacity(0.5)
                                .scaleEffect(animateLogo ? 1.2 : 1.0)
                            
                            Circle()
                                .fill(Color.theme.surface)
                                .frame(width: 90, height: 90)
                                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                            
                            Text("D")
                                .font(.system(size: 48, weight: .bold, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color.theme.primary, Color.theme.accent],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        
                        Text("Dipodi")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text("Train smarter, play better")
                            .font(.subheadline)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    .padding(.vertical, 20)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            animateLogo = true
                        }
                    }
                    
                    // --- Form Card ---
                    VStack(spacing: 20) {
                        // Email Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text(LocalizedStringKey("login.email_placeholder"))
                                    .font(.subheadline.weight(.medium))
                            } icon: {
                                Image(systemName: "envelope.fill")
                                    .foregroundColor(Color.theme.primary)
                            }
                            .foregroundColor(Color.theme.textPrimary)
                            
                            TextField("", text: $email)
                                .textFieldStyle(ModernTextFieldStyle())
                                .keyboardType(.emailAddress)
                                .autocapitalization(.none)
                                .textContentType(.emailAddress)
                        }
                        
                        // Password Field
                        VStack(alignment: .leading, spacing: 8) {
                            Label {
                                Text(LocalizedStringKey("login.password_placeholder"))
                                    .font(.subheadline.weight(.medium))
                            } icon: {
                                Image(systemName: "lock.fill")
                                    .foregroundColor(Color.theme.primary)
                            }
                            .foregroundColor(Color.theme.textPrimary)
                            
                            HStack {
                                if showPassword {
                                    TextField("", text: $password)
                                        .textFieldStyle(ModernTextFieldStyle(isSecure: false))
                                } else {
                                    SecureField("", text: $password)
                                        .textFieldStyle(ModernTextFieldStyle(isSecure: true))
                                }
                                
                                Button(action: { showPassword.toggle() }) {
                                    Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                        .foregroundColor(Color.theme.textSecondary)
                                }
                                .padding(.trailing, 16)
                            }
                        }
                        
                        // Error message
                        if let errorMessage = authViewModel.errorMessage {
                            HStack(spacing: 8) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                Text(errorMessage)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.red.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                            .transition(.scale.combined(with: .opacity))
                        }
                        
                        // Sign In Button
                        Button(action: {
                            authViewModel.login(email: email, password: password)
                        }) {
                            HStack(spacing: 12) {
                                if authViewModel.isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text(LocalizedStringKey("login.signin_button"))
                                        .font(.body.weight(.semibold))
                                    Image(systemName: "arrow.right")
                                }
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.primary.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .shadow(color: Color.theme.primary.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .disabled(authViewModel.isLoading || email.isEmpty || password.isEmpty)
                        .opacity(email.isEmpty || password.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(24)
                    .background(Color.theme.surface)
                    .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                    .cardShadow()
                    .padding(.horizontal, 24)
                    
                    // --- Social Logins ---
                    VStack(spacing: 16) {
                        HStack {
                            Rectangle()
                                .fill(Color.theme.textSecondary.opacity(0.2))
                                .frame(height: 1)
                            Text("login.or_signin_with".localized)
                                .font(.footnote)
                                .foregroundColor(Color.theme.textSecondary)
                            Rectangle()
                                .fill(Color.theme.textSecondary.opacity(0.2))
                                .frame(height: 1)
                        }

                        HStack(spacing: 16) {
                            SocialLoginButton(icon: "g.circle.fill", color: .red) {
                                // Google login
                            }
                            
                            SocialLoginButton(icon: "f.circle.fill", color: .blue) {
                                // Facebook login
                            }
                            
                            SocialLoginButton(icon: "apple.logo", color: .primary) {
                                // Apple login
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()

                    // --- Navigation to Register ---
                    HStack(spacing: 4) {
                        Text(LocalizedStringKey("login.no_account"))
                            .foregroundColor(Color.theme.textSecondary)
                        Button(action: {
                            isRegistering = true
                        }) {
                            Text(LocalizedStringKey("login.signup_button"))
                                .foregroundColor(Color.theme.primary)
                                .fontWeight(.bold)
                        }
                    }
                    .font(.subheadline)
                    .padding(.bottom, 32)
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            authViewModel.errorMessage = nil
        }
    }
}

// MARK: - Modern Text Field Style
struct ModernTextFieldStyle: TextFieldStyle {
    var isSecure: Bool = false
    
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.theme.background.opacity(0.6))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.theme.primary.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Social Login Button
struct SocialLoginButton: View {
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 54)
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.theme.textSecondary.opacity(0.1), lineWidth: 1)
                )
                .lightShadow()
        }
    }
}

#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    return LoginView(isRegistering: .constant(false))
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
        .preferredColorScheme(.dark)
}
