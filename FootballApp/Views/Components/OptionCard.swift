//
//  Untitled.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

struct OptionCard: View {
    private let titleKey: LocalizedStringKey
    private let subtitleKey: LocalizedStringKey?
    private let icon: String?
    private let isSelected: Bool
    private let action: () -> Void
    
    @State private var isPressed = false
    
    init(title: String, subtitle: String? = nil, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.titleKey = LocalizedStringKey(title)
        self.subtitleKey = subtitle.map { LocalizedStringKey($0) }
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    init(title: LocalizedStringKey, subtitle: LocalizedStringKey? = nil, icon: String? = nil, isSelected: Bool, action: @escaping () -> Void) {
        self.titleKey = title
        self.subtitleKey = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                action()
            }
        }) {
            HStack(alignment: .center, spacing: 16) {
                // Icon with enhanced styling
                if let icon = icon {
                    ZStack {
                        Circle()
                            .fill(
                                isSelected ? 
                                Color.theme.primary.opacity(0.15) : 
                                Color.theme.background.opacity(0.6)
                            )
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: icon)
                            .foregroundStyle(
                                isSelected ? 
                                LinearGradient(
                                    colors: [Color.theme.primary, Color.theme.accent],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ) : 
                                LinearGradient(
                                    colors: [Color.theme.textSecondary, Color.theme.textSecondary],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .font(.system(size: 22, weight: .semibold))
                    }
                    .scaleEffect(isSelected ? 1.05 : 1.0)
                }
                
                // Text content
                VStack(alignment: .leading, spacing: 6) {
                    Text(titleKey)
                        .font(.body.weight(.semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .multilineTextAlignment(.leading)
                    
                    if let subtitleKey = subtitleKey {
                        Text(subtitleKey)
                            .font(.caption)
                            .foregroundColor(Color.theme.textSecondary)
                            .multilineTextAlignment(.leading)
                            .lineLimit(2)
                    }
                }
                
                Spacer(minLength: 12)
                
                // Enhanced checkmark
                ZStack {
                    Circle()
                        .strokeBorder(
                            isSelected ? Color.theme.primary : Color.theme.textSecondary.opacity(0.3),
                            lineWidth: 2
                        )
                        .frame(width: 28, height: 28)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.theme.primary)
                            .frame(width: 28, height: 28)
                        
                        Image(systemName: "checkmark")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
            }
            .padding(16)
            .background(
                ZStack {
                    // Base layer
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(Color.theme.surface)
                    
                    // Selected gradient overlay
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.theme.primary.opacity(0.08),
                                        Color.theme.accent.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(
                        isSelected ? 
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ) : 
                        LinearGradient(
                            colors: [Color.clear, Color.clear],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 2
                    )
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .lightShadow()
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = true
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

#Preview {
    VStack(spacing: 16) {
        OptionCard(
            title: "Build Muscle",
            subtitle: "Gain strength and size with targeted workouts",
            icon: "figure.strengthtraining.traditional",
            isSelected: true
        ) {}
        
        OptionCard(
            title: LocalizedStringKey("Lose Weight"),
            subtitle: LocalizedStringKey("Burn fat and get lean"),
            icon: "flame.fill",
            isSelected: false
        ) {}
        
        OptionCard(
            title: "Stay Fit",
            subtitle: "Maintain your current fitness level",
            icon: "heart.fill",
            isSelected: false
        ) {}
        
        OptionCard(
            title: "No Icon Example",
            subtitle: "This card has no icon",
            isSelected: false
        ) {}
    }
    .padding()
    .background(Color.theme.background)
}
