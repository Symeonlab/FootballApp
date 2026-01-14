//
//  FitnessWorkoutComponents.swift
//  FootballApp
//
//  Modern fitness-style workout components matching iOS Fitness design
//

import SwiftUI

// MARK: - Fitness Progress Card
/// Glass-morphic progress card with circular progress indicator
struct FitnessProgressCard: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    let progress: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                // Icon
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 48, height: 48)
                    
                    Image(systemName: icon)
                        .font(.title3)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 3)
                        .frame(width: 36, height: 36)
                    
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 36, height: 36)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.white)
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .frame(width: 160, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .stroke(color.opacity(0.3), lineWidth: 1)
                )
        )
    }
}

// MARK: - Fitness Week Calendar
/// Horizontal week calendar with workout indicators
struct FitnessWeekCalendar: View {
    let days: [(String, Bool, Bool, Bool)] // (day abbr, isToday, isCompleted, isRestDay)
    let onDayTap: (Int) -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 12) {
                ForEach(Array(days.enumerated()), id: \.offset) { index, day in
                    Button {
                        onDayTap(index)
                    } label: {
                        VStack(spacing: 12) {
                            Text(day.0)
                                .font(.caption.weight(.medium))
                                .foregroundColor(.white.opacity(0.6))
                            
                            ZStack {
                                Circle()
                                    .fill(
                                        day.3 ? Color.gray.opacity(0.3) : // Rest day
                                        day.2 ? Color.purple : // Completed
                                        day.1 ? Color.purple : // Today
                                        Color.white.opacity(0.1)
                                    )
                                    .frame(width: 56, height: 56)
                                
                                if day.3 {
                                    Image(systemName: "moon.fill")
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.6))
                                } else {
                                    Image(systemName: "dumbbell.fill")
                                        .font(.title3)
                                        .foregroundColor(.white)
                                }
                            }
                        }
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.2)
        )
    }
}

// MARK: - Workout Detail Card
/// Card showing workout metadata (duration, focus, equipment)
struct WorkoutDetailCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    var isWide: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.headline.weight(.semibold))
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
        }
        .padding(20)
        .frame(maxWidth: isWide ? .infinity : nil, minHeight: 140, alignment: .topLeading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.2)
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .stroke(color.opacity(0.2), lineWidth: 1)
                )
        )
    }
}

// MARK: - Preview
struct FitnessComponents_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
        LinearGradient(
            colors: [
                Color(hex: "0A0A1E"),
                Color(hex: "1A1A2E"),
                Color(hex: "0F0F23")
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
        
        ScrollView {
            VStack(spacing: 32) {
                // Progress Cards
                Text("Your Progress")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 16) {
                        FitnessProgressCard(
                            icon: "flame.fill",
                            value: "0",
                            label: "Completed",
                            color: Color(hex: "FF3B30"),
                            progress: 0.0
                        )
                        
                        FitnessProgressCard(
                            icon: "figure.strengthtraining.traditional",
                            value: "14",
                            label: "Exercises",
                            color: Color(hex: "AF52DE"),
                            progress: 0.6
                        )
                        
                        FitnessProgressCard(
                            icon: "calendar",
                            value: "7",
                            label: "Sessions",
                            color: Color(hex: "5AC8FA"),
                            progress: 0.7
                        )
                    }
                    .padding(.horizontal, 24)
                }
                
                // Week Calendar
                Text("This Week")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                FitnessWeekCalendar(
                    days: [
                        ("LUN", false, false, true),
                        ("MAR", false, false, false),
                        ("MER", true, false, false),
                        ("JEU", false, false, false),
                        ("VEN", false, false, false),
                        ("SAM", false, false, false),
                        ("DIM", false, false, true)
                    ],
                    onDayTap: { _ in }
                )
                .padding(.horizontal, 24)
                
                // Start Button
                Button {} label: {
                    HStack(spacing: 12) {
                        Image(systemName: "dumbbell.fill")
                            .font(.title3.weight(.semibold))
                        Text("Start Workout")
                            .font(.title3.weight(.semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 20)
                    .background(
                        LinearGradient(
                            colors: [
                                Color(hex: "5E7CE2"),
                                Color(hex: "A06CD5")
                            ],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 24)
                
                // Workout Details
                Text("Workout Details")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 24)
                
                HStack(spacing: 16) {
                    WorkoutDetailCard(
                        icon: "clock.fill",
                        title: "Duration:",
                        value: "60-90 min",
                        color: Color(hex: "AF52DE")
                    )
                    
                    WorkoutDetailCard(
                        icon: "target",
                        title: "Focus:",
                        value: "Power & Sp...",
                        color: Color(hex: "FFD60A")
                    )
                }
                .padding(.horizontal, 24)
                
                WorkoutDetailCard(
                    icon: "dumbbell.fill",
                    title: "Equipment:",
                    value: "Full Gym",
                    color: Color(hex: "32D74B"),
                    isWide: true
                )
                .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
        }
    }
}

// Note: Color(hex:) extension is already defined in ColorExtensions.swift

}
