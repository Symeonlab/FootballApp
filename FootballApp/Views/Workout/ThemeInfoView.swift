//
//  ThemeInfoView.swift
//  FootballApp
//
//  Detailed information sheet about a workout session's theme and metadata.
//  Uses dark purple theme with glass morphism cards matching the app design system.
//

import SwiftUI

struct ThemeInfoView: View {
    let session: WorkoutSession
    @State private var showZoneGuide = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground(intensity: 0.4)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Header with zone color
                        headerSection

                        // Training method
                        if let method = session.metadata?.qualityMethod {
                            glassInfoCard(
                                icon: "target",
                                title: "workout.info.quality_method".localizedString,
                                value: method,
                                color: .blue
                            )
                        }

                        // Expected gains
                        if let gains = session.metadata?.gainPrediction {
                            glassInfoCardWithDescription(
                                icon: "arrow.up.right",
                                title: "workout.info.gain_prediction".localizedString,
                                value: gains,
                                description: "tooltip.gain_prediction".localizedString,
                                color: .green
                            )
                        }

                        // Injury risk
                        if let risk = session.metadata?.injuryRisk {
                            glassInfoCardWithDescription(
                                icon: "exclamationmark.triangle.fill",
                                title: "workout.info.injury_risk".localizedString,
                                value: risk,
                                description: "tooltip.injury_risk".localizedString,
                                color: riskColor(risk)
                            )
                        }

                        // Recovery window
                        if let window = session.metadata?.supercompWindow {
                            glassInfoCardWithDescription(
                                icon: "clock.arrow.circlepath",
                                title: "workout.info.supercomp_window".localizedString,
                                value: window,
                                description: "tooltip.supercomp_window".localizedString,
                                color: .purple
                            )
                        }

                        // Freshness indicator
                        if let freshness = session.metadata?.freshness24h {
                            glassInfoCardWithDescription(
                                icon: "battery.75percent",
                                title: "workout.info.freshness".localizedString,
                                value: "\(Int(freshness * 100))%",
                                description: "tooltip.freshness".localizedString,
                                color: freshness > 0.7 ? .green : (freshness > 0.4 ? .yellow : .red)
                            )
                        }

                        // RPE
                        if let meta = session.metadata, let rpe = meta.rpe {
                            rpeSection(rpe: rpe)
                        }

                        // Sleep & Hydration
                        recoverySection

                        // View all zones button
                        Button(action: { showZoneGuide = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "paintpalette.fill")
                                Text("workout.info.zone_guide".localizedString)
                            }
                            .font(.headline.weight(.semibold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color.appTheme.primaryGradient)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            .purpleGlow(intensity: 0.3)
                        }
                        .padding(.horizontal, 16)
                    }
                    .padding(.vertical, 16)
                    .padding(.bottom, 20)
                }
            }
            .navigationTitle("workout.info.about_theme".localizedString)
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
            .sheet(isPresented: $showZoneGuide) {
                ZoneInfoView(highlightedZone: session.metadata?.zoneColor)
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 14) {
            // Zone color circle with icon
            ZStack {
                Circle()
                    .fill(session.sessionZoneColor.opacity(0.2))
                    .frame(width: 80, height: 80)
                    .blur(radius: 10)

                Circle()
                    .fill(session.sessionZoneColor)
                    .frame(width: 64, height: 64)
                    .overlay(
                        Image(systemName: session.sessionIcon)
                            .font(.system(size: 28))
                            .foregroundColor(.white)
                    )
                    .shadow(color: session.sessionZoneColor.opacity(0.5), radius: 12, y: 4)
            }

            // Theme name
            Text(session.displayThemeName)
                .font(.title2.bold())
                .foregroundColor(.white)

            // Zone name badge
            if let meta = session.metadata, meta.zoneColor != nil {
                HStack(spacing: 6) {
                    Circle()
                        .fill(meta.zoneSwiftUIColor)
                        .frame(width: 8, height: 8)
                    Text(meta.zoneName)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(meta.zoneSwiftUIColor.opacity(0.2))
                        .overlay(
                            Capsule()
                                .strokeBorder(meta.zoneSwiftUIColor.opacity(0.3), lineWidth: 0.5)
                        )
                )
            }

            // Principal/secondary badge
            if let isPrincipal = session.metadata?.isPrincipalTheme {
                Text(isPrincipal ? "workout.info.principal_theme".localizedString : "workout.info.secondary_theme".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }
        }
        .padding(.vertical, 8)
    }

    // MARK: - Glass Info Card

    private func glassInfoCard(icon: String, title: String, value: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }

    private func glassInfoCardWithDescription(icon: String, title: String, value: String, description: String, color: Color) -> some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(color)
                .frame(width: 38, height: 38)
                .background(color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)
                Text(description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.4))
                    .lineLimit(2)
            }

            Spacer()
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }

    // MARK: - RPE Section

    private func rpeSection(rpe: Int) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: "gauge.medium")
                    .foregroundColor(.orange)
                Text("workout.info.rpe_explanation".localizedString)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
            }

            Text("tooltip.rpe_short".localizedString)
                .font(.caption)
                .foregroundColor(.white.opacity(0.4))

            // RPE bar visualization
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [rpeBarColor(rpe).opacity(0.7), rpeBarColor(rpe)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * CGFloat(rpe) / 10.0, height: 8)
                        .shadow(color: rpeBarColor(rpe).opacity(0.4), radius: 4, y: 1)
                }
            }
            .frame(height: 8)

            HStack {
                Text("1")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
                Spacer()
                Text(session.metadata?.rpeDescription ?? "\(rpe)/10")
                    .font(.subheadline.bold())
                    .foregroundColor(rpeBarColor(rpe))
                Spacer()
                Text("10")
                    .font(.system(size: 10))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(.ultraThinMaterial.opacity(0.5))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color.white.opacity(0.06), Color.clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                )
        )
        .padding(.horizontal, 16)
    }

    // MARK: - Recovery Section

    private var recoverySection: some View {
        let hasSleep = session.metadata?.sleepRecommendation != nil
        let hasHydration = session.metadata?.hydrationRecommendation != nil

        return Group {
            if hasSleep || hasHydration {
                VStack(spacing: 0) {
                    if let sleep = session.metadata?.sleepRecommendation {
                        HStack {
                            Image(systemName: "moon.fill")
                                .foregroundColor(.cyan)
                            Text("workout.sleep_tip".localizedString)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text(sleep)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        .padding(14)

                        if hasHydration {
                            Divider()
                                .background(Color.white.opacity(0.1))
                                .padding(.horizontal, 14)
                        }
                    }

                    if let hydration = session.metadata?.hydrationRecommendation {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundColor(.blue)
                            Text("workout.hydration_tip".localizedString)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                            Spacer()
                            Text(hydration)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                        }
                        .padding(14)
                    }
                }
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial.opacity(0.5))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color.white.opacity(0.06), Color.clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 0.5)
                        )
                )
                .padding(.horizontal, 16)
            }
        }
    }

    // MARK: - Helpers

    private func riskColor(_ risk: String) -> Color {
        let r = risk.lowercased()
        if r.contains("tres") || r.contains("very") || r.contains("extreme") { return .red }
        if r.contains("eleve") || r.contains("high") { return .orange }
        if r.contains("modere") || r.contains("moyen") || r.contains("moderate") || r.contains("medium") { return .yellow }
        return .green
    }

    private func rpeBarColor(_ rpe: Int) -> Color {
        switch rpe {
        case 1...3: return .green
        case 4...6: return .yellow
        case 7...8: return .orange
        case 9...10: return .red
        default: return .gray
        }
    }
}

// MARK: - Preview

#Preview("Theme Info") {
    ThemeInfoView(
        session: WorkoutSession(
            id: 1,
            day: "LUNDI",
            theme: "Strength",
            warmup: "5 min jog",
            finisher: "Stretching",
            exercises: [],
            metadata: WorkoutSessionMetadata(
                zoneColor: "orange",
                displayName: "Strength & Power",
                qualityMethod: "Progressive Overload",
                rpe: 8,
                mets: 7.5,
                estimatedLoad: 350,
                sleepRecommendation: "8-9 hours",
                hydrationRecommendation: "3.5L",
                isPrincipalTheme: true,
                supercompWindow: "36-48h",
                gainPrediction: "Maximal strength +2-3%",
                injuryRisk: "Moderate",
                freshness24h: 0.75,
                weeklyLoadSoFar: 800
            ),
            is_completed: false,
            completion_date: nil
        )
    )
}
