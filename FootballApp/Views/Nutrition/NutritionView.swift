//  NutritionView.swift
//  FootballApp
//
//  Nutrition tracking and meal planning view
//

import SwiftUI
import Combine

struct NutritionView: View {
    @EnvironmentObject var viewModel: NutritionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Dark purple animated background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // User Preferences from Onboarding
                        if let profile = authViewModel.currentUser?.profile {
                            userPreferencesSection(profile: profile)
                        }
                        
                        // Prophetic Medicine Advice
                        if let nutritionPlan = viewModel.nutritionPlan,
                           let advice = nutritionPlan.advice, !advice.isEmpty {
                            propheticAdviceSection(advice: advice)
                        }
                        
                        // Header Stats
                        nutritionStatsSection
                        
                        // Meals Section
                        mealsSection
                        
                        // Water Intake
                        waterIntakeSection
                        
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nutrition - Dipodi")
            .onAppear {
                if viewModel.nutritionPlan == nil {
                    viewModel.fetchNutritionPlan()
                }
            }
        }
    }
    
    // MARK: - User Preferences Section
    private func userPreferencesSection(profile: APIProfile) -> some View {
        VStack(spacing: 16) {
            HStack {
                let primaryColor = Color(hex: "9D4EDD")
                let secondaryColor = Color(hex: "C77DFF")
                
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(primaryColor, secondaryColor)
                
                Text("Your Nutrition Profile")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            VStack(spacing: 12) {
                // Goal
                if let goal = profile.goal {
                    PreferenceRow(
                        icon: "target",
                        title: "Goal",
                        value: formatGoal(goal),
                        color: Color(hex: "9D4EDD")
                    )
                }
                
                // Vegetarian status
                if let isVegetarian = profile.is_vegetarian {
                    PreferenceRow(
                        icon: "leaf.fill",
                        title: "Diet Type",
                        value: isVegetarian ? "Vegetarian" : "Standard",
                        color: Color(hex: "7B2CBF")
                    )
                }
                
                // Activity Level
                if let activityLevel = profile.activity_level {
                    PreferenceRow(
                        icon: "figure.run",
                        title: "Activity Level",
                        value: formatActivityLevel(activityLevel),
                        color: Color(hex: "C77DFF")
                    )
                }
                
                // Morphology
                if let morphology = profile.morphology {
                    PreferenceRow(
                        icon: "person.fill",
                        title: "Body Type",
                        value: morphology.capitalized,
                        color: Color(hex: "9D4EDD")
                    )
                }
                
                // Meals per day
                if let mealsPerDay = profile.meals_per_day {
                    PreferenceRow(
                        icon: "fork.knife",
                        title: "Daily Meals",
                        value: mealsPerDay,
                        color: Color(hex: "7B2CBF")
                    )
                }
            }
            .padding(16)
            .background {
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .fill(.ultraThinMaterial)
                    .overlay {
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        Color(hex: "9D4EDD").opacity(0.5),
                                        Color(hex: "C77DFF").opacity(0.2)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 1
                            )
                    }
            }
        }
    }
    
    // MARK: - Prophetic Medicine Advice Section
    private func propheticAdviceSection(advice: [NutritionAdvice]) -> some View {
        VStack(spacing: 16) {
            HStack {
                let primaryColor = Color(hex: "7B2CBF")
                let secondaryColor = Color(hex: "9D4EDD")
                
                Image(systemName: "leaf.circle.fill")
                    .font(.title2)
                    .foregroundStyle(primaryColor, secondaryColor)
                
                Text("Prophetic Medicine Advice")
                    .font(.headline.bold())
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            ForEach(advice) { adviceItem in
                AdviceCard(advice: adviceItem)
            }
        }
    }
    
    // MARK: - Nutrition Stats Section
    private var nutritionStatsSection: some View {
        VStack(spacing: 16) {
            Text("Daily Goals")
                .font(.headline)
                .foregroundColor(Color.appTheme.textPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NutritionStatCard(
                        icon: "flame.fill",
                        value: "\(viewModel.caloriesConsumed)",
                        target: "\(viewModel.caloriesTarget)",
                        label: "Calories",
                        color: .orange,
                        progress: Double(viewModel.caloriesConsumed) / Double(viewModel.caloriesTarget)
                    )
                    
                    NutritionStatCard(
                        icon: "leaf.fill",
                        value: "\(viewModel.proteinConsumed)g",
                        target: "\(viewModel.proteinTarget)g",
                        label: "Protein",
                        color: .green,
                        progress: Double(viewModel.proteinConsumed) / Double(viewModel.proteinTarget)
                    )
                    
                    NutritionStatCard(
                        icon: "cube.fill",
                        value: "\(viewModel.carbsConsumed)g",
                        target: "\(viewModel.carbsTarget)g",
                        label: "Carbs",
                        color: .blue,
                        progress: Double(viewModel.carbsConsumed) / Double(viewModel.carbsTarget)
                    )
                    
                    NutritionStatCard(
                        icon: "drop.fill",
                        value: "\(viewModel.fatsConsumed)g",
                        target: "\(viewModel.fatsTarget)g",
                        label: "Fats",
                        color: .purple,
                        progress: Double(viewModel.fatsConsumed) / Double(viewModel.fatsTarget)
                    )
                }
            }
        }
    }
    
    // MARK: - Meals Section
    private var mealsSection: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Today's Meals")
                    .font(.headline)
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Spacer()
                
                Button(action: { viewModel.showAddMeal = true }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color.appTheme.primary)
                }
            }
            
            if viewModel.meals.isEmpty {
                emptyMealsState
            } else {
                ForEach(viewModel.meals) { meal in
                    MealCard(meal: meal)
                }
            }
        }
    }
    
    // MARK: - Water Intake Section
    private var waterIntakeSection: some View {
        VStack(spacing: 16) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundColor(.blue)
                
                Text("Water Intake")
                    .font(.headline)
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Spacer()
                
                Text("\(viewModel.waterGlasses)/\(viewModel.waterGoal) glasses")
                    .font(.subheadline)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
            
            // Water glasses visualization
            HStack(spacing: 8) {
                ForEach(0..<viewModel.waterGoal, id: \.self) { index in
                    Button(action: {
                        if index < viewModel.waterGlasses {
                            viewModel.waterGlasses -= 1
                        } else if index == viewModel.waterGlasses {
                            viewModel.waterGlasses += 1
                        }
                    }) {
                        Image(systemName: index < viewModel.waterGlasses ? "drop.fill" : "drop")
                            .font(.title2)
                            .foregroundColor(index < viewModel.waterGlasses ? .blue : Color.appTheme.textTertiary)
                    }
                }
            }
            .padding(.vertical, 8)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appTheme.surface)
        )
    }
    
    // MARK: - Empty State
    private var emptyMealsState: some View {
        VStack(spacing: 16) {
            Image(systemName: "fork.knife.circle")
                .font(.system(size: 60))
                .foregroundColor(Color.appTheme.textTertiary)
            
            Text("No meals logged today")
                .font(.headline)
                .foregroundColor(Color.appTheme.textPrimary)
            
            Text("Start tracking your nutrition by adding your first meal")
                .font(.subheadline)
                .foregroundColor(Color.appTheme.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }
    
    // MARK: - Helper Functions
    private func formatGoal(_ goal: String) -> String {
        switch goal {
        case "WEIGHT_LOSS": return "Weight Loss"
        case "MUSCLE_GAIN": return "Muscle Gain"
        case "MAINTENANCE": return "Maintenance"
        default: return goal.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
    
    private func formatActivityLevel(_ level: String) -> String {
        switch level {
        case "SEDENTARY": return "Sedentary"
        case "LIGHT": return "Lightly Active"
        case "MODERATE": return "Moderately Active"
        case "VERY_ACTIVE": return "Very Active"
        case "EXTREMELY_ACTIVE": return "Extremely Active"
        default: return level.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

// MARK: - Preference Row Component
struct PreferenceRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 36, height: 36)
                
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(color)
            }
            
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
            
            Spacer()
            
            Text(value)
                .font(.subheadline.bold())
                .foregroundColor(.white)
        }
    }
}

// MARK: - Advice Card Component
struct AdviceCard: View {
    let advice: NutritionAdvice
    @State private var isExpanded = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(advice.condition_name)
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Text(isExpanded ? "Tap to collapse" : "Tap to see advice")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle.fill")
                        .font(.title3)
                        .foregroundColor(Color(hex: "9D4EDD"))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)
            
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Foods to avoid
                    if let avoid = advice.foods_to_avoid, !avoid.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.red)
                                Text("Foods to Avoid")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            ForEach(avoid, id: \.self) { food in
                                HStack {
                                    Circle()
                                        .fill(.red.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                    Text(food)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.red.opacity(0.1))
                        }
                    }
                    
                    // Foods to eat
                    if let eat = advice.foods_to_eat, !eat.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Foods to Eat")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            ForEach(eat, id: \.self) { food in
                                HStack {
                                    Circle()
                                        .fill(.green.opacity(0.3))
                                        .frame(width: 6, height: 6)
                                    Text(food)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                        }
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(.green.opacity(0.1))
                        }
                    }
                    
                    // Prophetic advice
                    if let propheticAdvice = advice.prophetic_advice_fr, !propheticAdvice.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Image(systemName: "leaf.circle.fill")
                                    .foregroundColor(Color(hex: "9D4EDD"))
                                Text("Prophetic Medicine")
                                    .font(.subheadline.bold())
                                    .foregroundColor(.white)
                            }
                            
                            Text(propheticAdvice)
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .background {
                            RoundedRectangle(cornerRadius: 8, style: .continuous)
                                .fill(Color(hex: "9D4EDD").opacity(0.1))
                        }
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.95)))
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(.ultraThinMaterial)
                .overlay {
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(
                            LinearGradient(
                                colors: [
                                    Color(hex: "7B2CBF").opacity(0.5),
                                    Color(hex: "9D4EDD").opacity(0.2)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
        }
    }
}


// MARK: - Nutrition Stat Card
private struct NutritionStatCard: View {
    let icon: String
    let value: String
    let target: String
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
                        .trim(from: 0, to: min(progress, 1.0))
                        .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                        .frame(width: 24, height: 24)
                        .rotationEffect(.degrees(-90))
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(value)
                    .font(.title3.bold())
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Text("of \(target)")
                    .font(.caption2)
                    .foregroundColor(Color.appTheme.textSecondary)
                
                Text(label)
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
            }
        }
        .padding(16)
        .frame(width: 140)
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

// MARK: - Meal Card
private struct MealCard: View {
    let meal: Meal
    
    var body: some View {
        HStack(spacing: 16) {
            // Meal icon
            ZStack {
                Circle()
                    .fill(mealColor.opacity(0.15))
                    .frame(width: 50, height: 50)
                
                Image(systemName: mealIcon)
                    .font(.title3)
                    .foregroundColor(mealColor)
            }
            
            // Meal details
            VStack(alignment: .leading, spacing: 4) {
                Text(meal.name)
                    .font(.headline)
                    .foregroundColor(Color.appTheme.textPrimary)
                
                Text("\(meal.calories) cal • \(meal.protein)g protein")
                    .font(.caption)
                    .foregroundColor(Color.appTheme.textSecondary)
                
                Text(meal.time)
                    .font(.caption2)
                    .foregroundColor(Color.appTheme.textTertiary)
            }
            
            Spacer()
            
            // Macros preview
            VStack(alignment: .trailing, spacing: 4) {
                macroRow(icon: "leaf.fill", value: "\(meal.protein)g", color: .green)
                macroRow(icon: "cube.fill", value: "\(meal.carbs)g", color: .blue)
                macroRow(icon: "drop.fill", value: "\(meal.fats)g", color: .purple)
            }
            .font(.caption2)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.appTheme.surface)
        )
    }
    
    private func macroRow(icon: String, value: String, color: Color) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
            Text(value)
                .foregroundColor(Color.appTheme.textSecondary)
        }
    }
    
    private var mealIcon: String {
        switch meal.type {
        case "breakfast": return "sunrise.fill"
        case "lunch": return "sun.max.fill"
        case "dinner": return "moon.stars.fill"
        case "snack": return "cup.and.saucer.fill"
        default: return "fork.knife"
        }
    }
    
    private var mealColor: Color {
        switch meal.type {
        case "breakfast": return .orange
        case "lunch": return .yellow
        case "dinner": return .indigo
        case "snack": return .pink
        default: return Color.appTheme.primary
        }
    }
}

// MARK: - Preview
#Preview {
    @Previewable @StateObject var nutritionVM = NutritionViewModel()
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    
    return NutritionView()
        .environmentObject(nutritionVM)
        .environmentObject(authVM)
        .environmentObject(langManager)
        .preferredColorScheme(.dark)
}
