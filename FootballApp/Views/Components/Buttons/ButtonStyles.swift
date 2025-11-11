//
//  ButtonStyles.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//
import SwiftUI
import Combine

#if true
public struct PrimaryButtonStyle: ButtonStyle {
    public var isLoading: Bool = false
    public init(isLoading: Bool = false) { self.isLoading = isLoading }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appTheme.primaryGradient)
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .overlay(
                Group {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    }
                }
            )
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

public struct SecondaryButtonStyle: ButtonStyle {
    public init() {}
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(Color.appTheme.textPrimary)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(Color.appTheme.surface)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
            .opacity(configuration.isPressed ? 0.9 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}
#endif

// Provide IconButtonStyle used by NutritionView
public struct IconButtonStyle: ButtonStyle {
    public var size: CGFloat = 40
    public var backgroundColor: Color
    public init(size: CGFloat = 40, backgroundColor: Color) {
        self.size = size
        self.backgroundColor = backgroundColor
    }
    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size, height: size)
            .background(
                Circle().fill(backgroundColor)
                    .overlay(Circle().stroke(Color.white.opacity(0.1), lineWidth: 1))
            )
            .foregroundColor(Color.appTheme.textPrimary)
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

extension IconButtonStyle {
    public init(size: CGFloat = 40) {
        self.init(size: size, backgroundColor: Color.appTheme.surface)
    }
}
