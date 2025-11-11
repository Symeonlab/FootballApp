//
//  VisualStyleGuide.swift
//  FootballApp
//
//  Visual reference for the updated design system
//  Open in Xcode Canvas for interactive preview
//

import SwiftUI

/// Visual style guide showing all available design elements
struct VisualStyleGuide: View {
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 32) {
                    // Header
                    VStack(spacing: 8) {
                        Text("Design System")
                            .heroTitle()
                        
                        Text("Purple Theme · Space-Optimized")
                            .captionText()
                    }
                    .padding(.top)
                    
                    Divider()
                    
                    // Colors Section
                    ColorPaletteSection()
                    
                    Divider()
                    
                    // Typography Section
                    TypographySection()
                    
                    Divider()
                    
                    // Cards Section
                    CardsSection()
                    
                    Divider()
                    
                    // Buttons Section
                    ButtonsSection()
                    
                    Divider()
                    
                    // Badges Section
                    BadgesSection()
                    
                    Divider()
                    
                    // Shadows Section
                    ShadowsSection()
                    
                    Spacer(minLength: 100)
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Style Guide")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - Color Palette Section
struct ColorPaletteSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Color Palette")
                .sectionHeader()
            
            // Primary Colors
            HStack(spacing: 12) {
                GuideColorSwatch(color: Color.theme.primary, name: "Primary")
                GuideColorSwatch(color: Color.theme.accent, name: "Accent")
            }
            
            // Semantic Colors
            HStack(spacing: 12) {
                GuideColorSwatch(color: Color.theme.success, name: "Success")
                GuideColorSwatch(color: Color.theme.error, name: "Error")
            }
            
            // Purple Spectrum
            VStack(alignment: .leading, spacing: 8) {
                Text("Purple Spectrum")
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.theme.textSecondary)
                
                HStack(spacing: 8) {
                    GuideColorSwatch(color: Color.theme.purpleLight, name: "Light", compact: true)
                    GuideColorSwatch(color: Color.theme.purpleMedium, name: "Medium", compact: true)
                    GuideColorSwatch(color: Color.theme.purpleDark, name: "Dark", compact: true)
                    GuideColorSwatch(color: Color.theme.purpleDeep, name: "Deep", compact: true)
                }
            }
        }
    }
}

struct GuideColorSwatch: View {
    let color: Color
    let name: String
    var compact: Bool = false
    
    var body: some View {
        VStack(spacing: 8) {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color)
                .frame(height: compact ? 60 : 80)
                .overlay {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.white.opacity(0.3), lineWidth: 1)
                }
                .shadow(color: color.opacity(0.3), radius: 8, x: 0, y: 4)
            
            Text(name)
                .font(.caption2.weight(.medium))
                .foregroundColor(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Typography Section
struct TypographySection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Typography")
                .sectionHeader()
            
            VStack(alignment: .leading, spacing: 12) {
                Text("Hero Title")
                    .heroTitle()
                
                Text("Section Header")
                    .sectionHeader()
                
                Text("Body text with normal weight and proper line height for readability.")
                    .bodyText()
                
                Text("Caption text for metadata and secondary information")
                    .captionText()
                
                Text("TUESDAY")
                    .dayLabel()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .lightShadow()
        }
    }
}

// MARK: - Cards Section
struct CardsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Card Styles")
                .sectionHeader()
            
            // Glass Card
            VStack(alignment: .leading, spacing: 8) {
                Text("Glass Card")
                    .font(.headline)
                Text("With material background and glossy border")
                    .captionText()
            }
            .padding(16)
            .glassCard(padding: 16, cornerRadius: 16)
            
            // Workout Card
            VStack(alignment: .leading, spacing: 8) {
                Text("TUESDAY")
                    .dayLabel()
                Text("Workout Card")
                    .font(.title3.bold())
                HStack {
                    Label("45 min", systemImage: "clock")
                        .captionText()
                    Label("8 exercises", systemImage: "list.bullet")
                        .captionText()
                }
            }
            .workoutCard(isCompleted: false, cornerRadius: 16)
            
            // Completed Workout Card
            VStack(alignment: .leading, spacing: 8) {
                Text("MONDAY")
                    .dayLabel()
                Text("Completed Workout")
                    .font(.title3.bold())
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color.theme.success)
                    Text("Finished")
                        .captionText()
                }
            }
            .workoutCard(isCompleted: true, cornerRadius: 16)
        }
    }
}

// MARK: - Buttons Section
struct ButtonsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Buttons")
                .sectionHeader()
            
            // Primary Button
            Text("Primary Button")
                .primaryButton()
            
            // Secondary Button
            Text("Secondary Button")
                .secondaryButton()
            
            // Small Action Buttons
            HStack(spacing: 10) {
                HStack(spacing: 6) {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.theme.primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .glassCompact(cornerRadius: 12)
                
                HStack(spacing: 6) {
                    Image(systemName: "plus")
                    Text("Add")
                }
                .font(.subheadline.weight(.semibold))
                .foregroundColor(Color.theme.accent)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .glassCompact(cornerRadius: 12)
            }
            
            // Floating Action Button
            HStack {
                Spacer()
                Image(systemName: "plus")
                    .floatingActionButton()
                Spacer()
            }
        }
    }
}

// MARK: - Badges Section
struct BadgesSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Badges")
                .sectionHeader()
            
            HStack(spacing: 12) {
                Text("Rest Day")
                    .restDayBadge()
                
                Text("Active")
                    .activeWorkoutBadge()
                
                Text("Done")
                    .completedWorkoutBadge()
            }
        }
    }
}

// MARK: - Shadows Section
struct ShadowsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shadow & Glow Effects")
                .sectionHeader()
            
            // Light Shadow
            Text("Light Shadow")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .lightShadow()
            
            // Card Shadow
            Text("Card Shadow")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .cardShadow()
            
            // Purple Glow
            Text("Purple Glow")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.primary)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .purpleGlow(intensity: 0.4)
            
            // Success Glow
            Text("Success Glow")
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.theme.success)
                .foregroundColor(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .successGlow(intensity: 0.4)
        }
    }
}

// MARK: - Spacing Guide
struct SpacingGuide: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            Text("Spacing System")
                .sectionHeader()
            
            VStack(alignment: .leading, spacing: 16) {
                GuideSpacingRow(value: 8, label: "Compact (.compactSpacing())")
                GuideSpacingRow(value: 12, label: "Minimal (.minimalPadding())")
                GuideSpacingRow(value: 16, label: "Standard (default)")
                GuideSpacingRow(value: 20, label: "Generous (headers)")
            }
        }
        .padding()
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .cardShadow()
    }
}

struct GuideSpacingRow: View {
    let value: CGFloat
    let label: String
    
    var body: some View {
        HStack(spacing: 12) {
            Rectangle()
                .fill(Color.theme.primary)
                .frame(width: value, height: 32)
                .clipShape(RoundedRectangle(cornerRadius: 4, style: .continuous))
            
            VStack(alignment: .leading, spacing: 2) {
                Text("\(Int(value))pt")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color.theme.textSecondary)
            }
        }
    }
}

// MARK: - Grid Example
struct GridExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Grid Layout (4 columns)")
                .sectionHeader()
            
            let columns = [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ]
            
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(0..<8, id: \.self) { index in
                    VStack(spacing: 8) {
                        Circle()
                            .fill(Color.theme.primaryGradient)
                            .frame(width: 44, height: 44)
                            .overlay {
                                Text("\(index + 1)")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            }
                        
                        Text("Day \(index + 1)")
                            .font(.caption2)
                            .foregroundColor(Color.theme.textSecondary)
                    }
                    .gridCardItem(cornerRadius: 12)
                }
            }
        }
        .padding()
    }
}

// MARK: - Complete Example: Workout Card
struct CompleteWorkoutCardExample: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 32) {
            Text("Complete Example")
                .sectionHeader()
            
            VStack(alignment: .leading, spacing: 12) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("TUESDAY")
                            .dayLabel()
                        
                        Text("Cardio Blast")
                            .font(.title3.bold())
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Status icon
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 48, height: 48)
                        
                        Circle()
                            .fill(Color.theme.primaryGradient.opacity(0.3))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: "play.fill")
                            .foregroundColor(Color.theme.primary)
                    }
                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 6, x: 0, y: 3)
                }
                
                // Metadata
                HStack(spacing: 12) {
                    Label("8 exercises", systemImage: "list.bullet")
                        .captionText()
                    
                    Label("45 min", systemImage: "clock")
                        .captionText()
                }
                
                // CTA Button
                HStack {
                    Spacer()
                    Text("Start Workout")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background(Color.theme.primaryGradient)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(16)
            .workoutCard(isCompleted: false, cornerRadius: 18)
        }
        .padding()
    }
}

// MARK: - Preview
#Preview("Complete Style Guide") {
    VisualStyleGuide()
}

#Preview("Spacing Guide") {
    ScrollView {
        VStack(spacing: 32) {
            SpacingGuide()
            GridExample()
            CompleteWorkoutCardExample()
        }
        .padding()
    }
    .background(Color.theme.background)
}
