//
//  RegisterView.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @EnvironmentObject var languageManager: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @Binding var isRegistering: Bool

    @State private var fullName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var acceptedTerms = false
    @State private var isAnimating = false

    @FocusState private var focusedField: Field?
    enum Field: Hashable { case name, email, password, confirmPassword }

    // Validation
    private var emailLooksValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 6
    }

    private var passwordsMatch: Bool {
        !password.isEmpty && password == confirmPassword
    }

    private var isPasswordStrong: Bool {
        password.count >= 6
    }

    private var canSubmit: Bool {
        !fullName.isEmpty &&
        emailLooksValid &&
        isPasswordStrong &&
        passwordsMatch &&
        acceptedTerms &&
        !authViewModel.isLoading
    }

    var body: some View {
        ZStack {
            // Animated background
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            // Gradient overlay
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
                    // Header
                    headerSection
                        .padding(.top, 20)

                    // Form card
                    formCard
                        .offset(y: isAnimating ? 0 : 20)
                        .opacity(isAnimating ? 1 : 0)

                    // Footer
                    footer
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)

                    Spacer(minLength: 40)
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 24)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { isRegistering = false }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 16, weight: .semibold))
                        Text("auth.back".localizedString)
                            .font(.system(size: 16, weight: .medium))
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("auth.done".localizedString) { focusedField = nil }
                    .foregroundColor(Color.theme.primary)
            }
        }
        .onAppear {
            authViewModel.errorMessage = nil
            withAnimation(.easeOut(duration: 0.8).delay(0.2)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Header Section
private extension RegisterView {
    var headerSection: some View {
        VStack(spacing: 12) {
            // App icon branding (matches login)
            ZStack {
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [Color.theme.primary.opacity(0.5), Color.theme.accent.opacity(0.2)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
                    .frame(width: 85, height: 85)
                    .blur(radius: 2)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)

                AppIconView(size: 65)
                    .clipShape(RoundedRectangle(cornerRadius: 15, style: .continuous))
                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 15, x: 0, y: 8)
            }
            .scaleEffect(isAnimating ? 1.0 : 0.5)
            .animation(.spring(response: 0.6, dampingFraction: 0.7), value: isAnimating)

            VStack(spacing: 6) {
                Text("auth.register_title".localizedString)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("auth.register_subtitle".localizedString)
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
        }
    }
}

// MARK: - Form Card
private extension RegisterView {
    var formCard: some View {
        VStack(spacing: 18) {
            // Full name field
            ModernTextField(
                icon: "person.fill",
                placeholder: "auth.fullname_placeholder".localizedString,
                text: $fullName,
                isValid: true,
                isFocused: focusedField == .name
            )
            .textContentType(.name)
            .focused($focusedField, equals: .name)
            .submitLabel(.next)
            .onSubmit { focusedField = .email }

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

            // Email validation hint
            if !email.isEmpty && !emailLooksValid {
                ValidationHint(
                    icon: "exclamationmark.circle.fill",
                    text: "auth.email_invalid".localizedString,
                    color: .orange
                )
            }

            // Password field
            ModernSecureField(
                icon: "lock.fill",
                placeholder: "auth.password_placeholder".localizedString,
                text: $password,
                showPassword: $showPassword,
                isFocused: focusedField == .password
            )
            .textContentType(.newPassword)
            .focused($focusedField, equals: .password)
            .submitLabel(.next)
            .onSubmit { focusedField = .confirmPassword }

            // Password requirements (shown proactively when focused or typing)
            if focusedField == .password || (!password.isEmpty && password.count < 6) {
                PasswordRequirementsView(password: password)
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))
            }

            // Password strength indicator
            if !password.isEmpty {
                PasswordStrengthIndicator(password: password)
            }

            // Confirm password field
            ModernSecureField(
                icon: "lock.fill",
                placeholder: "auth.confirm_password_placeholder".localizedString,
                text: $confirmPassword,
                showPassword: $showConfirmPassword,
                isFocused: focusedField == .confirmPassword
            )
            .textContentType(.newPassword)
            .focused($focusedField, equals: .confirmPassword)
            .submitLabel(.done)
            .onSubmit { focusedField = nil }

            // Password match indicator
            if !confirmPassword.isEmpty {
                HStack(spacing: 8) {
                    Image(systemName: passwordsMatch ? "checkmark.circle.fill" : "xmark.circle.fill")
                        .font(.system(size: 14))
                    Text(passwordsMatch ? "auth.passwords_match".localizedString : "auth.passwords_dont_match".localizedString)
                        .font(.system(size: 13, weight: .medium))
                }
                .foregroundColor(passwordsMatch ? .green : .red)
                .frame(maxWidth: .infinity, alignment: .leading)
                .transition(.opacity)
            }

            // Terms and conditions
            Button(action: {
                acceptedTerms.toggle()
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }) {
                HStack(alignment: .top, spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 6, style: .continuous)
                            .fill(acceptedTerms ? Color.theme.primary : Color.white.opacity(0.1))
                            .frame(width: 22, height: 22)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6, style: .continuous)
                                    .strokeBorder(acceptedTerms ? Color.clear : Color.white.opacity(0.3), lineWidth: 1.5)
                            )

                        if acceptedTerms {
                            Image(systemName: "checkmark")
                                .font(.system(size: 12, weight: .bold))
                                .foregroundColor(.white)
                        }
                    }

                    Text("auth.terms_agreement".localizedString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(.top, 4)

            // Error message
            if let errorMessage = authViewModel.errorMessage {
                ErrorBanner(message: errorMessage)
                    .transition(.asymmetric(
                        insertion: .scale.combined(with: .opacity),
                        removal: .opacity
                    ))
            }

            // Register button
            Button(action: attemptRegister) {
                HStack(spacing: 12) {
                    if authViewModel.isLoading {
                        ProgressView()
                            .tint(.white)
                            .scaleEffect(0.9)
                    } else {
                        Text("auth.create_account_button".localizedString)
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
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(.ultraThinMaterial)

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

// MARK: - Footer
private extension RegisterView {
    var footer: some View {
        HStack(spacing: 6) {
            Text("auth.already_have_account".localizedString)
                .foregroundColor(.white.opacity(0.7))

            Button(action: {
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
                isRegistering = false
            }) {
                Text("auth.signin_link".localizedString)
                    .fontWeight(.bold)
                    .foregroundColor(Color.theme.primary)
            }
        }
        .font(.system(size: 15))
        .frame(minHeight: 44)
    }

    func attemptRegister() {
        focusedField = nil
        authViewModel.errorMessage = nil

        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()

        authViewModel.register(
            name: fullName.trimmingCharacters(in: .whitespacesAndNewlines),
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password,
            confirmation: confirmPassword
        )
    }
}

// MARK: - Validation Hint
struct ValidationHint: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 14))
            Text(text)
                .font(.system(size: 13, weight: .medium))
        }
        .foregroundColor(color)
        .frame(maxWidth: .infinity, alignment: .leading)
        .transition(.asymmetric(
            insertion: .opacity.combined(with: .move(edge: .top)),
            removal: .opacity
        ))
    }
}

// MARK: - Password Requirements View
struct PasswordRequirementsView: View {
    let password: String

    private var hasMinLength: Bool { password.count >= 6 }
    private var hasUppercase: Bool { password.rangeOfCharacter(from: .uppercaseLetters) != nil }
    private var hasNumber: Bool { password.rangeOfCharacter(from: .decimalDigits) != nil }

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("auth.password_requirements_title".localizedString)
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))

            requirementRow(met: hasMinLength, text: "auth.password_req_length".localizedString)
            requirementRow(met: hasUppercase, text: "auth.password_req_uppercase".localizedString)
            requirementRow(met: hasNumber, text: "auth.password_req_number".localizedString)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(Color.white.opacity(0.06))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .strokeBorder(Color.white.opacity(0.08), lineWidth: 1)
        )
    }

    private func requirementRow(met: Bool, text: String) -> some View {
        HStack(spacing: 8) {
            Image(systemName: met ? "checkmark.circle.fill" : "circle")
                .font(.system(size: 12))
                .foregroundColor(met ? .green : .white.opacity(0.3))
            Text(text)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(met ? .white.opacity(0.8) : .white.opacity(0.4))
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    return NavigationStack {
        RegisterView(isRegistering: .constant(true))
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
    }
}
