//
//  ExplanationView.swift
//  FootballApp
//
//  Educational overlays and info sheets for complex features
//

import SwiftUI

// MARK: - Info Sheet Button
struct InfoButton: View {
    // 1. Change from String to LocalizedStringKey
    let titleKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    let tipKeys: [LocalizedStringKey]
    
    @State private var showingInfo = false
    
    var body: some View {
        Button(action: { showingInfo = true }) {
            Image(systemName: "info.circle.fill")
                .font(.title3)
                .foregroundColor(Color.theme.primary)
        }
        .sheet(isPresented: $showingInfo) {
            // Pass the keys to the ExplanationSheet
            ExplanationSheet(
                titleKey: titleKey,
                descriptionKey: descriptionKey,
                tipKeys: tipKeys
            )
        }
    }
}

// MARK: - Explanation Sheet
struct ExplanationSheet: View {
    // 2. Accept LocalizedStringKey instead of String
    let titleKey: LocalizedStringKey
    let descriptionKey: LocalizedStringKey
    let tipKeys: [LocalizedStringKey]
    
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // Hero Icon
                    ZStack {
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [Color.theme.primary.opacity(0.2), Color.theme.accent.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .frame(width: 100, height: 100)
                        
                        Image(systemName: "lightbulb.fill")
                            .font(.system(size: 50))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.top, 20)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        Text("info.about_this_feature".localized)
                            .font(.headline)
                            .foregroundColor(Color.theme.textPrimary)
                        
                        Text(descriptionKey) // 3. Use the key
                            .font(.body)
                            .foregroundColor(Color.theme.textSecondary)
                            .lineSpacing(6)
                    }
                    .padding(.horizontal, 24)
                    
                    // Tips
                    if !tipKeys.isEmpty {
                        VStack(alignment: .leading, spacing: 16) {
                            Label("info.tips".localized, systemImage: "star.fill")
                                .font(.headline)
                                .foregroundColor(Color.theme.primary)
                                .padding(.horizontal, 24)
                            
                            VStack(spacing: 12) {
                                ForEach(Array(tipKeys.enumerated()), id: \.offset) { index, tipKey in
                                    TipCard(number: index + 1, textKey: tipKey) // 4. Use the key
                                }
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // Got it button
                    PrimaryActionButton(
                        title: "common.got_it".localized,
                        action: { dismiss() }
                    )
                    .padding(.horizontal, 24)
                    .padding(.top, 12)
                }
                .padding(.bottom, 32)
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle(titleKey) // 5. Use the key
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
            }
        }
    }
}

// MARK: - Tip Card
struct TipCard: View {
    let number: Int
    let textKey: LocalizedStringKey // 6. Use LocalizedStringKey
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.theme.primary)
                    .frame(width: 32, height: 32)
                
                Text("\(number)")
                    .font(.subheadline.weight(.bold))
                    .foregroundColor(.white)
            }
            
            Text(textKey) // 7. Use the key
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
        }
        .padding()
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        .lightShadow()
    }
}

// MARK: - Feature Highlight Tooltip
struct FeatureTooltip: View {
    let messageKey: LocalizedStringKey // 8. Use LocalizedStringKey
    let action: () -> Void
    @Binding var isShowing: Bool
    
    var body: some View {
        if isShowing {
            VStack(spacing: 12) {
                HStack {
                    Image(systemName: "sparkles")
                        .foregroundColor(Color.theme.accent)
                    Text(messageKey) // 9. Use the key
                        .font(.subheadline)
                        .foregroundColor(Color.theme.textPrimary)
                    Spacer()
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(Color.theme.textSecondary)
                    }
                }
                
                Button(action: action) {
                    Text("common.learn_more".localized) // 10. Use a key
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.theme.primary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color.theme.primary.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .lightShadow()
            .padding()
            .transition(.move(edge: .top).combined(with: .opacity))
        }
    }
}

// MARK: - Onboarding Explanation Texts
// 11. All static strings are now localization keys
extension ExplanationSheet {
    // Training Days Info
    static var trainingDaysInfo: ExplanationSheet {
        ExplanationSheet(
            titleKey: "info.training_days.title",
            descriptionKey: "info.training_days.description",
            tipKeys: [
                "info.training_days.tip1",
                "info.training_days.tip2",
                "info.training_days.tip3",
                "info.training_days.tip4"
            ]
        )
    }
    
    // Nutrition Plan Info
    static var nutritionPlanInfo: ExplanationSheet {
        ExplanationSheet(
            titleKey: "info.nutrition_plan.title",
            descriptionKey: "info.nutrition_plan.description",
            tipKeys: [
                "info.nutrition_plan.tip1",
                "info.nutrition_plan.tip2",
                "info.nutrition_plan.tip3",
                "info.nutrition_plan.tip4",
                "info.nutrition_plan.tip5"
            ]
        )
    }
    
    // MET Value Info
    static var metValueInfo: ExplanationSheet {
        ExplanationSheet(
            titleKey: "info.met.title",
            descriptionKey: "info.met.description",
            tipKeys: [
                "info.met.tip1",
                "info.met.tip2",
                "info.met.tip3",
                "info.met.tip4",
                "info.met.tip5"
            ]
        )
    }
    
    // Player Profile Info
    static var playerProfileInfo: ExplanationSheet {
        ExplanationSheet(
            titleKey: "info.player_profile.title",
            descriptionKey: "info.player_profile.description",
            tipKeys: [
                "info.player_profile.tip1",
                "info.player_profile.tip2",
                "info.player_profile.tip3",
                "info.player_profile.tip4"
            ]
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        InfoButton(
            titleKey: "info.training_days.title",
            descriptionKey: "info.training_days.description",
            tipKeys: [
                "info.training_days.tip1",
                "info.training_days.tip2",
                "info.training_days.tip3"
            ]
        )
    }
    .padding()
    .environmentObject(LanguageManager())
}
