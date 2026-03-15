//
//  DarkPurpleAnimatedBackground.swift
//  FootballApp - DiPODDI
//
//  Enhanced dynamic background with aurora waves, floating particles,
//  and animated mesh gradient. Performant via TimelineView + Canvas.
//

import SwiftUI

// MARK: - Particle Model

private struct BackgroundParticle {
    let baseX: CGFloat
    let baseY: CGFloat
    let amplitudeX: CGFloat
    let amplitudeY: CGFloat
    let speedX: CGFloat
    let speedY: CGFloat
    let offsetX: CGFloat
    let offsetY: CGFloat
    let radius: CGFloat
    let opacity: Double
}

// MARK: - Main Background

struct DarkPurpleAnimatedBackground: View {
    /// Controls the overall intensity of aurora and particle effects (0.0 - 1.0)
    var intensity: Double = 1.0

    /// Pre-seeded particles created once
    @State private var particles: [BackgroundParticle] = []
    @State private var isReady = false

    var body: some View {
        GeometryReader { geo in
            if isReady {
                TimelineView(.animation(minimumInterval: 1.0 / 30.0)) { timeline in
                    let phase = timeline.date.timeIntervalSinceReferenceDate

                    ZStack {
                        // Layer 1 - Animated mesh gradient base
                        meshGradientBase(phase: phase)

                        // Layer 2 - Aurora wave effects
                        auroraWaves(phase: phase, size: geo.size)

                        // Layer 3 - Floating particles (Canvas for performance)
                        particleCanvas(phase: phase, size: geo.size)

                        // Layer 4 - Subtle noise texture for depth
                        noiseOverlay(size: geo.size)
                    }
                }
            } else {
                // Static fallback while initializing particles
                meshGradientBaseStatic
            }
        }
        .ignoresSafeArea()
        .onAppear {
            if particles.isEmpty {
                generateParticles()
            }
            isReady = true
        }
    }

    // MARK: - Layer 1: Animated Mesh Gradient

    private func meshGradientBase(phase: Double) -> some View {
        LinearGradient(
            colors: [
                Color(hex: "0A0A1E"),
                Color(hex: "12122A"),
                Color(hex: "1A1A3E"),
                Color(hex: "0F0F23")
            ],
            startPoint: UnitPoint(
                x: 0.5 + 0.25 * sin(phase * 0.08),
                y: 0.0 + 0.15 * cos(phase * 0.06)
            ),
            endPoint: UnitPoint(
                x: 0.5 - 0.2 * cos(phase * 0.07),
                y: 1.0 - 0.1 * sin(phase * 0.09)
            )
        )
    }

    private var meshGradientBaseStatic: some View {
        LinearGradient(
            colors: [
                Color(hex: "0A0A1E"),
                Color(hex: "12122A"),
                Color(hex: "1A1A3E"),
                Color(hex: "0F0F23")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    // MARK: - Layer 2: Aurora Waves

    private func auroraWaves(phase: Double, size: CGSize) -> some View {
        let auroraIntensity = intensity

        return ZStack {
            // Aurora band 1 - Primary purple, drifts top-right
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.theme.primary.opacity(0.12 * auroraIntensity),
                            Color.theme.primary.opacity(0.04 * auroraIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.5
                    )
                )
                .frame(width: size.width * 0.9, height: size.height * 0.35)
                .offset(
                    x: sin(phase * 0.12 + 0.5) * size.width * 0.25,
                    y: cos(phase * 0.09) * size.height * 0.15 - size.height * 0.18
                )
                .blur(radius: 55)

            // Aurora band 2 - Teal accent, drifts center-left
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color.theme.accent.opacity(0.08 * auroraIntensity),
                            Color.theme.accent.opacity(0.02 * auroraIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.45
                    )
                )
                .frame(width: size.width * 0.7, height: size.height * 0.3)
                .offset(
                    x: cos(phase * 0.10 + 2.0) * size.width * 0.3,
                    y: sin(phase * 0.07 + 1.0) * size.height * 0.12 + size.height * 0.1
                )
                .blur(radius: 50)

            // Aurora band 3 - Warm purple glow, bottom area
            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            Color(hex: "9470FF").opacity(0.10 * auroraIntensity),
                            Color.theme.primary.opacity(0.03 * auroraIntensity),
                            .clear
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size.width * 0.4
                    )
                )
                .frame(width: size.width * 0.8, height: size.height * 0.25)
                .offset(
                    x: sin(phase * 0.08 + 4.0) * size.width * 0.2,
                    y: cos(phase * 0.11 + 3.0) * size.height * 0.1 + size.height * 0.3
                )
                .blur(radius: 45)
        }
    }

    // MARK: - Layer 3: Floating Particles (Canvas)

    private func particleCanvas(phase: Double, size: CGSize) -> some View {
        Canvas { context, canvasSize in
            for particle in particles {
                let x = particle.baseX * canvasSize.width +
                    sin(phase * particle.speedX + particle.offsetX) * particle.amplitudeX * canvasSize.width
                let y = particle.baseY * canvasSize.height +
                    cos(phase * particle.speedY + particle.offsetY) * particle.amplitudeY * canvasSize.height

                let rect = CGRect(
                    x: x - particle.radius,
                    y: y - particle.radius,
                    width: particle.radius * 2,
                    height: particle.radius * 2
                )

                context.opacity = particle.opacity * intensity
                context.fill(Circle().path(in: rect), with: .color(.white))
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Layer 4: Noise Texture

    private func noiseOverlay(size: CGSize) -> some View {
        Canvas { context, canvasSize in
            // Subtle dot grid pattern for noise texture effect
            let spacing: CGFloat = 8
            let dotRadius: CGFloat = 0.5
            var row: CGFloat = 0
            while row < canvasSize.height {
                var col: CGFloat = 0
                while col < canvasSize.width {
                    let rect = CGRect(x: col, y: row, width: dotRadius * 2, height: dotRadius * 2)
                    context.opacity = 0.02
                    context.fill(Circle().path(in: rect), with: .color(.white))
                    col += spacing
                }
                row += spacing
            }
        }
        .allowsHitTesting(false)
    }

    // MARK: - Particle Generation

    private func generateParticles() {
        let count = Int(22.0 * intensity)
        var newParticles: [BackgroundParticle] = []

        for _ in 0..<max(count, 8) {
            newParticles.append(BackgroundParticle(
                baseX: CGFloat.random(in: 0.05...0.95),
                baseY: CGFloat.random(in: 0.05...0.95),
                amplitudeX: CGFloat.random(in: 0.02...0.08),
                amplitudeY: CGFloat.random(in: 0.02...0.06),
                speedX: CGFloat.random(in: 0.03...0.12),
                speedY: CGFloat.random(in: 0.03...0.10),
                offsetX: CGFloat.random(in: 0...(.pi * 2)),
                offsetY: CGFloat.random(in: 0...(.pi * 2)),
                radius: CGFloat.random(in: 1.5...4.0),
                opacity: Double.random(in: 0.06...0.18)
            ))
        }

        particles = newParticles
    }
}

// MARK: - Preview

#Preview("Dynamic Background") {
    DarkPurpleAnimatedBackground()
}

#Preview("Low Intensity") {
    DarkPurpleAnimatedBackground(intensity: 0.5)
}
