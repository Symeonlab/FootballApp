//
//  AuthViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import Foundation
import Combine
import os
import LocalAuthentication // For biometrics
import AuthenticationServices // <-- ADD THIS for Sign in with Apple

// This defines the state of your app
enum AppState {
    case loading
    case authentication
    case onboarding
    case updateWorkoutType  // Re-do onboarding (skip personal info) to update workout preferences
    case mainApp
}

class AuthViewModel: ObservableObject {
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DiPODDI", category: "AuthViewModel")
    
    // @Published properties will update your UI
    @Published var appState: AppState = .authentication
    @Published var currentUser: APIUser?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Manages the "Bearer" token
    private let tokenManager = APITokenManager.shared
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Check if we're in preview mode
        let isPreview = ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
        
        if isPreview {
            // Skip heavy operations in preview
            logger.debug("Preview mode: Skipping authentication check")
            appState = .authentication
            return
        }
        
        // Start in loading state
        appState = .loading
        
        // When the app starts, check if we have a token
        if let token = tokenManager.currentToken, !token.isEmpty {
            logger.debug("Found token, fetching user...")
            fetchUser()
        } else {
            logger.debug("No token found, moving to authentication.")
            appState = .authentication
        }
    }
    
    // MARK: - API Auth Functions
    
    /// Register new user
    /// Uses: POST /api/auth/register
    func register(name: String, email: String, password: String, confirmation: String) {
        logger.info("Attempting registration...")
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let response = try await APIService.shared.register(
                    name: name,
                    email: email,
                    password: password,
                    passwordConfirmation: confirmation
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.logger.info("Registration successful.")
                    self.handleSuccessfulAuth(response: response)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.logger.error("Registration failed: \(error.localizedDescription)")
                    self.errorMessage = (error as? APIError)?.message ?? "auth.error.registration_failed".localizedString
                }
            }
        }
    }

    /// Login user
    /// Uses: POST /api/auth/login
    func login(email: String, password: String) {
        logger.info("Attempting login...")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await APIService.shared.login(
                    email: email,
                    password: password
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.logger.info("Login successful.")
                    self.handleSuccessfulAuth(response: response)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.logger.error("Login failed: \(error.localizedDescription)")
                    self.errorMessage = (error as? APIError)?.message ?? "auth.error.invalid_credentials".localizedString
                }
            }
        }
    }

    /// Social login (Google, Facebook, Apple)
    /// Uses: POST /api/auth/{provider}/login
    func handleSocialLogin(provider: String, token: String) {
        logger.info("Attempting social login via \(provider)...")
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let response = try await APIService.shared.socialLogin(
                    provider: provider,
                    token: token
                )
                
                await MainActor.run {
                    self.isLoading = false
                    self.logger.info("Social login successful.")
                    self.handleSuccessfulAuth(response: response)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.logger.error("Social login failed: \(error.localizedDescription)")
                    self.errorMessage = "auth.error.social_login_failed".localizedString
                }
            }
        }
    }
    
    /// Fetch user data using saved token
    /// Uses: GET /api/user
    func fetchUser() {
        isLoading = true
        
        Task {
            do {
                let user = try await APIService.shared.getUser()
                
                await MainActor.run {
                    self.isLoading = false
                    self.logger.debug("Successfully fetched user \(user.email)")
                    self.currentUser = user
                    let isComplete = user.profile?.is_onboarding_complete ?? false
                    self.updateAppState(isOnboardingComplete: isComplete)
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                    self.logger.warning("Token invalid or user fetch failed. Logging out.")
                    self.signOut() // Token is invalid
                }
            }
        }
    }

    /// Sign out user
    /// Uses: POST /api/auth/logout
    func signOut() {
        guard tokenManager.currentToken != nil else {
            clearSession()
            return
        }
        
        logger.info("Signing out...")
        
        Task {
            do {
                _ = try await APIService.shared.logout()
                await MainActor.run {
                    self.logger.info("Server logout successful.")
                    self.clearSession()
                }
            } catch {
                await MainActor.run {
                    self.logger.warning("Server logout failed, clearing local session anyway.")
                    self.clearSession()
                }
            }
        }
    }
    
    /// Continue as guest (skip login)
    func continueAsGuest() {
        DispatchQueue.main.async {
            self.logger.info("Continuing as guest; transitioning to onboarding")
            self.currentUser = nil // Ensure no user is set
            self.appState = .onboarding
        }
    }
    
    // MARK: - State Management
    
    private func handleSuccessfulAuth(response: AuthResponse) {
        DispatchQueue.main.async {
            self.tokenManager.currentToken = response.token
            self.currentUser = response.user
            let isComplete = response.user.profile?.is_onboarding_complete ?? false
            self.updateAppState(isOnboardingComplete: isComplete)
        }
    }

    private func updateAppState(isOnboardingComplete: Bool) {
        DispatchQueue.main.async {
            if isOnboardingComplete {
                self.appState = .mainApp
            } else {
                self.appState = .onboarding
            }
        }
    }
    
    // Called by OnboardingViewModel when it finishes
    func completeOnboarding() {
        DispatchQueue.main.async {
            self.appState = .mainApp
        }
    }
    
    // Clears the token and user, returning to the login screen
    private func clearSession() {
        DispatchQueue.main.async {
            self.currentUser = nil
            self.tokenManager.currentToken = nil
            self.appState = .authentication
        }
    }
    
    // --- Biometric Logic ---
        
    func canUseBiometrics() -> Bool {
        var error: NSError?
        let context = LAContext()
        return context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
    }

    func biometryDisplayKey() -> String {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        
        switch context.biometryType {
        case .faceID: return "settings.biometrics.faceID"
        case .touchID: return "settings.biometrics.touchID"
        default: return "settings.biometrics.biometrics"
        }
    }
    
    func biometrySystemImageName() -> String {
        let context = LAContext()
        context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }
    
    func enableBiometricLogin(_ enabled: Bool) {
        logger.info("Biometric login set to \(enabled)")
    }
}

