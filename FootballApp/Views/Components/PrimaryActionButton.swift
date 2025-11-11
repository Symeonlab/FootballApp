//
//  PrimaryActionButton.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import SwiftUI

/// Enhanced primary "call to action" button with modern styling
struct PrimaryActionButton: View {
    var title: LocalizedStringKey
    var isEnabled: Bool = true
    var isLoading: Bool = false
    var action: () -> Void
    
    @State private var isPressed = false

    var body: some View {
        Button(action: {
            // Haptic feedback
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            
            action()
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .tint(.white)
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right")
                        .font(.body.weight(.semibold))
                }
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                Group {
                    if isEnabled {
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.primary.opacity(0.85)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    } else {
                        LinearGradient(
                            colors: [Color.gray.opacity(0.5), Color.gray.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .shadow(
                color: isEnabled ? Color.theme.primary.opacity(0.3) : Color.clear,
                radius: 12,
                x: 0,
                y: 6
            )
        }
        .disabled(!isEnabled || isLoading)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in
                    if isEnabled && !isLoading {
                        withAnimation(.easeInOut(duration: 0.1)) {
                            isPressed = true
                        }
                    }
                }
                .onEnded { _ in
                    withAnimation(.easeInOut(duration: 0.1)) {
                        isPressed = false
                    }
                }
        )
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .animation(.easeInOut(duration: 0.2), value: isEnabled)
    }
}

#Preview {
    VStack(spacing: 20) {
        PrimaryActionButton(
            title: "Continue",
            isEnabled: true,
            isLoading: false
        ) {
            print("Button tapped")
        }
        
        PrimaryActionButton(
            title: "Loading...",
            isEnabled: true,
            isLoading: true
        ) {
            print("Button tapped")
        }
        
        PrimaryActionButton(
            title: "Disabled",
            isEnabled: false
        ) {
            print("Button tapped")
        }
    }
    .padding()
    .background(Color.theme.background)
}
