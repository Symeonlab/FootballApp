//
//  ComponentShowcase.swift
//  FootballApp
//
//  Visual showcase of all enhanced UI components
//  Use this file to preview and test individual components
//

import SwiftUI

// MARK: - Component Showcase View
struct ComponentShowcase: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.backgroundGradientStyle
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // MARK: - Colors
                        ShowcaseSection(title: "Colors") {
                            ColorPaletteShowcase()
                        }
                        
                        // MARK: - Gradients
                        ShowcaseSection(title: "Gradients") {
                            GradientShowcase()
                        }
                        
                        // MARK: - Cards
                        ShowcaseSection(title: "Cards") {
                            CardsShowcase()
                        }
                        
                        // MARK: - Buttons
                        ShowcaseSection(title: "Buttons") {
                            ButtonsShowcase()
                        }
                        
                        // MARK: - Icons
                        ShowcaseSection(title: "Icons") {
                            IconsShowcase()
                        }
                        
                        // MARK: - Progress
                        ShowcaseSection(title: "Progress Indicators") {
                            ProgressShowcase()
                        }
                        
                        // MARK: - Typography
                        ShowcaseSection(title: "Typography") {
                            TypographyShowcase()
                        }
                        
                        // MARK: - Shadows
                        ShowcaseSection(title: "Shadows & Glows") {
                            ShadowsShowcase()
                        }
                        
                        Color.clear.frame(height: 60)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Component Showcase")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Section Container
struct ShowcaseSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.title2.bold())
                .foregroundStyle(Color.theme.textPrimary)
                .padding(.horizontal, 16)
            
            content
        }
    }
}

// MARK: - Color Palette Showcase
struct ColorPaletteShowcase: View {
    var body: some View {
        VStack(spacing: 12) {
            // Purple spectrum
            HStack(spacing: 8) {
                ShowcaseColorSwatch(name: "Light", color: Color.theme.purpleLight)
                ShowcaseColorSwatch(name: "Primary", color: Color.theme.primary)
                ShowcaseColorSwatch(name: "Dark", color: Color.theme.purpleDark)
                ShowcaseColorSwatch(name: "Deep", color: Color.theme.purpleDeep)
            }
            
            // Accent colors
            HStack(spacing: 8) {
                ShowcaseColorSwatch(name: "Pink", color: Color.theme.pink)
                ShowcaseColorSwatch(name: "Teal", color: Color.theme.teal)
                ShowcaseColorSwatch(name: "Orange", color: Color.theme.orange)
                ShowcaseColorSwatch(name: "Green", color: Color.theme.green)
            }
            
            // Status colors
            HStack(spacing: 8) {
                ShowcaseColorSwatch(name: "Success", color: Color.theme.success)
                ShowcaseColorSwatch(name: "Error", color: Color.theme.error)
                ShowcaseColorSwatch(name: "Warning", color: Color.theme.warning)
                ShowcaseColorSwatch(name: "Info", color: Color.theme.info)
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ShowcaseColorSwatch: View {
    let name: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 6) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: 60)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
            
            Text(name)
                .font(.caption2)
                .foregroundStyle(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Gradient Showcase
struct GradientShowcase: View {
    var body: some View {
        VStack(spacing: 12) {
            GradientSwatch(name: "Vibrant", gradient: Color.theme.vibrantGradient)
            GradientSwatch(name: "Cool", gradient: Color.theme.coolGradient)
            GradientSwatch(name: "Primary", gradient: Color.theme.primaryGradient)
            GradientSwatch(name: "Success", gradient: Color.theme.successGradient)
            GradientSwatch(name: "Warm", gradient: Color.theme.warmGradient)
        }
        .padding(.horizontal, 16)
    }
}

struct GradientSwatch: View {
    let name: String
    let gradient: LinearGradient
    
    var body: some View {
        HStack {
            Text(name)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(Color.theme.textPrimary)
                .frame(width: 80, alignment: .leading)
            
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(gradient)
                .frame(height: 50)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.5), lineWidth: 1)
                }
        }
    }
}

// MARK: - Cards Showcase
struct CardsShowcase: View {
    var body: some View {
        VStack(spacing: 12) {
            // Standard glass card
            VStack(alignment: .leading, spacing: 8) {
                Label("Standard Glass Card", systemImage: "square.fill")
                    .font(.headline)
                Text("This uses .glassCardFullScreen() modifier")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(16)
            .glassCardFullScreen(cornerRadius: 20)
            .maxWidthContent(padding: 16)
            
            // Compact glass
            HStack {
                Label("Compact Glass", systemImage: "circle.fill")
                    .font(.subheadline.weight(.medium))
                Spacer()
            }
            .padding(12)
            .glassCompact(cornerRadius: 12)
            .maxWidthContent(padding: 16)
            
            // Purple glass
            VStack(alignment: .leading, spacing: 8) {
                Label("Purple Glass Card", systemImage: "star.fill")
                    .font(.headline)
                    .foregroundStyle(Color.theme.primary)
                Text("Uses .glassPurple() for emphasis")
                    .font(.caption)
                    .foregroundStyle(Color.theme.textSecondary)
            }
            .padding(16)
            .glassPurple(cornerRadius: 16, intensity: 0.2)
            .maxWidthContent(padding: 16)
        }
    }
}

// MARK: - Buttons Showcase
struct ButtonsShowcase: View {
    var body: some View {
        VStack(spacing: 16) {
            // Primary CTA
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("Primary Button")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                    Spacer()
                }
                .foregroundStyle(.white)
                .padding(.vertical, 14)
                .background {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(.thinMaterial)
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .fill(Color.theme.vibrantGradient)
                            .opacity(0.95)
                    }
                }
            }
            .buttonStyle(.plain)
            .purpleGlow(intensity: 0.3)
            .maxWidthContent(padding: 16)
            
            // Secondary button
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("Secondary Button")
                        .font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .foregroundStyle(Color.theme.primary)
                .padding(.vertical, 14)
                .background {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14, style: .continuous)
                                .strokeBorder(Color.theme.primary.opacity(0.3), lineWidth: 1)
                        }
                }
            }
            .buttonStyle(.plain)
            .maxWidthContent(padding: 16)
            
            // Icon buttons
            HStack(spacing: 12) {
                IconButton(icon: "heart.fill", color: .pink)
                IconButton(icon: "star.fill", color: .orange)
                IconButton(icon: "flame.fill", color: .purple)
                IconButton(icon: "bolt.fill", color: .teal)
            }
            .maxWidthContent(padding: 16)
        }
    }
}

struct IconButton: View {
    let icon: String
    let color: Color
    
    var body: some View {
        Button(action: {}) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 56, height: 56)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 28
                        )
                    )
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Icons Showcase
struct IconsShowcase: View {
    var body: some View {
        VStack(spacing: 16) {
            // Various icon styles
            HStack(spacing: 16) {
                GlassIcon(icon: "figure.run", color: Color.theme.primary, size: 64)
                GlassIcon(icon: "flame.fill", color: Color.theme.orange, size: 64)
                GlassIcon(icon: "heart.fill", color: Color.theme.pink, size: 64)
                GlassIcon(icon: "leaf.fill", color: Color.theme.green, size: 64)
            }
            
            HStack(spacing: 16) {
                GlassIcon(icon: "figure.run", color: Color.theme.primary, size: 52)
                GlassIcon(icon: "flame.fill", color: Color.theme.orange, size: 52)
                GlassIcon(icon: "heart.fill", color: Color.theme.pink, size: 52)
                GlassIcon(icon: "leaf.fill", color: Color.theme.green, size: 52)
            }
        }
        .maxWidthContent(padding: 16)
    }
}

struct GlassIcon: View {
    let icon: String
    let color: Color
    let size: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .fill(.ultraThinMaterial)
                .frame(width: size, height: size)
            
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            color.opacity(0.3),
                            color.opacity(0.1)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: size / 2
                    )
                )
                .frame(width: size, height: size)
            
            Image(systemName: icon)
                .font(.system(size: size * 0.4))
                .foregroundStyle(color)
        }
    }
}

// MARK: - Progress Showcase
struct ProgressShowcase: View {
    @State private var progress: Double = 0.65
    
    var body: some View {
        VStack(spacing: 20) {
            // Circular progress
            HStack(spacing: 30) {
                CircularProgress(progress: progress, size: 80, lineWidth: 8)
                CircularProgress(progress: progress, size: 100, lineWidth: 10)
                CircularProgress(progress: progress, size: 120, lineWidth: 12)
            }
            
            // Progress slider
            VStack(spacing: 8) {
                Text("Progress: \(Int(progress * 100))%")
                    .font(.caption.weight(.medium))
                    .foregroundStyle(Color.theme.textSecondary)
                
                Slider(value: $progress, in: 0...1)
                    .tint(Color.theme.primary)
            }
            .padding(.horizontal, 16)
        }
        .padding(16)
        .glassCardFullScreen(cornerRadius: 20)
        .maxWidthContent(padding: 16)
    }
}

struct CircularProgress: View {
    let progress: Double
    let size: CGFloat
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.theme.primary.opacity(0.15), lineWidth: lineWidth)
            
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    Color.theme.vibrantGradient,
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.7), value: progress)
            
            Text("\(Int(progress * 100))%")
                .font(.system(size: size * 0.25, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.textPrimary)
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Typography Showcase
struct TypographyShowcase: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            TypographyExample(
                text: "Large Title",
                font: .largeTitle.bold(),
                description: ".largeTitle.bold()"
            )
            
            TypographyExample(
                text: "Title 2",
                font: .title2.bold(),
                description: ".title2.bold()"
            )
            
            TypographyExample(
                text: "Title 3",
                font: .title3.bold(),
                description: ".title3.bold()"
            )
            
            TypographyExample(
                text: "Headline Semibold",
                font: .headline.weight(.semibold),
                description: ".headline.weight(.semibold)"
            )
            
            TypographyExample(
                text: "Body Semibold",
                font: .body.weight(.semibold),
                description: ".body.weight(.semibold)"
            )
            
            TypographyExample(
                text: "Subheadline Medium",
                font: .subheadline.weight(.medium),
                description: ".subheadline.weight(.medium)"
            )
            
            TypographyExample(
                text: "Caption Medium",
                font: .caption.weight(.medium),
                description: ".caption.weight(.medium)"
            )
            
            TypographyExample(
                text: "CAPTION2 BOLD",
                font: .caption2.weight(.bold),
                description: ".caption2.weight(.bold)"
            )
        }
        .padding(16)
        .glassCardFullScreen(cornerRadius: 20)
        .maxWidthContent(padding: 16)
    }
}

struct TypographyExample: View {
    let text: String
    let font: Font
    let description: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(text)
                .font(font)
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(description)
                .font(.caption2)
                .foregroundStyle(Color.theme.textTertiary)
        }
    }
}

// MARK: - Shadows Showcase
struct ShadowsShowcase: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 16) {
                ShadowBoxLight(title: "Light")
                ShadowBoxCard(title: "Card")
            }
            
            HStack(spacing: 16) {
                ShadowBoxStrong(title: "Strong")
                ShadowBoxDramatic(title: "Dramatic")
            }
            
            HStack(spacing: 16) {
                ShadowBoxPurple(title: "Purple")
                ShadowBoxSuccess(title: "Success")
            }
        }
        .maxWidthContent(padding: 16)
    }
}

struct ShadowBoxLight: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .lightShadow()
    }
}

struct ShadowBoxCard: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .cardShadow()
    }
}

struct ShadowBoxStrong: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .strongShadow()
    }
}

struct ShadowBoxDramatic: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .dramaticShadow()
    }
}

struct ShadowBoxPurple: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .purpleGlow(intensity: 0.4)
    }
}

struct ShadowBoxSuccess: View {
    let title: String
    
    var body: some View {
        VStack {
            Text(title)
                .font(.caption.weight(.medium))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 30)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.white)
        }
        .successGlow(intensity: 0.4)
    }
}

// MARK: - Preview
#Preview {
    ComponentShowcase()
}
