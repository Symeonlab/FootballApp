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
    @State private var isAnimating = false
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var showForgotPasswordSuccess = false

    @FocusState private var focusedField: Field?
    enum Field { case email, password }

    @Binding var isRegistering: Bool

    private var emailLooksValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 6
    }

    private var canSubmit: Bool {
        emailLooksValid && password.count >= 6 && !authViewModel.isLoading
    }

    var body: some View {
        ZStack {
            // Animated background
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            // Gradient overlay for depth
            LinearGradient(
                colors: [
                    Color.black.opacity(0.4),
                    Color.clear,
                    Color.black.opacity(0.3)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    // Header with logo animation
                    headerSection
                        .padding(.top, 50)

                    // Main form card
                    formCard
                        .offset(y: isAnimating ? 0 : 20)
                        .opacity(isAnimating ? 1 : 0)

                    // Social login section
                    socialSection
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)

                    // Footer
                    footer
                        .offset(y: isAnimating ? 0 : 40)
                        .opacity(isAnimating ? 1 : 0)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.errorMessage = nil
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("auth.done".localizedString) { focusedField = nil }
                    .foregroundColor(Color.theme.primary)
            }
        }
        .sheet(isPresented: $showForgotPassword) {
            ForgotPasswordSheet(
                email: $forgotPasswordEmail,
                isPresented: $showForgotPassword,
                showSuccess: $showForgotPasswordSuccess
            )
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("auth.forgot_password_sent".localizedString, isPresented: $showForgotPasswordSuccess) {
            Button("common.ok".localizedString, role: .cancel) { }
        } message: {
            Text("auth.forgot_password_sent_message".localizedString)
        }
    }
}

// MARK: - Header Section
private extension LoginView {
    var headerSection: some View {
        VStack(spacing: 16) {
            // Animated logo
            ZStack {
                // Outer glow ring
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.theme.primary.opacity(0.6), Color.theme.accent.opacity(0.3)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 110, height: 110)
                    .blur(radius: 3)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)

                // App icon (matches actual icon)
                AppIconView(size: 90)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .shadow(color: Color.theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)

            VStack(spacing: 8) {
                Text("DiPODDI")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("auth.welcome_subtitle".localizedString)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
        }
        .accessibilityElement(children: .combine)
    }
}

// MARK: - Form Card
private extension LoginView {
    var formCard: some View {
        VStack(spacing: 20) {
            // Card header
            VStack(alignment: .leading, spacing: 6) {
                Text("auth.login_title".localizedString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)

                Text("auth.login_subtitle".localizedString)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            // Email field
            ModernTextField(
                icon: "envelope.fill",
                placeholder: "auth.email_placeholder".localizedString,
                text: $email,
                isValid: email.isEmpty || emailLooksValid,
                isFocused: focusedField == .email
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            // Password field
            ModernSecureField(
                icon: "lock.fill",
                placeholder: "auth.password_placeholder".localizedString,
                text: $password,
                showPassword: $showPassword,
                isFocused: focusedField == .password
            )
            .textContentType(.password)
            .focused($focusedField, equals: .password)
            .submitLabel(.go)
            .onSubmit { attemptLogin() }

            // Email validation hint
            if !email.isEmpty && !emailLooksValid {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .font(.system(size: 14))
                    Text("auth.email_invalid".localizedString)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.orange)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }

            // Password requirements hint (shown proactively when focused)
            if focusedField == .password && password.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 14))
                    Text("auth.password_requirements".localizedString)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.5))
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.asymmetric(
                    insertion: .opacity.combined(with: .move(edge: .top)),
                    removal: .opacity
                ))
            }

            // Password strength indicator
            if !password.isEmpty {
                PasswordStrengthIndicator(password: password)
                    .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }

            // Error message
            if let errorMessage = authViewModel.errorMessage {
                ErrorBanner(message: errorMessage)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
                    .accessibilityLabel(errorMessage)
            }

            // Forgot password
            HStack {
                Button(action: {
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                    forgotPasswordEmail = email
                    showForgotPassword = true
                }) {
                    Text("auth.forgot_password".localizedString)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Color.theme.primary)
                }
                .frame(minHeight: 44)
                Spacer()
            }

            // Login button
            Button(action: attemptLogin) {
                HStack(spacing: 12) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                    } else {
                        Text("auth.signin_button".localizedString)
                            .font(.system(size: 17, weight: .bold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 16, weight: .bold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(
                    Group {
                        if canSubmit {
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        } else {
                            Color.white.opacity(0.15)
                        }
                    }
                )
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shadow(color: canSubmit ? Color.theme.primary.opacity(0.4) : .clear, radius: 15, x: 0, y: 8)
            }
            .disabled(!canSubmit)
            .animation(.easeInOut(duration: 0.2), value: canSubmit)
        }
        .padding(24)
        .background(
            ZStack {
                // Glass morphism background
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

                // Subtle gradient overlay
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [Color.deepPurple.opacity(0.2), Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
        )
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 1
                )
        )
        .shadow(color: .black.opacity(0.3), radius: 30, x: 0, y: 15)
    }
}

// MARK: - Social Section
private extension LoginView {
    var socialSection: some View {
        VStack(spacing: 16) {
            // Divider with text
            HStack(spacing: 16) {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.0), Color.white.opacity(0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                Text("auth.or_continue_with".localizedString)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .fixedSize()

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [Color.white.opacity(0.3), Color.white.opacity(0.0)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }

            // Social buttons
            HStack(spacing: 16) {
                SocialAuthButton(
                    icon: "apple.logo",
                    label: "Apple",
                    backgroundColor: Color.white,
                    foregroundColor: .black
                ) {
                    // Apple Sign In
                }

                SocialAuthButton(
                    icon: "g.circle.fill",
                    label: "Google",
                    backgroundColor: Color.white.opacity(0.1),
                    foregroundColor: .white
                ) {
                    // Google Sign In
                }
            }
        }
    }
}

// MARK: - Footer
private extension LoginView {
    var footer: some View {
        HStack(spacing: 6) {
            Text("auth.no_account".localizedString)
                .foregroundColor(.white.opacity(0.7))

            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isRegistering = true
            }) {
                Text("auth.create_account".localizedString)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.primary)
            }
        }
        .font(.system(size: 15))
        .frame(minHeight: 44)
    }

    func attemptLogin() {
        focusedField = nil
        authViewModel.errorMessage = nil

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        authViewModel.login(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
    }
}

// MARK: - Modern TextField
struct ModernTextField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isValid: Bool = true
    var isFocused: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color.theme.primary : .white.opacity(0.6))
                .frame(width: 24)

            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(isFocused ? 0.12 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    isFocused ? Color.theme.primary.opacity(0.6) : (isValid ? Color.white.opacity(0.1) : Color.orange.opacity(0.5)),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Modern Secure Field
struct ModernSecureField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    @Binding var showPassword: Bool
    var isFocused: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .medium))
                .foregroundColor(isFocused ? Color.theme.primary : .white.opacity(0.6))
                .frame(width: 24)

            Group {
                if showPassword {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(.white.opacity(0.4)))
                }
            }
            .font(.system(size: 16, weight: .medium))
            .foregroundColor(.white)

            Button(action: {
                showPassword.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.5))
                    .frame(width: 44, height: 44)
                    .contentShape(Rectangle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.white.opacity(isFocused ? 0.12 : 0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(
                    isFocused ? Color.theme.primary.opacity(0.6) : Color.white.opacity(0.1),
                    lineWidth: isFocused ? 2 : 1
                )
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Password Strength Indicator
struct PasswordStrengthIndicator: View {
    let password: String

    private var strength: (level: Int, text: String, color: Color) {
        let length = password.count
        let hasUppercase = password.rangeOfCharacter(from: .uppercaseLetters) != nil
        let hasLowercase = password.rangeOfCharacter(from: .lowercaseLetters) != nil
        let hasNumbers = password.rangeOfCharacter(from: .decimalDigits) != nil
        let hasSpecial = password.rangeOfCharacter(from: CharacterSet(charactersIn: "!@#$%^&*()_+-=[]{}|;:,.<>?")) != nil

        var score = 0
        if length >= 6 { score += 1 }
        if length >= 8 { score += 1 }
        if hasUppercase && hasLowercase { score += 1 }
        if hasNumbers { score += 1 }
        if hasSpecial { score += 1 }

        switch score {
        case 0...1: return (1, "auth.password_weak".localizedString, .red)
        case 2...3: return (2, "auth.password_medium".localizedString, .orange)
        case 4: return (3, "auth.password_strong".localizedString, .green)
        default: return (4, "auth.password_very_strong".localizedString, .green)
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                ForEach(0..<4, id: \.self) { index in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(index < strength.level ? strength.color : Color.white.opacity(0.2))
                        .frame(height: 4)
                }
            }

            Text(strength.text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(strength.color)
        }
    }
}

// MARK: - Error Banner
struct ErrorBanner: View {
    let message: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 18))
                .foregroundColor(.red)

            Text(message)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white)
                .fixedSize(horizontal: false, vertical: true)

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.red.opacity(0.2))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .strokeBorder(Color.red.opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Social Auth Button
struct SocialAuthButton: View {
    let icon: String
    let label: String
    let backgroundColor: Color
    let foregroundColor: Color
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                Text(label)
                    .font(.system(size: 15, weight: .semibold))
            }
            .foregroundColor(foregroundColor)
            .frame(maxWidth: .infinity)
            .frame(height: 52)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
            )
        }
    }
}

// MARK: - Forgot Password Sheet
struct ForgotPasswordSheet: View {
    @Binding var email: String
    @Binding var isPresented: Bool
    @Binding var showSuccess: Bool
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var isLoading = false

    private var isValidEmail: Bool {
        email.contains("@") && email.contains(".") && email.count >= 6
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.theme.background.ignoresSafeArea()

                VStack(spacing: 24) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(Color.theme.primary.opacity(0.15))
                            .frame(width: 80, height: 80)

                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 36))
                            .foregroundColor(Color.theme.primary)
                    }
                    .padding(.top, 20)

                    VStack(spacing: 8) {
                        Text("auth.reset_password_title".localizedString)
                            .font(.system(size: 24, weight: .bold))
                            .foregroundColor(Color.theme.textPrimary)

                        Text("auth.reset_password_subtitle".localizedString)
                            .font(.system(size: 15))
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }

                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("auth.email_label".localizedString)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(Color.theme.textSecondary)

                        TextField("", text: $email, prompt: Text("auth.email_placeholder".localizedString).foregroundColor(Color.theme.textSecondary.opacity(0.5)))
                            .font(.system(size: 16))
                            .foregroundColor(Color.theme.textPrimary)
                            .padding(16)
                            .background(Color.theme.surface)
                            .cornerRadius(12)
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled(true)
                    }
                    .padding(.horizontal, 24)

                    // Send button
                    Button(action: sendResetEmail) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("auth.send_reset_link".localizedString)
                                    .font(.system(size: 17, weight: .bold))
                            }
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 52)
                        .background(isValidEmail ? Color.theme.primary : Color.theme.primary.opacity(0.4))
                        .cornerRadius(14)
                    }
                    .disabled(!isValidEmail || isLoading)
                    .padding(.horizontal, 24)

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { isPresented = false }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 24))
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
        }
    }

    private func sendResetEmail() {
        isLoading = true
        Task {
            do {
                _ = try await APIService.shared.forgotPassword(email: email)
                await MainActor.run {
                    isLoading = false
                    isPresented = false
                    showSuccess = true
                }
            } catch {
                await MainActor.run {
                    isLoading = false
                }
            }
        }
    }
}

// MARK: - Preview
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
