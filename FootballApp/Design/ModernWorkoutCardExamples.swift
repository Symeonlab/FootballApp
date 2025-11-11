//
//  ModernWorkoutCardExamples.swift
//  FootballApp
//
//  Demonstration of UI/UX improvements from Color+Theme.swift
//  Based on screenshot designs with purple theme
//

import SwiftUI

// MARK: - Complete Workout Card Example
struct ModernWorkoutCard: View {
    let workout: WorkoutSession
    let isCompleted: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                // Header with day and completion status
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        // Day label (compact, uppercase)
                        Text(workout.day.uppercased())
                            .dayLabel()
                        
                        // Workout theme (hero style)
                        Text(workout.theme)
                            .font(.title3.bold())
                            .foregroundColor(Color.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    // Completion indicator with glass effect
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 48, height: 48)
                        
                        Circle()
                            .fill(
                                isCompleted ?
                                Color.theme.successGradient :
                                Color.theme.primaryGradient
                            )
                            .frame(width: 48, height: 48)
                            .opacity(0.3)
                        
                        Image(systemName: isCompleted ? "checkmark" : "play.fill")
                            .font(.body.weight(.bold))
                            .foregroundColor(isCompleted ? Color.theme.success : Color.theme.primary)
                    }
                    .shadow(
                        color: (isCompleted ? Color.theme.success : Color.theme.primary).opacity(0.3),
                        radius: 6,
                        x: 0,
                        y: 3
                    )
                }
                
                // Exercise count and metadata (compact)
                if let exercises = workout.exercises {
                    HStack(spacing: 12) {
                        Label("\(exercises.count) exercises", systemImage: "list.bullet")
                            .captionText()
                        
                        Label("~45 min", systemImage: "clock")
                            .captionText()
                    }
                }
                
                // CTA Button (full-width, gradient)
                HStack {
                    Spacer()
                    Text(isCompleted ? "Review Workout" : "Start Workout")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(.white)
                    Spacer()
                }
                .padding(.vertical, 12)
                .background {
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .fill(
                            isCompleted ?
                            Color.theme.successGradient :
                            Color.theme.primaryGradient
                        )
                        .opacity(0.9)
                }
                .shadow(
                    color: (isCompleted ? Color.theme.success : Color.theme.primary).opacity(0.3),
                    radius: 8,
                    x: 0,
                    y: 4
                )
            }
            .padding(16)
            .workoutCard(isCompleted: isCompleted, cornerRadius: 18)
        }
        .buttonStyle(.plain)
        .pressableScale(pressed: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
        .accessibleCard(
            label: "\(workout.day) - \(workout.theme)",
            hint: isCompleted ? "Completed workout" : "Tap to start workout"
        )
    }
}

// MARK: - Weekly Calendar Grid (Space-Efficient)
struct ModernWeeklyCalendar: View {
    let sessions: [WorkoutSession]
    let completedWorkouts: Set<Int>
    let onWorkoutTap: (WorkoutSession) -> Void
    
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            Text("This Week")
                .sectionHeader()
                .padding(.horizontal)
            
            // Grid of workout days
            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(sessions) { session in
                    ModernDayCard(
                        session: session,
                        isCompleted: completedWorkouts.contains(session.id),
                        onTap: { onWorkoutTap(session) }
                    )
                }
            }
            .padding(.horizontal)
        }
    }
}

// MARK: - Individual Day Card (Compact Design)
struct ModernDayCard: View {
    let session: WorkoutSession
    let isCompleted: Bool
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var isRestDay: Bool {
        session.theme.lowercased().contains("repos") || session.theme.lowercased().contains("rest")
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                // Day name (compact)
                Text(session.day.prefix(3).uppercased())
                    .dayLabel()
                
                // Icon with glass background
                ZStack {
                    Circle()
                        .fill(.thinMaterial)
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    iconColor.opacity(0.3),
                                    iconColor.opacity(0.1)
                                ],
                                center: .center,
                                startRadius: 0,
                                endRadius: 22
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: iconName)
                        .font(.body)
                        .foregroundColor(iconColor)
                }
                .shadow(color: iconColor.opacity(0.25), radius: 4, x: 0, y: 2)
                
                // Workout type (minimal text)
                Text(session.theme)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(Color.theme.textSecondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 4)
            .gridCardItem(cornerRadius: 16)
        }
        .buttonStyle(.plain)
        .pressableScale(pressed: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
    
    var iconName: String {
        if isRestDay {
            return "bed.double.fill"
        } else if isCompleted {
            return "checkmark.circle.fill"
        } else {
            return "figure.run"
        }
    }
    
    var iconColor: Color {
        if isRestDay {
            return Color.theme.textSecondary
        } else if isCompleted {
            return Color.theme.success
        } else {
            return Color.theme.primary
        }
    }
}

// MARK: - Exercise List Item (Information-Dense)
struct ModernExerciseListItem: View {
    let exercise: WorkoutExercise
    let index: Int
    let isCompleted: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Index badge (compact)
                ZStack {
                    Circle()
                        .fill(
                            isCompleted ?
                            Color.theme.success.opacity(0.15) :
                            Color.theme.primary.opacity(0.15)
                        )
                        .frame(width: 32, height: 32)
                    
                    if isCompleted {
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Color.theme.success)
                    } else {
                        Text("\(index)")
                            .font(.caption.weight(.bold))
                            .foregroundColor(Color.theme.primary)
                    }
                }
                
                // Exercise info (compact)
                VStack(alignment: .leading, spacing: 3) {
                    Text(exercise.name)
                        .font(.subheadline.weight(.semibold))
                        .foregroundColor(Color.theme.textPrimary)
                        .lineLimit(1)
                    
                    HStack(spacing: 8) {
                        Label(exercise.sets, systemImage: "repeat")
                        Label(exercise.reps, systemImage: "number")
                    }
                    .font(.caption2)
                    .foregroundColor(Color.theme.textSecondary)
                }
                
                Spacer()
                
                // Video indicator
                if exercise.video_url != nil {
                    Image(systemName: "play.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color.theme.accent)
                }
            }
            .exerciseListItem(isCompleted: isCompleted)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Progress Dashboard (Compact & Visual)
struct ModernProgressDashboard: View {
    let totalWorkouts: Int
    let completedWorkouts: Int
    let totalExercises: Int
    let completedExercises: Int
    
    var completionPercentage: Double {
        guard totalWorkouts > 0 else { return 0 }
        return Double(completedWorkouts) / Double(totalWorkouts)
    }
    
    var body: some View {
        HStack(spacing: 20) {
            // Circular progress ring (compact)
            ZStack {
                Circle()
                    .stroke(Color.theme.primary.opacity(0.2), lineWidth: 10)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: completionPercentage)
                    .stroke(
                        Color.theme.primaryGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: completionPercentage)
                
                VStack(spacing: 2) {
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(Color.theme.textPrimary)
                    
                    Text("Done")
                        .font(.caption2)
                        .foregroundColor(Color.theme.textSecondary)
                }
            }
            
            // Stats (compact rows)
            VStack(alignment: .leading, spacing: 12) {
                ModernStatRow(
                    icon: "figure.strengthtraining.traditional",
                    label: "Workouts",
                    value: "\(completedWorkouts)/\(totalWorkouts)",
                    color: Color.theme.primary
                )
                
                ModernStatRow(
                    icon: "flame.fill",
                    label: "Exercises",
                    value: "\(completedExercises)/\(totalExercises)",
                    color: Color.theme.orange
                )
            }
            
            Spacer()
        }
        .padding(16)
        .glassCard(padding: 16, cornerRadius: 20)
    }
}

struct ModernStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body)
                .foregroundColor(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundColor(Color.theme.textSecondary)
                
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
            }
        }
    }
}

// MARK: - Modern Tab Bar (From Screenshots)
struct ModernCustomTabBar: View {
    @Binding var selectedTab: Int
    @Namespace private var animation
    
    let tabs: [(icon: String, title: String)] = [
        ("figure.walk", "Workouts"),
        ("chart.bar.fill", "Progress"),
        ("leaf.fill", "Nutrition"),
        ("person.fill", "Profile")
    ]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs.indices, id: \.self) { index in
                Button {
                    withAnimation(.interactiveSpring()) {
                        selectedTab = index
                    }
                    // Haptic feedback
                    let generator = UIImpactFeedbackGenerator(style: .medium)
                    generator.impactOccurred()
                } label: {
                    VStack(spacing: 6) {
                        ZStack {
                            if selectedTab == index {
                                // Glass background for selected tab
                                Capsule()
                                    .fill(.thinMaterial)
                                    .frame(width: 64, height: 40)
                                    .overlay {
                                        Capsule()
                                            .fill(Color.theme.primaryGradient.opacity(0.3))
                                    }
                                    .shadow(color: Color.theme.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                                    .matchedGeometryEffect(id: "tab_selection", in: animation)
                            }
                            
                            Image(systemName: tabs[index].icon)
                                .tabBarIcon(isSelected: selectedTab == index)
                        }
                        .frame(height: 40)
                        
                        Text(tabs[index].title)
                            .font(.system(size: 11, weight: selectedTab == index ? .semibold : .regular))
                            .foregroundColor(selectedTab == index ? Color.theme.primary : Color.theme.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.plain)
            }
        }
        .customTabBar()
    }
}

// MARK: - Quick Action Buttons (Compact & Efficient)
struct ModernQuickActionButton: View {
    let icon: String
    let title: String
    let gradient: LinearGradient
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.callout)
                    .foregroundStyle(gradient)
                
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(Color.theme.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 10)
            .padding(.horizontal, 12)
            .background {
                ZStack {
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(.ultraThinMaterial)
                    
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(gradient.opacity(0.1))
                    
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
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
            .lightShadow()
        }
        .buttonStyle(.plain)
        .pressableScale(pressed: isPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in isPressed = false }
        )
    }
}

// MARK: - Preview Examples
#Preview("Modern Workout Card") {
    ModernWorkoutCard(
        workout: WorkoutSession(
            id: 1,
            day: "Tuesday",
            theme: "Cardio",
            warmup: "5 min",
            finisher: "5 min",
            exercises: [
                WorkoutExercise(id: 1, name: "Running", sets: "3", reps: "10", recovery: "60s", video_url: nil, is_completed: nil)
            ],
            is_completed: nil,
            completion_date: nil
        ),
        isCompleted: false,
        onTap: {}
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Weekly Calendar") {
    ModernWeeklyCalendar(
        sessions: [
            WorkoutSession(id: 1, day: "Mon", theme: "Strength", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 2, day: "Tue", theme: "Cardio", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 3, day: "Wed", theme: "Yoga", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 4, day: "Thu", theme: "HIIT", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 5, day: "Fri", theme: "Rest", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 6, day: "Sat", theme: "Boxing", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
            WorkoutSession(id: 7, day: "Sun", theme: "Stretch", warmup: nil, finisher: nil, exercises: [], is_completed: nil, completion_date: nil),
        ],
        completedWorkouts: [1, 3],
        onWorkoutTap: { _ in }
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Progress Dashboard") {
    ModernProgressDashboard(
        totalWorkouts: 7,
        completedWorkouts: 4,
        totalExercises: 28,
        completedExercises: 16
    )
    .padding()
    .background(Color.theme.background)
}

#Preview("Tab Bar") {
    VStack {
        Spacer()
        ModernCustomTabBar(selectedTab: .constant(0))
    }
    .background(Color.theme.background)
}
