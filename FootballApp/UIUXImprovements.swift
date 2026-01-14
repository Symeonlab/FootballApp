//
//  UIUXImprovements.swift
//  FootballApp
//
//  Modern UI/UX Components with Liquid Glass Design
//  Enhanced visual hierarchy, animations, and user experience
//

import SwiftUI

// MARK: - Enhanced Loading States with Skeleton Loaders

/// Modern skeleton loader for content placeholders
struct SkeletonView: View {
    @State private var isAnimating = false
    
    let height: CGFloat
    let cornerRadius: CGFloat
    
    init(height: CGFloat = 20, cornerRadius: CGFloat = 8) {
        self.height = height
        self.cornerRadius = cornerRadius
    }
    
    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
            .fill(
                LinearGradient(
                    colors: [
                        Color.gray.opacity(0.3),
                        Color.gray.opacity(0.15),
                        Color.gray.opacity(0.3)
                    ],
                    startPoint: isAnimating ? .leading : .trailing,
                    endPoint: isAnimating ? .trailing : .leading
                )
            )
            .frame(height: height)
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    isAnimating = true
                }
            }
    }
}

/// Skeleton loader for workout cards
struct WorkoutCardSkeleton: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                SkeletonView(height: 24, cornerRadius: 12)
                    .frame(width: 100)
                Spacer()
                SkeletonView(height: 24, cornerRadius: 12)
                    .frame(width: 60)
            }
            
            SkeletonView(height: 16, cornerRadius: 8)
            SkeletonView(height: 16, cornerRadius: 8)
                .frame(width: 200)
            
            HStack(spacing: 8) {
                SkeletonView(height: 32, cornerRadius: 16)
                    .frame(width: 80)
                SkeletonView(height: 32, cornerRadius: 16)
                    .frame(width: 100)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .strokeBorder(Color.white.opacity(0.2), lineWidth: 1)
        }
    }
}

// MARK: - Liquid Glass Components

/// Enhanced glass card with modern liquid glass effect
struct LiquidGlassCard<Content: View>: View {
    let content: Content
    let cornerRadius: CGFloat
    let tintColor: Color?
    let isInteractive: Bool
    
    @State private var isPressed = false
    
    init(
        cornerRadius: CGFloat = 20,
        tintColor: Color? = nil,
        isInteractive: Bool = false,
        @ViewBuilder content: () -> Content
    ) {
        self.cornerRadius = cornerRadius
        self.tintColor = tintColor
        self.isInteractive = isInteractive
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background {
                ZStack {
                    // Base glass effect
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    // Tint overlay
                    if let tintColor = tintColor {
                        RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [
                                        tintColor.opacity(0.15),
                                        tintColor.opacity(0.05)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    }
                    
                    // Glossy border with gradient
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2),
                                    Color.white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1.5
                        )
                    
                    // Subtle inner highlight
                    RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                        .blur(radius: 1)
                        .offset(y: -1)
                        .mask(
                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                        )
                }
            }
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
            .shadow(color: tintColor?.opacity(0.2) ?? .clear, radius: 15, x: 0, y: 8)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
            .if(isInteractive) { view in
                view
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            isPressed = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                isPressed = false
                            }
                        }
                    }
            }
    }
}

// MARK: - Enhanced Buttons with Liquid Glass

struct LiquidGlassButton: View {
    let title: String
    let icon: String?
    let style: ButtonStyleType
    let action: () -> Void
    
    @State private var isPressed = false
    
    enum ButtonStyleType {
        case primary
        case secondary
        case destructive
        
        var colors: [Color] {
            switch self {
            case .primary:
                return [Color.theme.primary, Color.theme.accent]
            case .secondary:
                return [Color.theme.purpleLight, Color.theme.purpleMedium]
            case .destructive:
                return [Color.theme.error, Color.theme.error.opacity(0.8)]
            }
        }
        
        var foregroundColor: Color {
            switch self {
            case .primary, .destructive:
                return .white
            case .secondary:
                return Color.theme.primary
            }
        }
    }
    
    init(
        _ title: String,
        icon: String? = nil,
        style: ButtonStyleType = .primary,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
                // Haptic feedback
                #if !targetEnvironment(simulator)
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                #endif
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            
            action()
        }) {
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                }
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
            }
            .foregroundColor(style.foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background {
                if style == .secondary {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(.ultraThinMaterial)
                        .overlay {
                            RoundedRectangle(cornerRadius: 16, style: .continuous)
                                .stroke(
                                    LinearGradient(
                                        colors: style.colors,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    lineWidth: 2
                                )
                        }
                } else {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: style.colors,
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
            }
            .shadow(color: style.colors.first?.opacity(0.3) ?? .clear, radius: 12, x: 0, y: 6)
        }
        .scaleEffect(isPressed ? 0.96 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Enhanced Stats Cards

struct EnhancedStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let trend: Trend?
    
    enum Trend {
        case up, down, neutral
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return .gray
            }
        }
    }
    
    init(
        icon: String,
        value: String,
        label: String,
        color: Color,
        trend: Trend? = nil
    ) {
        self.icon = icon
        self.value = value
        self.label = label
        self.color = color
        self.trend = trend
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [color, color.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)
                    .background {
                        Circle()
                            .fill(color.opacity(0.15))
                    }
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(trend.color)
                        .padding(6)
                        .background(trend.color.opacity(0.15), in: Circle())
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background {
            ZStack {
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(
                        LinearGradient(
                            colors: [
                                color.opacity(0.3),
                                color.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .strokeBorder(
                        LinearGradient(
                            colors: [
                                Color.white.opacity(0.4),
                                Color.white.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 1
                    )
            }
        }
        .shadow(color: color.opacity(0.3), radius: 15, x: 0, y: 8)
    }
}

// MARK: - Enhanced Empty States

struct EnhancedEmptyState: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        subtitle: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.subtitle = subtitle
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color.theme.primary.opacity(0.2),
                                Color.theme.accent.opacity(0.1)
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50, weight: .semibold))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            .shadow(color: Color.theme.primary.opacity(0.3), radius: 20, x: 0, y: 10)
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.system(size: 16))
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            if let actionTitle = actionTitle, let action = action {
                LiquidGlassButton(actionTitle, icon: "plus.circle.fill", style: .primary, action: action)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
            }
        }
        .padding(40)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Progress Ring with Animation

struct AnimatedProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    
    @State private var animatedProgress: Double = 0
    
    init(progress: Double, color: Color = Color.theme.primary, lineWidth: CGFloat = 8) {
        self.progress = min(max(progress, 0), 1)
        self.color = color
        self.lineWidth = lineWidth
    }
    
    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)
            
            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    LinearGradient(
                        colors: [color, color.opacity(0.7)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.spring(response: 1.0, dampingFraction: 0.7), value: animatedProgress)
        }
        .onAppear {
            animatedProgress = progress
        }
        .onChange(of: progress) { oldValue, newValue in
            withAnimation(.spring(response: 1.0, dampingFraction: 0.7)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Floating Action Button

struct FloatingActionButton: View {
    let icon: String
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            #if !targetEnvironment(simulator)
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            #endif
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isPressed = false
            }
            
            action()
        }) {
            Image(systemName: icon)
                .font(.system(size: 24, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 64, height: 64)
                .background {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.theme.primary, Color.theme.accent],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .shadow(color: Color.theme.primary.opacity(0.4), radius: 20, x: 0, y: 10)
                .shadow(color: .black.opacity(0.3), radius: 10, x: 0, y: 5)
        }
        .scaleEffect(isPressed ? 0.9 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

// MARK: - Helper Extensions

extension View {
    /// Conditionally applies a modifier
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

// MARK: - Preview Helpers

#Preview("Liquid Glass Card") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 20) {
                LiquidGlassCard(cornerRadius: 20, tintColor: Color.theme.primary) {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Liquid Glass Card")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        Text("This card demonstrates the modern liquid glass effect with enhanced visual depth and interactive animations.")
                            .font(.body)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                
                EnhancedStatCard(
                    icon: "figure.run",
                    value: "12",
                    label: "Workouts Completed",
                    color: Color.theme.primary,
                    trend: .up
                )
                
                LiquidGlassButton("Start Workout", icon: "play.fill", style: .primary) {
                    print("Workout started")
                }
                
                LiquidGlassButton("View Progress", icon: "chart.line.uptrend.xyaxis", style: .secondary) {
                    print("View progress")
                }
            }
            .padding()
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Empty State") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        EnhancedEmptyState(
            icon: "dumbbell.fill",
            title: "No Workouts Yet",
            subtitle: "Start your fitness journey by creating your first workout plan",
            actionTitle: "Create Workout",
            action: {
                print("Create workout tapped")
            }
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Progress Ring") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        VStack(spacing: 40) {
            AnimatedProgressRing(progress: 0.75, color: Color.theme.primary, lineWidth: 12)
                .frame(width: 120, height: 120)
                .overlay {
                    Text("75%")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundColor(.white)
                }
            
            AnimatedProgressRing(progress: 0.45, color: .green, lineWidth: 10)
                .frame(width: 100, height: 100)
                .overlay {
                    Text("45%")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.white)
                }
        }
    }
    .preferredColorScheme(.dark)
}

#Preview("Skeleton Loaders") {
    ZStack {
        Color.black
            .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 16) {
                WorkoutCardSkeleton()
                WorkoutCardSkeleton()
                WorkoutCardSkeleton()
            }
            .padding()
        }
    }
    .preferredColorScheme(.dark)
}
