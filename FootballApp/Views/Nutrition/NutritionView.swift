//  NutritionView.swift
//  FootballApp
//
//  Nutrition tracking and meal planning view
//

import SwiftUI
import Combine
import os.log

struct NutritionView: View {
    @EnvironmentObject var viewModel: NutritionViewModel
    @EnvironmentObject var authViewModel: AuthViewModel

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "NutritionView")

    var body: some View {
        NavigationStack {
            ZStack {
                // Dark background
                DarkPurpleAnimatedBackground()
                    .ignoresSafeArea()

                if viewModel.isLoading && viewModel.nutritionPlan == nil {
                    loadingState
                } else if let errorMessage = viewModel.errorMessage, viewModel.nutritionPlan == nil {
                    errorState(errorMessage)
                } else {
                    mainContent
                }
            }
            .navigationTitle("nutrition.title".localizedString)
            .navigationBarTitleDisplayMode(.large)
            .refreshable {
                await viewModel.fetchNutritionPlanAsync()
            }
        }
        .task {
            if viewModel.nutritionPlan == nil {
                logger.info("📥 NutritionView: Fetching nutrition plan")
                await viewModel.fetchNutritionPlanAsync()
            }
        }
    }

    // MARK: - Loading State
    private var loadingState: some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                    .blur(radius: 20)
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .orange))
                    .scaleEffect(1.5)
            }
            Text("nutrition.loading_plan".localizedString)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.7))
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Error State
    private func errorState(_ errorMessage: String) -> some View {
        VStack(spacing: 20) {
            Spacer()
            ZStack {
                Circle()
                    .fill(Color.orange.opacity(0.1))
                    .frame(width: 100, height: 100)
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 40))
                    .foregroundColor(.orange)
            }
            Text(errorMessage)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            Button(action: {
                Task { await viewModel.fetchNutritionPlanAsync() }
            }) {
                Text("nutrition.error_retry".localizedString)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 28)
                    .padding(.vertical, 12)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                    )
            }
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Main Content
    private var mainContent: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Weekly Nutrition Stories
                NutritionWeeklyStoriesRow(viewModel: viewModel)

                // Calorie + Macros Hero Card (combined for better visual impact)
                calorieAndMacrosHeroCard

                // Daily Meal Plan
                if let plan = viewModel.nutritionPlan,
                   let meals = plan.daily_meals, !meals.isEmpty {
                    dailyMealPlanSection(meals: meals)
                } else if viewModel.nutritionPlan != nil {
                    // Empty state for meals
                    VStack(spacing: 12) {
                        Image(systemName: "fork.knife")
                            .font(.system(size: 28))
                            .foregroundColor(.orange.opacity(0.4))
                        Text("nutrition.no_meals_yet".localizedString)
                            .font(.subheadline.weight(.medium))
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color.white.opacity(0.03))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20, style: .continuous)
                                    .strokeBorder(Color.white.opacity(0.06), lineWidth: 1)
                            )
                    )
                }

                // Water Intake
                waterIntakeSection

                // User Profile Summary
                if let profile = authViewModel.currentUser?.profile {
                    userPreferencesSection(profile: profile)
                }

                // Health & Prophetic Advice
                if let plan = viewModel.nutritionPlan,
                   let advice = plan.advice, !advice.isEmpty {
                    propheticAdviceSection(advice: advice)
                }

                Spacer(minLength: 120)
            }
            .padding(.horizontal, 16)
            .padding(.top, 8)
        }
    }

    // MARK: - Calorie + Macros Hero Card
    private var calorieAndMacrosHeroCard: some View {
        VStack(spacing: 20) {
            // Calorie Ring
            HStack(spacing: 24) {
                // Ring
                ZStack {
                    Circle()
                        .fill(Color.orange.opacity(0.08))
                        .frame(width: 140, height: 140)
                        .blur(radius: 20)

                    Circle()
                        .stroke(Color.white.opacity(0.08), lineWidth: 14)
                        .frame(width: 120, height: 120)

                    Circle()
                        .trim(from: 0, to: min(viewModel.nutritionProgress, 1.0))
                        .stroke(
                            LinearGradient(
                                colors: [.orange, .pink],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 14, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.spring(response: 0.8, dampingFraction: 0.7), value: viewModel.nutritionProgress)

                    VStack(spacing: 2) {
                        Text("\(viewModel.caloriesConsumed)")
                            .font(.system(size: 30, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("nutrition.of_kcal".localizedString(with: viewModel.caloriesTarget))
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                    }
                }

                // Status + remaining
                VStack(alignment: .leading, spacing: 10) {
                    Text(calorieStatusText)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.white)

                    HStack(spacing: 6) {
                        Image(systemName: remainingCalories >= 0 ? "flame.fill" : "exclamationmark.triangle.fill")
                            .font(.system(size: 12))
                            .foregroundColor(remainingCalories >= 0 ? .orange : .red)
                        Text(remainingCalories >= 0
                             ? "nutrition.kcal_remaining".localizedString(with: remainingCalories)
                             : "nutrition.kcal_over_target".localizedString(with: abs(remainingCalories)))
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(remainingCalories >= 0 ? .white.opacity(0.7) : .red)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Capsule().fill(Color.white.opacity(0.06)))
                }
            }

            // Macros row
            HStack(spacing: 10) {
                MacroCard(
                    icon: "leaf.fill",
                    name: "nutrition.protein".localizedString,
                    consumed: viewModel.proteinConsumed,
                    target: viewModel.proteinTarget,
                    unit: "g",
                    color: .green
                )
                MacroCard(
                    icon: "bolt.fill",
                    name: "nutrition.carbs".localizedString,
                    consumed: viewModel.carbsConsumed,
                    target: viewModel.carbsTarget,
                    unit: "g",
                    color: .blue
                )
                MacroCard(
                    icon: "drop.fill",
                    name: "nutrition.fats".localizedString,
                    consumed: viewModel.fatsConsumed,
                    target: viewModel.fatsTarget,
                    unit: "g",
                    color: .purple
                )
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.pink.opacity(0.15), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
    }

    private var remainingCalories: Int {
        viewModel.caloriesTarget - viewModel.caloriesConsumed
    }

    private var calorieStatusText: String {
        let progress = viewModel.nutritionProgress
        if progress >= 1.0 {
            return "nutrition.target_reached".localizedString
        } else if progress >= 0.8 {
            return "nutrition.almost_there".localizedString
        } else if progress >= 0.5 {
            return "nutrition.halfway".localizedString
        } else {
            return "nutrition.keep_fueling".localizedString
        }
    }

    // MARK: - Daily Meal Plan Section
    private func dailyMealPlanSection(meals: [AppMeal]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "fork.knife")
                    .foregroundStyle(
                        LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )
                Text("nutrition.todays_meal_plan".localizedString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                if let totalCal = totalMealCalories(meals) {
                    Text("~\(totalCal) kcal")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundColor(.orange.opacity(0.8))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Capsule().fill(Color.orange.opacity(0.1)))
                }
            }

            VStack(spacing: 10) {
                ForEach(Array(meals.enumerated()), id: \.element.id) { index, meal in
                    MealPlanCard(meal: meal, mealNumber: index + 1)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.orange.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func totalMealCalories(_ meals: [AppMeal]) -> Int? {
        let cals = meals.compactMap(\.estimated_calories)
        guard !cals.isEmpty else { return nil }
        return cals.reduce(0, +)
    }

    // MARK: - Water Intake Section
    private var waterIntakeSection: some View {
        VStack(spacing: 14) {
            HStack {
                Image(systemName: "drop.fill")
                    .font(.title3)
                    .foregroundStyle(LinearGradient(colors: [.blue, .cyan], startPoint: .top, endPoint: .bottom))

                Text("nutrition.hydration.title".localizedString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)

                Spacer()

                Text("\(viewModel.waterGlasses)/\(viewModel.waterGoal)")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.cyan)
            }

            // Progress bar
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white.opacity(0.08))
                        .frame(height: 10)

                    RoundedRectangle(cornerRadius: 8)
                        .fill(
                            LinearGradient(colors: [.blue, .cyan], startPoint: .leading, endPoint: .trailing)
                        )
                        .frame(
                            width: geo.size.width * min(Double(viewModel.waterGlasses) / Double(max(viewModel.waterGoal, 1)), 1.0),
                            height: 10
                        )
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: viewModel.waterGlasses)
                }
            }
            .frame(height: 10)

            // Interactive water drops
            HStack(spacing: 6) {
                ForEach(0..<viewModel.waterGoal, id: \.self) { index in
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                            viewModel.waterGlasses = index < viewModel.waterGlasses ? index : index + 1
                        }
                    }) {
                        Image(systemName: index < viewModel.waterGlasses ? "drop.fill" : "drop")
                            .font(.system(size: 18))
                            .foregroundColor(index < viewModel.waterGlasses ? .cyan : .white.opacity(0.2))
                            .frame(width: 32, height: 32)
                            .background(
                                Circle()
                                    .fill(index < viewModel.waterGlasses ? Color.cyan.opacity(0.15) : Color.clear)
                            )
                    }
                }
            }
            .padding(.top, 2)

            if viewModel.waterGlasses < viewModel.waterGoal {
                HStack(spacing: 6) {
                    Image(systemName: "lightbulb.fill")
                        .foregroundColor(.yellow)
                        .font(.system(size: 11))
                    Text("nutrition.more_glasses".localizedString(with: viewModel.waterGoal - viewModel.waterGlasses))
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color.blue.opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - User Preferences Section
    private func userPreferencesSection(profile: APIProfile) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .foregroundColor(Color(hex: "9D4EDD"))
                Text("nutrition.your_profile".localizedString)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                Spacer()
            }

            VStack(spacing: 10) {
                if let goal = profile.goal {
                    CompactPreferenceRow(icon: "target", title: "nutrition.goal".localizedString, value: formatGoal(goal), color: .orange)
                }
                if let isVegetarian = profile.is_vegetarian {
                    CompactPreferenceRow(icon: "leaf.fill", title: "nutrition.diet".localizedString, value: isVegetarian ? "nutrition.vegetarian".localizedString : "nutrition.standard".localizedString, color: .green)
                }
                if let activityLevel = profile.activity_level {
                    CompactPreferenceRow(icon: "figure.run", title: "nutrition.activity".localizedString, value: formatActivityLevel(activityLevel), color: .blue)
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color.white.opacity(0.04))
                .overlay(
                    RoundedRectangle(cornerRadius: 20, style: .continuous)
                        .strokeBorder(Color(hex: "9D4EDD").opacity(0.15), lineWidth: 1)
                )
        )
    }

    // MARK: - Prophetic Medicine Advice Section
    private func propheticAdviceSection(advice: [NutritionAdvice]) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color(hex: "7B2CBF").opacity(0.3), Color(hex: "9D4EDD").opacity(0.15)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 36, height: 36)
                    Image(systemName: "leaf.circle.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "9D4EDD"))
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("nutrition.health_advice".localizedString)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    Text("\(advice.count) " + "nutrition.conditions".localizedString)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                }
                Spacer()
            }

            ForEach(advice) { adviceItem in
                AdviceCard(advice: adviceItem)
            }
        }
    }

    // MARK: - Helpers
    private func formatGoal(_ goal: String) -> String {
        switch goal {
        case "WEIGHT_LOSS": return "goal.weight_loss".localizedString
        case "MUSCLE_GAIN": return "goal.muscle_gain".localizedString
        case "MAINTENANCE": return "goal.maintenance".localizedString
        default: return goal.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }

    private func formatActivityLevel(_ level: String) -> String {
        switch level {
        case "SEDENTARY": return "activity.sedentary".localizedString
        case "LIGHT": return "activity.light".localizedString
        case "MODERATE": return "activity.moderate".localizedString
        case "VERY_ACTIVE": return "activity.very_active".localizedString
        case "EXTREMELY_ACTIVE": return "activity.extreme".localizedString
        default: return level.replacingOccurrences(of: "_", with: " ").capitalized
        }
    }
}

// MARK: - Macro Card Component
struct MacroCard: View {
    let icon: String
    let name: String
    let consumed: Int
    let target: Int
    let unit: String
    let color: Color

    private var progress: Double {
        guard target > 0 else { return 0 }
        return Double(consumed) / Double(target)
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.15), lineWidth: 5)
                    .frame(width: 44, height: 44)

                Circle()
                    .trim(from: 0, to: min(progress, 1.0))
                    .stroke(color, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                    .frame(width: 44, height: 44)
                    .rotationEffect(.degrees(-90))
                    .animation(.spring(response: 0.6, dampingFraction: 0.7), value: progress)

                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(spacing: 1) {
                Text("\(consumed)")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text("/\(target)\(unit)")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }

            Text(name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white.opacity(0.5))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(color.opacity(0.06))
        )
    }
}

// MARK: - Meal Plan Card Component
struct MealPlanCard: View {
    let meal: AppMeal
    let mealNumber: Int
    @State private var isExpanded = false

    private var mealIcon: String {
        let type = meal.meal_type ?? meal.name.lowercased()
        switch type {
        case "breakfast", "petit-déjeuner", "petit déjeuner": return "sunrise.fill"
        case "lunch", "déjeuner": return "sun.max.fill"
        case "dinner", "dîner": return "moon.stars.fill"
        case "snack", "collation", "goûter": return "cup.and.saucer.fill"
        default: return "fork.knife"
        }
    }

    private var mealColor: Color {
        let type = meal.meal_type ?? meal.name.lowercased()
        switch type {
        case "breakfast", "petit-déjeuner", "petit déjeuner": return .orange
        case "lunch", "déjeuner": return .yellow
        case "dinner", "dîner": return .indigo
        case "snack", "collation", "goûter": return .pink
        default: return .orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12, style: .continuous)
                            .fill(mealColor.opacity(0.15))
                            .frame(width: 42, height: 42)

                        Image(systemName: mealIcon)
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(mealColor)
                    }

                    VStack(alignment: .leading, spacing: 3) {
                        Text(meal.name)
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.white)

                        HStack(spacing: 8) {
                            Text("\(meal.items.count) items")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))

                            if let cal = meal.estimated_calories, cal > 0 {
                                Text("~\(cal) kcal")
                                    .font(.system(size: 11, weight: .bold, design: .rounded))
                                    .foregroundColor(mealColor.opacity(0.8))
                            }
                        }
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.white.opacity(0.3))
                        .frame(width: 28, height: 28)
                        .background(Circle().fill(Color.white.opacity(0.05)))
                }
            }
            .buttonStyle(.plain)

            // Expanded content
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [mealColor.opacity(0.3), .clear],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(height: 1)
                        .padding(.vertical, 10)

                    // Show food details if available, otherwise show simple items
                    if let details = meal.food_details, !details.isEmpty {
                        ForEach(details) { detail in
                            HStack(spacing: 10) {
                                Image(systemName: foodTypeIcon(detail.food_type))
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(mealColor.opacity(0.7))
                                    .frame(width: 20)

                                Text(detail.name)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))

                                Spacer()

                                if let kcal = detail.kcal_per_100g {
                                    Text("\(Int(kcal))kcal")
                                        .font(.system(size: 10, weight: .bold, design: .rounded))
                                        .foregroundColor(.white.opacity(0.35))
                                }
                            }
                            .padding(.vertical, 3)
                        }
                    } else {
                        ForEach(meal.items, id: \.self) { item in
                            HStack(spacing: 10) {
                                Circle()
                                    .fill(mealColor.opacity(0.5))
                                    .frame(width: 5, height: 5)

                                Text(item)
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.85))

                                Spacer()
                            }
                            .padding(.vertical, 2)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
        )
    }

    private func foodTypeIcon(_ type: String?) -> String {
        switch type {
        case "viande": return "flame.fill"
        case "poisson": return "drop.fill"
        case "legume": return "leaf.fill"
        case "feculent": return "circle.grid.3x3.fill"
        case "fruit": return "heart.circle.fill"
        case "fruit_sec": return "leaf.circle.fill"
        case "laitage": return "mug.fill"
        case "oeuf": return "oval.fill"
        case "plat_principal": return "star.fill"
        case "accompagnement": return "square.grid.2x2.fill"
        case "dessert": return "sparkles"
        default: return "circle.fill"
        }
    }
}

// MARK: - Compact Preference Row
struct CompactPreferenceRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 13))
                .foregroundColor(color)
                .frame(width: 22)

            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.white.opacity(0.5))

            Spacer()

            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white)
        }
    }
}

// MARK: - Advice Card Component
struct AdviceCard: View {
    let advice: NutritionAdvice
    @State private var isExpanded = false

    private var localizedPropheticAdvice: String? {
        let lang = LanguageManager.shared.selected
        switch lang {
        case .arabic:
            if let ar = advice.prophetic_advice_ar, !ar.isEmpty { return ar }
            return advice.prophetic_advice_fr
        default:
            if let fr = advice.prophetic_advice_fr, !fr.isEmpty { return fr }
            return advice.prophetic_advice_ar
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Condition icon
                    ZStack {
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .fill(Color(hex: "9D4EDD").opacity(0.15))
                            .frame(width: 38, height: 38)
                        Image(systemName: "heart.text.clipboard.fill")
                            .font(.system(size: 15))
                            .foregroundColor(Color(hex: "9D4EDD"))
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(advice.condition_name)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        Text(isExpanded ? "nutrition.tap_to_collapse".localizedString : "nutrition.tap_to_see_advice".localizedString)
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.4))
                    }

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(hex: "9D4EDD").opacity(0.6))
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                        .animation(.spring(response: 0.3), value: isExpanded)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 10) {
                    Rectangle()
                        .fill(Color(hex: "9D4EDD").opacity(0.15))
                        .frame(height: 1)
                        .padding(.vertical, 10)

                    // Foods to eat
                    if let eat = advice.foods_to_eat, !eat.isEmpty {
                        adviceFoodSection(
                            title: "nutrition.foods_to_eat".localizedString,
                            icon: "checkmark.circle.fill",
                            color: .green,
                            foods: eat
                        )
                    }

                    // Foods to avoid
                    if let avoid = advice.foods_to_avoid, !avoid.isEmpty {
                        adviceFoodSection(
                            title: "nutrition.foods_to_avoid".localizedString,
                            icon: "xmark.circle.fill",
                            color: .red,
                            foods: avoid
                        )
                    }

                    // Prophetic advice
                    if let propheticAdvice = localizedPropheticAdvice, !propheticAdvice.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack(spacing: 6) {
                                Image(systemName: "sparkles")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "9D4EDD"))
                                Text("nutrition.prophetic_medicine".localizedString)
                                    .font(.system(size: 13, weight: .bold))
                                    .foregroundColor(.white.opacity(0.9))
                            }

                            Text(propheticAdvice)
                                .font(.system(size: 12))
                                .foregroundColor(.white.opacity(0.7))
                                .lineSpacing(4)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .padding(12)
                        .background(
                            RoundedRectangle(cornerRadius: 12, style: .continuous)
                                .fill(Color(hex: "9D4EDD").opacity(0.08))
                        )
                    }
                }
                .transition(.opacity.combined(with: .scale(scale: 0.97, anchor: .top)))
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [
                                    Color(hex: "7B2CBF").opacity(isExpanded ? 0.4 : 0.15),
                                    Color(hex: "9D4EDD").opacity(isExpanded ? 0.2 : 0.08)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .animation(.spring(response: 0.3), value: isExpanded)
    }

    private func adviceFoodSection(title: String, icon: String, color: Color, foods: [String]) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(color)
                Text(title)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.white.opacity(0.9))
            }

            // Flow layout with tags
            FlowLayout(spacing: 6) {
                ForEach(foods, id: \.self) { food in
                    Text(food)
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(color.opacity(0.9))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule().fill(color.opacity(0.1))
                                .overlay(Capsule().strokeBorder(color.opacity(0.2), lineWidth: 0.5))
                        )
                }
            }
        }
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(color.opacity(0.04))
        )
    }
}

// MARK: - Nutrition Weekly Stories Row
struct NutritionWeeklyStoriesRow: View {
    @ObservedObject var viewModel: NutritionViewModel
    @State private var selectedDayIndex: Int? = nil
    @State private var showMealPrepTips: Bool = false

    private var dayNames: [String] {
        [
            "day.mon".localizedString, "day.tue".localizedString, "day.wed".localizedString,
            "day.thu".localizedString, "day.fri".localizedString, "day.sat".localizedString,
            "day.sun".localizedString
        ]
    }
    private var fullDayNames: [String] {
        [
            "day.monday".localizedString, "day.tuesday".localizedString, "day.wednesday".localizedString,
            "day.thursday".localizedString, "day.friday".localizedString, "day.saturday".localizedString,
            "day.sunday".localizedString
        ]
    }

    private var currentDayIndex: Int {
        let weekday = Calendar.current.component(.weekday, from: Date())
        return weekday == 1 ? 6 : weekday - 2
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("nutrition.weekly_plan".localizedString)
                        .font(.headline.bold())
                        .foregroundColor(.white)
                    Text("nutrition.tap_for_details".localizedString)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.5))
                }

                Spacer()

                Button(action: { showMealPrepTips = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "lightbulb.fill")
                            .font(.caption.bold())
                        Text("nutrition.tips".localizedString)
                            .font(.caption.bold())
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 7)
                    .background(
                        Capsule().fill(
                            LinearGradient(colors: [.orange, .pink], startPoint: .leading, endPoint: .trailing)
                        )
                    )
                }
            }
            .padding(.horizontal, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    NutritionWeeklyOverviewBubble(
                        caloriesConsumed: viewModel.caloriesConsumed,
                        caloriesTarget: viewModel.caloriesTarget,
                        mealsCount: viewModel.nutritionPlan?.daily_meals?.count ?? 0
                    )
                    .onTapGesture { selectedDayIndex = -1 }

                    ForEach(0..<7, id: \.self) { dayIndex in
                        NutritionDayBubble(
                            dayName: dayNames[dayIndex],
                            isToday: dayIndex == currentDayIndex,
                            isPast: dayIndex < currentDayIndex,
                            mealsCount: viewModel.nutritionPlan?.daily_meals?.count ?? 0,
                            nutritionProgress: dayIndex == currentDayIndex ? viewModel.nutritionProgress : (dayIndex < currentDayIndex ? 0.0 : 0)
                        )
                        .onTapGesture { selectedDayIndex = dayIndex }
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.vertical, 12)
        .sheet(item: Binding(
            get: { selectedDayIndex.map { NutritionDaySelection(dayIndex: $0) } },
            set: { selectedDayIndex = $0?.dayIndex }
        )) { selection in
            NutritionDayDetailSheet(
                dayIndex: selection.dayIndex,
                dayName: selection.dayIndex == -1 ? "nutrition.weekly_overview".localizedString : fullDayNames[selection.dayIndex],
                meals: viewModel.nutritionPlan?.daily_meals ?? [],
                caloriesTarget: viewModel.caloriesTarget,
                proteinTarget: viewModel.proteinTarget,
                carbsTarget: viewModel.carbsTarget,
                fatsTarget: viewModel.fatsTarget
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(isPresented: $showMealPrepTips) {
            MealPrepTipsSheet()
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
        }
    }
}

struct NutritionDaySelection: Identifiable {
    let dayIndex: Int
    var id: Int { dayIndex }
}

// MARK: - Weekly Overview Bubble
struct NutritionWeeklyOverviewBubble: View {
    let caloriesConsumed: Int
    let caloriesTarget: Int
    let mealsCount: Int

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .strokeBorder(
                        AngularGradient(
                            colors: [.orange, .pink, .purple, .blue, .cyan, .orange],
                            center: .center
                        ),
                        lineWidth: 3
                    )
                    .frame(width: 64, height: 64)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2A2A4E"), Color(hex: "1E1E3E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 56, height: 56)

                VStack(spacing: 1) {
                    Image(systemName: "fork.knife.circle.fill")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.orange)
                    Text("\(mealsCount)")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                }
            }

            Text("nutrition.week".localizedString)
                .font(.caption2.bold())
                .foregroundColor(.orange)
        }
    }
}

// MARK: - Day Bubble
struct NutritionDayBubble: View {
    let dayName: String
    let isToday: Bool
    let isPast: Bool
    let mealsCount: Int
    let nutritionProgress: Double

    private var ringColor: Color {
        if isToday { return .orange }
        else if isPast && nutritionProgress > 0.7 { return .green }
        else if isPast { return .yellow }
        else { return .gray.opacity(0.3) }
    }

    private var statusIcon: String {
        if isPast && nutritionProgress > 0.8 { return "checkmark" }
        else if isToday { return "fork.knife" }
        else { return "calendar" }
    }

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Circle()
                    .strokeBorder(
                        isToday ?
                        LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing) :
                        LinearGradient(colors: [ringColor, ringColor], startPoint: .topLeading, endPoint: .bottomTrailing),
                        lineWidth: isToday ? 3 : 2
                    )
                    .frame(width: 56, height: 56)

                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color(hex: "2A2A4E"), Color(hex: "1E1E3E")],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 48, height: 48)

                Image(systemName: statusIcon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(ringColor)

                if isToday {
                    Circle()
                        .fill(Color.orange)
                        .frame(width: 12, height: 12)
                        .overlay(Circle().stroke(Color(hex: "1E1E2E"), lineWidth: 2))
                        .offset(x: 18, y: -18)
                }
            }

            Text(dayName)
                .font(.caption2.bold())
                .foregroundColor(isToday ? .white : .white.opacity(0.5))
        }
    }
}

// MARK: - Day Detail Sheet
struct NutritionDayDetailSheet: View {
    let dayIndex: Int
    let dayName: String
    let meals: [AppMeal]
    let caloriesTarget: Int
    let proteinTarget: Int
    let carbsTarget: Int
    let fatsTarget: Int

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1A1A3E"), Color(hex: "0F0F23")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        // Targets
                        VStack(alignment: .leading, spacing: 14) {
                            Text("nutrition.daily_targets".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)

                            HStack(spacing: 12) {
                                NutritionTargetCard(icon: "flame.fill", label: "nutrition.calories".localizedString, value: "\(caloriesTarget)", color: .orange)
                                NutritionTargetCard(icon: "leaf.fill", label: "nutrition.protein".localizedString, value: "\(proteinTarget)g", color: .green)
                            }
                            HStack(spacing: 12) {
                                NutritionTargetCard(icon: "bolt.fill", label: "nutrition.carbs".localizedString, value: "\(carbsTarget)g", color: .blue)
                                NutritionTargetCard(icon: "drop.fill", label: "nutrition.fats".localizedString, value: "\(fatsTarget)g", color: .purple)
                            }
                        }
                        .padding(16)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                        .padding(.horizontal)

                        // Meals
                        if !meals.isEmpty {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("nutrition.meals_for_day".localizedString)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .padding(.horizontal)

                                ForEach(meals) { meal in
                                    MealDetailCard(meal: meal)
                                        .padding(.horizontal)
                                }
                            }
                        } else {
                            VStack(spacing: 12) {
                                Image(systemName: "fork.knife.circle")
                                    .font(.system(size: 48))
                                    .foregroundColor(.white.opacity(0.3))
                                Text("nutrition.no_meals_planned".localizedString)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(40)
                        }

                        Spacer(minLength: 40)
                    }
                    .padding(.top)
                }
            }
            .navigationTitle(dayName)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
    }
}

// MARK: - Nutrition Target Card
struct NutritionTargetCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.15))
                    .frame(width: 38, height: 38)
                Image(systemName: icon)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(color)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(value)
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                Text(label)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
            }

            Spacer()
        }
        .padding(12)
        .frame(maxWidth: .infinity)
        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.04)))
    }
}

// MARK: - Meal Detail Card
struct MealDetailCard: View {
    let meal: AppMeal

    private var mealIcon: String {
        let type = meal.meal_type ?? meal.name.lowercased()
        switch type {
        case "breakfast", "petit-déjeuner", "petit déjeuner": return "sunrise.fill"
        case "lunch", "déjeuner": return "sun.max.fill"
        case "dinner", "dîner": return "moon.stars.fill"
        case "snack", "collation", "goûter": return "cup.and.saucer.fill"
        default: return "fork.knife"
        }
    }

    private var mealColor: Color {
        let type = meal.meal_type ?? meal.name.lowercased()
        switch type {
        case "breakfast", "petit-déjeuner", "petit déjeuner": return .orange
        case "lunch", "déjeuner": return .yellow
        case "dinner", "dîner": return .indigo
        case "snack", "collation", "goûter": return .pink
        default: return .orange
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(mealColor.opacity(0.2))
                        .frame(width: 42, height: 42)
                    Image(systemName: mealIcon)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(mealColor)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(meal.name)
                        .font(.headline)
                        .foregroundColor(.white)

                    HStack(spacing: 8) {
                        Text("\(meal.items.count) items")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.5))
                        if let cal = meal.estimated_calories, cal > 0 {
                            Text("~\(cal) kcal")
                                .font(.caption.bold())
                                .foregroundColor(mealColor)
                        }
                    }
                }
                Spacer()
            }

            VStack(alignment: .leading, spacing: 8) {
                if let details = meal.food_details, !details.isEmpty {
                    ForEach(details) { detail in
                        HStack(spacing: 10) {
                            Image(systemName: mealDetailFoodIcon(detail.food_type))
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(mealColor.opacity(0.7))
                                .frame(width: 20)
                            Text(detail.name)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                            Spacer()
                            if let kcal = detail.kcal_per_100g {
                                Text("\(Int(kcal))kcal/100g")
                                    .font(.system(size: 10, weight: .bold, design: .rounded))
                                    .foregroundColor(.white.opacity(0.35))
                            }
                        }
                    }
                } else {
                    ForEach(meal.items, id: \.self) { item in
                        HStack(spacing: 10) {
                            Circle()
                                .fill(mealColor.opacity(0.5))
                                .frame(width: 5, height: 5)
                            Text(item)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                            Spacer()
                        }
                    }
                }
            }
            .padding(.leading, 22)
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.white.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(mealColor.opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func mealDetailFoodIcon(_ type: String?) -> String {
        switch type {
        case "viande": return "flame.fill"
        case "poisson": return "drop.fill"
        case "legume": return "leaf.fill"
        case "feculent": return "circle.grid.3x3.fill"
        case "fruit": return "heart.circle.fill"
        case "fruit_sec": return "leaf.circle.fill"
        case "laitage": return "mug.fill"
        case "oeuf": return "oval.fill"
        case "plat_principal": return "star.fill"
        case "accompagnement": return "square.grid.2x2.fill"
        case "dessert": return "sparkles"
        default: return "circle.fill"
        }
    }
}

// MARK: - Meal Prep Tips Sheet
struct MealPrepTipsSheet: View {
    @Environment(\.dismiss) private var dismiss

    var tips: [(String, String, String, Color)] {
        [
            ("cart.fill", "nutrition.plan_ahead".localizedString, "nutrition.plan_ahead_desc".localizedString, Color.blue),
            ("clock.fill", "nutrition.batch_cook".localizedString, "nutrition.batch_cook_desc".localizedString, Color.orange),
            ("tray.fill", "nutrition.portion_control".localizedString, "nutrition.portion_control_desc".localizedString, Color.green),
            ("snowflake", "nutrition.freeze_smart".localizedString, "nutrition.freeze_smart_desc".localizedString, Color.cyan),
            ("leaf.fill", "nutrition.fresh_last".localizedString, "nutrition.fresh_last_desc".localizedString, Color.green),
            ("flame.fill", "nutrition.cook_once".localizedString, "nutrition.cook_once_desc".localizedString, Color.red)
        ]
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(hex: "1A1A3E"), Color(hex: "0F0F23")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 16) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(LinearGradient(colors: [.orange, .pink], startPoint: .topLeading, endPoint: .bottomTrailing))
                                    .frame(width: 70, height: 70)
                                Image(systemName: "lightbulb.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white)
                            }

                            Text("nutrition.meal_prep_tips".localizedString)
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            Text("nutrition.save_time_week".localizedString)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .padding(.top, 20)

                        ForEach(tips, id: \.0) { tip in
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(tip.3.opacity(0.2))
                                        .frame(width: 48, height: 48)
                                    Image(systemName: tip.0)
                                        .font(.title3)
                                        .foregroundColor(tip.3)
                                }

                                VStack(alignment: .leading, spacing: 3) {
                                    Text(tip.1)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    Text(tip.2)
                                        .font(.subheadline)
                                        .foregroundColor(.white.opacity(0.65))
                                }
                                Spacer()
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 16).fill(Color.white.opacity(0.05)))
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
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
