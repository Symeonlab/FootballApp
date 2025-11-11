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
    
    private var cancellables = Set<AnyCancellable>()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "Nutrition")
    
    init() {
        // Lazy fetch on appear/refresh
    }
    
    func fetchNutritionPlan() {
        logger.info("🍎 Fetching nutrition plan from API...")
        isLoading = true
        errorMessage = nil
        
        APIService.shared.request(endpoint: "/api/nutrition-plan", method: "GET")
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
            }, receiveValue: { [weak self] (plan: AppNutritionPlan) in
                guard let self = self else { return }
                self.nutritionPlan = plan
                self.logger.info("📊 Nutrition plan loaded:")
                self.logger.info("   - Daily calories: \(plan.daily_calorie_intake)")
                self.logger.info("   - Meals: \(plan.daily_meals?.count ?? 0)")
                self.logger.info("   - Advice items: \(plan.advice?.count ?? 0)")
                
                // Log advice details
                if let advice = plan.advice {
                    for item in advice {
                        self.logger.debug("   - Condition: \(item.condition_name)")
                    }
                }
            })
            .store(in: &cancellables)
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

