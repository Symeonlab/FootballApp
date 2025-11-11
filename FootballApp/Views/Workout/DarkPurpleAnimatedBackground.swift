//
//  DarkPurpleAnimatedBackground.swift
//  FootballApp
//

import SwiftUI

struct DarkPurpleAnimatedBackground: View {
    @State private var animate = false

    var body: some View {
        LinearGradient(
            colors: [
                .deepPurple,
                .darkPurple,
                .black,
                .deepPurple.opacity(0.85)
            ],
            startPoint: animate ? .topLeading : .bottomTrailing,
            endPoint: animate ? .bottomTrailing : .topLeading
        )
        .animation(.easeInOut(duration: 8).repeatForever(autoreverses: true), value: animate)
        .onAppear { animate = true }
        .overlay(
            RadialGradient(
                colors: [
                    .lightPurple.opacity(0.35),
                    .clear
                ],
                center: animate ? .topTrailing : .bottomLeading,
                startRadius: 20,
                endRadius: 420
            )
            .animation(.easeInOut(duration: 10).repeatForever(autoreverses: true), value: animate)
        )
    }
}

#Preview {
    DarkPurpleAnimatedBackground()
}
