//
//  FitnessNutritionComponents.swift
//  FootballApp
//
//  Modern fitness-style nutrition components matching iOS design
//

import SwiftUI

// MARK: - Nutrition Progress Card
/// Glass-morphic nutrition card with circular progress indicator
struct NutritionProgressCard: View {
    let icon: String
    let value: String
    let unit: String
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
                        .font(.title2)
                        .foregroundColor(color)
                }
                
                Spacer()
                
                // Progress Ring
                ZStack {
                    Circle()
                        .stroke(color.opacity(0.2), lineWidth: 4)
                        .frame(width: 40, height: 40)
                    
                    Circle()
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(color, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        .frame(width: 40, height: 40)
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 1.0), value: progress)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 32, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text(unit)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                Text(label)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .frame(width: 160, height: 160)
        .background(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .fill(.ultraThinMaterial)
                .opacity(0.3)
                .overlay(
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [color.opacity(0.5), color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: color.opacity(0.3), radius: 20, x: 0, y: 10)
    }
}

// MARK: - Nutrition Week Calendar
/// Weekly nutrition tracking calendar
struct NutritionWeekCalendar: View {
    let days: [(String, MealType?)] // (day abbr, meal type)
    let onDayTap: (Int) -> Void
    
    enum MealType {
        case breakfast, lunch, dinner, snack, water, healthy
        
        var icon: String {
            switch self {
            case .breakfast: return "sunrise.fill"
            case .lunch: return "fork.knife"
            case .dinner: return "fork.knife"
            case .snack: return "🍎"
            case .water: return "drop.fill"
            case .healthy: return "leaf.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .breakfast: return Color(hex: "FF6B6B")
            case .lunch: return Color(hex: "5E7CE2")
            case .dinner: return Color(hex: "A06CD5")
            case .snack: return Color(hex: "FF6B6B")
            case .water: return Color(hex: "5E7CE2")
            case .healthy: return Color(hex: "4ECB71")
            }
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
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
                                    .fill(day.1?.color ?? Color.white.opacity(0.1))
                                    .frame(width: 60, height: 60)
                                
                                if let mealType = day.1 {
                                    Image(systemName: mealType.icon)
                                        .font(.title2)
                                        .foregroundColor(.white)
                                } else {
                                    Circle()
                                        .stroke(Color.white.opacity(0.2), lineWidth: 2)
                                        .frame(width: 60, height: 60)
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

// MARK: - Nutrition Detail Card
/// Card showing nutrition metadata
struct NutritionDetailCard: View {
    let icon: String
    let title: String
    let value: String
    let subtitle: String?
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 56, height: 56)
                
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
            }
            
            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                
                Text(value)
                    .font(.title3.weight(.bold))
                    .foregroundColor(.white)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
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

// MARK: - Log Meal Button
/// Large gradient button for logging meals
struct LogMealButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: "fork.knife")
                    .font(.title2.weight(.semibold))
                Text("Log Meal")
                    .font(.title2.weight(.semibold))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 22)
            .background(
                LinearGradient(
                    colors: [
                        Color(hex: "3B82F6"),
                        Color(hex: "8B5CF6")
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(20)
            .shadow(color: Color(hex: "8B5CF6").opacity(0.4), radius: 20, x: 0, y: 10)
        }
    }
}

// MARK: - Preview
struct FitnessNutritionComponents_Previews: PreviewProvider {
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
                    // Title
                    Text("Nutrition")
                        .font(.system(size: 40, weight: .bold))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 24)
                        .padding(.top, 20)
                    
                    // Your Progress
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Your Progress")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                NutritionProgressCard(
                                    icon: "flame.fill",
                                    value: "1850",
                                    unit: "kcal",
                                    label: "Consumed",
                                    color: Color(hex: "FF6B6B"),
                                    progress: 0.74
                                )
                                
                                NutritionProgressCard(
                                    icon: "leaf.fill",
                                    value: "120",
                                    unit: "g",
                                    label: "Protein",
                                    color: Color(hex: "A06CD5"),
                                    progress: 0.8
                                )
                                
                                NutritionProgressCard(
                                    icon: "drop.fill",
                                    value: "2.5",
                                    unit: "L",
                                    label: "Water",
                                    color: Color(hex: "5E7CE2"),
                                    progress: 0.83
                                )
                            }
                            .padding(.horizontal, 24)
                        }
                    }
                    
                    // This Week
                    VStack(alignment: .leading, spacing: 16) {
                        Text("This Week")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        NutritionWeekCalendar(
                            days: [
                                ("LUN", .snack),
                                ("MAR", .water),
                                ("MER", .dinner),
                                ("JEU", .healthy),
                                ("VEN", .dinner),
                                ("SAM", .water),
                                ("DIM", .healthy)
                            ],
                            onDayTap: { _ in }
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    // Log Meal Button
                    LogMealButton {
                        print("Log meal tapped")
                    }
                    .padding(.horizontal, 24)
                    
                    // Nutrition Details
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Nutrition Details")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                        
                        HStack(spacing: 16) {
                            NutritionDetailCard(
                                icon: "fork.knife",
                                title: "Meals:",
                                value: "3 Meals",
                                subtitle: "2 Snacks",
                                color: Color(hex: "A06CD5")
                            )
                            
                            NutritionDetailCard(
                                icon: "target",
                                title: "Goal:",
                                value: "Maintenance",
                                subtitle: nil,
                                color: Color(hex: "FFD60A")
                            )
                        }
                        .padding(.horizontal, 24)
                        
                        NutritionDetailCard(
                            icon: "chart.pie.fill",
                            title: "Macros:",
                            value: "C: 45%, P: 30%",
                            subtitle: "F: 25%",
                            color: Color(hex: "4ECB71")
                        )
                        .padding(.horizontal, 24)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.vertical, 24)
            }
        }
    }
}

// Note: Color(hex:) extension is already defined in ColorExtensions.swift
