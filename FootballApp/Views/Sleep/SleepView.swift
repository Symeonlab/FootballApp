//
//  SleepView.swift
//  DiPODDI
//
//  Sleep & Recovery view with protocols, chronotypes, and sleep calculator
//

import SwiftUI

struct SleepView: View {
    @StateObject private var viewModel = SleepViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var selectedSection: SleepSection = .calculator
    @State private var wakeHour = 7
    @State private var wakeMinute = 0
    @State private var selectedCycles = 5

    enum SleepSection: String, CaseIterable {
        case calculator, protocols, chronotypes

        var title: LocalizedStringKey {
            switch self {
            case .calculator: return "sleep.calculator"
            case .protocols: return "sleep.protocols"
            case .chronotypes: return "sleep.chronotypes"
            }
        }

        var icon: String {
            switch self {
            case .calculator: return "moon.zzz.fill"
            case .protocols: return "bed.double.fill"
            case .chronotypes: return "clock.fill"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Section Picker
                        sectionPicker

                        switch selectedSection {
                        case .calculator:
                            calculatorSection
                        case .protocols:
                            protocolsSection
                        case .chronotypes:
                            chronotypesSection
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("sleep.title".localized)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .task {
                await viewModel.fetchProtocols()
                await viewModel.fetchChronotypes()
            }
        }
    }

    // MARK: - Section Picker

    private var sectionPicker: some View {
        HStack(spacing: 8) {
            ForEach(SleepSection.allCases, id: \.self) { section in
                Button {
                    withAnimation(.spring(response: 0.3)) {
                        selectedSection = section
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: section.icon)
                            .font(.system(size: 14))
                        Text(section.title)
                            .font(.system(size: 13, weight: .semibold))
                    }
                    .padding(.horizontal, 14)
                    .padding(.vertical, 10)
                    .background(
                        selectedSection == section
                        ? Color.accentColor.opacity(0.3)
                        : Color.white.opacity(0.08)
                    )
                    .foregroundColor(selectedSection == section ? .white : .white.opacity(0.6))
                    .clipShape(Capsule())
                }
            }
        }
    }

    // MARK: - Calculator

    private var calculatorSection: some View {
        VStack(spacing: 16) {
            Card {
                VStack(spacing: 16) {
                    Text("sleep.wake_time".localized)
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        Picker("sleep.hour".localized, selection: $wakeHour) {
                            ForEach(0..<24, id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 100)
                        .clipped()

                        Text(":").font(.title).foregroundColor(.white)

                        Picker("sleep.minute".localized, selection: $wakeMinute) {
                            ForEach([0, 15, 30, 45], id: \.self) { Text(String(format: "%02d", $0)).tag($0) }
                        }
                        .pickerStyle(.wheel)
                        .frame(width: 70, height: 100)
                        .clipped()
                    }

                    Stepper("sleep.cycles".localizedString + ": \(selectedCycles)", value: $selectedCycles, in: 3...7)
                        .foregroundColor(.white)

                    AppButton(title: "sleep.calculate".localizedString, style: .primary) {
                        Task {
                            let time = String(format: "%02d:%02d", wakeHour, wakeMinute)
                            await viewModel.calculateBedtime(wakeTime: time, cycles: selectedCycles)
                        }
                    }
                }
            }

            if let calc = viewModel.sleepCalculation {
                Card {
                    VStack(spacing: 12) {
                        Text("sleep.recommended_bedtime".localized)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))

                        Text(calc.recommendedBedtime)
                            .font(.system(size: 48, weight: .bold, design: .rounded))
                            .foregroundColor(.accentColor)

                        Text("\(calc.cycles) " + "sleep.cycles_label".localizedString + " - \(calc.totalSleep)")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.6))

                        Divider().background(Color.white.opacity(0.2))

                        ForEach(calc.options, id: \.cycles) { option in
                            HStack {
                                Text("\(option.cycles) " + "sleep.cycles_label".localizedString)
                                    .foregroundColor(.white.opacity(0.7))
                                Spacer()
                                Text(option.bedtime)
                                    .fontWeight(.semibold)
                                    .foregroundColor(.white)
                                Text("(\(option.totalSleep))")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .font(.subheadline)
                        }
                    }
                }
            }
        }
    }

    // MARK: - Protocols

    private var protocolsSection: some View {
        VStack(spacing: 12) {
            Text("tooltip.sleep_protocol".localizedString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)

            if viewModel.isLoading {
                ProgressView().tint(.white)
            } else {
                ForEach(viewModel.protocols) { proto in
                    Card {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: categoryIcon(proto.category))
                                    .foregroundColor(categoryColor(proto.category))
                                Text(proto.conditionName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text(proto.category.capitalized)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(categoryColor(proto.category).opacity(0.2))
                                    .foregroundColor(categoryColor(proto.category))
                                    .clipShape(Capsule())
                            }

                            HStack(spacing: 16) {
                                Label("\(proto.cyclesMin)-\(proto.cyclesMax) " + "sleep.cycles_label".localizedString, systemImage: "repeat")
                                Label(proto.totalSleep, systemImage: "clock")
                            }
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))

                            Text(proto.objective)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
            }
        }
    }

    // MARK: - Chronotypes

    private var chronotypesSection: some View {
        VStack(spacing: 12) {
            // Explanation of what chronotypes are
            Text("sleep.chronotype_explanation".localizedString)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.6))
                .fixedSize(horizontal: false, vertical: true)

            Text("tooltip.chronotype".localizedString)
                .font(.caption)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 4)

            ForEach(viewModel.chronotypes) { chrono in
                Card {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text(chrono.icon ?? "")
                                .font(.system(size: 36))
                            VStack(alignment: .leading, spacing: 2) {
                                Text(chrono.name)
                                    .font(.headline.bold())
                                    .foregroundColor(.white)
                                Text(chrono.key.capitalized)
                                    .font(.caption2.weight(.semibold))
                                    .foregroundColor(.accentColor)
                            }
                            Spacer()
                        }

                        // Time schedule in distinct pill-shaped badges
                        HStack(spacing: 8) {
                            ChronoTimeBadge(icon: "sunrise.fill", time: chrono.wakeTime, color: .orange)
                            ChronoTimeBadge(icon: "bolt.fill", time: "\(chrono.peakStart)-\(chrono.peakEnd)", color: .yellow)
                            ChronoTimeBadge(icon: "moon.fill", time: chrono.bedtime, color: Color(hex: "6C5CE7"))
                        }

                        Text(chrono.description)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                            .fixedSize(horizontal: false, vertical: true)

                        Text(chrono.character)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                            .italic()
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private struct ChronoTimeBadge: View {
        let icon: String
        let time: String
        let color: Color

        var body: some View {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.caption2)
                    .foregroundColor(color)
                Text(time)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(color.opacity(0.15))
            )
        }
    }

    private func categoryIcon(_ category: String) -> String {
        switch category {
        case "injury": return "bandage.fill"
        case "medical": return "cross.case.fill"
        case "recovery": return "leaf.fill"
        default: return "bed.double.fill"
        }
    }

    private func categoryColor(_ category: String) -> Color {
        switch category {
        case "injury": return .red
        case "medical": return .orange
        case "recovery": return .green
        default: return .blue
        }
    }
}
