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

    @FocusState private var focusedField: Field?
    enum Field { case email, password }

    @Binding var isRegistering: Bool

    private var emailLooksValid: Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.contains("@") && trimmed.contains(".") && trimmed.count >= 6
    }

    private var canSubmit: Bool {
        emailLooksValid && !password.isEmpty && !authViewModel.isLoading
    }

    var body: some View {
        ZStack {
            // ✅ Your purple animated background
            DarkPurpleAnimatedBackground()
                .ignoresSafeArea()

            // Optional: subtle dark veil to keep text readable on bright devices
            Color.black.opacity(0.20)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    header
                        .padding(.top, 40)

                    formCard

                    socialSection

                    footer
                        .padding(.top, 4)

                    Spacer(minLength: 24)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 24)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            authViewModel.errorMessage = nil
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") { focusedField = nil }
            }
        }
    }
}

// MARK: - Sections
private extension LoginView {

    var header: some View {
        VStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 22, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .frame(width: 84, height: 84)
                    .overlay(
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .shadow(color: .black.opacity(0.25), radius: 18, x: 0, y: 10)

                Text("D")
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }

            Text("Dipodi")
                .font(.system(.largeTitle, design: .rounded).weight(.bold))
                .foregroundColor(.white)

            Text(LocalizedStringKey("login.subtitle")) // e.g. “Train smarter, play better”
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.85))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 10)
        }
        .accessibilityElement(children: .combine)
    }

    var formCard: some View {
        VStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(LocalizedStringKey("login.title")) // e.g. “Welcome back”
                    .font(.title2.weight(.semibold))
                    .foregroundColor(.white)

                Text(LocalizedStringKey("login.hint")) // e.g. “Sign in to continue”
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.75))
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            AuthField(
                title: LocalizedStringKey("login.email_placeholder"),
                systemImage: "envelope.fill",
                text: $email,
                prompt: LocalizedStringKey("login.email_prompt")
            )
            .keyboardType(.emailAddress)
            .textContentType(.emailAddress)
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled(true)
            .focused($focusedField, equals: .email)
            .submitLabel(.next)
            .onSubmit { focusedField = .password }

            VStack(alignment: .leading, spacing: 6) {
                TextLabelIcon(
                    title: LocalizedStringKey("login.password_placeholder"),
                    systemImage: "lock.fill"
                )

                ZStack(alignment: .trailing) {
                    Group {
                        if showPassword {
                            TextField("", text: $password, prompt: Text(LocalizedStringKey("login.password_prompt")))
                        } else {
                            SecureField("", text: $password, prompt: Text(LocalizedStringKey("login.password_prompt")))
                        }
                    }
                    .textFieldStyle(PurpleTextFieldStyle())
                    .textContentType(.password)
                    .focused($focusedField, equals: .password)
                    .submitLabel(.go)
                    .onSubmit { attemptLogin() }

                    Button { showPassword.toggle() } label: {
                        Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                            .foregroundColor(.white.opacity(0.75))
                            .padding(12)
                            .contentShape(Rectangle())
                    }
                    .accessibilityLabel(showPassword ? "Hide password" : "Show password")
                }
            }

            if !email.isEmpty && !emailLooksValid {
                InlineInfoRow(
                    systemImage: "info.circle.fill",
                    text: LocalizedStringKey("login.email_invalid")
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }

            if let errorMessage = authViewModel.errorMessage {
                InlineErrorRow(text: errorMessage)
                    .transition(.opacity.combined(with: .scale))
            }

            HStack {
                Button {
                    // TODO: Hook to reset password flow
                } label: {
                    Text(LocalizedStringKey("login.forgot_password"))
                        .font(.footnote.weight(.semibold))
                        .foregroundColor(.white.opacity(0.90))
                }

                Spacer()
            }
            .padding(.top, 2)

            Button(action: attemptLogin) {
                HStack(spacing: 10) {
                    if authViewModel.isLoading {
                        ProgressView().tint(.white)
                    } else {
                        Text(LocalizedStringKey("login.signin_button"))
                            .font(.body.weight(.semibold))
                        Image(systemName: "arrow.right")
                            .font(.body.weight(.semibold))
                    }
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: [Color.theme.primary, Color.theme.primary.opacity(0.78)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .shadow(color: Color.theme.primary.opacity(0.35), radius: 14, x: 0, y: 8)
            }
            .disabled(!canSubmit)
            .opacity(canSubmit ? 1.0 : 0.55)
        }
        .padding(20)
        .background(
            // Material + tinted overlay for purple theme consistency
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(Color.deepPurple.opacity(0.18))
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 26, style: .continuous)
                .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.25), radius: 22, x: 0, y: 12)
    }

    var socialSection: some View {
        VStack(spacing: 14) {
            HStack {
                Rectangle().fill(Color.white.opacity(0.18)).frame(height: 1)
                Text("login.or_signin_with".localized)
                    .font(.footnote)
                    .foregroundColor(.white.opacity(0.80))
                Rectangle().fill(Color.white.opacity(0.18)).frame(height: 1)
            }

            HStack(spacing: 12) {
                SocialLoginButton(icon: "apple.logo", color: .white) { }
                SocialLoginButton(icon: "g.circle.fill", color: .red) { }
                SocialLoginButton(icon: "f.circle.fill", color: .blue) { }
            }
        }
        .padding(.top, 2)
    }

    var footer: some View {
        HStack(spacing: 6) {
            Text(LocalizedStringKey("login.no_account"))
                .foregroundColor(.white.opacity(0.75))

            Button { isRegistering = true } label: {
                Text(LocalizedStringKey("login.signup_button"))
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .underline()
            }
        }
        .font(.subheadline)
        .padding(.top, 8)
    }

    func attemptLogin() {
        focusedField = nil
        authViewModel.errorMessage = nil
        authViewModel.login(
            email: email.trimmingCharacters(in: .whitespacesAndNewlines),
            password: password
        )
    }
}

// MARK: - Reusable UI Bits

private struct TextLabelIcon: View {
    let title: LocalizedStringKey
    let systemImage: String

    var body: some View {
        Label {
            Text(title)
                .font(.subheadline.weight(.semibold))
        } icon: {
            Image(systemName: systemImage)
                .foregroundColor(Color.theme.primary)
        }
        .foregroundColor(.white)
    }
}

private struct AuthField: View {
    let title: LocalizedStringKey
    let systemImage: String
    @Binding var text: String
    let prompt: LocalizedStringKey

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            TextLabelIcon(title: title, systemImage: systemImage)
            TextField("", text: $text, prompt: Text(prompt))
                .textFieldStyle(PurpleTextFieldStyle())
        }
    }
}

private struct InlineErrorRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
            Text(text)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(.red)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.red.opacity(0.14))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct InlineInfoRow: View {
    let systemImage: String
    let text: LocalizedStringKey

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: systemImage)
            Text(text)
                .font(.footnote)
                .fixedSize(horizontal: false, vertical: true)
            Spacer(minLength: 0)
        }
        .foregroundColor(.white.opacity(0.80))
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.08))
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Purple TextField Style (better contrast on dark purple bg)
struct PurpleTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .foregroundColor(.white)
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.black.opacity(0.22))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
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
                .font(.title3.weight(.semibold))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.black.opacity(0.18))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.12), lineWidth: 1)
                )
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
