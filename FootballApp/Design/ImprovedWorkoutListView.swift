//
//  ImprovedWorkoutListView.swift
//  FootballApp
//
//  Example implementation of the enhanced design system
//  Demonstrates space-efficient, intuitive, and dynamic UI
//

import SwiftUI

// MARK: - Example: Improved Workout List View
/// This view demonstrates the enhanced purple theme with full screen space utilization
struct ImprovedWorkoutListView: View {
    @State private var selectedDay: String?
    @State private var completionPercentage: Double = 0.65
    
    let mockWorkouts = [
        ExampleWorkoutDay(day: "Monday", theme: "Cardio", exercises: 4, duration: 45, isCompleted: true),
        ExampleWorkoutDay(day: "Tuesday", theme: "Strength", exercises: 6, duration: 50, isCompleted: true),
        ExampleWorkoutDay(day: "Wednesday", theme: "HIIT", exercises: 5, duration: 35, isCompleted: false),
        ExampleWorkoutDay(day: "Thursday", theme: "Yoga", exercises: 3, duration: 40, isCompleted: false),
        ExampleWorkoutDay(day: "Friday", theme: "Cardio", exercises: 4, duration: 45, isCompleted: false),
        ExampleWorkoutDay(day: "Saturday", theme: "Boxing", exercises: 7, duration: 55, isCompleted: false),
        ExampleWorkoutDay(day: "Sunday", theme: "Rest", exercises: 0, duration: 0, isCompleted: false)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
                // Full-screen gradient background
                Color.theme.backgroundGradientStyle
                    .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // MARK: - Story Reels Section
                        WorkoutReelsSection(workouts: mockWorkouts)
                            .padding(.top, 8)
                        
                        // MARK: - Progress Dashboard
                        CompactProgressDashboard(
                            completionPercentage: completionPercentage,
                            totalWorkouts: 7,
                            completedWorkouts: 2
                        )
                        .padding(.horizontal, 16)
                        
                        // MARK: - Today's Workout Hero
                        TodaysWorkoutHero(workout: mockWorkouts[2])
                            .padding(.horizontal, 16)
                        
                        // MARK: - Weekly Calendar Grid
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("This Week")
                                    .font(.title3.bold())
                                    .foregroundStyle(Color.theme.textPrimary)
                                
                                Spacer()
                                
                                Button(action: {}) {
                                    HStack(spacing: 4) {
                                        Text("View All")
                                            .font(.subheadline.weight(.medium))
                                        Image(systemName: "chevron.right")
                                            .font(.caption.weight(.semibold))
                                    }
                                    .foregroundStyle(Color.theme.primary)
                                }
                            }
                            .padding(.horizontal, 16)
                            
                            WeeklyWorkoutGrid(
                                workouts: mockWorkouts,
                                selectedDay: $selectedDay
                            )
                        }
                        
                        // MARK: - Quick Stats Section
                        QuickStatsGrid()
                            .padding(.horizontal, 16)
                        
                        // Add bottom padding for tab bar
                        Color.clear.frame(height: 100)
                    }
                    .padding(.top, 4)
                }
            }
            .navigationTitle("Workouts")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

// MARK: - Story Reels Section
struct WorkoutReelsSection: View {
    let workouts: [ExampleWorkoutDay]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 14) {
                // Main "Watch Reels" story
                VStack(spacing: 6) {
                    ZStack {
                        Circle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 68, height: 68)
                        
                        Circle()
                            .stroke(
                                Color.theme.vibrantGradient,
                                lineWidth: 3
                            )
                            .frame(width: 72, height: 72)
                        
                        Image(systemName: "play.rectangle.fill")
                            .font(.title3)
                            .foregroundStyle(Color.theme.vibrantGradient)
                    }
                    .purpleGlow(intensity: 0.3)
                    
                    Text("Reels")
                        .font(.caption2.weight(.medium))
                        .foregroundStyle(Color.theme.primary)
                }
                
                // Workout day stories
                ForEach(workouts) { workout in
                    if workout.theme != "Rest" {
                        ExampleWorkoutStoryCircle(workout: workout)
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
        }
    }
}

struct ExampleWorkoutStoryCircle: View {
    let workout: ExampleWorkoutDay
    
    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 68, height: 68)
                
                Circle()
                    .stroke(
                        workout.isCompleted ?
                            Color.theme.successGradient :
                            LinearGradient(
                                colors: [Color.theme.primary.opacity(0.4), Color.theme.primary.opacity(0.2)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                        lineWidth: 2.5
                    )
                    .frame(width: 72, height: 72)
                
                Image(systemName: workout.isCompleted ? "checkmark" : "figure.run")
                    .font(.title3)
                    .foregroundStyle(workout.isCompleted ? Color.theme.success : Color.theme.primary)
            }
            
            Text(workout.day.prefix(3))
                .font(.caption2.weight(.medium))
                .foregroundStyle(workout.isCompleted ? Color.theme.success : Color.theme.textSecondary)
                .lineLimit(1)
        }
    }
}

// MARK: - Compact Progress Dashboard
struct CompactProgressDashboard: View {
    let completionPercentage: Double
    let totalWorkouts: Int
    let completedWorkouts: Int
    
    var body: some View {
        HStack(spacing: 20) {
            // Progress Ring
            ZStack {
                Circle()
                    .stroke(Color.theme.primary.opacity(0.15), lineWidth: 10)
                    .frame(width: 90, height: 90)
                
                Circle()
                    .trim(from: 0, to: completionPercentage)
                    .stroke(
                        Color.theme.vibrantGradient,
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .frame(width: 90, height: 90)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 1.0, dampingFraction: 0.7), value: completionPercentage)
                
                VStack(spacing: 2) {
                    Text("\(Int(completionPercentage * 100))%")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.theme.textPrimary)
                    
                    Text("Done")
                        .font(.caption2)
                        .foregroundStyle(Color.theme.textSecondary)
                }
            }
            
            // Stats
            VStack(alignment: .leading, spacing: 14) {
                ExampleDashboardStatRow(
                    icon: "figure.strengthtraining.traditional",
                    label: "Workouts",
                    value: "\(completedWorkouts)/\(totalWorkouts)",
                    color: Color.theme.primary
                )
                
                ExampleDashboardStatRow(
                    icon: "flame.fill",
                    label: "Calories",
                    value: "2,450",
                    color: Color.theme.orange
                )
            }
            
            Spacer()
        }
        .padding(16)
        .glassCardFullScreen(cornerRadius: 20)
    }
}

struct ExampleDashboardStatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.body.weight(.medium))
                .foregroundStyle(color)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption2)
                    .foregroundStyle(Color.theme.textSecondary)
                
                Text(value)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Color.theme.textPrimary)
            }
        }
    }
}

// MARK: - Today's Workout Hero Card
struct TodaysWorkoutHero: View {
    let workout: ExampleWorkoutDay
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header section
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack(spacing: 6) {
                            Image(systemName: "star.fill")
                                .font(.caption2)
                            Text(workout.day.uppercased())
                                .font(.caption.weight(.bold))
                        }
                        .foregroundStyle(Color.theme.primary)
                        .tracking(0.8)
                        
                        Text(workout.theme)
                            .font(.title2.bold())
                            .foregroundStyle(Color.theme.textPrimary)
                    }
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .fill(.thinMaterial)
                            .frame(width: 56, height: 56)
                        
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [
                                        Color.theme.primary.opacity(0.4),
                                        Color.theme.primary.opacity(0.2)
                                    ],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 28
                                )
                            )
                            .frame(width: 56, height: 56)
                        
                        Image(systemName: "play.fill")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(Color.theme.primary)
                    }
                    .purpleGlow(intensity: 0.25)
                }
                
                // Stats
                HStack(spacing: 16) {
                    Label("\(workout.exercises) exercises", systemImage: "flame.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.theme.textSecondary)
                    
                    Label("~\(workout.duration) min", systemImage: "clock.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(Color.theme.textSecondary)
                    
                    if workout.exercises > 0 {
                        Label("3 bonus", systemImage: "gift.fill")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color.theme.pink)
                    }
                }
            }
            .padding(16)
            
            // CTA Button
            Button(action: {}) {
                HStack {
                    Spacer()
                    Text("Start Workout")
                        .font(.subheadline.weight(.semibold))
                    Image(systemName: "arrow.right")
                        .font(.subheadline.weight(.semibold))
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
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
            .buttonStyle(.plain)
            .purpleGlow(intensity: 0.3)
        }
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.15),
                                    Color.clear,
                                    Color.black.opacity(0.03)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color.white.opacity(0.6),
                                    Color.white.opacity(0.2)
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
}

// MARK: - Weekly Workout Grid
struct WeeklyWorkoutGrid: View {
    let workouts: [ExampleWorkoutDay]
    @Binding var selectedDay: String?
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(workouts) { workout in
                ExampleDayWorkoutCard(
                    workout: workout,
                    isSelected: selectedDay == workout.day
                )
                .onTapGesture {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedDay = workout.day
                    }
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct ExampleDayWorkoutCard: View {
    let workout: ExampleWorkoutDay
    let isSelected: Bool
    
    var isRestDay: Bool {
        workout.theme == "Rest"
    }
    
    var iconColor: Color {
        if isRestDay {
            return Color.theme.restDay
        } else if workout.isCompleted {
            return Color.theme.success
        } else {
            return Color.theme.primary
        }
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Day label
            Text(workout.day.prefix(3).uppercased())
                .font(.caption2.weight(.bold))
                .foregroundStyle(iconColor)
                .tracking(0.8)
            
            // Icon circle
            ZStack {
                Circle()
                    .fill(.ultraThinMaterial)
                    .frame(width: 52, height: 52)
                
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                iconColor.opacity(0.3),
                                iconColor.opacity(0.1)
                            ],
                            center: .center,
                            startRadius: 0,
                            endRadius: 26
                        )
                    )
                    .frame(width: 52, height: 52)
                
                Image(systemName: workout.isCompleted ? "checkmark" : (isRestDay ? "bed.double.fill" : "figure.run"))
                    .font(.title3)
                    .foregroundStyle(iconColor)
            }
            
            // Duration
            if !isRestDay {
                Text("\(workout.duration)m")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.theme.textSecondary)
            } else {
                Text("Rest")
                    .font(.caption2.weight(.medium))
                    .foregroundStyle(Color.theme.textSecondary)
            }
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(Color.theme.primary.opacity(0.1))
                    }
                }
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            isSelected ?
                                Color.theme.primary.opacity(0.5) :
                                Color.white.opacity(0.3),
                            lineWidth: isSelected ? 2 : 1
                        )
                }
        }
        .lightShadow()
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
    }
}

// MARK: - Quick Stats Grid
struct QuickStatsGrid: View {
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            QuickStatCard(
                icon: "flame.fill",
                value: "2,450",
                label: "Calories",
                color: Color.theme.orange
            )
            
            QuickStatCard(
                icon: "clock.fill",
                value: "540",
                label: "Minutes",
                color: Color.theme.teal
            )
            
            QuickStatCard(
                icon: "heart.fill",
                value: "142",
                label: "Avg BPM",
                color: Color.theme.pink
            )
            
            QuickStatCard(
                icon: "trophy.fill",
                value: "15",
                label: "Streak",
                color: Color.theme.success
            )
        }
    }
}

struct QuickStatCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(Color.theme.textPrimary)
            
            Text(label)
                .font(.caption.weight(.medium))
                .foregroundStyle(Color.theme.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 20)
        .glassCardFullScreen(cornerRadius: 16)
    }
}

// MARK: - Supporting Models (Demo/Example Only)
struct ExampleWorkoutDay: Identifiable {
    let id = UUID()
    let day: String
    let theme: String
    let exercises: Int
    let duration: Int
    let isCompleted: Bool
}

// MARK: - Preview
#Preview {
    ImprovedWorkoutListView()
}
