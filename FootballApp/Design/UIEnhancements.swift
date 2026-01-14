//
//  UIEnhancements.swift
//  FootballApp
//
//  Enhanced UI components and utilities
//

import SwiftUI

// MARK: - Shimmer Effect for Loading States
struct ShimmerEffect: ViewModifier {
    @State private var phase: CGFloat = 0
    
    func body(content: Content) -> some View {
        content
            .overlay(
                LinearGradient(
                    colors: [
                        .clear,
                        .white.opacity(0.3),
                        .clear
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
                .offset(x: phase)
                .mask(content)
            )
            .onAppear {
                withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                    phase = 300
                }
            }
    }
}

extension View {
    func shimmer() -> some View {
        modifier(ShimmerEffect())
    }
}

// MARK: - Skeleton Loading View
struct SkeletonLoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ForEach(0..<3) { _ in
                HStack(spacing: 12) {
                    Circle()
                        .fill(Color.theme.textSecondary.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.theme.textSecondary.opacity(0.2))
                            .frame(height: 20)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.theme.textSecondary.opacity(0.2))
                            .frame(width: 150, height: 16)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(Color.theme.surface)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .shimmer()
            }
        }
        .padding()
    }
}

// MARK: - Pull to Refresh Indicator
struct PullToRefreshIndicator: View {
    let isRefreshing: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            if isRefreshing {
                ProgressView()
                    .tint(Color.theme.primary)
            } else {
                Image(systemName: "arrow.down")
                    .foregroundColor(Color.theme.primary)
            }
            
            Text(isRefreshing ? "Refreshing..." : "Pull to refresh")
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding()
    }
}

// MARK: - Success Checkmark Animation
// Note: FloatingActionButton is now defined in UIUXImprovements.swift to avoid duplication
struct SuccessCheckmark: View {
    @State private var trimEnd: CGFloat = 0
    @State private var scale: CGFloat = 0.8
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.green.opacity(0.1))
                .frame(width: 100, height: 100)
            
            Circle()
                .strokeBorder(Color.green, lineWidth: 3)
                .frame(width: 80, height: 80)
            
            Path { path in
                path.move(to: CGPoint(x: 30, y: 50))
                path.addLine(to: CGPoint(x: 45, y: 65))
                path.addLine(to: CGPoint(x: 70, y: 35))
            }
            .trim(from: 0, to: trimEnd)
            .stroke(Color.green, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
            .frame(width: 100, height: 100)
        }
        .scaleEffect(scale)
        .onAppear {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                scale = 1.0
            }
            
            withAnimation(.easeInOut(duration: 0.5).delay(0.2)) {
                trimEnd = 1.0
            }
        }
    }
}

// MARK: - Badge Component
struct BadgeView: View {
    let text: String
    let color: Color
    
    init(text: String, color: Color = Color.theme.primary) {
        self.text = text
        self.color = color
    }
    
    var body: some View {
        Text(text)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color)
            .clipShape(Capsule())
    }
}

// MARK: - Info Card Component
struct InfoCard: View {
    let title: String
    let description: String
    let icon: String
    let iconColor: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            ZStack {
                Circle()
                    .fill(iconColor.opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3.weight(.semibold))
                    .foregroundColor(iconColor)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(3)
            }
            
            Spacer()
        }
        .padding()
        .background(Color.theme.surface)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .lightShadow()
    }
}

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let description: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String = "tray",
        title: String,
        description: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.description = description
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                Circle()
                    .fill(Color.theme.primary.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: icon)
                    .font(.system(size: 50))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.theme.primary, Color.theme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            }
            
            VStack(spacing: 8) {
                Text(title)
                    .font(.title2.bold())
                    .foregroundColor(Color.theme.textPrimary)
                
                Text(description)
                    .font(.body)
                    .foregroundColor(Color.theme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    HStack(spacing: 8) {
                        Text(actionTitle)
                        Image(systemName: "arrow.right")
                    }
                    .font(.body.weight(.semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.theme.primary)
                    .clipShape(Capsule())
                }
                .padding(.top, 8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background)
    }
}

// MARK: - Stat Card Component
struct StatCard: View {
    let value: String
    let label: String
    let icon: String
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down, neutral
        
        var color: Color {
            switch self {
            case .up: return .green
            case .down: return .red
            case .neutral: return Color.theme.textSecondary
            }
        }
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .neutral: return "minus"
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(Color.theme.primary)
                
                Spacer()
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.caption)
                        .foregroundColor(trend.color)
                }
            }
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundColor(Color.theme.textPrimary)
            
            Text(label)
                .font(.subheadline)
                .foregroundColor(Color.theme.textSecondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            LinearGradient(
                colors: [Color.theme.surface, Color.theme.surface.opacity(0.95)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .cardShadow()
    }
}

// MARK: - Toast Notification
struct ToastView: View {
    let message: String
    let type: ToastType
    
    enum ToastType {
        case success, error, info, warning
        
        var color: Color {
            switch self {
            case .success: return .green
            case .error: return .red
            case .info: return Color.theme.primary
            case .warning: return .orange
            }
        }
        
        var icon: String {
            switch self {
            case .success: return "checkmark.circle.fill"
            case .error: return "xmark.circle.fill"
            case .info: return "info.circle.fill"
            case .warning: return "exclamationmark.triangle.fill"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: type.icon)
                .foregroundColor(type.color)
                .font(.title3)
            
            Text(message)
                .font(.subheadline.weight(.medium))
                .foregroundColor(Color.theme.textPrimary)
            
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .strongShadow()
        .padding(.horizontal)
    }
}

// MARK: - Previews
#Preview("Skeleton Loading") {
    SkeletonLoadingView()
        .background(Color.theme.background)
}

// Preview for FloatingActionButton moved to UIUXImprovements.swift

#Preview("Success Checkmark") {
    SuccessCheckmark()
}

#Preview("Info Card") {
    InfoCard(
        title: "Pro Tip",
        description: "Stay hydrated during your workout for optimal performance",
        icon: "lightbulb.fill",
        iconColor: .orange
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Empty State") {
    EmptyStateView(
        icon: "figure.run",
        title: "No Workouts Yet",
        description: "Start your fitness journey by creating your first workout plan",
        actionTitle: "Create Workout",
        action: { print("Create workout") }
    )
}

#Preview("Stat Cards") {
    HStack(spacing: 12) {
        StatCard(
            value: "142",
            label: "Workouts",
            icon: "flame.fill",
            trend: .up
        )
        
        StatCard(
            value: "68kg",
            label: "Weight",
            icon: "scalemass.fill",
            trend: .down
        )
    }
    .padding()
    .background(Color.theme.background)
}

#Preview("Toasts") {
    VStack(spacing: 16) {
        ToastView(message: "Workout completed!", type: .success)
        ToastView(message: "Connection error", type: .error)
        ToastView(message: "New feature available", type: .info)
        ToastView(message: "Low battery", type: .warning)
    }
    .padding()
    .background(Color.theme.background)
}
