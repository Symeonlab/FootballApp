//
//  DeleteAccountView.swift
//  FootballApp - DiPODDI
//
//  GDPR-compliant account deletion view
//

import SwiftUI

struct DeleteAccountView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var password = ""
    @State private var confirmationText = ""
    @State private var isDeleting = false
    @State private var showError = false
    @State private var errorMessage = ""

    var canDelete: Bool {
        !password.isEmpty && confirmationText == "DELETE"
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Warning Banner
                        HStack(spacing: 12) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            VStack(alignment: .leading, spacing: 4) {
                                Text("delete_account.warning_title".localizedString)
                                    .font(.headline)
                                    .foregroundColor(.red)
                                Text("delete_account.warning_message".localizedString)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.red.opacity(0.15))
                        )

                        // What will be deleted
                        VStack(alignment: .leading, spacing: 10) {
                            Text("delete_account.what_deleted".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            ForEach(deletedItems, id: \.self) { item in
                                HStack(spacing: 8) {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                    Text(item)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.7))
                                }
                            }
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color.white.opacity(0.08))
                        )

                        // Password confirmation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("delete_account.enter_password".localizedString)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            SecureField("login.password_placeholder".localizedString, text: $password)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                        }

                        // Type DELETE confirmation
                        VStack(alignment: .leading, spacing: 8) {
                            Text("delete_account.type_delete".localizedString)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            TextField("DELETE", text: $confirmationText)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 10)
                                        .fill(Color.white.opacity(0.08))
                                )
                                .foregroundColor(.white)
                                .autocorrectionDisabled()
                                .textInputAutocapitalization(.characters)
                        }

                        // Delete button
                        Button(role: .destructive) {
                            Task { await deleteAccount() }
                        } label: {
                            HStack {
                                if isDeleting {
                                    ProgressView()
                                        .tint(.white)
                                }
                                Text("delete_account.confirm_button".localizedString)
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 12, style: .continuous)
                                    .fill(canDelete ? Color.red : Color.gray.opacity(0.5))
                            )
                            .foregroundColor(.white)
                        }
                        .disabled(!canDelete || isDeleting)
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("delete_account.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("common.cancel".localizedString) { dismiss() }
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }
            .alert("common.error".localizedString, isPresented: $showError) {
                Button("common.ok".localizedString, role: .cancel) {}
            } message: {
                Text(errorMessage)
            }
        }
    }

    private var deletedItems: [String] {
        [
            "delete_account.item_profile".localizedString,
            "delete_account.item_workouts".localizedString,
            "delete_account.item_progress".localizedString,
            "delete_account.item_health".localizedString,
            "delete_account.item_feedback".localizedString,
            "delete_account.item_achievements".localizedString,
        ]
    }

    private func deleteAccount() async {
        isDeleting = true
        defer { isDeleting = false }

        do {
            let _: GenericAPIResponse<String?> = try await APIService.shared.request(
                endpoint: APIEndpoints.accountDelete,
                method: "DELETE",
                body: ["password": password, "confirmation": "DELETE"]
            )
            await MainActor.run {
                authViewModel.signOut()
            }
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
    }
}
