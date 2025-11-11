//
//  ColorExtensions.swift
//  FootballApp
//
//  Centralized Color extensions to avoid duplicate declarations
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
}

// MARK: - App Theme Colors
// Centralized color definitions for the app
extension Color {
    struct AppTheme {
        // Primary Colors
        static let primary = Color(hex: "4338CA") // Indigo
        static let accent = Color(hex: "7C3AED") // Purple
        
        // Background Colors
        static let backgroundDark = Color(hex: "0A0A12")
        static let backgroundMedium = Color(hex: "12121F")
        static let backgroundLight = Color(hex: "0F0F1A")
        
        // Text Colors
        static let textPrimary = Color.white
        static let textSecondary = Color(hex: "9CA3AF")
        
        // Additional Colors
        static let success = Color(hex: "10B981")
        static let warning = Color(hex: "F59E0B")
        static let error = Color(hex: "EF4444")
    }
    
    // Convenience static properties for easier access
    static let appPrimary = AppTheme.primary
    static let appAccent = AppTheme.accent
    static let appBackgroundDark = AppTheme.backgroundDark
    static let appBackgroundMedium = AppTheme.backgroundMedium
    static let appBackgroundLight = AppTheme.backgroundLight
    static let appTextPrimary = AppTheme.textPrimary
    static let appTextSecondary = AppTheme.textSecondary
}
