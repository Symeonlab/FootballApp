//
//  NutritionReelsView.swift
//  FootballApp
//
//  Reels-style scrolling view for nutrition content
//

import SwiftUI

struct NutritionReelsView: View {
    let plan: AppNutritionPlan
    @State private var currentIndex: Int = 0
    @State private var dragOffset: CGFloat = 0
    
    var allReels: [NutritionReel] {
        var reels: [NutritionReel] = []
        
        // Add calorie overview reel
        reels.append(.calorieOverview(plan: plan))
        
        // Add macros reel if available
        if plan.macros != nil {
            reels.append(.macros(plan: plan))
        }
        
        // Add a reel for each meal
        if let meals = plan.daily_meals {
            for meal in meals {
                reels.append(.meal(meal))
            }
        }
        
        // Add a reel for each advice
        if let advice = plan.advice, !advice.isEmpty {
            for item in advice {
                reels.append(.advice(item))
            }
        }
        
        return reels
    }
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                // Background
                Color.black
                    .ignoresSafeArea()
                
                // Reels Content
                TabView(selection: $currentIndex) {
                    ForEach(Array(allReels.enumerated()), id: \.offset) { index, reel in
                        NutritionReelCard(reel: reel, geometry: geometry)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .ignoresSafeArea()
                
                // Top Overlay - Title and Progress
                VStack(spacing: 16) {
                    HStack(spacing: 4) {
                        ForEach(0..<allReels.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentIndex ? Color.white : Color.white.opacity(0.3))
                                .frame(height: 3)
                                .animation(.easeInOut, value: currentIndex)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 8)
                    
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("nutrition.your_plan".localizedString)
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text(reelTitle(for: allReels[currentIndex]))
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text("\(currentIndex + 1)/\(allReels.count)")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.8))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                Capsule()
                                    .fill(.ultraThinMaterial)
                            )
                    }
                    .padding(.horizontal, 20)
                }
                .frame(maxHeight: .infinity, alignment: .top)
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.6), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 200)
                    .ignoresSafeArea(edges: .top),
                    alignment: .top
                )
            }
        }
    }
    
    private func reelTitle(for reel: NutritionReel) -> String {
        switch reel {
        case .calorieOverview:
            return "nutrition.daily_target".localizedString
        case .macros:
            return "nutrition.macronutrients".localizedString
        case .meal(let meal):
            return meal.name
        case .advice(let advice):
            return advice.condition_name
        }
    }
}

// MARK: - Nutrition Reel Type
enum NutritionReel: Identifiable {
    case calorieOverview(plan: AppNutritionPlan)
    case macros(plan: AppNutritionPlan)
    case meal(AppMeal)
    case advice(NutritionAdvice)
    
    var id: String {
        switch self {
        case .calorieOverview:
            return "calorie_overview"
        case .macros:
            return "macros"
        case .meal(let meal):
            return "meal_\(meal.id)"
        case .advice(let advice):
            return "advice_\(advice.id)"
        }
    }
}

// MARK: - Nutrition Reel Card
struct NutritionReelCard: View {
    let reel: NutritionReel
    let geometry: GeometryProxy
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // Gradient Background
            gradientBackground
                .ignoresSafeArea()
            
            // Content
            content
                .padding(.horizontal, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.6).delay(0.1)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    @ViewBuilder
    private var content: some View {
        switch reel {
        case .calorieOverview(let plan):
            CalorieOverviewReelContent(plan: plan, isAnimating: isAnimating)
        case .macros(let plan):
            MacrosReelContent(plan: plan, isAnimating: isAnimating)
        case .meal(let meal):
            MealReelContent(meal: meal, isAnimating: isAnimating)
        case .advice(let advice):
            AdviceReelContent(advice: advice, isAnimating: isAnimating)
        }
    }
    
    private var gradientBackground: LinearGradient {
        switch reel {
        case .calorieOverview:
            return LinearGradient(
                colors: [Color(hex: "FF6B6B"), Color(hex: "FF8E53")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .macros:
            return LinearGradient(
                colors: [Color(hex: "4ECDC4"), Color(hex: "44A08D")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .meal:
            return LinearGradient(
                colors: [Color(hex: "667EEA"), Color(hex: "764BA2")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        case .advice:
            return LinearGradient(
                colors: [Color(hex: "F093FB"), Color(hex: "F5576C")],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Calorie Overview Reel Content
struct CalorieOverviewReelContent: View {
    let plan: AppNutritionPlan
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Main Calorie Display
            VStack(spacing: 16) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.3), radius: 20)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("\(Int(plan.daily_calorie_intake))")
                    .font(.system(size: 72, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 10)
                    .offset(y: isAnimating ? 0 : 50)
                    .opacity(isAnimating ? 1 : 0)
                
                Text("nutrition.daily_target".localizedString.uppercased())
                    .font(.title3.weight(.semibold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            // Supporting Text
            VStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "target")
                        .foregroundColor(.white.opacity(0.8))
                    Text("nutrition.personalized_target".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                HStack(spacing: 8) {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundColor(.white.opacity(0.8))
                    Text("nutrition.optimized_goals".localizedString)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .offset(y: isAnimating ? 0 : 30)
            .opacity(isAnimating ? 1 : 0)
            
            Spacer()
        }
    }
}

// MARK: - Macros Reel Content
struct MacrosReelContent: View {
    let plan: AppNutritionPlan
    let isAnimating: Bool
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 20) {
                Text("nutrition.macronutrients".localizedString.uppercased())
                    .font(.title2.weight(.bold))
                    .foregroundColor(.white)
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : -30)
                    .opacity(isAnimating ? 1 : 0)
                
                if let macros = plan.macros {
                    VStack(spacing: 24) {
                        ReelMacroRow(
                            icon: "🥩",
                            name: "nutrition.protein".localizedString.uppercased(),
                            value: Int(macros["protein_grams"] ?? macros["protein"] ?? 0),
                            color: .red,
                            delay: 0.1,
                            isAnimating: isAnimating
                        )

                        ReelMacroRow(
                            icon: "🍞",
                            name: "nutrition.carbs".localizedString.uppercased(),
                            value: Int(macros["carb_grams"] ?? macros["carbs"] ?? 0),
                            color: .blue,
                            delay: 0.2,
                            isAnimating: isAnimating
                        )

                        ReelMacroRow(
                            icon: "🥑",
                            name: "nutrition.fats".localizedString.uppercased(),
                            value: Int(macros["fat_grams"] ?? macros["fats"] ?? 0),
                            color: .orange,
                            delay: 0.3,
                            isAnimating: isAnimating
                        )
                    }
                }
            }
            
            Spacer()
        }
    }
}

struct ReelMacroRow: View {
    let icon: String
    let name: String
    let value: Int
    let color: Color
    let delay: Double
    let isAnimating: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Text(icon)
                .font(.system(size: 40))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.caption.weight(.semibold))
                    .foregroundColor(.white.opacity(0.8))
                    .tracking(1)
                
                Text("\(value)g")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
            }
            
            Spacer()
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.15))
                .shadow(color: .black.opacity(0.1), radius: 10)
        )
        .offset(x: isAnimating ? 0 : -50)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

// MARK: - Meal Reel Content
struct MealReelContent: View {
    let meal: AppMeal
    let isAnimating: Bool
    
    var mealIcon: String {
        switch meal.name.lowercased() {
        case let name where name.contains("breakfast"): return "sunrise.fill"
        case let name where name.contains("lunch"): return "sun.max.fill"
        case let name where name.contains("dinner"): return "moon.stars.fill"
        case let name where name.contains("snack"): return "leaf.fill"
        default: return "fork.knife"
        }
    }
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Meal Header
            VStack(spacing: 16) {
                Image(systemName: mealIcon)
                    .font(.system(size: 60))
                    .foregroundColor(.white)
                    .shadow(color: .white.opacity(0.3), radius: 15)
                    .scaleEffect(isAnimating ? 1.0 : 0.5)
                    .opacity(isAnimating ? 1 : 0)
                
                Text(meal.name.uppercased())
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(2)
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
            }
            
            // Food Items
            VStack(spacing: 16) {
                ForEach(Array(meal.items.enumerated()), id: \.offset) { index, item in
                    HStack(spacing: 12) {
                        Circle()
                            .fill(.white.opacity(0.3))
                            .frame(width: 8, height: 8)
                        
                        Text(item)
                            .font(.title3.weight(.medium))
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16, style: .continuous)
                            .fill(.white.opacity(0.15))
                    )
                    .offset(x: isAnimating ? 0 : -50)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(
                        .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(index) * 0.1 + 0.2),
                        value: isAnimating
                    )
                }
            }
            
            Spacer()
        }
    }
}

// MARK: - Advice Reel Content
struct AdviceReelContent: View {
    let advice: NutritionAdvice
    let isAnimating: Bool
    
    var conditionIcon: String {
        switch advice.condition_name.uppercased() {
        case let name where name.contains("DIABÈTE") || name.contains("DIABETES"):
            return "heart.text.square.fill"
        case let name where name.contains("OBÉSITÉ") || name.contains("SURPOIDS"):
            return "figure.walk"
        case let name where name.contains("DIGESTIF"):
            return "stomach.fill"
        default:
            return "leaf.fill"
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 32) {
                Spacer()
                    .frame(height: 100)
                
                // Header
                VStack(spacing: 16) {
                    Image(systemName: conditionIcon)
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                        .shadow(color: .white.opacity(0.3), radius: 15)
                        .scaleEffect(isAnimating ? 1.0 : 0.5)
                        .opacity(isAnimating ? 1 : 0)
                    
                    Text(advice.condition_name)
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .offset(y: isAnimating ? 0 : 30)
                        .opacity(isAnimating ? 1 : 0)
                }
                .padding(.bottom, 20)
                
                // Foods to Avoid
                if let avoid = advice.foods_to_avoid, !avoid.isEmpty {
                    AdviceSection(
                        title: "AVOID",
                        icon: "xmark.circle.fill",
                        items: avoid,
                        color: .red,
                        isAnimating: isAnimating,
                        delay: 0.2
                    )
                }
                
                // Foods to Eat
                if let eat = advice.foods_to_eat, !eat.isEmpty {
                    AdviceSection(
                        title: "nutrition.recommended".localizedString.uppercased(),
                        icon: "checkmark.circle.fill",
                        items: eat,
                        color: .green,
                        isAnimating: isAnimating,
                        delay: 0.4
                    )
                }
                
                // Prophetic Advice
                if let propheticAdvice = advice.prophetic_advice_fr, !propheticAdvice.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles")
                                .foregroundColor(.yellow)
                            Text("nutrition.traditional_remedies".localizedString.uppercased())
                                .font(.caption.weight(.bold))
                                .foregroundColor(.white.opacity(0.9))
                                .tracking(1)
                        }
                        
                        Text(propheticAdvice)
                            .font(.body)
                            .foregroundColor(.white.opacity(0.9))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(.white.opacity(0.2))
                    )
                    .offset(y: isAnimating ? 0 : 30)
                    .opacity(isAnimating ? 1 : 0)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6), value: isAnimating)
                }
                
                Spacer()
                    .frame(height: 100)
            }
            .padding(.horizontal, 24)
        }
    }
}

struct AdviceSection: View {
    let title: String
    let icon: String
    let items: [String]
    let color: Color
    let isAnimating: Bool
    let delay: Double
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .foregroundColor(color)
                Text(title)
                    .font(.caption.weight(.bold))
                    .foregroundColor(.white.opacity(0.9))
                    .tracking(1)
            }
            
            VStack(spacing: 8) {
                ForEach(items, id: \.self) { item in
                    HStack(spacing: 10) {
                        Circle()
                            .fill(color.opacity(0.6))
                            .frame(width: 6, height: 6)
                        
                        Text(item)
                            .font(.subheadline)
                            .foregroundColor(.white)
                        
                        Spacer()
                    }
                }
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.white.opacity(0.15))
        )
        .offset(y: isAnimating ? 0 : 30)
        .opacity(isAnimating ? 1 : 0)
        .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay), value: isAnimating)
    }
}

// MARK: - Preview
#Preview {
    NutritionReelsView(
        plan: AppNutritionPlan(
            daily_calorie_intake: 2500,
            macros: ["protein": 150, "carbs": 280, "fats": 80],
            daily_meals: [
                AppMeal(name: "Breakfast", items: ["Eggs", "Toast", "Yogurt"]),
                AppMeal(name: "Lunch", items: ["Chicken", "Rice", "Vegetables"])
            ],
            advice: [
                NutritionAdvice(
                    condition_name: "DIABÈTE",
                    foods_to_avoid: ["Sugar", "White bread"],
                    foods_to_eat: ["Vegetables", "Whole grains"],
                    prophetic_advice_fr: "Fenugrec",
                    prophetic_advice_ar: nil
                )
            ]
        )
    )
}
