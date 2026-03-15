//
//  PrivacyPolicyView.swift
//  FootballApp - DiPODDI
//
//  GDPR-compliant privacy policy view
//

import SwiftUI

struct PrivacyPolicyView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 20) {
                        // Header
                        VStack(alignment: .leading, spacing: 8) {
                            Text("privacy.title".localizedString)
                                .font(.title2.bold())
                                .foregroundColor(.white)
                            Text("privacy.last_updated".localizedString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                        }

                        // Data Collection
                        privacySection(
                            icon: "person.crop.circle.fill",
                            title: "privacy.data_collection.title".localizedString,
                            content: "privacy.data_collection.content".localizedString
                        )

                        // How We Use Data
                        privacySection(
                            icon: "gearshape.fill",
                            title: "privacy.data_usage.title".localizedString,
                            content: "privacy.data_usage.content".localizedString
                        )

                        // Data Storage & Security
                        privacySection(
                            icon: "lock.shield.fill",
                            title: "privacy.data_security.title".localizedString,
                            content: "privacy.data_security.content".localizedString
                        )

                        // Your Rights (GDPR)
                        privacySection(
                            icon: "checkmark.shield.fill",
                            title: "privacy.your_rights.title".localizedString,
                            content: "privacy.your_rights.content".localizedString
                        )

                        // Data Retention
                        privacySection(
                            icon: "clock.fill",
                            title: "privacy.retention.title".localizedString,
                            content: "privacy.retention.content".localizedString
                        )

                        // Contact
                        privacySection(
                            icon: "envelope.fill",
                            title: "privacy.contact.title".localizedString,
                            content: "privacy.contact.content".localizedString
                        )
                    }
                    .padding()
                    .padding(.bottom, 30)
                }
            }
            .navigationTitle("privacy.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("common.close".localizedString) { dismiss() }
                        .foregroundColor(Color(hex: "4A90E2"))
                }
            }
        }
    }

    @ViewBuilder
    private func privacySection(icon: String, title: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(Color(hex: "4A90E2"))
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            Text(content)
                .font(.body)
                .foregroundColor(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color.white.opacity(0.08))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
    }
}
