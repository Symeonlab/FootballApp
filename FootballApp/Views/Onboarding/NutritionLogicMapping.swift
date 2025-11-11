//
//  NutritionLogicMapping.swift
//  FootballApp
//
//  Nutrition logic and food combination rules based on Prophetic Medicine
//

import Foundation

// MARK: - Nutrition Logic Helpers

struct NutritionLogicHelper {
    
    // MARK: - Breakfast Combinations Logic
    /// Returns true if breakfast combination is valid
    static func isValidBreakfastCombination(_ items: Set<String>) -> Bool {
        // BREAD RULES
        if items.contains("BREAD") {
            // Bread alone is NOT allowed
            if items.count == 1 { return false }
        }
        
        // TEA + COFFEE together is NOT allowed
        if items.contains("TEA") && items.contains("COFFEE") {
            return false
        }
        
        // CHOCOLATE is only allowed with MILK
        if items.contains("HOT_CHOCOLATE") && !items.contains("MILK") {
            return false
        }
        
        // EGGS should not be with MILK
        if items.contains("EGGS") && items.contains("MILK") {
            return false
        }
        
        // FRUITS with FRUIT_JUICE is not recommended (redundant)
        if items.contains("FRUITS") && items.contains("FRUIT_JUICE") {
            return false
        }
        
        return true
    }
    
    // MARK: - Meal Combinations Logic
    
    /// Entrée (Starter) combinations
    enum EntreeCategory {
        case type1  // Alone or with type2
        case type2  // With all
        case type3  // Alone or with type2
        case type4  // Not with type3/5 (eggs)
        case type5  // Not with type4
    }
    
    /// Plats (Main dishes) with accompaniment requirements
    enum PlatCategory {
        case withAccompaniment  // types 1,3,4,5,6,7
        case withoutAccompaniment  // type 2
    }
    
    /// Accompaniment combinations
    static func canCombineAccompaniments(_ acc1: String, _ acc2: String) -> Bool {
        let incompatiblePairs: [(String, String)] = [
            ("ACC3", "ACC5"),  // Type 3 can't mix with type 5
            ("ACC4", "ACC5")   // Type 4 can't mix with type 5
        ]
        
        for pair in incompatiblePairs {
            if (acc1 == pair.0 && acc2 == pair.1) || (acc1 == pair.1 && acc2 == pair.0) {
                return false
            }
        }
        
        return true
    }
    
    /// Dessert rules
    static func isValidDessertWithMeal(dessert: String, hadMeat: Bool, isEvening: Bool) -> Bool {
        // If had meat, no cheese desserts
        if hadMeat && dessert.contains("CHEESE") {
            return false
        }
        
        // No fruits in evening
        if isEvening && dessert.contains("FRUIT") {
            return false
        }
        
        // Dessert type 3 doesn't mix with type 1
        // (Implement based on your dessert type system)
        
        return true
    }
    
    // MARK: - Food Restrictions by Medical Condition
    
    /// Get foods to avoid based on medical conditions
    static func getFoodsToAvoid(for conditions: [String]) -> [String] {
        var avoidList: Set<String> = []
        
        for condition in conditions {
            switch condition {
            case "OBESITY":
                avoidList.formUnion(["MEAT", "DESSERTS", "CHEESE", "YOGURT", "MILK", "PASTRIES", "RICE", "PASTA"])
                
            case "DIABETES":
                // Diabetes has allowed foods, not restrictions
                break
                
            case "CROHNS":
                avoidList.formUnion(["WHOLE_MILK", "CITRUS_YOGURT", "FATTY_MEAT", "FRIED_EGGS", "WHOLE_GRAINS", 
                                    "NUTS", "CRUCIFEROUS_VEGETABLES", "RICE", "ONIONS", "GARLIC", "PEPPERS", "COFFEE", "TEA"])
                
            case "CELIAC":
                avoidList.formUnion(["COUSCOUS", "PASTA", "BREAD", "PIZZA"])
                
            case "RHEUMATISM":
                avoidList.formUnion(["RED_MEAT", "SHELLFISH", "WHITE_BREAD", "DESSERTS"])
                
            case "PSORIASIS":
                avoidList.formUnion(["DESSERTS", "WHITE_BREAD", "PASTRIES", "RED_MEAT"])
                
            case "KIDNEY":
                avoidList.formUnion(["MEAT", "CHEESE", "EGGS", "CEREALS_RICE", "CEREALS_PASTA"])
                
            case "LACTOSE_INTOLERANCE":
                avoidList.formUnion(["CHEESE", "MILK", "YOGURT"])
                
            case "ECZEMA":
                avoidList.formUnion(["DESSERTS", "PASTRIES", "BREAD", "FRUIT_JUICE"])
                
            case "URTICARIA":
                avoidList.formUnion(["COFFEE", "CHEESE", "FISH", "EGGS", "NUTS", "SEAFOOD", "MILK", "WHEAT"])
                
            case "ASTHMA":
                avoidList.formUnion(["DESSERTS", "FRUIT_JUICE", "PASTRIES"])
                
            case "DIGESTIVE_INFECTIONS":
                avoidList.formUnion(["RED_MEAT", "SHELLFISH", "FISH", "CORN"])
                
            case "DIGESTION_TROUBLES":
                avoidList.formUnion(["COFFEE", "TEA", "CHEESE", "RAW_VEGETABLES", "CABBAGE", "TOMATOES", 
                                    "FRUIT_JUICE", "BREAD"])
                
            case "FATIGUE":
                // Has allowed foods, not restrictions
                break
                
            case "MOOD_DISORDERS":
                avoidList.formUnion(["DESSERTS", "PASTRIES", "FRUIT_JUICE_EXCEPT_ORANGE"])
                
            case "REPEATED_INFECTIONS":
                avoidList.formUnion(["RED_MEAT", "PASTRIES", "DESSERTS", "SHRIMP", "LOBSTER", "MUSSELS", 
                                    "HERRING", "SARDINES", "MACKEREL"])
                
            case "SKIN_TROUBLES":
                avoidList.formUnion(["DESSERTS", "PASTRIES", "MILK", "YOGURT"])
                
            case "JOINT_PAIN":
                avoidList.formUnion(["WHEAT", "BARLEY", "RYE", "DESSERTS", "PASTRIES", "MEAT"])
                
            case "MIGRAINES":
                avoidList.formUnion(["CHEESE", "DESSERTS", "PASTRIES"])
                
            case "HYPERTENSION":
                avoidList.formUnion(["RED_MEAT", "YOGURT", "MILK", "DESSERTS", "CHEESE", "WHITE_RICE", 
                                    "FRUIT_JUICE", "BANANA"])
                
            case "CHOLESTEROL":
                avoidList.formUnion(["POTATOES", "BREAD", "MEAT", "SHRIMP", "LANGOUSTINES", "MACKEREL"])
                
            case "TRIGLYCERIDES":
                avoidList.formUnion(["MEAT", "BREAD"])
                // Only eat 2 times per week
                
            case "VITAMIN_DEFICIENCY":
                avoidList.formUnion(["BREAD", "DRIED_FRUITS", "WHEAT", "LEGUMES", "TEA", "BEANS", "NUTS", "BEETS"])
                
            case "SLEEP_DISORDERS":
                avoidList.formUnion(["COFFEE", "TEA"])
                // Don't eat too much in evening
                
            case "TRANSIT_TROUBLES":
                avoidList.formUnion(["CHEESE", "RAW_VEGETABLES", "TOMATOES", "DESSERTS", "MILK", "YOGURT", 
                                    "PASTA", "BREAD", "SEMOLINA", "ASPARAGUS", "CABBAGE", "BROCCOLI", 
                                    "LEEKS", "ARTICHOKE", "LEGUMES", "MEAT"])
                
            default:
                break
            }
        }
        
        return Array(avoidList)
    }
    
    /// Get foods to encourage based on medical conditions
    static func getFoodsToEncourage(for conditions: [String]) -> [String] {
        var encourageList: Set<String> = []
        
        for condition in conditions {
            switch condition {
            case "DIABETES":
                encourageList.formUnion(["FRUITS_5_DAY", "VEGETABLES_5_DAY", "WHOLE_GRAINS", 
                                        "LEGUMES_2_WEEK", "DAIRY_2_DAY", "POULTRY", "FISH", "WATER_1.5L"])
                
            case "FATIGUE":
                encourageList.formUnion(["LEEKS", "ASPARAGUS", "ARTICHOKE", "BANANAS", "BERRIES", 
                                        "BEANS", "VEGETABLES", "QUINOA", "PASTA", "FISH"])
                
            case "HYPERTENSION":
                // Rice/pasta always with vegetables
                encourageList.formUnion(["VEGETABLES_WITH_RICE", "VEGETABLES_WITH_PASTA"])
                
            case "TRIGLYCERIDES":
                encourageList.formUnion(["TEA", "MILK", "VEGETABLES", "FRUITS", "POTATOES", 
                                        "PASTA", "RICE", "LEGUMES"])
                
            case "TRANSIT_TROUBLES":
                encourageList.formUnion(["SOUP"])
                
            default:
                break
            }
        }
        
        return Array(encourageList)
    }
    
    /// Get Prophetic Medicine advice for conditions
    static func getPropheticAdvice(for condition: String) -> String {
        switch condition {
        case "DIABETES":
            return "Fenugrec / Feuilles d'Olivier / Le chromonium / al-ithmid / cossus indien"
            
        case "OBESITY":
            return "Jus de fruits / Jus de dattes / Eau au miel / Poudre de graines de Nigelle Sativa"
            
        case "CROHNS":
            return "La graine de nigelle / Le champignon chinois (chitaké, maitaké, reishi) / Le gattilie / La sauge"
            
        case "RHEUMATISM":
            return "Des Omégas 3 / Le collagène / Le collagène marin / Le glucosamine"
            
        case "PSORIASIS":
            return "La Camomille (huile mélangée avec vaseline) / La réglisse (pommade) / Huile de nigelle"
            
        case "KIDNEY":
            return "Champignon chinois (le riche / cordyceps) / Vitamine B12 / Le ginseng"
            
        case "LACTOSE_INTOLERANCE":
            return "Graines de nigelle / Tisanes de réglisse / Du curcuma"
            
        case "ECZEMA":
            return "L'aloe Véra / La mucopolysaccharide / La camomille"
            
        case "URTICARIA":
            return "Graine de nigelle mélangée au citron et gingembre / La matricaire / La partenelle / La bromélaïne / La pectine / Vitamine B5 / La glutamine / Huiles essentielles d'eucalyptus et menthe poivrée avec crème d'aloe Véra"
            
        case "ASTHMA":
            return "Le miel, le pollen ou la propolis / La réglisse"
            
        case "DIGESTIVE_INFECTIONS":
            return "Le gingembre, la camomille et les graines de fenouil / Charbon végétal / Compléments à base d'artichaut, pissenlit ou boldo"
            
        case "DIGESTION_TROUBLES":
            return "Miel / Le pollen / La taliban / La nigelle / La banane"
            
        case "FATIGUE":
            return "Champignons chinois (chitaké, maitaké, reishi) / Le ginseng / Le maca / L'ashwaganda"
            
        case "REPEATED_INFECTIONS":
            return "Le Chrysanthellum / Infusions de romarin / Cynarine / Feuilles d'artichaut / Gingembre / Jus de betterave et carotte (0.5L/jour) avec orange et miel / Huile de foie de morue / La propolis"
            
        case "SKIN_TROUBLES":
            return "L'huile de cade"
            
        case "JOINT_PAIN":
            return "L'harpagophytum / La capsaïcine / Vitamine B6 et magnésium / Camphre, gaulthérie ou thym"
            
        case "MIGRAINES":
            return "La Camomille / La Camomille Romaine / La Camomille allemande / La Paternelle / Costus indien"
            
        case "HYPERTENSION":
            return "Le Safran / Le fenouil"
            
        case "CHOLESTEROL":
            return "Thé vert / La pomme / Curcuma, pissenlit, radis noir (jus ou ampoule) / Levure de riz rouge"
            
        case "TRANSIT_TROUBLES":
            return "La passiflore, graines de fenouil, camomille ou mélisse / Graines de lin le soir avec yaourt nature / Ampoules d'artichaut"
            
        case "SLEEP_DISORDERS":
            return "15 graines de nigelle dans un verre de lait chaud avec une grande cuillère de miel avant de dormir / La Valerienne"
            
        default:
            return ""
        }
    }
    
    // MARK: - Calorie Calculations
    
    /// Calculate BMR using Harris-Benedict formula
    static func calculateBMR(gender: String, weight: Double, height: Double, age: Int) -> Double {
        if gender == "HOMME" {
            // Men: BMR = 88.362 + (13.397 x weight) + (4.799 x height) - (5.677 x age)
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        } else {
            // Women: BMR = 447.593 + (9.247 x weight) + (3.098 x height) - (4.330 x age)
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    /// Get activity multiplier
    static func getActivityMultiplier(_ activityLevel: String) -> Double {
        switch activityLevel {
        case "SEDENTARY":
            return 1.2  // Little or no exercise
        case "LIGHT":
            return 1.375  // Exercise 1-3 days/week
        case "MODERATE":
            return 1.55  // Exercise 3-5 days/week
        case "VERY_ACTIVE":
            return 1.725  // Exercise 6-7 days/week
        case "EXTREMELY_ACTIVE":
            return 1.9  // Very hard exercise/sports and physical job
        default:
            return 1.55
        }
    }
    
    /// Calculate total daily energy expenditure
    static func calculateTDEE(bmr: Double, activityLevel: String) -> Double {
        return bmr * getActivityMultiplier(activityLevel)
    }
    
    /// Adjust calories for goal
    static func adjustCaloriesForGoal(tdee: Double, goal: String) -> Double {
        switch goal {
        case "WEIGHT_LOSS":
            return tdee * 0.85  // -15% for weight loss
        case "MUSCLE_GAIN":
            return tdee * 1.15  // +15% for muscle gain
        case "MAINTENANCE":
            return tdee  // No change
        default:
            return tdee
        }
    }
    
    /// Calculate macronutrient distribution
    static func calculateMacros(calories: Double, goal: String) -> (protein: Double, carbs: Double, fats: Double) {
        switch goal {
        case "WEIGHT_LOSS":
            // High protein, moderate carbs, low fat
            let protein = calories * 0.35 / 4  // 35% protein, 4 cal/g
            let carbs = calories * 0.40 / 4    // 40% carbs, 4 cal/g
            let fats = calories * 0.25 / 9     // 25% fats, 9 cal/g
            return (protein, carbs, fats)
            
        case "MUSCLE_GAIN":
            // High protein, high carbs, moderate fat
            let protein = calories * 0.30 / 4  // 30% protein
            let carbs = calories * 0.50 / 4    // 50% carbs
            let fats = calories * 0.20 / 9     // 20% fats
            return (protein, carbs, fats)
            
        case "MAINTENANCE":
            // Balanced macros
            let protein = calories * 0.25 / 4  // 25% protein
            let carbs = calories * 0.50 / 4    // 50% carbs
            let fats = calories * 0.25 / 9     // 25% fats
            return (protein, carbs, fats)
            
        default:
            let protein = calories * 0.25 / 4
            let carbs = calories * 0.50 / 4
            let fats = calories * 0.25 / 9
            return (protein, carbs, fats)
        }
    }
}

// MARK: - Example Usage

/*
 // Calculate nutrition plan
 let bmr = NutritionLogicHelper.calculateBMR(
     gender: "HOMME",
     weight: 75,
     height: 180,
     age: 28
 )
 
 let tdee = NutritionLogicHelper.calculateTDEE(
     bmr: bmr,
     activityLevel: "MODERATE"
 )
 
 let targetCalories = NutritionLogicHelper.adjustCaloriesForGoal(
     tdee: tdee,
     goal: "MUSCLE_GAIN"
 )
 
 let macros = NutritionLogicHelper.calculateMacros(
     calories: targetCalories,
     goal: "MUSCLE_GAIN"
 )
 
 // Get restrictions
 let medicalConditions = ["DIABETES", "LACTOSE_INTOLERANCE"]
 let avoid = NutritionLogicHelper.getFoodsToAvoid(for: medicalConditions)
 let encourage = NutritionLogicHelper.getFoodsToEncourage(for: medicalConditions)
 
 // Get Prophetic Medicine advice
 for condition in medicalConditions {
     let advice = NutritionLogicHelper.getPropheticAdvice(for: condition)
     print("\(condition): \(advice)")
 }
 
 // Validate breakfast
 let breakfast: Set<String> = ["BREAD", "BUTTER", "COFFEE"]
 let isValid = NutritionLogicHelper.isValidBreakfastCombination(breakfast)
 */
