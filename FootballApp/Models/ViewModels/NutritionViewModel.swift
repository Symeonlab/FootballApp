//
//  NutritionViewModel.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import Foundation
import Combine
import os.log
import SwiftUI

final class NutritionViewModel: ObservableObject {
    @Published var nutritionPlan: AppNutritionPlan?
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var showAddMeal: Bool = false
    @Published var meals: [Meal] = []
    @Published var waterGlasses: Int = 0

    // Daily Goals
    @Published var caloriesConsumed: Int = 0
    @Published var caloriesTarget: Int = 2500
    @Published var proteinConsumed: Int = 0
    @Published var proteinTarget: Int = 150
    @Published var carbsConsumed: Int = 0
    @Published var carbsTarget: Int = 250
    @Published var fatsConsumed: Int = 0
    @Published var fatsTarget: Int = 70
    @Published var waterGoal: Int = 8
    @Published var waterTarget: Int = 8

    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "Nutrition")
    private let api = APIService.shared

    // Preview detection
    private var isPreview: Bool {
        ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
    }

    // MARK: - Computed Properties
    var nutritionProgress: Double {
        guard caloriesTarget > 0 else { return 0 }
        return Double(caloriesConsumed) / Double(caloriesTarget)
    }

    // Daily calorie target from nutrition plan
    var dailyCalories: Int {
        if let plan = nutritionPlan {
            return Int(plan.daily_calorie_intake)
        }
        return caloriesTarget
    }

    @MainActor
    init() {
        logger.info("🍎 NutritionViewModel initialized (Preview: \(self.isPreview))")

        if isPreview {
            logger.info("⚠️ Running in preview mode - loading mock data")
            loadMockData()
        }
    }

    // MARK: - Mock Data for Preview
    @MainActor
    func loadMockData() {
        logger.info("📦 Loading mock nutrition data")

        let mockMeals = [
            AppMeal(
                name: "Breakfast",
                items: ["150g fromage blanc", "100g flocon d'avoine", "1 banane"],
                meal_type: "breakfast",
                estimated_calories: 625,
                food_details: [
                    FoodDetail(name: "150g fromage blanc", kcal_per_100g: 98, food_type: "laitage"),
                    FoodDetail(name: "100g flocon d'avoine", kcal_per_100g: 367, food_type: "feculent"),
                    FoodDetail(name: "1 banane", kcal_per_100g: 89, food_type: "fruit")
                ]
            ),
            AppMeal(
                name: "Lunch",
                items: ["Filet de poulet", "Riz basmati", "Haricots verts", "Yaourt nature"],
                meal_type: "lunch",
                estimated_calories: 875,
                food_details: [
                    FoodDetail(name: "Filet de poulet", kcal_per_100g: 165, food_type: "viande"),
                    FoodDetail(name: "Riz basmati", kcal_per_100g: 130, food_type: "feculent"),
                    FoodDetail(name: "Haricots verts", kcal_per_100g: 31, food_type: "legume"),
                    FoodDetail(name: "Yaourt nature", kcal_per_100g: 61, food_type: "laitage")
                ]
            ),
            AppMeal(
                name: "Dinner",
                items: ["Pavé de saumon", "Quinoa", "Brocoli", "Compote"],
                meal_type: "dinner",
                estimated_calories: 750,
                food_details: [
                    FoodDetail(name: "Pavé de saumon", kcal_per_100g: 208, food_type: "poisson"),
                    FoodDetail(name: "Quinoa", kcal_per_100g: 120, food_type: "feculent"),
                    FoodDetail(name: "Brocoli vapeur", kcal_per_100g: 34, food_type: "legume"),
                    FoodDetail(name: "Compote de pomme", kcal_per_100g: 68, food_type: "dessert")
                ]
            ),
            AppMeal(
                name: "Snack",
                items: ["50g d'amandes", "1 pomme"],
                meal_type: "snack",
                estimated_calories: 250,
                food_details: [
                    FoodDetail(name: "50g d'amandes", kcal_per_100g: 634, food_type: "fruit_sec"),
                    FoodDetail(name: "1 pomme", kcal_per_100g: 53, food_type: "fruit")
                ]
            )
        ]

        let mockAdvice = [
            NutritionAdvice(
                condition_name: "General Health",
                foods_to_avoid: ["Processed foods", "Sugary drinks"],
                foods_to_eat: ["Fruits", "Vegetables", "Whole grains"],
                prophetic_advice_fr: "Eat moderately - fill 1/3 with food, 1/3 with water, leave 1/3 empty.",
                prophetic_advice_ar: nil
            )
        ]

        self.nutritionPlan = AppNutritionPlan(
            daily_calorie_intake: 2500,
            macros: ["protein_grams": 188, "carb_grams": 250, "fat_grams": 83],
            daily_meals: mockMeals,
            advice: mockAdvice
        )

        self.caloriesTarget = 2500
        self.caloriesConsumed = 1800
        self.proteinTarget = 150
        self.proteinConsumed = 110
        self.carbsTarget = 250
        self.carbsConsumed = 180
        self.fatsTarget = 70
        self.fatsConsumed = 45
        self.waterGlasses = 5

        logger.info("✅ Loaded mock nutrition data")
    }

    // MARK: - API Methods (Combine-based for backward compatibility)
    func fetchNutritionPlan() {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchNutritionPlan() - running in preview mode")
            Task { @MainActor in loadMockData() }
            return
        }

        logger.info("🍎 Fetching nutrition plan from API...")
        isLoading = true
        errorMessage = nil

        let publisher: AnyPublisher<GenericAPIResponse<AppNutritionPlan>, Error> = api.request(endpoint: "/api/nutrition-plan", method: "GET")
        publisher
            .sink(receiveCompletion: { [weak self] completion in
                guard let self = self else { return }
                self.isLoading = false

                switch completion {
                case .finished:
                    self.logger.info("✅ Nutrition plan fetched successfully")
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.logger.error("❌ Error fetching nutrition plan: \(error.localizedDescription)")

                    // Log more details for APIError
                    if let apiError = error as? APIError {
                        self.logger.error("   API Error: \(apiError.message)")
                        if let validationErrors = apiError.errors {
                            self.logger.error("   Validation errors: \(String(describing: validationErrors))")
                        }
                    }
                }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                let plan = response.data
                self.nutritionPlan = plan
                self.updateTargetsFromPlan(plan)
                #if DEBUG
                self.logger.info("Nutrition plan loaded: \(Int(plan.daily_calorie_intake)) kcal, \(plan.daily_meals?.count ?? 0) meals")
                #endif
            })
            .store(in: &cancellables)
    }

    // MARK: - Async/Await API Methods
    func fetchNutritionPlanAsync() async {
        // Skip API calls in preview
        guard !isPreview else {
            logger.info("⚠️ Skipping fetchNutritionPlanAsync() - running in preview mode")
            await MainActor.run { loadMockData() }
            return
        }

        logger.info("🍎 Fetching nutrition plan from API (async)...")

        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        do {
            let plan: AppNutritionPlan = try await api.getNutritionPlan()

            await MainActor.run {
                self.nutritionPlan = plan
                self.updateTargetsFromPlan(plan)
                self.isLoading = false

                self.logger.info("✅ Nutrition plan fetched successfully")
                self.logger.info("📊 Daily calories: \(plan.daily_calorie_intake)")
                self.logger.info("   - Meals: \(plan.daily_meals?.count ?? 0)")
                self.logger.info("   - Advice items: \(plan.advice?.count ?? 0)")
            }
        } catch {
            await MainActor.run {
                self.errorMessage = error.localizedDescription
                self.isLoading = false
            }
            logger.error("❌ Failed to fetch nutrition plan: \(error.localizedDescription)")
        }
    }

    // MARK: - Helpers
    private func updateTargetsFromPlan(_ plan: AppNutritionPlan) {
        caloriesTarget = Int(plan.daily_calorie_intake)

        if let macros = plan.macros {
            // API returns protein_grams, carb_grams, fat_grams
            // Also support legacy keys: protein, carbs, fats
            if let protein = macros["protein_grams"] ?? macros["protein"] {
                proteinTarget = Int(protein)
            }
            if let carbs = macros["carb_grams"] ?? macros["carbs"] {
                carbsTarget = Int(carbs)
            }
            if let fats = macros["fat_grams"] ?? macros["fats"] {
                fatsTarget = Int(fats)
            }
        }
    }
}

// MARK: - Supporting Models
struct Meal: Identifiable, Codable {
    let id: UUID
    let name: String
    let type: String
    let time: String
    let calories: Int
    let protein: Int
    let carbs: Int
    let fats: Int
    
    init(id: UUID = UUID(), name: String, type: String, time: String, calories: Int, protein: Int, carbs: Int, fats: Int) {
        self.id = id
        self.name = name
        self.type = type
        self.time = time
        self.calories = calories
        self.protein = protein
        self.carbs = carbs
        self.fats = fats
    }
}

