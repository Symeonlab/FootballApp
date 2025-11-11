//  WorkoutUIComponents.swift
//  FootballApp
//
//  Consolidated modern workout UI components
//  Single source of truth for all workout-related UI elements
//

import SwiftUI

// MARK: - Modern Stat Card
/// A card that displays a workout statistic with progress indicator
struct ModernWorkoutStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
                
                Spacer()
                
                // Mini progress ring
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 3)
                        .frame(width: 24, height: 24)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title2.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(width: 130)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                }
        }
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Story Item
/// A circular story-style button with gradient border
struct WorkoutStoryItem: View {
    let icon: String
    let title: String
    let gradientColors: [Color]
    let hasNotification: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    // Gradient border ring
                    Circle()
                        .stroke(
                            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing),
                            lineWidth: 3
                        )
                        .frame(width: 68, height: 68)
                    
                    // Inner circle
                    Circle()
                        .fill(Color.appTheme.surface)
                        .frame(width: 60, height: 60)
                        .overlay {
                            Image(systemName: icon)
                                .font(.title2)
                                .foregroundStyle(
                                    LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)
                                )
                        }
                    
                    // Notification dot
                    if hasNotification {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 12, height: 12)
                            .overlay {
                                Circle()
                                    .stroke(Color.appTheme.background, lineWidth: 2)
                            }
                            .offset(x: 24, y: -24)
                    }
                }
                
                Text(title)
                    .font(.caption.weight(.medium))
                    .foregroundColor(Color.appTheme.textPrimary)
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Modern Workout Session Card
/// A comprehensive card showing workout session details
struct ModernWorkoutSessionCard: View {
    let theme: String
    let exerciseCount: Int
    let isCompleted: Bool
    let isRestDay: Bool
    let exercises: [String]
    let onStart: () -> Void
    
    var body: some View {
        Button(action: onStart) {
            VStack(spacing: 0) {
                // Header with gradient
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(theme)
                            .font(.title3.bold())
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Label("\(exerciseCount) exercises", systemImage: "dumbbell.fill")
                            Label("~45 min", systemImage: "clock.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    }
                    
                    Spacer()
                    
                    // Action indicator
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 50, height: 50)
                        
                        Image(systemName: isRestDay ? "moon.stars.fill" : (isCompleted ? "checkmark" : "play.fill"))
                            .font(.title3)
                            .foregroundColor(.white)
                    }
                }
                .padding(20)
                .background {
                    LinearGradient(
                        colors: isRestDay
                            ? [Color.blue.opacity(0.8), Color.indigo.opacity(0.8)]
                            : (isCompleted
                                ? [Color.green.opacity(0.8), Color.mint.opacity(0.8)]
                                : [Color.appTheme.primary, Color.appTheme.accent]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
                
                // Exercise preview
                if !isRestDay && !exercises.isEmpty {
                    VStack(spacing: 0) {
                        ForEach(Array(exercises.prefix(3).enumerated()), id: \.offset) { index, exercise in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(Color.appTheme.primary.opacity(0.2))
                                    .frame(width: 36, height: 36)
                                    .overlay {
                                        Text("\(index + 1)")
                                            .font(.caption.bold())
                                            .foregroundColor(Color.appTheme.primary)
                                    }
                                
                                Text(exercise)
                                    .font(.subheadline)
                                    .foregroundColor(Color.appTheme.textPrimary)
                                    .lineLimit(1)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            
                            if index < min(exercises.count, 3) - 1 {
                                Divider()
                                    .background(Color.appTheme.textTertiary.opacity(0.3))
                                    .padding(.leading, 64)
                            }
                        }
                    }
                    .background(Color.appTheme.surface)
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: 24, style: .continuous)
                    .stroke(
                        isCompleted ? Color.green.opacity(0.5) : Color.white.opacity(0.1),
                        lineWidth: isCompleted ? 2 : 1
                    )
            }
            .shadow(color: Color.appTheme.primary.opacity(0.2), radius: 20, x: 0, y: 10)
        }
        .buttonStyle(.plain)
        .disabled(isRestDay)
    }
}

// MARK: - Modern Weekly Calendar
/// A horizontal calendar showing workout days with completion status
struct ModernWorkoutWeeklyCalendar: View {
    let days: [(String, Bool, Bool, Bool)] // (day abbreviation, isToday, isCompleted, isRestDay)
    let onDayTap: (Int) -> Void
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                Button {
                    if !day.3 { // Not a rest day
                        onDayTap(index)
                    }
                } label: {
                    VStack(spacing: 8) {
                        Text(day.0)
                            .font(.caption2.weight(.semibold))
                            .foregroundColor(Color.appTheme.textSecondary)
                        
                        ZStack {
                            Circle()
                                .fill(
                                    day.1 // isToday
                                        ? LinearGradient(colors: [Color.appTheme.primary, Color.appTheme.accent], startPoint: .topLeading, endPoint: .bottomTrailing)
                                        : (day.2 // isCompleted
                                            ? LinearGradient(colors: [.green, .mint], startPoint: .topLeading, endPoint: .bottomTrailing)
                                            : LinearGradient(colors: [Color.appTheme.surface], startPoint: .topLeading, endPoint: .bottomTrailing))
                                )
                                .frame(width: 40, height: 40)
                            
                            if day.3 { // isRestDay
                                Image(systemName: "moon.fill")
                                    .font(.caption)
                                    .foregroundColor(day.1 ? .white : Color.appTheme.textSecondary)
                            } else if day.2 { // isCompleted
                                Image(systemName: "checkmark")
                                    .font(.caption.bold())
                                    .foregroundColor(.white)
                            } else {
                                Image(systemName: "dumbbell.fill")
                                    .font(.caption)
                                    .foregroundColor(day.1 ? .white : Color.appTheme.textSecondary)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
                .disabled(day.3)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                }
        }
    }
}

// MARK: - Completed Badge
/// A small badge indicating workout completion
struct WorkoutCompletedBadge: View {
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .font(.caption)
            Text("Done")
                .font(.caption.weight(.semibold))
        }
        .foregroundColor(.green)
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background {
            Capsule()
                .fill(Color.green.opacity(0.15))
        }
    }
}

// MARK: - Modern Loading View
/// An animated loading indicator for workouts
struct ModernWorkoutLoadingView: View {
    @State private var rotation: Double = 0
    @State private var scale: CGFloat = 1.0
    
    var body: some View {
        VStack(spacing: 24) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(
                        AngularGradient(
                            colors: [Color.appTheme.primary, Color.appTheme.accent, Color.clear],
                            center: .center
                        ),
                        lineWidth: 4
                    )
                    .frame(width: 80, height: 80)
                    .rotationEffect(.degrees(rotation))
                
                // Inner icon
                Image(systemName: "figure.strengthtraining.traditional")
                    .font(.system(size: 30))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTheme.primary, Color.appTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
            }
            
            VStack(spacing: 8) {
                Text("Loading Workouts")
                    .font(.headline.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Text("Preparing your training plan...")
                    .font(.subheadline)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
        }
        .onAppear {
            withAnimation(.linear(duration: 1.5).repeatForever(autoreverses: false)) {
                rotation = 360
            }
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                scale = 1.1
            }
        }
    }
}

// MARK: - Modern Empty State View
/// Empty state view with generate workout button
struct ModernWorkoutEmptyStateView: View {
    let onGenerate: () -> Void
    @State private var isGenerating = false
    @State private var iconOffset: CGFloat = 0
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Animated illustration
            ZStack {
                Circle()
                    .fill(Color.appTheme.primary.opacity(0.1))
                    .frame(width: 180, height: 180)
                    .blur(radius: 40)
                
                Image(systemName: "figure.run.circle.fill")
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [Color.appTheme.primary, Color.appTheme.accent],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .offset(y: iconOffset)
            }
            
            VStack(spacing: 16) {
                Text("No Workout Plan Yet")
                    .font(.title.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Text("Generate your personalized workout plan to start your fitness journey.")
                    .font(.body)
                    .foregroundColor(Color.appTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Button {
                isGenerating = true
                onGenerate()
            } label: {
                HStack(spacing: 12) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "sparkles")
                    }
                    Text(isGenerating ? "Generating..." : "Generate Workout Plan")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background {
                    LinearGradient(
                        colors: [Color.appTheme.primary, Color.appTheme.accent],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
            .disabled(isGenerating)
            .padding(.horizontal, 40)
            
            Spacer()
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                iconOffset = -10
            }
        }
    }
}

// MARK: - Workout List Row
/// A list row showing workout day information
struct ModernWorkoutListRow: View {
    let day: String
    let theme: String
    let exerciseCount: Int
    let isCompleted: Bool
    let isRestDay: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Day indicator
            VStack(spacing: 4) {
                Text(String(day.prefix(3)).uppercased())
                    .font(.caption2.weight(.bold))
                    .foregroundColor(Color.appTheme.textSecondary)
                
                ZStack {
                    Circle()
                        .fill(
                            isCompleted
                                ? Color.green.opacity(0.15)
                                : Color.appTheme.primary.opacity(0.15)
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: isRestDay ? "moon.stars.fill" : (isCompleted ? "checkmark" : "dumbbell.fill"))
                        .foregroundColor(isRestDay ? .blue : (isCompleted ? .green : Color.appTheme.primary))
                }
            }
            .frame(width: 60)
            
            // Content
            VStack(alignment: .leading, spacing: 6) {
                Text(theme)
                    .font(.headline)
                    .foregroundColor(Color.appTheme.textPrimary)
                
                if !isRestDay {
                    Text("\(exerciseCount) exercises")
                        .font(.caption)
                        .foregroundColor(Color.appTheme.textSecondary)
                }
            }
            
            Spacer()
            
            if !isRestDay {
                Image(systemName: "chevron.right")
                    .font(.caption.weight(.semibold))
                    .foregroundColor(Color.appTheme.textTertiary)
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(isCompleted ? Color.green.opacity(0.05) : Color.appTheme.surface)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            isCompleted ? Color.green.opacity(0.3) : Color.white.opacity(0.1),
                            lineWidth: 1
                        )
                }
        }
    }
}

// MARK: - Preview
#Preview("Workout UI Components") {
    ScrollView {
        VStack(spacing: 24) {
            // Stat Cards
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ModernWorkoutStatCard(
                        icon: "flame.fill",
                        value: "5",
                        label: "Completed",
                        color: .orange,
                        progress: 0.7
                    )
                    
                    ModernWorkoutStatCard(
                        icon: "figure.strengthtraining.traditional",
                        value: "42",
                        label: "Exercises",
                        color: Color.appTheme.primary,
                        progress: 0.5
                    )
                }
                .padding(.horizontal)
            }
            
            // Session Card
            ModernWorkoutSessionCard(
                theme: "Upper Body Power",
                exerciseCount: 6,
                isCompleted: false,
                isRestDay: false,
                exercises: ["Bench Press", "Pull-ups", "Shoulder Press"],
                onStart: {}
            )
            .padding(.horizontal)
            
            // Weekly Calendar
            ModernWorkoutWeeklyCalendar(
                days: [
                    ("M", false, true, false),
                    ("T", false, true, false),
                    ("W", true, false, false),
                    ("T", false, false, false),
                    ("F", false, false, false),
                    ("S", false, false, true),
                    ("S", false, false, false)
                ],
                onDayTap: { _ in }
            )
            .padding(.horizontal)
            
            // List Row
            ModernWorkoutListRow(
                day: "Monday",
                theme: "Leg Day",
                exerciseCount: 8,
                isCompleted: false,
                isRestDay: false
            )
            .padding(.horizontal)
            
            // Completed Badge
            WorkoutCompletedBadge()
            
            // Loading View
            ModernWorkoutLoadingView()
                .frame(height: 200)
        }
        .padding(.vertical)
    }
    .background(Color.appTheme.background)
}
