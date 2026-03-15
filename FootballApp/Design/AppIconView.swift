//
//  AppIconView.swift
//  FootballApp - DiPODDI
//
//  Programmatic app icon generator.
//  Use ImageRenderer to export a 1024x1024 PNG for the App Store.
//

import SwiftUI

struct AppIconView: View {
    let size: CGFloat

    init(size: CGFloat = 1024) {
        self.size = size
    }

    var body: some View {
        ZStack {
            // Layer 1: Background gradient (brand colors)
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1A1A3E"),
                            Color(hex: "12122A"),
                            Color(hex: "0A0A1E")
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            // Layer 2: Primary purple glow (top-right)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "7B61FF").opacity(0.45),
                            Color(hex: "7B61FF").opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.5
                    )
                )
                .frame(width: size * 0.85, height: size * 0.85)
                .offset(x: size * 0.18, y: -size * 0.22)

            // Layer 3: Teal accent glow (bottom-left)
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "82EEF8").opacity(0.3),
                            Color(hex: "82EEF8").opacity(0.08),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.4
                    )
                )
                .frame(width: size * 0.6, height: size * 0.6)
                .offset(x: -size * 0.18, y: size * 0.22)

            // Layer 4: Subtle secondary purple glow (center-bottom)
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "9470FF").opacity(0.15),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size * 0.35
                    )
                )
                .frame(width: size * 0.7, height: size * 0.4)
                .offset(y: size * 0.1)

            // Layer 5: dp monogram logo with white-to-teal gradient
            Image("DipoddiLogo")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: size * 0.55, height: size * 0.55)
                .foregroundStyle(
                    LinearGradient(
                        colors: [.white, Color(hex: "82EEF8")],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .shadow(color: Color(hex: "7B61FF").opacity(0.6), radius: size * 0.04, x: 0, y: size * 0.01)
                .shadow(color: Color(hex: "7B61FF").opacity(0.3), radius: size * 0.08, x: 0, y: size * 0.02)

            // Layer 6: Subtle inner border for polish
            RoundedRectangle(cornerRadius: size * 0.22, style: .continuous)
                .strokeBorder(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.25),
                            Color.white.opacity(0.08),
                            Color.white.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: size * 0.004
                )
        }
        .frame(width: size, height: size)
        .clipShape(RoundedRectangle(cornerRadius: size * 0.22, style: .continuous))
    }
}

// MARK: - Icon Export Helper

@MainActor
func exportAppIcon() -> Data? {
    let renderer = ImageRenderer(content: AppIconView(size: 1024))
    renderer.scale = 1.0
    return renderer.uiImage?.pngData()
}

// MARK: - Preview

#Preview("App Icon 1024") {
    AppIconView(size: 300)
        .padding()
        .background(Color.black)
}

#Preview("App Icon Small") {
    HStack(spacing: 20) {
        AppIconView(size: 60)
        AppIconView(size: 120)
        AppIconView(size: 180)
    }
    .padding()
    .background(Color.black)
}
