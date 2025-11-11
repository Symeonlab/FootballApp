import Foundation

// MARK: - Auth Models
struct AuthResponse: Codable {
    let message: String
    let token: String
    let user: APIUser
}

struct APIUser: Codable, Identifiable {
    let id: Int
    let name: String?
    let email: String
    let role: String
    let profile: APIProfile?
}

struct APIProfile: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let is_onboarding_complete: Bool
    
    // All profile fields
    var discipline: String?
    var position: String?
    var in_club: Bool?
    var match_day: String?
    var training_days: [String]?
    var training_focus: String?
    var level: String?
    var has_injury: Bool?
    var injury_location: String?
    var training_location: String?
    var gym_preferences: [String]?
    var cardio_preferences: [String]?
    var outdoor_preferences: [String]?
    var home_preferences: [String]?
    var gender: String?
    var height: Double?
    var weight: Double?
    var age: Int?
    var country: String?
    var region: String?
    var pro_level: String?
    var ideal_weight: Double?
    var birth_date: String?
    var activity_level: String?
    var goal: String?
    var morphology: String?
    var hormonal_issues: String?
    var is_vegetarian: Bool?
    var meals_per_day: String?
    var breakfast_preferences: [String]?
    var bad_habits: [String]?
    var snacking_habits: String?
    var vegetable_consumption: String?
    var fish_consumption: String?
    var meat_consumption: String?
    var dairy_consumption: String?
    var sugary_food_consumption: String?
    var cereal_consumption: String?
    var starchy_food_consumption: String?
    var sugary_drink_consumption: String?
    var egg_consumption: String?
    var fruit_consumption: String?
    var takes_medication: Bool?
    var has_diabetes: Bool?
    var family_history: [String]?
    var medical_history: [String]?
}

struct APIResponseMessage: Codable {
    let message: String
}

// --- ADD THIS STRUCT ---
// This is the response for PUT /api/user/profile
struct UserProfileUpdateResponse: Codable {
    let message: String
    let user: APIUser
}
// --- END OF ADDITION ---

typealias MessageResponse = APIResponseMessage
typealias ErrorResponse = APIError

// MARK: - Onboarding Models
struct OnboardingOption: Codable, Identifiable, Hashable {
    var id: String { key }
    let type: String
    let key: String
    let name: String
}

struct PlayerProfileOption: Codable, Identifiable, Hashable {
    var id: String { key }
    let key: String
    let name: String
    let group: String
}

struct InterestOption: Codable, Identifiable, Hashable {
    var id: String { key }
    let key: String
    let name: String
    let icon: String
}

struct OnboardingDataResponse: Codable {
    let discipline: [OnboardingOption]?
    let level: [OnboardingOption]?
    let goal: [OnboardingOption]?
    let location: [OnboardingOption]?
    let injury_location: [OnboardingOption]?
    let morphology: [OnboardingOption]?
    let activity_level: [OnboardingOption]?
    let hormonal_issues: [OnboardingOption]?
    let interests: [InterestOption]?
    let player_profiles: [String: [PlayerProfileOption]]?
    
    // --- ADD THESE MISSING LINES ---
    let gym_preferences: [OnboardingOption]?
    let cardio_preferences: [OnboardingOption]?
    let outdoor_preferences: [OnboardingOption]?
    let home_preferences: [OnboardingOption]?
    // --- END OF ADDITION ---
}

// This is the data struct you will send TO the API
struct OnboardingData: Codable {
    // Sport
    var discipline: String?
    var position: String?
    var inClub: Bool?
    var matchDay: String?
    var trainingDays: [String]?
    var trainingFocus: String?
    var level: String?
    var hasInjury: Bool?
    var injuryLocation: String?
    var trainingLocation: String?
    var gymPreferences: [String]?
    var cardioPreferences: [String]?
    var outdoorPreferences: [String]?
    var homePreferences: [String]?

    // Personal Info
    var name: String?
    var gender: String?
    var height: Double?
    var weight: Double?
    var age: Int?
    var country: String?
    var region: String?
    var proLevel: String?

    // Nutrition
    var idealWeight: Double?
    var birthDate: Date? // Use Date for the picker
    var activityLevel: String?
    var goal: String?
    var morphology: String?
    var hormonalIssues: String?
    var isVegetarian: Bool?
    var mealsPerDay: String?
    var breakfastPreferences: [String]?
    var badHabits: [String]?
    var snackingHabits: String?
    var vegetableConsumption: String?
    var fishConsumption: String?
    var meatConsumption: String?
    var dairyConsumption: String?
    var sugaryFoodConsumption: String?
    var cerealConsumption: String?
    var starchyFoodConsumption: String?
    var sugaryDrinkConsumption: String?
    var eggConsumption: String?
    var fruitConsumption: String?
    var takesMedication: Bool?
    var hasDiabetes: Bool?
    var familyHistory: [String]?
    var medicalHistory: [String]?
    
    // Add CodingKeys to map to snake_case for your Laravel API
    enum CodingKeys: String, CodingKey {
        case discipline, position, gender, height, weight, age, country, region, goal, morphology, name
        case inClub = "in_club", matchDay = "match_day", trainingDays = "training_days"
        case trainingFocus = "training_focus", hasInjury = "has_injury", injuryLocation = "injury_location"
        case trainingLocation = "training_location", gymPreferences = "gym_preferences"
        case cardioPreferences = "cardio_preferences", outdoorPreferences = "outdoor_preferences"
        case homePreferences = "home_preferences", proLevel = "pro_level", idealWeight = "ideal_weight"
        case birthDate = "birth_date", activityLevel = "activity_level", hormonalIssues = "hormonal_issues"
        case isVegetarian = "is_vegetarian", mealsPerDay = "meals_per_day"
        case breakfastPreferences = "breakfast_preferences", badHabits = "bad_habits"
        case snackingHabits = "snacking_habits", vegetableConsumption = "vegetable_consumption"
        case fishConsumption = "fish_consumption", meatConsumption = "meat_consumption"
        case dairyConsumption = "dairy_consumption", sugaryFoodConsumption = "sugary_food_consumption"
        case cerealConsumption = "cereal_consumption", starchyFoodConsumption = "starchy_food_consumption"
        case sugaryDrinkConsumption = "sugary_drink_consumption", eggConsumption = "egg_consumption"
        case fruitConsumption = "fruit_consumption", takesMedication = "takes_medication"
        case hasDiabetes = "has_diabetes", familyHistory = "family_history", medicalHistory = "medical_history"
    }
}


// MARK: - Main App Models
struct WorkoutSession: Codable, Identifiable {
    let id: Int
    let day: String
    let theme: String
    let warmup: String?
    let finisher: String?
    let exercises: [WorkoutExercise]?
    var is_completed: Bool? // Track if workout is done
    var completion_date: String? // When it was completed
}

struct WorkoutExercise: Codable, Identifiable {
    let id: Int
    let name: String
    let sets: String
    let reps: String
    let recovery: String
    let video_url: String?
    var is_completed: Bool? // Track if exercise is done
    
    // Computed properties for backward compatibility
    var series: Int? {
        // Parse "4 sets" -> 4
        Int(sets.components(separatedBy: " ").first ?? "3")
    }
    
    var repetitions: Int? {
        // Parse "12 reps" -> 12
        Int(reps.components(separatedBy: " ").first ?? "12")
    }
}

struct AppNutritionPlan: Codable {
    let daily_calorie_intake: Double
    let macros: [String: Double]?
    let daily_meals: [AppMeal]?
    let advice: [NutritionAdvice]?
}

struct AppMeal: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let items: [String]
}

struct NutritionAdvice: Codable, Hashable, Identifiable {
    var id: String { condition_name }
    let condition_name: String
    let foods_to_avoid: [String]?
    let foods_to_eat: [String]?
    let prophetic_advice_fr: String?
    let prophetic_advice_ar: String?
    
    enum CodingKeys: String, CodingKey {
        case condition_name
        case foods_to_avoid
        case foods_to_eat
        case prophetic_advice_fr
        case prophetic_advice_ar
    }
    
    // Computed properties for backward compatibility
    var condition: String { condition_name }
    var avoid: [String]? { foods_to_avoid }
    var eat: [String]? { foods_to_eat }
    var prophetic_advice: String? { prophetic_advice_fr }
}

struct APIExercise: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
    let category: String
    let sub_category: String
    let description: String?
    let video_url: String?
    let met_value: Double?
}

struct ToggleFavoriteResponse: Codable {
    let status: String
    let attached: Bool
}

struct ReminderSettings: Codable, Identifiable {
    let id: Int
    var breakfast_enabled: Bool
    var breakfast_time: String
    var lunch_enabled: Bool
    var lunch_time: String
    var dinner_enabled: Bool
    var dinner_time: String
    var workout_enabled: Bool
    var workout_time: String
}

struct UserProgress: Codable, Identifiable {
    let id: Int
    let user_id: Int
    let date: String
    var weight: Double?
    var waist: Double?
    var chest: Double?
    var hips: Double?
    var mood: String?
    var notes: String?
    var workout_completed: String?
}

typealias Exercise = APIExercise
typealias UserProgressLog = UserProgress

struct DashboardMetrics: Codable {
    let stats: DashboardStats?
    let chart: ChartData?
    let my_latest_progress: [UserProgressLog]?
}

struct DashboardStats: Codable {
    let total_users: Int
    let new_users_week: Int
    let total_progress_logs: Int
    let published_posts: Int
}

struct ChartData: Codable {
    let labels: [String]
    let data: [Int]
}
