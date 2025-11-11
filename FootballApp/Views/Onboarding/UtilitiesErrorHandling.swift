//
//  ErrorHandling.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 13/11/2025.
//

import Foundation
import SwiftUI

// MARK: - App Errors
enum AppError: LocalizedError {
    case networkError(String)
    case authenticationError
    case validationError(String)
    case serverError(Int, String)
    case decodingError
    case unknown(Error)
    
    var errorDescription: String? {
        switch self {
        case .networkError(let message):
            return "Network Error: \(message)"
        case .authenticationError:
            return "Authentication failed. Please login again."
        case .validationError(let message):
            return message
        case .serverError(let code, let message):
            return "Server Error (\(code)): \(message)"
        case .decodingError:
            return "Failed to process server response."
        case .unknown(let error):
            return "An unexpected error occurred: \(error.localizedDescription)"
        }
    }
    
    var userFriendlyMessage: String {
        switch self {
        case .networkError:
            return "Unable to connect. Please check your internet connection."
        case .authenticationError:
            return "Your session has expired. Please login again."
        case .validationError(let message):
            return message
        case .serverError:
            return "Something went wrong on our end. Please try again later."
        case .decodingError:
            return "Unable to process the response. Please try again."
        case .unknown:
            return "An unexpected error occurred. Please try again."
        }
    }
    
    var icon: String {
        switch self {
        case .networkError:
            return "wifi.slash"
        case .authenticationError:
            return "lock.shield"
        case .validationError:
            return "exclamationmark.triangle"
        case .serverError:
            return "server.rack"
        case .decodingError:
            return "doc.text.fill.badge.ellipsis"
        case .unknown:
            return "exclamationmark.circle"
        }
    }
}

// MARK: - Error Alert View
struct ErrorAlertView: View {
    let error: AppError
    let dismissAction: () -> Void
    let retryAction: (() -> Void)?
    
    init(error: AppError, dismissAction: @escaping () -> Void, retryAction: (() -> Void)? = nil) {
        self.error = error
        self.dismissAction = dismissAction
        self.retryAction = retryAction
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Error Icon
            Image(systemName: error.icon)
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            // Error Message
            VStack(spacing: 8) {
                Text("Oops!")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text(error.userFriendlyMessage)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            // Actions
            VStack(spacing: 12) {
                if let retryAction = retryAction {
                    Button(action: retryAction) {
                        Text("Try Again")
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.theme.primary)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
                
                Button(action: dismissAction) {
                    Text("Dismiss")
                        .fontWeight(.medium)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(Color.theme.textPrimary)
                        .cornerRadius(12)
                }
            }
        }
        .padding(30)
        .background(Color.theme.surface)
        .cornerRadius(20)
        .shadow(radius: 20)
        .padding(40)
    }
}

// MARK: - Error Toast View
struct ErrorToast: View {
    let message: String
    let icon: String
    @Binding var isShowing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.white)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(.white)
            
            Spacer()
            
            Button(action: { withAnimation { isShowing = false } }) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding()
        .background(Color.red)
        .cornerRadius(12)
        .shadow(radius: 10)
        .padding(.horizontal)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
}

// MARK: - View Extensions for Error Handling
extension View {
    func errorAlert(
        error: Binding<AppError?>,
        retryAction: (() -> Void)? = nil
    ) -> some View {
        self.overlay {
            if let appError = error.wrappedValue {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation {
                            error.wrappedValue = nil
                        }
                    }
                
                ErrorAlertView(
                    error: appError,
                    dismissAction: {
                        withAnimation {
                            error.wrappedValue = nil
                        }
                    },
                    retryAction: retryAction
                )
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: error.wrappedValue != nil)
    }
    
    func errorToast(
        message: Binding<String?>,
        icon: String = "exclamationmark.triangle.fill"
    ) -> some View {
        self.overlay(alignment: .top) {
            if let msg = message.wrappedValue {
                ErrorToast(
                    message: msg,
                    icon: icon,
                    isShowing: Binding(
                        get: { message.wrappedValue != nil },
                        set: { if !$0 { message.wrappedValue = nil } }
                    )
                )
                .padding(.top, 50)
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                        withAnimation {
                            message.wrappedValue = nil
                        }
                    }
                }
            }
        }
    }
}

// MARK: - Usage Examples
#Preview("Error Alert") {
    Color.gray.opacity(0.1)
        .ignoresSafeArea()
        .errorAlert(
            error: .constant(.networkError("Unable to connect")),
            retryAction: {
                print("Retry tapped")
            }
        )
}

#Preview("Error Toast") {
    VStack {
        Text("Main Content")
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(Color.theme.background)
    .errorToast(message: .constant("Failed to load data"))
}
