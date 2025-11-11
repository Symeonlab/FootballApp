//
//  GlassButtonStyle.swift
//  FootballApp
//
//  Custom glass button styles using SwiftUI's latest material design
//

import SwiftUI

// MARK: - Glass Button Style
struct GlassButtonStyle: ButtonStyle {
    var variant: GlassVariant = .regular
    var isProminent: Bool = false
    
    enum GlassVariant {
        case regular
        case prominent
        case bordered
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background {
                ZStack {
                    if isProminent {
                        // Prominent glass with gradient
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                            .overlay {
                                RoundedRectangle(cornerRadius: 16, style: .continuous)
                                    .fill(
                                        LinearGradient(
                                            colors: [
                                                Color.blue.opacity(0.4),
                                                Color.cyan.opacity(0.3)
                                            ],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                    } else {
                        // Regular glass
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.ultraThinMaterial)
                    }
                    
                    // Border overlay
                    if variant == .bordered {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [
                                        Color.white.opacity(0.5),
                                        Color.white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
                }
            }
            .shadow(color: .black.opacity(configuration.isPressed ? 0.1 : 0.15), radius: configuration.isPressed ? 5 : 12, x: 0, y: configuration.isPressed ? 2 : 6)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Gradient Glass Button Style
struct GradientGlassButtonStyle: ButtonStyle {
    var startColor: Color = .blue
    var endColor: Color = .cyan
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .background {
                ZStack {
                    // Glass base
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.thinMaterial)
                    
                    // Gradient overlay
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [startColor, endColor],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .opacity(0.8)
                    
                    // Glossy highlight
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.3),
                                    Color.clear
                                ],
                                startPoint: .top,
                                endPoint: .center
                            )
                        )
                }
            }
            .shadow(color: startColor.opacity(configuration.isPressed ? 0.2 : 0.4), radius: configuration.isPressed ? 8 : 16, x: 0, y: configuration.isPressed ? 4 : 8)
            .scaleEffect(configuration.isPressed ? 0.96 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - Card Glass Button Style (for flat buttons on cards)
struct CardGlassButtonStyle: ButtonStyle {
    var color: Color = .blue
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(color.opacity(0.1))
                    }
            }
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        color.opacity(configuration.isPressed ? 0.4 : 0.2),
                        lineWidth: 1
                    )
            }
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.25, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Icon Glass Button Style
struct IconGlassButtonStyle: ButtonStyle {
    var size: CGFloat = 48
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title3)
            .foregroundStyle(.primary)
            .frame(width: size, height: size)
            .background {
                ZStack {
                    Circle()
                        .fill(.ultraThinMaterial)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: size / 2
                            )
                        )
                }
            }
            .overlay {
                Circle()
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.5),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
            .shadow(color: .black.opacity(configuration.isPressed ? 0.05 : 0.1), radius: configuration.isPressed ? 5 : 10, x: 0, y: configuration.isPressed ? 2 : 5)
            .scaleEffect(configuration.isPressed ? 0.92 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// MARK: - Extension for easy access
extension ButtonStyle where Self == GlassButtonStyle {
    static var glass: GlassButtonStyle {
        GlassButtonStyle()
    }
    
    static var glassProminent: GlassButtonStyle {
        GlassButtonStyle(isProminent: true)
    }
    
    static var glassBordered: GlassButtonStyle {
        GlassButtonStyle(variant: .bordered)
    }
}

extension ButtonStyle where Self == GradientGlassButtonStyle {
    static func gradientGlass(from startColor: Color = .blue, to endColor: Color = .cyan) -> GradientGlassButtonStyle {
        GradientGlassButtonStyle(startColor: startColor, endColor: endColor)
    }
}

extension ButtonStyle where Self == CardGlassButtonStyle {
    static func cardGlass(color: Color = .blue) -> CardGlassButtonStyle {
        CardGlassButtonStyle(color: color)
    }
}

extension ButtonStyle where Self == IconGlassButtonStyle {
    static func iconGlass(size: CGFloat = 48) -> IconGlassButtonStyle {
        IconGlassButtonStyle(size: size)
    }
}

// MARK: - Glass Card Modifier
struct GlassCardModifier: ViewModifier {
    var padding: CGFloat = 20
    var cornerRadius: CGFloat = 24
    
    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background {
                ZStack {
                    // Base glass
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.1),
                                    Color.clear,
                                    Color.black.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.5),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
    }
}

extension View {
    func glassCard(padding: CGFloat = 20, cornerRadius: CGFloat = 24) -> some View {
        modifier(GlassCardModifier(padding: padding, cornerRadius: cornerRadius))
    }
}
