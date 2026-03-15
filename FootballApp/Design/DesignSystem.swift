//
//  DesignSystem.swift
//  DiPODDI
//
//  Extracted from WorkoutPlan.swift to organize design components.
//

import SwiftUI

// MARK: - Design System (Theme, Card, AppButton, FormRow)
struct AppTheme {
    struct Colors {
        static let primary = Color.accentColor
        static let secondary = Color.secondary
        static let bg = Color(UIColor.systemBackground)
        static let surface = Color(UIColor.secondarySystemBackground)
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
    }
    struct Spacing {
        static let s: CGFloat = 8
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
    }
}

struct Card<Content: View>: View {
    let content: () -> Content
    init(@ViewBuilder content: @escaping () -> Content) { self.content = content }
    var body: some View {
        content()
            .padding(AppTheme.Spacing.m)
            .background(AppTheme.Colors.surface, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

struct AppButton: View {
    enum Style { case primary, secondary, destructive }
    let title: String
    let style: Style
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .foregroundStyle(.white)
                .background(background)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
        }
        .buttonStyle(.plain)
        .padding(.vertical, 4)
        .accessibilityLabel(Text(title))
    }
    private var background: some View {
        switch style {
        case .primary: return AnyView(AppTheme.Colors.primary)
        case .secondary: return AnyView(Color.gray)
        case .destructive: return AnyView(AppTheme.Colors.error)
        }
    }
}

struct FormRow<Control: View>: View {
    let title: String
    var subtitle: String? = nil
    let control: () -> Control
    init(_ title: String, subtitle: String? = nil, @ViewBuilder control: @escaping () -> Control) {
        self.title = title; self.subtitle = subtitle; self.control = control
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(title).font(.headline)
                Spacer()
                control()
            }
            if let subtitle { Text(subtitle).font(.footnote).foregroundStyle(.secondary) }
        }
        .padding(.vertical, 8)
    }
}
