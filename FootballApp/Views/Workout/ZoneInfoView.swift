//
//  ZoneInfoView.swift
//  FootballApp
//
//  Training zones guide showing all 5 intensity zones with descriptions.
//  Uses dark purple theme with glass morphism cards.
//

import SwiftUI

struct ZoneInfoView: View {
    var highlightedZone: String? = nil
    @Environment(\.dismiss) private var dismiss

    // Static zone data (matches the IntensityZone seeder on the API)
    private let zones: [(color: String, nameKey: String, range: String, rpeRange: String, descKey: String, swiftColor: Color, icon: String)] = [
        ("blue",   "zone.blue",   "50-60%",  "RPE 1-3",  "zone.blue.desc",   .blue,   "drop.fill"),
        ("green",  "zone.green",  "60-70%",  "RPE 3-5",  "zone.green.desc",  .green,  "leaf.fill"),
        ("yellow", "zone.yellow", "70-80%",  "RPE 5-7",  "zone.yellow.desc", .yellow, "figure.run"),
        ("orange", "zone.orange", "80-90%",  "RPE 7-9",  "zone.orange.desc", .orange, "bolt.fill"),
        ("red",    "zone.red",    "90-100%", "RPE 9-10", "zone.red.desc",    .red,    "flame.fill"),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground(intensity: 0.4)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header explanation
                        VStack(spacing: 10) {
                            Text("workout.info.zone_explanation".localizedString)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)

                            Text("tooltip.rpe_short".localizedString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.5))
                                .multilineTextAlignment(.center)
                        }
                        .padding(.horizontal, 20)

                        // Zone spectrum bar
                        HStack(spacing: 0) {
                            ForEach(zones, id: \.color) { zone in
                                zone.swiftColor
                                    .frame(height: 8)
                            }
                        }
                        .clipShape(Capsule())
                        .padding(.horizontal, 20)

                        // Zone cards
                        ForEach(zones, id: \.color) { zone in
                            zoneCard(zone: zone, isHighlighted: zone.color == highlightedZone)
                        }
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("workout.info.training_zones".localizedString)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title3)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }

    // MARK: - Zone Card

    private func zoneCard(
        zone: (color: String, nameKey: String, range: String, rpeRange: String, descKey: String, swiftColor: Color, icon: String),
        isHighlighted: Bool
    ) -> some View {
        HStack(spacing: 14) {
            // Zone color indicator circle
            ZStack {
                Circle()
                    .fill(zone.swiftColor.opacity(0.25))
                    .frame(width: 48, height: 48)

                Circle()
                    .fill(zone.swiftColor)
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: zone.icon)
                            .font(.system(size: 16, weight: .bold))
                            .foregroundColor(.white)
                    )
                    .shadow(color: zone.swiftColor.opacity(0.5), radius: 6, y: 2)
            }

            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 8) {
                    Text(zone.nameKey.localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    Text(zone.range)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(zone.swiftColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(zone.swiftColor.opacity(0.15))
                        .clipShape(Capsule())
                }

                Text(zone.rpeRange)
                    .font(.caption.weight(.medium))
                    .foregroundColor(.white.opacity(0.5))

                Text(zone.descKey.localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .lineLimit(3)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(isHighlighted ? 0.12 : 0.06),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isHighlighted
                                ? zone.swiftColor.opacity(0.6)
                                : Color.white.opacity(0.1),
                            lineWidth: isHighlighted ? 1.5 : 0.5
                        )
                )
        )
        .shadow(color: isHighlighted ? zone.swiftColor.opacity(0.3) : .clear, radius: 8, y: 4)
        .padding(.horizontal, 16)
        .scaleEffect(isHighlighted ? 1.02 : 1.0)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}

// MARK: - Preview

#Preview("Zone Info") {
    ZoneInfoView(highlightedZone: "orange")
}

#Preview("Zone Info - No Highlight") {
    ZoneInfoView()
}
