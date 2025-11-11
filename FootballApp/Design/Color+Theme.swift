//
//  Color+Theme.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI

// MARK: - Color Theme
// Comprehensive color system optimized for fitness/workout apps with purple theme
struct ColorTheme {
    // MARK: - Primary Colors
    let primary = Color("PrimaryPurple") // #7B61FF - Main brand purple
    let accent = Color("AccentTeal")     // #82EEF8 - Accent teal/cyan
    
    // MARK: - Purple Spectrum (Enhanced for better visual hierarchy)
    let purpleLight = Color(red: 0.58, green: 0.44, blue: 1.0)      // #9470FF - Lighter purple
    let purpleMedium = Color(red: 0.48, green: 0.38, blue: 1.0)     // #7B61FF - Main purple
    let purpleDark = Color(red: 0.38, green: 0.28, blue: 0.85)      // #6147D9 - Darker purple
    let purpleDeep = Color(red: 0.28, green: 0.18, blue: 0.65)      // #472EA6 - Deep purple
    
    // MARK: - Accent Colors (Complementary palette)
    let pink = Color(red: 1.0, green: 0.4, blue: 0.7)               // #FF66B2 - Pink accent
    let teal = Color(red: 0.51, green: 0.93, blue: 0.97)            // #82EEF8 - Teal accent
    let orange = Color(red: 1.0, green: 0.62, blue: 0.32)           // #FF9E52 - Warm orange
    let green = Color(red: 0.4, green: 0.85, blue: 0.55)            // #66D98C - Success green
    
    // MARK: - Background Colors (Optimized for full-screen usage)
    let background = Color(red: 0.97, green: 0.97, blue: 0.99)      // #F7F7FC - Very light purple tint
    let backgroundGradient = Color(red: 0.95, green: 0.94, blue: 0.98) // #F2F0FA - Subtle purple gradient
    let surface = Color.white                                        // #FFFFFF - Pure white for cards
    let surfaceElevated = Color(red: 0.99, green: 0.99, blue: 1.0)  // #FCFCFF - Slightly elevated surface
    
    // MARK: - Text Colors (Improved contrast)
    let textPrimary = Color(red: 0.15, green: 0.15, blue: 0.2)      // #262633 - Almost black with purple tint
    let textSecondary = Color(red: 0.54, green: 0.54, blue: 0.58)   // #8A8A94 - Medium gray
    let textTertiary = Color(red: 0.70, green: 0.70, blue: 0.74)    // #B3B3BC - Light gray
    let textInverse = Color.white                                    // #FFFFFF - White text
    
    // MARK: - Status Colors
    let success = Color(red: 0.4, green: 0.85, blue: 0.55)          // #66D98C - Success/completed
    let error = Color(red: 1.0, green: 0.35, blue: 0.45)            // #FF5973 - Error/warning
    let warning = Color(red: 1.0, green: 0.75, blue: 0.30)          // #FFBF4D - Warning
    let info = Color(red: 0.40, green: 0.70, blue: 1.0)             // #66B3FF - Info
    
    // MARK: - Semantic Colors (Context-specific)
    let restDay = Color(red: 0.65, green: 0.65, blue: 0.70)         // #A6A6B3 - Rest day indicator
    let activeWorkout = Color(red: 0.48, green: 0.38, blue: 1.0)    // #7B61FF - Active workout
    let completedWorkout = Color(red: 0.4, green: 0.85, blue: 0.55) // #66D98C - Completed workout
    
    // MARK: - Mesh Gradient (for background effects)
    let meshGradient = LinearGradient(
        colors: [
            Color(red: 0.97, green: 0.97, blue: 0.99),  // Very light purple
            Color(red: 0.95, green: 0.94, blue: 0.98),  // Subtle purple tint
            Color(red: 0.96, green: 0.95, blue: 0.98)   // Light purple blend
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // MARK: - Enhanced Gradients (Modern glass morphism style)
    
    // Primary purple gradient - Use for main CTAs and headers
    let primaryGradient = LinearGradient(
        colors: [
            Color(red: 0.58, green: 0.44, blue: 1.0),    // Light purple
            Color(red: 0.48, green: 0.38, blue: 1.0)     // Main purple
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Vibrant gradient - Use for hero sections and featured content
    let vibrantGradient = LinearGradient(
        colors: [
            Color(red: 0.48, green: 0.38, blue: 1.0),    // Purple
            Color(red: 1.0, green: 0.4, blue: 0.7)       // Pink
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Cool gradient - Use for cards and secondary elements
    let coolGradient = LinearGradient(
        colors: [
            Color(red: 0.48, green: 0.38, blue: 1.0),    // Purple
            Color(red: 0.51, green: 0.93, blue: 0.97)    // Teal
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Subtle background gradient - Use for full-screen backgrounds
    let backgroundGradientStyle = LinearGradient(
        colors: [
            Color(red: 0.97, green: 0.96, blue: 0.99),   // Very light purple
            Color(red: 0.95, green: 0.94, blue: 0.98),   // Subtle purple tint
            Color(red: 0.96, green: 0.95, blue: 0.98)    // Light purple blend
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Card gradient - Use for elevated cards with glass effect
    let cardGradient = LinearGradient(
        colors: [
            Color.white,
            Color.white.opacity(0.98),
            Color(red: 0.99, green: 0.99, blue: 1.0).opacity(0.95)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    // Success gradient - Use for completed states
    let successGradient = LinearGradient(
        colors: [
            Color(red: 0.4, green: 0.85, blue: 0.55),
            Color(red: 0.3, green: 0.75, blue: 0.45)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Warm gradient - Use for active/in-progress states
    let warmGradient = LinearGradient(
        colors: [
            Color(red: 1.0, green: 0.62, blue: 0.32),    // Orange
            Color(red: 1.0, green: 0.45, blue: 0.50)     // Coral
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Radial Gradients (For circular elements)
    let radialPrimaryGradient = RadialGradient(
        colors: [
            Color(red: 0.58, green: 0.44, blue: 1.0),
            Color(red: 0.48, green: 0.38, blue: 1.0),
            Color(red: 0.38, green: 0.28, blue: 0.85)
        ],
        center: .center,
        startRadius: 0,
        endRadius: 100
    )
    
    // MARK: - Angular Gradients (For dynamic animated elements)
    @available(iOS 16.0, *)
    var angularPrimaryGradient: AngularGradient {
        AngularGradient(
            colors: [
                Color(red: 0.48, green: 0.38, blue: 1.0),    // Purple
                Color(red: 1.0, green: 0.4, blue: 0.7),      // Pink
                Color(red: 0.51, green: 0.93, blue: 0.97),   // Teal
                Color(red: 0.48, green: 0.38, blue: 1.0)     // Purple (loop)
            ],
            center: .center
        )
    }
}

// MARK: - Color Extension
extension Color {
    static let theme = ColorTheme()
    
    // Convenience property for consistency with existing code
    static let appTheme = ColorTheme()
    
    // NOTE: init(hex:) is defined in a separate extension to avoid duplication
    
    // MARK: - Dynamic opacity helpers
    func dynamicOpacity(for state: ViewState) -> Color {
        switch state {
        case .active: return self
        case .inactive: return self.opacity(0.6)
        case .disabled: return self.opacity(0.3)
        case .pressed: return self.opacity(0.8)
        }
    }
    
    enum ViewState {
        case active, inactive, disabled, pressed
    }
}

// MARK: - Enhanced Shadow Styles
struct AdaptiveHorizontalPadding: ViewModifier {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    func body(content: Content) -> some View {
        // Avoid UIScreen.main (deprecated). Size class is a stable proxy for compact vs regular layouts.
        content.padding(.horizontal, horizontalSizeClass == .regular ? 20 : 16)
    }
}

extension View {
    // MARK: - Basic Shadows
    
    /// Subtle shadow for cards - Modern and minimal
    func cardShadow() -> some View {
        self.shadow(color: .black.opacity(0.08), radius: 12, x: 0, y: 4)
            .shadow(color: .black.opacity(0.04), radius: 4, x: 0, y: 2)
    }
    
    /// Very light shadow for nested elements
    func lightShadow() -> some View {
        self.shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
    }
    
    /// Strong shadow for floating elements and modals
    func strongShadow() -> some View {
        self.shadow(color: .black.opacity(0.15), radius: 24, x: 0, y: 12)
            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
    }
    
    /// Extra strong shadow for prominent elements
    func dramaticShadow() -> some View {
        self.shadow(color: .black.opacity(0.20), radius: 32, x: 0, y: 16)
            .shadow(color: .black.opacity(0.10), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Colored Shadows (For purple theme)
    
    /// Purple glow effect - Use for primary buttons and active states
    func purpleGlow(intensity: CGFloat = 0.3) -> some View {
        self.shadow(color: Color.theme.primary.opacity(intensity), radius: 16, x: 0, y: 8)
            .shadow(color: Color.theme.primary.opacity(intensity * 0.5), radius: 8, x: 0, y: 4)
    }
    
    /// Pink glow effect - Use for accent elements
    func pinkGlow(intensity: CGFloat = 0.3) -> some View {
        self.shadow(color: Color.theme.pink.opacity(intensity), radius: 16, x: 0, y: 8)
    }
    
    /// Success glow - Use for completed states
    func successGlow(intensity: CGFloat = 0.3) -> some View {
        self.shadow(color: Color.theme.success.opacity(intensity), radius: 12, x: 0, y: 6)
    }
    
    // MARK: - Inner Shadows (Glass morphism effect)
    
    /// Inner shadow effect for pressed states
    func innerShadow() -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .stroke(Color.black.opacity(0.1), lineWidth: 0.5)
                .blur(radius: 2)
                .offset(x: 0, y: 1)
        )
    }
}

// MARK: - Glass Morphism Helpers
extension View {
    /// Full glass card with border and shadow - Optimized for full-screen usage
    func glassCardFullScreen(
        padding: CGFloat = 16,
        cornerRadius: CGFloat = 20,
        borderOpacity: Double = 0.2
    ) -> some View {
        self
            .background {
                ZStack {
                    // Base glass effect
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Subtle gradient overlay for depth
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.black.opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // Glossy border
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.clear
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .cardShadow()
    }
    
    /// Compact glass effect for tight spaces
    func glassCompact(cornerRadius: CGFloat = 12) -> some View {
        self
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.white.opacity(0.3), lineWidth: 0.5)
            }
            .lightShadow()
    }
    
    /// Prominent glass effect with purple tint - Use for important CTAs
    func glassPurple(cornerRadius: CGFloat = 16, intensity: Double = 0.2) -> some View {
        self
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.theme.primary.opacity(intensity),
                                    Color.theme.primary.opacity(intensity * 0.5)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .overlay {
                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                    .strokeBorder(Color.theme.primary.opacity(0.3), lineWidth: 1)
            }
            .purpleGlow(intensity: 0.2)
    }
}

// MARK: - Layout Helpers (Maximize screen space)
extension View {
    /// Edge-to-edge content with safe area respect
    func fullScreenContent() -> some View {
        self
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .ignoresSafeArea(edges: .horizontal)
    }
    
    /// Maximum width with horizontal padding
    func maxWidthContent(padding: CGFloat = 16) -> some View {
        self
            .frame(maxWidth: .infinity)
            .padding(.horizontal, padding)
    }
    
    /// Adaptive padding based on size class
    func adaptivePadding() -> some View {
        self.modifier(AdaptiveHorizontalPadding())
    }
}

// MARK: - Animation Helpers (Smooth and dynamic interactions)
extension View {
    /// Spring animation for interactive elements
    func interactiveSpring() -> Animation {
        .spring(response: 0.3, dampingFraction: 0.7)
    }
    
    /// Smooth animation for transitions
    func smoothTransition() -> Animation {
        .easeInOut(duration: 0.3)
    }
    
    /// Bouncy animation for celebrations and success states
    func bouncyAnimation() -> Animation {
        .spring(response: 0.5, dampingFraction: 0.6)
    }
    
    /// Quick tap animation for immediate feedback
    func quickTap() -> Animation {
        .easeOut(duration: 0.15)
    }
    
    /// Smooth scale effect with haptic feedback
    func pressableScale(pressed: Bool) -> some View {
        self
            .scaleEffect(pressed ? 0.96 : 1.0)
            .animation(.interactiveSpring(), value: pressed)
    }
}

// MARK: - Typography Helpers (Consistent text styling from screenshots)
extension View {
    /// Large hero title (for workout names and headers)
    func heroTitle() -> some View {
        self.modifier(HeroTitleModifier())
    }
    
    /// Section header style (bold, prominent)
    func sectionHeader() -> some View {
        self.modifier(SectionHeaderModifier())
    }
    
    /// Body text style
    func bodyText() -> some View {
        self.modifier(BodyTextModifier())
    }
    
    /// Caption style (for metadata and secondary info)
    func captionText() -> some View {
        self.modifier(CaptionTextModifier())
    }
    
    /// Day label style (from screenshots - compact day names)
    func dayLabel() -> some View {
        self.modifier(DayLabelModifier())
    }
}

// MARK: - Typography Modifiers
struct HeroTitleModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.system(size: 32, weight: .bold, design: .rounded))
            .foregroundStyle(
                LinearGradient(
                    colors: [Color.theme.primary, Color.theme.accent],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
    }
}

struct SectionHeaderModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.headline.bold())
            .foregroundColor(Color.theme.textPrimary)
    }
}

struct BodyTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.body)
            .foregroundColor(Color.theme.textPrimary)
    }
}

struct CaptionTextModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption)
            .foregroundColor(Color.theme.textSecondary)
    }
}

struct DayLabelModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.caption2.weight(.bold))
            .foregroundColor(Color.theme.primary)
            .tracking(0.5)
    }
}

// MARK: - Interactive Button Styles (Matching screenshots)
extension View {
    /// Primary action button with gradient (main CTAs)
    func primaryButton(cornerRadius: CGFloat = 16) -> some View {
        self
            .font(.headline.weight(.semibold))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Color.theme.primaryGradient)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .purpleGlow(intensity: 0.3)
    }
    
    /// Secondary button with glass effect
    func secondaryButton(cornerRadius: CGFloat = 16) -> some View {
        self
            .font(.headline.weight(.medium))
            .foregroundColor(Color.theme.primary)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .glassCompact(cornerRadius: cornerRadius)
    }
    
    /// Floating action button (FAB) - for key actions
    func floatingActionButton() -> some View {
        self
            .font(.title2.weight(.semibold))
            .foregroundColor(.white)
            .frame(width: 60, height: 60)
            .background(Color.theme.primaryGradient)
            .clipShape(Circle())
            .dramaticShadow()
    }
    
    /// Tab bar icon style (from screenshots - bottom navigation)
    func tabBarIcon(isSelected: Bool) -> some View {
        self
            .font(.system(size: 22, weight: isSelected ? .semibold : .regular))
            .foregroundStyle(
                isSelected ?
                LinearGradient(
                    colors: [Color.theme.primary, Color.theme.pink],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                ) :
                LinearGradient(
                    colors: [Color.theme.textSecondary, Color.theme.textSecondary],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .scaleEffect(isSelected ? 1.1 : 1.0)
    }
}

// MARK: - Workout-Specific Modifiers (From Screenshots)
extension View {
    /// Rest day badge styling
    func restDayBadge() -> some View {
        self
            .font(.caption2.weight(.semibold))
            .foregroundColor(Color.theme.restDay)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.theme.restDay.opacity(0.15))
            .clipShape(Capsule())
    }
    
    /// Active workout badge styling (in-progress workouts)
    func activeWorkoutBadge() -> some View {
        self
            .font(.caption2.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.theme.activeWorkout)
            .clipShape(Capsule())
            .purpleGlow(intensity: 0.2)
    }
    
    /// Completed workout badge styling (checkmark states)
    func completedWorkoutBadge() -> some View {
        self
            .font(.caption2.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.theme.completedWorkout)
            .clipShape(Capsule())
            .successGlow(intensity: 0.2)
    }
    
    /// Workout card styling (matches screenshot cards)
    func workoutCard(isCompleted: Bool = false, cornerRadius: CGFloat = 16) -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    if isCompleted {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color.theme.success.opacity(0.15),
                                        Color.theme.success.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.4),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 0.5
                        )
                }
            }
            .shadow(color: isCompleted ? Color.theme.success.opacity(0.2) : Color.black.opacity(0.06), radius: 8, x: 0, y: 4)
    }
    
    /// Exercise list item styling (compact, information-dense)
    func exerciseListItem(isCompleted: Bool = false) -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(
                        isCompleted ? Color.theme.primary.opacity(0.3) : Color.clear,
                        lineWidth: 1.5
                    )
            }
            .lightShadow()
    }
}

// MARK: - Space Optimization Modifiers (Zero-waste layouts from screenshots)
extension View {
    /// Compact vertical spacing (reduce padding waste)
    func compactSpacing() -> some View {
        self.padding(.vertical, 8)
    }
    
    /// Minimal padding (tight layouts)
    func minimalPadding() -> some View {
        self.padding(12)
    }
    
    /// Full-width edge-to-edge cards (maximize content area)
    func fullWidthCard(cornerRadius: CGFloat = 16) -> some View {
        self
            .frame(maxWidth: .infinity)
            .background(Color.theme.surface)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .cardShadow()
    }
    
    /// Grid item sizing (for weekly calendar from screenshots)
    func gridCardItem(cornerRadius: CGFloat = 16) -> some View {
        self
            .frame(maxWidth: .infinity)
            .aspectRatio(0.85, contentMode: .fit)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .lightShadow()
    }
    
    /// Tab bar styling (from screenshots - bottom navigation bar)
    func customTabBar() -> some View {
        self
            .padding(.horizontal, 16)
            .padding(.top, 20)
            .padding(.bottom, 40)
            .background {
                ZStack {
                    Rectangle()
                        .fill(.ultraThinMaterial)
                    
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.1),
                            Color.clear
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                }
                .ignoresSafeArea(edges: .bottom)
            }
            .overlay(alignment: .top) {
                Rectangle()
                    .fill(.ultraThinMaterial)
                    .frame(height: 0.5)
                    .opacity(0.3)
            }
            .shadow(color: .black.opacity(0.15), radius: 30, x: 0, y: -10)
    }
}

// MARK: - Haptic Feedback Helpers (Enhanced UX)
extension View {
    /// Trigger light haptic feedback
    func lightHaptic() -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
        }
    }
    
    /// Trigger medium haptic feedback
    func mediumHaptic() -> some View {
        self.onTapGesture {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
        }
    }
    
    /// Trigger success haptic feedback
    func successHaptic() -> some View {
        self.onTapGesture {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
}

// MARK: - Accessibility Helpers (Inclusive design)
extension View {
    /// Accessible card with VoiceOver support
    func accessibleCard(label: String, hint: String? = nil) -> some View {
        self
            .accessibilityElement(children: .combine)
            .accessibilityLabel(label)
            .accessibilityHint(hint ?? "")
            .accessibilityAddTraits(.isButton)
    }
    
    /// Accessible badge
    func accessibleBadge(label: String) -> some View {
        self
            .accessibilityLabel(label)
            .accessibilityAddTraits(.isStaticText)
    }
}
