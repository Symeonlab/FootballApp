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

// MARK: - Modern Workout Components

/// Loading view for workout screen
struct ModernWorkoutLoadingView: View {
    var body: some View {
        VStack(spacing: 24) {
            // Skeleton loaders to preview the layout while loading
            VStack(spacing: 16) {
                // Weekly strip skeleton
                HStack(spacing: 0) {
                    ForEach(0..<7, id: \.self) { _ in
                        VStack(spacing: 6) {
                            SkeletonView(height: 36, cornerRadius: 18)
                                .frame(width: 36)
                            SkeletonView(height: 10, cornerRadius: 4)
                                .frame(width: 24)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .padding(.horizontal)

                // Today hero card skeleton
                HStack(spacing: 20) {
                    SkeletonView(height: 86, cornerRadius: 43)
                        .frame(width: 86)
                    VStack(alignment: .leading, spacing: 10) {
                        SkeletonView(height: 22, cornerRadius: 8)
                            .frame(width: 160)
                        SkeletonView(height: 14, cornerRadius: 6)
                            .frame(width: 120)
                        SkeletonView(height: 36, cornerRadius: 18)
                            .frame(width: 140)
                    }
                    Spacer()
                }
                .padding(18)
                .background(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color.white.opacity(0.04))
                )
                .padding(.horizontal)

                // Weekly schedule skeleton rows
                VStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { _ in
                        WorkoutCardSkeleton()
                    }
                }
                .padding(.horizontal)
            }
            .padding(.top, 60)

            Spacer()

            Text("workouts.generating_plan".localizedString)
                .font(.subheadline.weight(.medium))
                .foregroundColor(.white.opacity(0.6))
                .padding(.bottom, 120)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// Empty state view for workout screen
struct ModernWorkoutEmptyStateView: View {
    let onGenerate: () -> Void

    var body: some View {
        EnhancedEmptyState(
            icon: "dumbbell.fill",
            title: "workout.no_plan".localizedString,
            subtitle: "workout.generate_plan_subtitle".localizedString,
            actionTitle: "workout.generate_plan".localizedString,
            action: onGenerate
        )
    }
}

/// Weekly calendar showing workout days
struct ModernWorkoutWeeklyCalendar: View {
    let days: [(String, Bool, Bool, Bool)] // (day, isToday, isCompleted, isRestDay)
    let onDayTap: (Int) -> Void

    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                Button {
                    onDayTap(index)
                } label: {
                    VStack(spacing: 6) {
                        Text(day.0)
                            .font(.caption.bold())
                            .foregroundColor(day.1 ? .white : .white.opacity(0.6))

                        ZStack {
                            Circle()
                                .fill(dayBackgroundColor(isToday: day.1, isCompleted: day.2, isRestDay: day.3))
                                .frame(width: 36, height: 36)

                            if day.2 {
                                Image(systemName: "checkmark")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(.white)
                            } else if day.3 {
                                Image(systemName: "moon.fill")
                                    .font(.system(size: 14))
                                    .foregroundColor(.white.opacity(0.5))
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(day.1 ? Color.theme.primary.opacity(0.2) : Color.clear)
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        )
    }

    private func dayBackgroundColor(isToday: Bool, isCompleted: Bool, isRestDay: Bool) -> Color {
        if isCompleted {
            return Color.green
        } else if isToday {
            return Color.theme.primary
        } else if isRestDay {
            return Color.gray.opacity(0.3)
        }
        return Color.white.opacity(0.1)
    }
}

/// Workout session card
struct ModernWorkoutSessionCard: View {
    let theme: String
    let exerciseCount: Int
    let isCompleted: Bool
    let isRestDay: Bool
    let exercises: [String]
    let onStart: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onStart) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(theme)
                            .font(.title3.bold())
                            .foregroundColor(.white)

                        Text("\(exerciseCount) exercises")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    ZStack {
                        Circle()
                            .fill(isCompleted ? Color.green : Color.theme.primary)
                            .frame(width: 44, height: 44)

                        Image(systemName: isCompleted ? "checkmark" : "play.fill")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                if !exercises.isEmpty {
                    HStack(spacing: 8) {
                        ForEach(exercises.prefix(3), id: \.self) { exercise in
                            Text(exercise)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    Capsule()
                                        .fill(Color.white.opacity(0.1))
                                )
                        }

                        if exercises.count > 3 {
                            Text("+\(exercises.count - 3)")
                                .font(.caption.bold())
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
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
                                    (isCompleted ? Color.green : Color.theme.primary).opacity(0.2),
                                    (isCompleted ? Color.green : Color.theme.primary).opacity(0.05)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.3), Color.white.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            }
            .shadow(color: (isCompleted ? Color.green : Color.theme.primary).opacity(0.2), radius: 15, x: 0, y: 8)
        }
        .buttonStyle(.plain)
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isPressed)
    }
}

/// Simple list row for rest days
struct ModernWorkoutListRow: View {
    let day: String
    let theme: String
    let exerciseCount: Int
    let isCompleted: Bool
    let isRestDay: Bool

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: "moon.fill")
                    .font(.system(size: 18))
                    .foregroundColor(.white.opacity(0.5))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(day)
                    .font(.subheadline.bold())
                    .foregroundColor(.white.opacity(0.6))

                Text(theme)
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
            }

            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.5)
        )
    }
}

/// Stat card for workout statistics
struct ModernWorkoutStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let progress: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)

                Spacer()

                AnimatedProgressRing(progress: progress, color: color, lineWidth: 3)
                    .frame(width: 24, height: 24)
            }

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(16)
        .frame(width: 130)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .strokeBorder(color.opacity(0.3), lineWidth: 1)
        }
    }
}

// NOTE: Color.appTheme is defined in Color+Theme.swift as ColorTheme()

// MARK: - Workout Week Summary Reels

/// A horizontal paging view that shows a summary of each day's workout
struct WorkoutWeekSummaryReels: View {
    let sessions: [WorkoutSession]
    let completedWorkouts: Set<Int>
    let onDayTap: (WorkoutSession) -> Void

    @State private var currentPage: Int = 0

    private let daysMapping: [String: String] = [
        "LUNDI": "Monday",
        "MARDI": "Tuesday",
        "MERCREDI": "Wednesday",
        "JEUDI": "Thursday",
        "VENDREDI": "Friday",
        "SAMEDI": "Saturday",
        "DIMANCHE": "Sunday"
    ]

    var body: some View {
        VStack(spacing: 16) {
            // Section header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("workout.your_week".localizedString)
                        .font(.title3.bold())
                        .foregroundColor(.white)
                    Text("workout.swipe_to_see".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                Spacer()

                // Page indicator dots
                HStack(spacing: 6) {
                    ForEach(0..<sessions.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                            .animation(.easeInOut(duration: 0.2), value: currentPage)
                    }
                }
            }
            .padding(.horizontal, 4)

            // Horizontal paging reels
            TabView(selection: $currentPage) {
                ForEach(Array(sessions.enumerated()), id: \.element.id) { index, session in
                    WorkoutDaySummaryCard(
                        session: session,
                        dayName: daysMapping[session.day.uppercased()] ?? session.day,
                        isCompleted: completedWorkouts.contains(session.id),
                        onStart: { onDayTap(session) }
                    )
                    .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .frame(height: 280)
        }
    }
}

/// Individual day summary card for the reels view
struct WorkoutDaySummaryCard: View {
    let session: WorkoutSession
    let dayName: String
    let isCompleted: Bool
    let onStart: () -> Void

    private var isRestDay: Bool {
        session.isRestDay
    }

    private var themeIcon: String {
        session.sessionIcon
    }

    private var themeColor: Color {
        if isRestDay { return session.sessionZoneColor }
        if isCompleted { return Color.green }
        return session.sessionZoneColor
    }

    var body: some View {
        VStack(spacing: 0) {
            // Day header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(dayName.uppercased())
                        .font(.caption.bold())
                        .foregroundColor(themeColor)
                        .tracking(1.5)

                    Text(session.displayThemeName)
                        .font(.title2.bold())
                        .foregroundColor(.white)
                }

                Spacer()

                // Status badge
                ZStack {
                    Circle()
                        .fill(isCompleted ? Color.green : (isRestDay ? Color.gray.opacity(0.3) : themeColor.opacity(0.2)))
                        .frame(width: 50, height: 50)

                    Image(systemName: isCompleted ? "checkmark" : themeIcon)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(isCompleted ? .white : (isRestDay ? .white.opacity(0.5) : themeColor))
                }
            }
            .padding(20)

            Divider()
                .background(Color.white.opacity(0.1))

            if isRestDay {
                // Rest day content
                VStack(spacing: 12) {
                    Image(systemName: "bed.double.fill")
                        .font(.system(size: 40))
                        .foregroundColor(.white.opacity(0.3))

                    Text("workout.recovery_day".localizedString)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.8))

                    Text("workout.recovery_message".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(20)
            } else {
                // Workout content
                VStack(alignment: .leading, spacing: 16) {
                    // Exercise count & duration estimate
                    HStack(spacing: 20) {
                        HStack(spacing: 8) {
                            Image(systemName: "list.bullet")
                                .foregroundColor(themeColor)
                            Text(String(format: "workout.exercises_count".localizedString, session.exercises?.count ?? 0))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }

                        HStack(spacing: 8) {
                            Image(systemName: "clock")
                                .foregroundColor(themeColor)
                            Text("~\(estimatedDuration) min")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }

                    // Exercise preview list
                    if let exercises = session.exercises, !exercises.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(exercises.prefix(3)) { exercise in
                                HStack(spacing: 10) {
                                    Circle()
                                        .fill(themeColor.opacity(0.3))
                                        .frame(width: 6, height: 6)

                                    Text(exercise.name)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.9))

                                    Spacer()

                                    Text("\(exercise.sets)")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.5))
                                }
                            }

                            if exercises.count > 3 {
                                Text("+ \(exercises.count - 3) more exercises")
                                    .font(.caption)
                                    .foregroundColor(themeColor)
                                    .padding(.top, 4)
                            }
                        }
                    }

                    Spacer()

                    // Start button
                    Button(action: onStart) {
                        HStack {
                            Image(systemName: isCompleted ? "arrow.counterclockwise" : "play.fill")
                            Text(isCompleted ? "Do Again" : "Start Workout")
                                .fontWeight(.semibold)
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(
                            LinearGradient(
                                colors: [themeColor, themeColor.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                    }
                }
                .padding(20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [themeColor.opacity(0.5), themeColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: themeColor.opacity(0.2), radius: 20, x: 0, y: 10)
        .padding(.horizontal, 4)
    }

    private var estimatedDuration: Int {
        guard let exercises = session.exercises else { return 20 }
        // Estimate: warmup (5) + exercises (sets * 1.5 min each) + cooldown (5)
        let exerciseTime = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2) // ~2 min per set including rest
        }
        return 5 + exerciseTime + 5
    }
}

// MARK: - Today's Workout Highlight Card

/// A prominent card showing today's workout at a glance
struct TodayWorkoutCard: View {
    let session: WorkoutSession?
    let isCompleted: Bool
    let onStart: () -> Void

    private var isRestDay: Bool {
        session?.isRestDay ?? true
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 8, height: 8)
                        Text("workout.todays_focus".localizedString)
                            .font(.caption.bold())
                            .foregroundColor(.green)
                            .tracking(1.2)
                    }

                    if let session = session {
                        Text(isRestDay ? "workout.rest_and_recover".localizedString : session.displayThemeName)
                            .font(.title.bold())
                            .foregroundColor(.white)
                    } else {
                        Text("workout.no_workout_planned".localizedString)
                            .font(.title.bold())
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                if isCompleted {
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 32))
                            .foregroundColor(.green)
                        Text("common.done".localizedString)
                            .font(.caption.bold())
                            .foregroundColor(.green)
                    }
                }
            }
            .padding(20)

            if let session = session, !isRestDay {
                Divider()
                    .background(Color.white.opacity(0.1))

                // Quick stats
                HStack(spacing: 0) {
                    TodayStatItem(
                        icon: "figure.strengthtraining.functional",
                        value: "\(session.exercises?.count ?? 0)",
                        label: "workout.stat.exercises".localizedString
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1))

                    TodayStatItem(
                        icon: "clock.fill",
                        value: "~\(estimatedDuration(for: session))",
                        label: "Minutes"
                    )

                    Divider()
                        .frame(height: 40)
                        .background(Color.white.opacity(0.1))

                    TodayStatItem(
                        icon: "flame.fill",
                        value: estimatedCalories(for: session),
                        label: "Calories"
                    )
                }
                .padding(.vertical, 16)

                // Start button
                Button(action: onStart) {
                    HStack(spacing: 12) {
                        Image(systemName: isCompleted ? "arrow.counterclockwise" : "play.fill")
                            .font(.title3)
                        Text(isCompleted ? "Do Again" : "Start Today's Workout")
                            .font(.headline)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color.appTheme.primary, Color.appTheme.primary.opacity(0.7)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                }
                .cornerRadius(0)
                .cornerRadius(20, corners: [.bottomLeft, .bottomRight])
            } else if isRestDay {
                // Rest day message
                VStack(spacing: 12) {
                    HStack(spacing: 16) {
                        Image(systemName: "moon.stars.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.purple.opacity(0.7))

                        VStack(alignment: .leading, spacing: 4) {
                            Text("workout.recovery_part_of_progress".localizedString)
                                .font(.subheadline.bold())
                                .foregroundColor(.white)
                            Text("workout.rest_well_hydrate".localizedString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }
                .padding(20)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(hex: "1E1E2E"),
                            Color(hex: "2A2A3E")
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.white.opacity(0.2), Color.white.opacity(0.05)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: Color.appTheme.primary.opacity(0.2), radius: 20, x: 0, y: 10)
    }

    private func estimatedDuration(for session: WorkoutSession) -> String {
        guard let exercises = session.exercises else { return "20" }
        let exerciseTime = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return "\(5 + exerciseTime + 5)"
    }

    private func estimatedCalories(for session: WorkoutSession) -> String {
        guard let exercises = session.exercises else { return "150" }
        // Rough estimate: 8-12 calories per minute of exercise
        let minutes = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return "\(minutes * 10)"
    }
}

struct TodayStatItem: View {
    let icon: String
    let value: String
    let label: String

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(Color.appTheme.primary)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// Helper for rounded corners on specific sides
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

// MARK: - Section Header

/// Reusable section header for workout view
struct WorkoutSectionHeader: View {
    let title: String
    let subtitle: String?
    let icon: String?

    init(title: String, subtitle: String? = nil, icon: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    var body: some View {
        HStack(spacing: 12) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color.appTheme.primary)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.title3.bold())
                    .foregroundColor(.white)

                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }

            Spacer()
        }
    }
}

// MARK: - Daily Status Stories (Instagram-style)

/// Data model for a daily story
struct DailyStory: Identifiable {
    let id = UUID()
    let dayIndex: Int
    let dayName: String
    let dayAbbrev: String
    let isToday: Bool
    let workout: WorkoutSession?
    let workoutCompleted: Bool
    let nutritionProgress: Double // 0-1
    let caloriesConsumed: Int
    let caloriesTarget: Int
    let waterGlasses: Int
    let waterTarget: Int
    var isWeeklyOverview: Bool = false // Flag for weekly summary story
}

/// Instagram-style stories row showing daily status
struct DailyStatusStoriesRow: View {
    let stories: [DailyStory]
    let onStoryTap: (DailyStory) -> Void
    let onWeeklyOverviewTap: (() -> Void)?

    init(stories: [DailyStory], onStoryTap: @escaping (DailyStory) -> Void, onWeeklyOverviewTap: (() -> Void)? = nil) {
        self.stories = stories
        self.onStoryTap = onStoryTap
        self.onWeeklyOverviewTap = onWeeklyOverviewTap
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                // Weekly Overview bubble (first item)
                WeeklyOverviewBubble(stories: stories)
                    .onTapGesture {
                        if let onWeeklyTap = onWeeklyOverviewTap {
                            onWeeklyTap()
                        } else {
                            // Create a summary story
                            let summaryStory = DailyStory(
                                dayIndex: -1,
                                dayName: "Weekly Summary",
                                dayAbbrev: "WEEK",
                                isToday: false,
                                workout: nil,
                                workoutCompleted: false,
                                nutritionProgress: stories.map { $0.nutritionProgress }.reduce(0, +) / Double(max(stories.count, 1)),
                                caloriesConsumed: stories.map { $0.caloriesConsumed }.reduce(0, +),
                                caloriesTarget: stories.map { $0.caloriesTarget }.reduce(0, +),
                                waterGlasses: stories.map { $0.waterGlasses }.reduce(0, +),
                                waterTarget: stories.map { $0.waterTarget }.reduce(0, +),
                                isWeeklyOverview: true
                            )
                            onStoryTap(summaryStory)
                        }
                    }

                // Individual day stories
                ForEach(stories) { story in
                    DailyStoryBubble(story: story)
                        .onTapGesture {
                            onStoryTap(story)
                        }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

/// Weekly Overview bubble (appears first in stories row)
struct WeeklyOverviewBubble: View {
    let stories: [DailyStory]

    private var completedWorkouts: Int {
        stories.filter { $0.workoutCompleted }.count
    }

    private var totalWorkouts: Int {
        stories.filter { !($0.workout?.isRestDay ?? true) }.count
    }

    private var weekProgress: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Gradient ring for weekly overview
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [.cyan, .blue, .purple, .pink, .orange, .cyan],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 68, height: 68)

                // Inner circle with week icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "2A2A4E"),
                                Color(hex: "1E1E3E")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                // Week icon
                VStack(spacing: 2) {
                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)

                    Text("\(completedWorkouts)/\(totalWorkouts)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.cyan)
                }

                // Progress ring
                Circle()
                    .trim(from: 0, to: weekProgress)
                    .stroke(
                        Color.green,
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 54, height: 54)
                    .rotationEffect(.degrees(-90))
            }

            // Label
            Text("WEEK")
                .font(.caption2.bold())
                .foregroundColor(.cyan)
        }
    }
}

/// Individual story bubble (circular avatar with ring)
struct DailyStoryBubble: View {
    let story: DailyStory

    private var ringColor: Color {
        if story.isToday {
            return Color.appTheme.primary
        } else if story.workoutCompleted && story.nutritionProgress > 0.7 {
            return .green
        } else if story.workout?.isRestDay == true {
            return (story.workout?.sessionZoneColor ?? .purple).opacity(0.6)
        } else {
            return .gray.opacity(0.4)
        }
    }

    private var statusIcon: String {
        if story.workout?.isRestDay == true {
            return story.workout?.sessionIcon ?? "moon.zzz.fill"
        } else if story.workoutCompleted {
            return "checkmark"
        } else {
            return story.workout?.sessionIcon ?? "figure.run"
        }
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                // Outer ring (gradient for active, solid for completed)
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: story.isToday ?
                                [Color.appTheme.primary, .purple, .pink, Color.appTheme.primary] :
                                [ringColor, ringColor],
                            center: .center
                        ),
                        lineWidth: story.isToday ? 3 : 2
                    )
                    .frame(width: 68, height: 68)

                // Inner circle with icon
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [
                                Color(hex: "1E1E2E"),
                                Color(hex: "2A2A3E")
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 60, height: 60)

                // Status icon
                Image(systemName: statusIcon)
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(story.workoutCompleted ? .green : (story.isToday ? .white : .white.opacity(0.6)))

                // Progress ring overlay for nutrition
                if story.nutritionProgress > 0 {
                    Circle()
                        .trim(from: 0, to: story.nutritionProgress)
                        .stroke(
                            Color.orange.opacity(0.8),
                            style: StrokeStyle(lineWidth: 2, lineCap: .round)
                        )
                        .frame(width: 54, height: 54)
                        .rotationEffect(.degrees(-90))
                }

                // "Today" badge
                if story.isToday {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Circle()
                                .stroke(Color(hex: "1E1E2E"), lineWidth: 2)
                        )
                        .offset(x: 24, y: -24)
                }
            }

            // Day label
            Text(story.dayAbbrev)
                .font(.caption2.bold())
                .foregroundColor(story.isToday ? .white : .white.opacity(0.6))
        }
    }
}

/// Full-screen story detail view (like Instagram story)
struct StoryDetailView: View {
    let story: DailyStory
    let onClose: () -> Void
    let onStartWorkout: () -> Void

    @State private var progress: CGFloat = 0
    @State private var currentPage: Int = 0
    @State private var isPaused: Bool = false
    @State private var progressTimer: Timer?

    private var totalPages: Int {
        story.isWeeklyOverview ? 2 : 3 // Weekly has 2 pages, daily has 3
    }

    var body: some View {
        ZStack {
            // Background gradient
            backgroundGradient
                .ignoresSafeArea()

            // Main content layout
            VStack(spacing: 0) {
                // Top section: Progress bars and header
                VStack(spacing: 12) {
                    // Progress bars
                    HStack(spacing: 4) {
                        ForEach(0..<totalPages, id: \.self) { index in
                            Capsule()
                                .fill(Color.white.opacity(0.3))
                                .frame(height: 3)
                                .overlay(alignment: .leading) {
                                    GeometryReader { geo in
                                        Capsule()
                                            .fill(Color.white)
                                            .frame(width: index < currentPage ? geo.size.width : (index == currentPage ? geo.size.width * progress : 0))
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 16)

                    // Header
                    HStack {
                        // Day info
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .strokeBorder(
                                        AngularGradient(
                                            colors: story.isWeeklyOverview ?
                                                [.cyan, .blue, .purple, .pink, .cyan] :
                                                [accentColor, accentColor.opacity(0.7)],
                                            center: .center
                                        ),
                                        lineWidth: 2
                                    )
                                    .frame(width: 44, height: 44)

                                Circle()
                                    .fill(Color(hex: "2A2A4E"))
                                    .frame(width: 38, height: 38)

                                if story.isWeeklyOverview {
                                    Image(systemName: "calendar.badge.checkmark")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(.cyan)
                                } else {
                                    Text(story.dayAbbrev)
                                        .font(.caption.bold())
                                        .foregroundColor(.white)
                                }
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text(story.dayName)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text(story.isWeeklyOverview ? "common.this_week".localizedString : (story.isToday ? "common.today".localizedString : formattedDate))
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }

                        Spacer()

                        // Pause button
                        Button {
                            isPaused.toggle()
                            if isPaused {
                                progressTimer?.invalidate()
                            } else {
                                startProgressAnimation()
                            }
                        } label: {
                            Image(systemName: isPaused ? "play.fill" : "pause.fill")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.7))
                                .frame(width: 28, height: 28)
                                .background(Circle().fill(Color.white.opacity(0.1)))
                        }

                        // Close button
                        Button(action: onClose) {
                            Image(systemName: "xmark")
                                .font(.title3.bold())
                                .foregroundColor(.white)
                                .frame(width: 36, height: 36)
                                .background(Circle().fill(Color.white.opacity(0.2)))
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.top, 60)

                // Content area - TabView with pages
                TabView(selection: $currentPage) {
                    if story.isWeeklyOverview {
                        WeeklyOverviewSummaryPage(story: story)
                            .tag(0)
                        WeeklyOverviewStatsPage(story: story)
                            .tag(1)
                    } else {
                        StoryDailySummaryPage(story: story, onStartWorkout: onStartWorkout)
                            .tag(0)
                        StoryWorkoutPage(story: story, onStart: onStartWorkout)
                            .tag(1)
                        StoryNutritionPage(story: story)
                            .tag(2)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))

                // Page indicators
                HStack(spacing: 8) {
                    ForEach(0..<totalPages, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.white : Color.white.opacity(0.3))
                            .frame(width: 6, height: 6)
                    }
                }
                .padding(.bottom, 30)
            }

            // Tap zones overlay
            VStack {
                Spacer()
                    .frame(height: 140)

                HStack(spacing: 0) {
                    // Left tap - previous page
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if currentPage > 0 {
                                    currentPage -= 1
                                }
                            }
                        }

                    // Right tap - next page
                    Rectangle()
                        .fill(Color.clear)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.25)) {
                                if currentPage < totalPages - 1 {
                                    currentPage += 1
                                } else {
                                    onClose()
                                }
                            }
                        }
                }

                Spacer()
                    .frame(height: 60)
            }
        }
        .preferredColorScheme(.dark)
        .statusBar(hidden: true)
        .gesture(
            DragGesture(minimumDistance: 50)
                .onEnded { value in
                    if value.translation.height > 100 {
                        onClose()
                    }
                }
        )
        .onAppear {
            startProgressAnimation()
        }
        .onChange(of: currentPage) { _, _ in
            progress = 0
            startProgressAnimation()
        }
        .onDisappear {
            progressTimer?.invalidate()
        }
    }

    private var backgroundGradient: some View {
        ZStack {
            // Base gradient - brighter and more visible
            LinearGradient(
                colors: backgroundColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Overlay gradient for depth
            RadialGradient(
                colors: [accentColor.opacity(0.15), Color.clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 400
            )

            // Bottom fade
            LinearGradient(
                colors: [Color.clear, Color.black.opacity(0.3)],
                startPoint: .center,
                endPoint: .bottom
            )
        }
    }

    private var accentColor: Color {
        if story.isWeeklyOverview {
            return .cyan
        }
        switch currentPage {
        case 0: return Color.appTheme.primary
        case 1: return story.workoutCompleted ? .green : .purple
        case 2: return .orange
        default: return Color.appTheme.primary
        }
    }

    private var backgroundColors: [Color] {
        if story.isWeeklyOverview {
            return [Color(hex: "0F1A2E"), Color(hex: "1A2A4E"), Color(hex: "0A1528")]
        }

        switch currentPage {
        case 0: // Summary - Deep blue/purple
            return [Color(hex: "1A1A3E"), Color(hex: "2A2A5E"), Color(hex: "151535")]
        case 1: // Workout
            if story.workoutCompleted {
                return [Color(hex: "1A2E1A"), Color(hex: "2A4A2A"), Color(hex: "152515")]
            } else {
                return [Color(hex: "2E1A3E"), Color(hex: "4A2A5E"), Color(hex: "251535")]
            }
        case 2: // Nutrition - Warm orange/amber
            return [Color(hex: "2E2A1A"), Color(hex: "4A3A2A"), Color(hex: "352A15")]
        default:
            return [Color(hex: "1A1A3E"), Color(hex: "2A2A4E"), Color(hex: "151530")]
        }
    }

    private var formattedDate: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let dayOffset = story.dayIndex - currentDayIndex
        if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM d"
            return formatter.string(from: date)
        }
        return "common.this_week".localizedString
    }

    private var currentDayIndex: Int {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        return (weekday + 5) % 7
    }

    private func startProgressAnimation() {
        guard !isPaused else { return }
        progressTimer?.invalidate()
        progress = 0

        withAnimation(.linear(duration: 6)) {
            progress = 1
        }

        // Auto-advance after 6 seconds
        progressTimer = Timer.scheduledTimer(withTimeInterval: 6, repeats: false) { _ in
            guard !isPaused else { return }
            if currentPage < totalPages - 1 {
                withAnimation(.easeInOut(duration: 0.3)) {
                    currentPage += 1
                }
            }
        }
    }
}

// MARK: - Weekly Overview Summary Page
struct WeeklyOverviewSummaryPage: View {
    let story: DailyStory

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 20)

                // Week progress ring
                VStack(spacing: 16) {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 14)
                            .frame(width: 160, height: 160)

                        Circle()
                            .trim(from: 0, to: story.nutritionProgress)
                            .stroke(
                                AngularGradient(
                                    colors: [.cyan, .blue, .purple, .pink, .orange, .cyan],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 14, lineCap: .round)
                            )
                            .frame(width: 160, height: 160)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 4) {
                            Text("\(Int(story.nutritionProgress * 100))%")
                                .font(.system(size: 42, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("workout.week_complete".localizedString)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    Text("workout.weekly_summary".localizedString)
                        .font(.title.bold())
                        .foregroundColor(.white)

                    Text("workout.heres_how_week".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }

                // Quick stats
                HStack(spacing: 16) {
                    WeekStatCard(
                        icon: "flame.fill",
                        value: "\(story.caloriesConsumed)",
                        label: "Total Calories",
                        color: .orange
                    )

                    WeekStatCard(
                        icon: "drop.fill",
                        value: "\(story.waterGlasses)",
                        label: "Glasses of Water",
                        color: .blue
                    )
                }
                .padding(.horizontal, 20)

                // Motivational message
                VStack(spacing: 12) {
                    Image(systemName: weekMotivationalIcon)
                        .font(.system(size: 36))
                        .foregroundColor(.cyan)

                    Text(weekMotivationalMessage)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                }
                .padding(24)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 60)
            }
        }
    }

    private var weekMotivationalIcon: String {
        if story.nutritionProgress >= 0.8 {
            return "star.fill"
        } else if story.nutritionProgress >= 0.5 {
            return "hand.thumbsup.fill"
        } else {
            return "bolt.fill"
        }
    }

    private var weekMotivationalMessage: String {
        if story.nutritionProgress >= 0.8 {
            return "Outstanding week! You're crushing your goals!"
        } else if story.nutritionProgress >= 0.5 {
            return "Good progress this week! Keep pushing forward."
        } else {
            return "Every step counts. Finish the week strong!"
        }
    }
}

// MARK: - Weekly Overview Stats Page
struct WeeklyOverviewStatsPage: View {
    let story: DailyStory

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                Text("workout.weekly_breakdown".localizedString)
                    .font(.title2.bold())
                    .foregroundColor(.white)

                // Nutrition breakdown
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Image(systemName: "chart.pie.fill")
                            .foregroundColor(.orange)
                        Text("tab.nutrition".localizedString)
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    VStack(spacing: 12) {
                        WeeklyStatRow(
                            label: "Calories Consumed",
                            value: "\(story.caloriesConsumed) / \(story.caloriesTarget)",
                            progress: Double(story.caloriesConsumed) / Double(max(story.caloriesTarget, 1)),
                            color: .orange
                        )

                        WeeklyStatRow(
                            label: "Hydration",
                            value: "\(story.waterGlasses) / \(story.waterTarget) glasses",
                            progress: Double(story.waterGlasses) / Double(max(story.waterTarget, 1)),
                            color: .blue
                        )

                        WeeklyStatRow(
                            label: "Nutrition Goal",
                            value: "\(Int(story.nutritionProgress * 100))%",
                            progress: story.nutritionProgress,
                            color: .green
                        )
                    }
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)

                // Tips section
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                        Text("workout.weekly_tips".localizedString)
                            .font(.headline)
                            .foregroundColor(.white)
                    }

                    Text(weeklyTip)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 60)
            }
        }
    }

    private var weeklyTip: String {
        if story.waterGlasses < story.waterTarget / 2 {
            return "Focus on hydration this week. Try keeping a water bottle with you at all times."
        } else if story.nutritionProgress < 0.5 {
            return "Track your meals consistently to reach your nutrition goals. Small improvements add up!"
        } else {
            return "Great consistency! Keep maintaining these healthy habits and you'll see amazing results."
        }
    }
}

// MARK: - Supporting Views for Weekly Overview
struct WeekStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.system(size: 20, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.08))
        )
    }
}

struct WeeklyStatRow: View {
    let label: String
    let value: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                Spacer()
                Text(value)
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * min(progress, 1.0), height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

// MARK: - Daily Summary Page (Instagram-style accomplishments)
struct StoryDailySummaryPage: View {
    let story: DailyStory
    let onStartWorkout: () -> Void

    private var isRestDay: Bool {
        story.workout?.isRestDay ?? true
    }

    private var overallProgress: Double {
        var total: Double = 0
        var count: Double = 0

        // Workout progress (50% weight)
        if !isRestDay {
            total += story.workoutCompleted ? 1.0 : 0.0
            count += 1
        }

        // Nutrition progress (50% weight)
        total += story.nutritionProgress
        count += 1

        return count > 0 ? total / count : 0
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer(minLength: 16)

                // Day Title - Clear and prominent
                VStack(spacing: 6) {
                    Text(story.isToday ? "story.today".localizedString : story.dayName.uppercased())
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .tracking(2)
                        .foregroundColor(Color.appTheme.primary)

                    Text(story.isToday ? "story.daily_overview".localizedString : formattedDateDisplay)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }

                // Quick Stats Row - Easy to read at a glance
                HStack(spacing: 12) {
                    QuickStatBubble(
                        icon: isRestDay ? (story.workout?.sessionIcon ?? "moon.zzz.fill") : (story.workoutCompleted ? "checkmark.circle.fill" : "dumbbell.fill"),
                        value: isRestDay ? "story.rest".localizedString : (story.workoutCompleted ? "story.done".localizedString : "story.todo".localizedString),
                        label: "story.workout".localizedString,
                        color: isRestDay ? (story.workout?.sessionZoneColor ?? .purple) : (story.workoutCompleted ? .green : .orange),
                        isCompleted: isRestDay || story.workoutCompleted
                    )

                    QuickStatBubble(
                        icon: "flame.fill",
                        value: "\(story.caloriesConsumed)",
                        label: "story.calories".localizedString,
                        color: .orange,
                        isCompleted: story.nutritionProgress >= 0.8
                    )

                    QuickStatBubble(
                        icon: "drop.fill",
                        value: "\(story.waterGlasses)/\(story.waterTarget)",
                        label: "story.water".localizedString,
                        color: .blue,
                        isCompleted: story.waterGlasses >= story.waterTarget
                    )
                }
                .padding(.horizontal, 16)

                // Overall Day Score - Prominent visual
                VStack(spacing: 12) {
                    ZStack {
                        // Background glow
                        Circle()
                            .fill(Color.appTheme.primary.opacity(0.2))
                            .frame(width: 140, height: 140)
                            .blur(radius: 25)

                        // Background ring
                        Circle()
                            .stroke(Color.white.opacity(0.1), lineWidth: 12)
                            .frame(width: 120, height: 120)

                        // Progress ring
                        Circle()
                            .trim(from: 0, to: overallProgress)
                            .stroke(
                                AngularGradient(
                                    colors: [.green, .cyan, .blue, .purple, .pink, .green],
                                    center: .center
                                ),
                                style: StrokeStyle(lineWidth: 12, lineCap: .round)
                            )
                            .frame(width: 120, height: 120)
                            .rotationEffect(.degrees(-90))

                        VStack(spacing: 2) {
                            Text("\(Int(overallProgress * 100))%")
                                .font(.system(size: 36, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            Text("workout.complete".localizedString)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }

                    // Status message
                    Text(progressMessage)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .padding(.vertical, 8)

                // Detailed Progress Section
                VStack(alignment: .leading, spacing: 14) {
                    Text("common.todays_progress".localizedString)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 4)

                    VStack(spacing: 10) {
                        // Workout status
                        DetailedProgressRow(
                            icon: isRestDay ? (story.workout?.sessionIcon ?? "moon.zzz.fill") : "dumbbell.fill",
                            title: isRestDay ? "story.rest_day".localizedString : (story.workout?.displayThemeName ?? "story.workout".localizedString),
                            detail: isRestDay ? "story.recovery_relaxation".localizedString : String(format: "story.exercises_planned".localizedString, story.workout?.exercises?.count ?? 0),
                            progress: isRestDay ? 1.0 : (story.workoutCompleted ? 1.0 : 0.0),
                            color: isRestDay ? (story.workout?.sessionZoneColor ?? .purple) : (story.workoutCompleted ? .green : .orange)
                        )

                        // Calories status
                        DetailedProgressRow(
                            icon: "flame.fill",
                            title: "story.nutrition".localizedString,
                            detail: String(format: "story.calories_of".localizedString, story.caloriesConsumed, story.caloriesTarget),
                            progress: story.nutritionProgress,
                            color: .orange
                        )

                        // Water status
                        DetailedProgressRow(
                            icon: "drop.fill",
                            title: "story.hydration".localizedString,
                            detail: String(format: "story.glasses_of".localizedString, story.waterGlasses, story.waterTarget),
                            progress: Double(story.waterGlasses) / Double(max(story.waterTarget, 1)),
                            color: .blue
                        )
                    }
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.08))
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .strokeBorder(Color.white.opacity(0.1), lineWidth: 1)
                        )
                )
                .padding(.horizontal, 16)

                // Action Button (if today and workout not completed)
                if story.isToday && !isRestDay && !story.workoutCompleted {
                    Button(action: onStartWorkout) {
                        HStack(spacing: 12) {
                            Image(systemName: "play.fill")
                                .font(.system(size: 16, weight: .bold))
                            Text("\("workout.start".localizedString) \(story.workout?.displayThemeName ?? "workout.label".localizedString)")
                                .font(.system(size: 16, weight: .bold))
                            Spacer()
                            Text(String(format: "story.min_duration".localizedString, estimatedDuration))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [Color.appTheme.primary, Color.appTheme.primary.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: Color.appTheme.primary.opacity(0.4), radius: 10, x: 0, y: 5)
                    }
                    .padding(.horizontal, 16)
                }

                // Swipe hint
                HStack(spacing: 6) {
                    Text("workout.swipe_details".localizedString)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Image(systemName: "chevron.right")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 8)

                Spacer(minLength: 50)
            }
        }
    }

    private var formattedDateDisplay: String {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let currentDayIndex = (calendar.component(.weekday, from: Date()) + 5) % 7
        let dayOffset = story.dayIndex - currentDayIndex
        if let date = calendar.date(byAdding: .day, value: dayOffset, to: today) {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE, MMM d"
            return formatter.string(from: date)
        }
        return story.dayName
    }

    private var estimatedDuration: Int {
        guard let exercises = story.workout?.exercises else { return 30 }
        let time = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return 10 + time
    }

    private var progressMessage: String {
        if overallProgress >= 0.9 {
            return "Amazing! You're crushing it!"
        } else if overallProgress >= 0.7 {
            return "Great progress today!"
        } else if overallProgress >= 0.5 {
            return "Halfway there, keep going!"
        } else if story.isToday {
            return "Let's make today count!"
        } else {
            return "Tap to see workout details"
        }
    }
}

// MARK: - Quick Stat Bubble (for story summary)
struct QuickStatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let isCompleted: Bool

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 50, height: 50)

                Image(systemName: icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(color)

                if isCompleted {
                    Circle()
                        .fill(.green)
                        .frame(width: 14, height: 14)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 8, weight: .bold))
                                .foregroundColor(.white)
                        )
                        .offset(x: 18, y: -18)
                }
            }

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.white.opacity(0.06))
        )
    }
}

// MARK: - Detailed Progress Row
struct DetailedProgressRow: View {
    let icon: String
    let title: String
    let detail: String
    let progress: Double
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            // Icon
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 40, height: 40)

                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(color)
            }

            // Text content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    Spacer()

                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(progress >= 0.8 ? .green : color)
                }

                Text(detail)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))

                // Progress bar
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 3)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 3)
                            .fill(
                                LinearGradient(
                                    colors: [color, color.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * min(progress, 1.0), height: 6)
                    }
                }
                .frame(height: 6)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Accomplishment Row
struct AccomplishmentRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundColor(isCompleted ? .green : .white.opacity(0.3))
        }
    }
}

// MARK: - To-Do Row
struct ToDoRow: View {
    let icon: String
    let title: String
    let subtitle: String
    let priority: Priority

    enum Priority {
        case high, medium, low

        var color: Color {
            switch self {
            case .high: return .red
            case .medium: return .orange
            case .low: return .yellow
            }
        }
    }

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(priority.color.opacity(0.2))
                    .frame(width: 44, height: 44)

                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(priority.color)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white)

                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }

            Spacer()

            // Priority indicator
            Circle()
                .fill(priority.color)
                .frame(width: 8, height: 8)
        }
    }
}

/// Workout page within story
struct StoryWorkoutPage: View {
    let story: DailyStory
    let onStart: () -> Void

    private var isRestDay: Bool {
        story.workout?.isRestDay ?? true
    }

    private var themeColor: Color {
        story.workout?.sessionZoneColor ?? Color.appTheme.primary
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer(minLength: 40)

                if isRestDay {
                    // Rest day content with enhanced visuals
                    VStack(spacing: 24) {
                        ZStack {
                            // Glow effect
                            Circle()
                                .fill(Color.purple.opacity(0.2))
                                .frame(width: 150, height: 150)
                                .blur(radius: 30)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color.purple.opacity(0.3), Color.purple.opacity(0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 130, height: 130)

                            Image(systemName: "moon.stars.fill")
                                .font(.system(size: 55))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.purple, .pink],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 12) {
                            Text("workout.rest_day".localizedString)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            Text("workout.rest_day_message".localizedString)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 40)
                        }

                        // Rest day tips
                        VStack(alignment: .leading, spacing: 12) {
                            RestTipRow(icon: "drop.fill", text: "common.stay_hydrated".localizedString, color: .blue)
                            RestTipRow(icon: "figure.flexibility", text: "common.light_stretching".localizedString, color: .green)
                            RestTipRow(icon: "bed.double.fill", text: "workout.rest_well_hydrate".localizedString, color: .purple)
                        }
                        .padding(20)
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                        )
                        .padding(.horizontal, 30)
                    }
                } else if let workout = story.workout {
                    // Workout content with enhanced visuals
                    VStack(spacing: 24) {
                        // Status icon with glow
                        ZStack {
                            Circle()
                                .fill((story.workoutCompleted ? Color.green : themeColor).opacity(0.2))
                                .frame(width: 150, height: 150)
                                .blur(radius: 30)

                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            (story.workoutCompleted ? Color.green : themeColor).opacity(0.3),
                                            (story.workoutCompleted ? Color.green : themeColor).opacity(0.1)
                                        ],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 130, height: 130)

                            Image(systemName: story.workoutCompleted ? "checkmark.circle.fill" : workoutIcon)
                                .font(.system(size: 55))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: story.workoutCompleted ? [.green, .mint] : [themeColor, themeColor.opacity(0.7)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }

                        VStack(spacing: 8) {
                            Text(workout.displayThemeName)
                                .font(.largeTitle.bold())
                                .foregroundColor(.white)

                            HStack(spacing: 16) {
                                Label("\(workout.exercises?.count ?? 0)", systemImage: "list.bullet")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))

                                Label("~\(estimatedDuration) min", systemImage: "clock")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }

                            if story.workoutCompleted {
                                HStack(spacing: 6) {
                                    Image(systemName: "checkmark.seal.fill")
                                    Text("workout.completed".localizedString)
                                }
                                .font(.headline)
                                .foregroundColor(.green)
                                .padding(.top, 4)
                            }
                        }

                        // Exercise preview
                        if let exercises = workout.exercises, !exercises.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("workout.exercises".localizedString)
                                    .font(.headline)
                                    .foregroundColor(.white)

                                ForEach(exercises.prefix(4)) { exercise in
                                    HStack(spacing: 12) {
                                        Circle()
                                            .fill(themeColor)
                                            .frame(width: 8, height: 8)

                                        Text(exercise.name)
                                            .font(.body)
                                            .foregroundColor(.white)

                                        Spacer()

                                        Text(exercise.sets)
                                            .font(.caption)
                                            .foregroundColor(.white.opacity(0.6))
                                            .padding(.horizontal, 10)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(Color.white.opacity(0.1))
                                            )
                                    }
                                }

                                if exercises.count > 4 {
                                    Text("+ \(exercises.count - 4) more exercises")
                                        .font(.caption)
                                        .foregroundColor(themeColor)
                                        .padding(.top, 4)
                                }
                            }
                            .padding(20)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.white.opacity(0.08))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .strokeBorder(themeColor.opacity(0.2), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, 20)
                        }

                        // Start button (only if not completed and is today)
                        if !story.workoutCompleted && story.isToday {
                            Button(action: onStart) {
                                HStack(spacing: 12) {
                                    Image(systemName: "play.fill")
                                    Text("workout.start_workout".localizedString)
                                        .fontWeight(.bold)
                                }
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 18)
                                .background(
                                    LinearGradient(
                                        colors: [themeColor, themeColor.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                                .shadow(color: themeColor.opacity(0.4), radius: 12, x: 0, y: 6)
                            }
                            .padding(.horizontal, 30)
                        }
                    }
                }

                Spacer(minLength: 60)
            }
        }
    }

    private var workoutIcon: String {
        story.workout?.sessionIcon ?? "dumbbell.fill"
    }

    private var estimatedDuration: Int {
        guard let exercises = story.workout?.exercises else { return 30 }
        let time = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return 10 + time
    }
}

// Rest day tip row
struct RestTipRow: View {
    let icon: String
    let text: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.2), in: Circle())

            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.9))
        }
    }
}

/// Nutrition page within story
struct StoryNutritionPage: View {
    let story: DailyStory

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                Spacer(minLength: 30)

                // Calories ring with enhanced visuals
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(Color.orange.opacity(0.15))
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)

                    Circle()
                        .stroke(Color.white.opacity(0.15), lineWidth: 14)
                        .frame(width: 170, height: 170)

                    Circle()
                        .trim(from: 0, to: min(story.nutritionProgress, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .pink, .red],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 170, height: 170)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 6) {
                        Text("\(story.caloriesConsumed)")
                            .font(.system(size: 42, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("/ \(story.caloriesTarget) kcal")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }

                Text("workout.daily_nutrition".localizedString)
                    .font(.title.bold())
                    .foregroundColor(.white)

                // Stats grid with enhanced styling
                HStack(spacing: 16) {
                    NutritionStatBubble(
                        icon: "drop.fill",
                        value: "\(story.waterGlasses)/\(story.waterTarget)",
                        label: "Water",
                        color: .blue
                    )

                    NutritionStatBubble(
                        icon: "flame.fill",
                        value: "\(Int(story.nutritionProgress * 100))%",
                        label: "Goal",
                        color: .orange
                    )

                    NutritionStatBubble(
                        icon: story.nutritionProgress >= 0.8 ? "checkmark.circle.fill" : "chart.line.uptrend.xyaxis",
                        value: story.nutritionProgress >= 0.8 ? "Great" : "Track",
                        label: "Status",
                        color: story.nutritionProgress >= 0.8 ? .green : .yellow
                    )
                }
                .padding(.horizontal, 20)

                // Progress breakdown
                VStack(alignment: .leading, spacing: 16) {
                    Text("workout.progress_breakdown".localizedString)
                        .font(.headline)
                        .foregroundColor(.white)

                    NutritionProgressRow(
                        label: "Calories",
                        current: story.caloriesConsumed,
                        target: story.caloriesTarget,
                        color: .orange,
                        icon: "flame.fill"
                    )

                    NutritionProgressRow(
                        label: "Hydration",
                        current: story.waterGlasses,
                        target: story.waterTarget,
                        color: .blue,
                        icon: "drop.fill"
                    )
                }
                .padding(20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.08))
                )
                .padding(.horizontal, 20)

                // Tip with enhanced styling
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(Color.yellow.opacity(0.2))
                            .frame(width: 40, height: 40)
                        Image(systemName: "lightbulb.fill")
                            .foregroundColor(.yellow)
                    }

                    Text(nutritionTip)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.leading)
                }
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.06))
                )
                .padding(.horizontal, 20)

                Spacer(minLength: 60)
            }
        }
    }

    private var nutritionTip: String {
        if story.waterGlasses < story.waterTarget / 2 {
            return "Don't forget to stay hydrated! Aim for \(story.waterTarget) glasses today."
        } else if story.nutritionProgress < 0.5 {
            return "You're halfway through the day. Make sure to fuel your body properly."
        } else if story.nutritionProgress >= 0.9 {
            return "Great job! You've almost hit your nutrition goals for today."
        } else {
            return "Keep it up! Balanced nutrition supports your training."
        }
    }
}

// Nutrition progress row
struct NutritionProgressRow: View {
    let label: String
    let current: Int
    let target: Int
    let color: Color
    let icon: String

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(Double(current) / Double(target), 1.0)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.caption)
                    .foregroundColor(color)
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                Spacer()
                Text("\(current) / \(target)")
                    .font(.subheadline.bold())
                    .foregroundColor(.white)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [color, color.opacity(0.7)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: geo.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct NutritionStatBubble: View {
    let icon: String
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)

                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }

            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)

            Text(label)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Simplified Today Card

/// Compact today's workout card for simplified view
struct CompactTodayCard: View {
    let workout: WorkoutSession?
    let isCompleted: Bool
    let nutritionProgress: Double
    let onTap: () -> Void

    private var isRestDay: Bool {
        workout?.isRestDay ?? true
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // Left: Workout status
                ZStack {
                    Circle()
                        .fill(statusColor.opacity(0.2))
                        .frame(width: 56, height: 56)

                    Image(systemName: statusIcon)
                        .font(.title2)
                        .foregroundColor(statusColor)
                }

                // Middle: Info
                VStack(alignment: .leading, spacing: 4) {
                    Text(isRestDay ? "story.rest_day".localizedString : (workout?.displayThemeName ?? "story.no_workout".localizedString))
                        .font(.headline)
                        .foregroundColor(.white)

                    if !isRestDay, let exercises = workout?.exercises {
                        Text("\(String(format: "story.exercises_planned".localizedString, exercises.count)) • \(String(format: "story.min_duration".localizedString, estimatedDuration))")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    } else if isRestDay {
                        Text("workout.recovery_stretching".localizedString)
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }

                Spacer()

                // Right: Action indicator
                if !isRestDay && !isCompleted {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(Color.appTheme.primary)
                } else if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 36))
                        .foregroundColor(.green)
                }
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 20, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [statusColor.opacity(0.5), statusColor.opacity(0.1)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }

    private var statusColor: Color {
        if isCompleted { return .green }
        if isRestDay { return workout?.sessionZoneColor ?? .purple }
        return Color.appTheme.primary
    }

    private var statusIcon: String {
        if isCompleted { return "checkmark" }
        if isRestDay { return workout?.sessionIcon ?? "moon.zzz.fill" }
        return workout?.sessionIcon ?? "dumbbell.fill"
    }

    private var estimatedDuration: Int {
        guard let exercises = workout?.exercises else { return 30 }
        let time = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return 10 + time
    }
}

// MARK: - Quick Action Buttons

struct WorkoutQuickAction: View {
    let icon: String
    let label: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.15))
                        .frame(width: 52, height: 52)

                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundColor(color)
                }

                Text(label)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Weekly Progress Strip (Replaces DailyStatusStoriesRow + QuickStatPill)
struct WeeklyProgressStrip: View {
    let stories: [DailyStory]
    let completedCount: Int
    let totalWorkouts: Int
    let onDayTap: (DailyStory) -> Void

    @State private var pulseToday = false

    var body: some View {
        VStack(spacing: 14) {
            // 7-day circles
            HStack(spacing: 0) {
                ForEach(stories) { story in
                    Button(action: { onDayTap(story) }) {
                        VStack(spacing: 6) {
                            ZStack {
                                // Ring
                                Circle()
                                    .stroke(ringColor(for: story).opacity(0.25), lineWidth: 3)
                                    .frame(width: story.isToday ? 40 : 32, height: story.isToday ? 40 : 32)

                                Circle()
                                    .trim(from: 0, to: story.workoutCompleted ? 1.0 : (story.isToday ? 0.15 : 0))
                                    .stroke(ringColor(for: story), style: StrokeStyle(lineWidth: 3, lineCap: .round))
                                    .frame(width: story.isToday ? 40 : 32, height: story.isToday ? 40 : 32)
                                    .rotationEffect(.degrees(-90))

                                // Inner icon
                                if story.workoutCompleted {
                                    Image(systemName: "checkmark")
                                        .font(.system(size: story.isToday ? 14 : 11, weight: .bold))
                                        .foregroundColor(.green)
                                } else if isRestDay(story) {
                                    Image(systemName: story.workout?.sessionIcon ?? "moon.fill")
                                        .font(.system(size: story.isToday ? 14 : 10))
                                        .foregroundColor((story.workout?.sessionZoneColor ?? .purple).opacity(0.7))
                                } else if story.isToday {
                                    Image(systemName: "flame.fill")
                                        .font(.system(size: 14, weight: .semibold))
                                        .foregroundColor(Color.appTheme.primary)
                                } else {
                                    Circle()
                                        .fill(Color.white.opacity(0.15))
                                        .frame(width: 6, height: 6)
                                }
                            }
                            .scaleEffect(story.isToday && pulseToday ? 1.08 : 1.0)

                            Text(story.dayAbbrev)
                                .font(.system(size: 10, weight: story.isToday ? .bold : .medium))
                                .foregroundColor(story.isToday ? .white : .white.opacity(0.5))
                        }
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                }
            }

            // Progress bar
            VStack(spacing: 8) {
                GeometryReader { geo in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.08))
                            .frame(height: 6)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [Color.appTheme.primary, Color.appTheme.primary.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geo.size.width * progressFraction, height: 6)
                            .animation(.spring(response: 0.6, dampingFraction: 0.8), value: completedCount)
                    }
                }
                .frame(height: 6)

                HStack {
                    Text(String(format: NSLocalizedString("workout.x_of_y_completed", comment: ""), completedCount, totalWorkouts))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                    Spacer()
                    Text("\(Int(progressFraction * 100))%")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(Color.appTheme.primary)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.appTheme.primary.opacity(0.3), Color.appTheme.primary.opacity(0.08)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                pulseToday = true
            }
        }
    }

    private var progressFraction: CGFloat {
        guard totalWorkouts > 0 else { return 0 }
        return CGFloat(completedCount) / CGFloat(totalWorkouts)
    }

    private func ringColor(for story: DailyStory) -> Color {
        if story.workoutCompleted { return .green }
        if isRestDay(story) { return story.workout?.sessionZoneColor ?? .purple }
        if story.isToday { return Color.appTheme.primary }
        return Color.white.opacity(0.2)
    }

    private func isRestDay(_ story: DailyStory) -> Bool {
        story.workout?.isRestDay ?? true
    }
}

// MARK: - Today Hero Card (Replaces CompactTodayCard)
struct TodayHeroCard: View {
    let workout: WorkoutSession?
    let isCompleted: Bool
    let completionPercentage: Double
    let onTap: () -> Void

    @State private var ringAnimation: CGFloat = 0

    private var isRestDay: Bool {
        workout?.isRestDay ?? true
    }

    private var exerciseCount: Int {
        workout?.exercises?.count ?? 0
    }

    private var estimatedMinutes: Int {
        guard let exercises = workout?.exercises else { return 0 }
        let time = exercises.reduce(0) { total, ex in
            let sets = Int(ex.sets.components(separatedBy: " ").first ?? "3") ?? 3
            return total + (sets * 2)
        }
        return 10 + time // 10 min warmup/cooldown + exercise time
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 20) {
                // Progress ring
                ZStack {
                    Circle()
                        .fill(accentColor.opacity(0.08))
                        .frame(width: 100, height: 100)
                        .blur(radius: 15)

                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 10)
                        .frame(width: 86, height: 86)

                    Circle()
                        .trim(from: 0, to: ringAnimation)
                        .stroke(
                            LinearGradient(
                                colors: isCompleted ? [.green, .green.opacity(0.7)] : [accentColor, accentColor.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 10, lineCap: .round)
                        )
                        .frame(width: 86, height: 86)
                        .rotationEffect(.degrees(-90))

                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.system(size: 28, weight: .bold))
                            .foregroundColor(.green)
                    } else if isRestDay {
                        Image(systemName: workout?.sessionIcon ?? "moon.zzz.fill")
                            .font(.system(size: 26))
                            .foregroundColor(workout?.sessionZoneColor ?? .purple)
                    } else {
                        VStack(spacing: 2) {
                            Image(systemName: workout?.sessionIcon ?? "dumbbell.fill")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(accentColor)
                            Text("\(exerciseCount)")
                                .font(.system(size: 13, weight: .bold, design: .rounded))
                                .foregroundColor(.white.opacity(0.6))
                        }
                    }
                }

                // Info
                VStack(alignment: .leading, spacing: 8) {
                    if isRestDay {
                        Text("workout.rest_day".localizedString)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                        Text("workout.rest_day_recovery".localizedString)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    } else {
                        Text(workout?.displayThemeName ?? "workout.no_plan".localizedString)
                            .font(.system(size: 22, weight: .bold))
                            .foregroundColor(.white)
                            .lineLimit(2)

                        HStack(spacing: 10) {
                            // Zone badge
                            if let zoneColor = workout?.metadata?.zoneColor, !zoneColor.isEmpty {
                                HStack(spacing: 4) {
                                    Circle()
                                        .fill(workout?.sessionZoneColor ?? .clear)
                                        .frame(width: 8, height: 8)
                                    Text(workout?.metadata?.zoneName ?? "")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(workout?.sessionZoneColor ?? .white.opacity(0.5))
                            }

                            // RPE badge
                            if let rpe = workout?.metadata?.rpe {
                                HStack(spacing: 3) {
                                    Image(systemName: "gauge.medium")
                                        .font(.system(size: 10))
                                    Text("RPE \(rpe)")
                                        .font(.system(size: 11, weight: .semibold))
                                }
                                .foregroundColor(.white.opacity(0.6))
                            }
                        }

                        HStack(spacing: 12) {
                            HStack(spacing: 4) {
                                Image(systemName: "figure.run")
                                    .font(.system(size: 11))
                                Text("\(exerciseCount) \("workout.exercises".localizedString)")
                                    .font(.system(size: 12, weight: .medium))
                            }
                            .foregroundColor(.white.opacity(0.5))

                            if estimatedMinutes > 0 {
                                HStack(spacing: 4) {
                                    Image(systemName: "clock")
                                        .font(.system(size: 11))
                                    Text("~\(estimatedMinutes) min")
                                        .font(.system(size: 12, weight: .medium))
                                }
                                .foregroundColor(.white.opacity(0.5))
                            }
                        }

                        // CTA
                        if isCompleted {
                            HStack(spacing: 6) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 14))
                                Text("workout.completed".localizedString)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.green)
                            .padding(.top, 4)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "play.fill")
                                    .font(.system(size: 12))
                                Text("workout.start_now".localizedString)
                                    .font(.system(size: 14, weight: .bold))
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 10)
                            .background(
                                Capsule().fill(
                                    LinearGradient(
                                        colors: [accentColor, accentColor.opacity(0.7)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .padding(.top, 4)
                        }
                    }
                }

                Spacer()
            }
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .fill(Color.white.opacity(0.04))
                    .overlay(
                        RoundedRectangle(cornerRadius: 24, style: .continuous)
                            .strokeBorder(
                                LinearGradient(
                                    colors: [accentColor.opacity(0.4), accentColor.opacity(0.1), .clear],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    )
            )
        }
        .buttonStyle(.plain)
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                ringAnimation = isCompleted ? 1.0 : (isRestDay ? 1.0 : 0.15)
            }
        }
    }

    private var accentColor: Color {
        if isCompleted { return .green }
        if isRestDay { return workout?.sessionZoneColor ?? .purple }
        return workout?.sessionZoneColor ?? Color.appTheme.primary
    }
}

// MARK: - Gradient Floating Action Button (with label)
struct GradientFloatingActionButton: View {
    let icon: String
    let label: String
    let gradientColors: [Color]
    let action: () -> Void

    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .medium)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .bold))
                Text(label)
                    .font(.system(size: 14, weight: .bold))
            }
            .foregroundColor(.white)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                Capsule().fill(
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .shadow(color: gradientColors.first?.opacity(0.5) ?? .clear, radius: 16, x: 0, y: 8)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Workout Phase Progress Bar
struct WorkoutPhaseProgressBar: View {
    let currentPhase: Int // 0=intro, 1=warmup, 2=exercises, 3=cooldown, 4=done
    let exerciseProgress: Double // 0-1 within exercises phase
    let totalPhases: Int

    private var phaseNames: [String] {
        [
            "workout.phase.intro".localizedString,
            "workout.phase.warmup".localizedString,
            "workout.phase.exercise".localizedString,
            "workout.phase.cooldown".localizedString,
            "workout.phase.done".localizedString
        ]
    }

    var body: some View {
        HStack(spacing: 3) {
            ForEach(0..<totalPhases, id: \.self) { index in
                Capsule()
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 3)
                    .overlay(alignment: .leading) {
                        GeometryReader { geo in
                            Capsule()
                                .fill(phaseColor(for: index))
                                .frame(width: segmentWidth(for: index, totalWidth: geo.size.width))
                        }
                    }
            }
        }
        .padding(.horizontal, 16)
    }

    private func segmentWidth(for index: Int, totalWidth: CGFloat) -> CGFloat {
        if index < currentPhase { return totalWidth }
        if index == currentPhase {
            if currentPhase == 2 { // exercises phase
                return totalWidth * exerciseProgress
            }
            return totalWidth * 0.5 // partial for current non-exercise phase
        }
        return 0
    }

    private func phaseColor(for index: Int) -> Color {
        if index < currentPhase { return .white }
        if index == currentPhase { return .white.opacity(0.9) }
        return .clear
    }
}
