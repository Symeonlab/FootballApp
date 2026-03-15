//
//  ColorExtensions.swift
//  FootballApp
//
//  Centralized Color extensions for the app
//  - Hex initialization
//  - Named purple colors for animated backgrounds
//

import SwiftUI

// MARK: - Color Hex Extension
extension Color {
    /// Initialize a Color from a hex string
    /// Supports 3, 6, and 8 character hex strings (RGB and ARGB)
    /// - Parameter hex: Hex color string (e.g., "4338CA", "#4338CA", "AABBCCDD")
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }

    // MARK: - Named Purple Colors (for DarkPurpleAnimatedBackground)
    static let deepPurple = Color(red: 0.23, green: 0.07, blue: 0.36)
    static let darkPurple = Color(red: 0.15, green: 0.05, blue: 0.25)
    static let lightPurple = Color(red: 0.62, green: 0.40, blue: 0.82)
}

// NOTE: Main color theme is defined in Color+Theme.swift as Color.theme
// Use Color.theme.primary, Color.theme.accent, etc. for app-wide colors
