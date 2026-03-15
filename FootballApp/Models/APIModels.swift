import Foundation
import SwiftUI

// MARK: - Auth Models
struct AuthResponse: Codable {
    let success: Bool
    let message: String
    let data: AuthData

    // Convenience accessors
    var token: String { data.token }
    var user: APIUser { data.user }
}

struct AuthData: Codable {
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

// Response for PUT /api/user/profile
// API returns: {"success": true, "message": "...", "data": {user object}}
struct UserProfileUpdateResponse: Codable {
    let success: Bool?
    let message: String
    let data: APIUser

    var user: APIUser { data }
}

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
    var hasHormonalIssues: Bool?
    var familyHistory: [String]?
    var medicalHistory: [String]?

    // Onboarding status
    var isOnboardingComplete: Bool?

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
        case hasDiabetes = "has_diabetes", hasHormonalIssues = "has_hormonal_issues"
        case familyHistory = "family_history", medicalHistory = "medical_history"
        case isOnboardingComplete = "is_onboarding_complete"
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
    let metadata: WorkoutSessionMetadata? // Rich session data: zone, RPE, display name, etc.
    var is_completed: Bool? // Track if workout is done
    var completion_date: String? // When it was completed

    // API returns these fields but we don't need them in the app
    private let user_id: Int?
    private let created_at: String?
    private let updated_at: String?

    private enum CodingKeys: String, CodingKey {
        case id, day, theme, warmup, finisher, exercises, metadata
        case is_completed, completion_date
        case user_id, created_at, updated_at
    }

    // MARK: - Convenience Properties

    /// Whether this is a rest day (no training). Uses metadata zone or falls back to theme name matching.
    var isRestDay: Bool {
        if let zone = metadata?.zoneColor, !zone.isEmpty {
            return false // Has a training zone → not a rest day
        }
        let t = theme.lowercased()
        return t.contains("repos") || t.contains("rest") || t == "repos"
    }

    /// The display-friendly theme name. Prefers the metadata display_name, falls back to raw theme.
    var displayThemeName: String {
        metadata?.displayName ?? theme
    }

    /// The session's zone color for UI rendering. Falls back to app primary color.
    var sessionZoneColor: Color {
        metadata?.zoneSwiftUIColor ?? Color.appTheme.primary
    }

    /// The appropriate SF Symbol icon for this session based on zone color.
    var sessionIcon: String {
        if isRestDay { return "moon.zzz.fill" }
        if let icon = metadata?.zoneIcon { return icon }
        // Legacy fallback: string-match on theme name
        let t = theme.lowercased()
        if t.contains("force") || t.contains("strength") { return "dumbbell.fill" }
        if t.contains("cardio") || t.contains("endurance") || t.contains("hiit") { return "figure.run" }
        if t.contains("vitesse") || t.contains("speed") { return "bolt.fill" }
        if t.contains("mobilit") || t.contains("flexibility") || t.contains("récup") { return "figure.flexibility" }
        if t.contains("maison") || t.contains("home") || t.contains("circuit") { return "house.fill" }
        if t.contains("perte") || t.contains("sèche") { return "flame.fill" }
        if t.contains("coordination") || t.contains("proprioception") { return "figure.walk" }
        return "figure.strengthtraining.functional"
    }

    // Memberwise initializer for programmatic creation (previews, tests)
    init(id: Int, day: String, theme: String, warmup: String? = nil, finisher: String? = nil,
         exercises: [WorkoutExercise]? = nil, metadata: WorkoutSessionMetadata? = nil,
         is_completed: Bool? = nil, completion_date: String? = nil) {
        self.id = id
        self.day = day
        self.theme = theme
        self.warmup = warmup
        self.finisher = finisher
        self.exercises = exercises
        self.metadata = metadata
        self.is_completed = is_completed
        self.completion_date = completion_date
        self.user_id = nil
        self.created_at = nil
        self.updated_at = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        day = try container.decode(String.self, forKey: .day)
        theme = try container.decode(String.self, forKey: .theme)
        warmup = try container.decodeIfPresent(String.self, forKey: .warmup)
        finisher = try container.decodeIfPresent(String.self, forKey: .finisher)
        exercises = try container.decodeIfPresent([WorkoutExercise].self, forKey: .exercises)
        metadata = try container.decodeIfPresent(WorkoutSessionMetadata.self, forKey: .metadata)
        is_completed = try container.decodeIfPresent(Bool.self, forKey: .is_completed)
        completion_date = try container.decodeIfPresent(String.self, forKey: .completion_date)
        // Decode but ignore
        user_id = try container.decodeIfPresent(Int.self, forKey: .user_id)
        created_at = try container.decodeIfPresent(String.self, forKey: .created_at)
        updated_at = try container.decodeIfPresent(String.self, forKey: .updated_at)
    }
}

struct WorkoutExercise: Codable, Identifiable {
    let id: Int
    let name: String
    let sets: String
    let reps: String
    let recovery: String
    let video_url: String?
    var is_completed: Bool? // Track if exercise is done

    // API returns this field but we don't need it
    private let workout_session_id: Int?

    private enum CodingKeys: String, CodingKey {
        case id, name, sets, reps, recovery, video_url, is_completed, workout_session_id
    }

    // Memberwise initializer for programmatic creation (previews, tests)
    init(id: Int, name: String, sets: String, reps: String, recovery: String,
         video_url: String? = nil, is_completed: Bool? = nil) {
        self.id = id
        self.name = name
        self.sets = sets
        self.reps = reps
        self.recovery = recovery
        self.video_url = video_url
        self.is_completed = is_completed
        self.workout_session_id = nil
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        sets = try container.decode(String.self, forKey: .sets)
        reps = try container.decode(String.self, forKey: .reps)
        recovery = try container.decode(String.self, forKey: .recovery)
        video_url = try container.decodeIfPresent(String.self, forKey: .video_url)
        is_completed = try container.decodeIfPresent(Bool.self, forKey: .is_completed)
        workout_session_id = try container.decodeIfPresent(Int.self, forKey: .workout_session_id)
    }

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
    let meal_type: String?
    let estimated_calories: Int?
    let food_details: [FoodDetail]?

    // Explicit init for programmatic creation (previews, mock data)
    init(name: String, items: [String], meal_type: String? = nil, estimated_calories: Int? = nil, food_details: [FoodDetail]? = nil) {
        self.name = name
        self.items = items
        self.meal_type = meal_type
        self.estimated_calories = estimated_calories
        self.food_details = food_details
    }
}

struct FoodDetail: Codable, Identifiable, Hashable {
    var id: String { name }
    let name: String
    let kcal_per_100g: Double?
    let food_type: String?

    init(name: String, kcal_per_100g: Double? = nil, food_type: String? = nil) {
        self.name = name
        self.kcal_per_100g = kcal_per_100g
        self.food_type = food_type
    }
}

struct NutritionAdvice: Codable, Hashable, Identifiable {
    var id: String { condition_name }

    // Stored properties matching API response
    let condition_name: String
    let foods_to_avoid: [String]?
    let foods_to_eat: [String]?
    let prophetic_advice_fr: String?
    let prophetic_advice_ar: String?

    // CodingKeys to map API response fields to iOS naming
    enum CodingKeys: String, CodingKey {
        case condition_name = "condition"  // API sends "condition", we store as condition_name
        case foods_to_avoid = "avoid"      // API sends "avoid", we store as foods_to_avoid
        case foods_to_eat = "eat"          // API sends "eat", we store as foods_to_eat
        case prophetic_advice_fr = "prophetic_advice"  // API sends "prophetic_advice"
        case prophetic_advice_ar
    }

    // Explicit initializer for programmatic creation (previews, mock data)
    init(condition_name: String, foods_to_avoid: [String]?, foods_to_eat: [String]?, prophetic_advice_fr: String?, prophetic_advice_ar: String?) {
        self.condition_name = condition_name
        self.foods_to_avoid = foods_to_avoid
        self.foods_to_eat = foods_to_eat
        self.prophetic_advice_fr = prophetic_advice_fr
        self.prophetic_advice_ar = prophetic_advice_ar
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

// MARK: - Goal Models
struct Goal: Codable, Identifiable {
    let id: Int
    let goalType: GoalType
    let goalTypeLabel: String?
    let status: GoalStatus
    let progress: Double
    let expectedProgress: Double?
    let isOnTrack: Bool?
    let targetWeight: Double?
    let targetWaist: Double?
    let targetChest: Double?
    let targetHips: Double?
    let startWeight: Double?
    let startWaist: Double?
    let targetWorkoutsPerWeek: Int?
    let startDate: String?
    let targetDate: String?
    let completedAt: String?
    let weeksCompleted: Int?
    let totalWeeks: Int?
    let achievements: [String]?
    let notes: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case goalType = "goal_type"
        case goalTypeLabel = "goal_type_label"
        case status, progress
        case expectedProgress = "expected_progress"
        case isOnTrack = "is_on_track"
        case targetWeight = "target_weight"
        case targetWaist = "target_waist"
        case targetChest = "target_chest"
        case targetHips = "target_hips"
        case startWeight = "start_weight"
        case startWaist = "start_waist"
        case targetWorkoutsPerWeek = "target_workouts_per_week"
        case startDate = "start_date"
        case targetDate = "target_date"
        case completedAt = "completed_at"
        case weeksCompleted = "weeks_completed"
        case totalWeeks = "total_weeks"
        case achievements, notes
        case createdAt = "created_at"
    }
}

enum GoalType: String, Codable, CaseIterable {
    case weightLoss = "weight_loss"
    case muscleGain = "muscle_gain"
    case maintain = "maintain"
    case custom = "custom"

    var displayName: String {
        switch self {
        case .weightLoss: return "goal.weight_loss".localizedString
        case .muscleGain: return "goal.muscle_gain".localizedString
        case .maintain: return "goal.maintain".localizedString
        case .custom: return "goal.custom".localizedString
        }
    }
}

enum GoalStatus: String, Codable {
    case active
    case completed
    case paused
    case abandoned

    var displayName: String {
        switch self {
        case .active: return "goals.status.active".localizedString
        case .completed: return "goals.status.completed".localizedString
        case .paused: return "goals.status.paused".localizedString
        case .abandoned: return "goals.status.abandoned".localizedString
        }
    }

    var icon: String {
        switch self {
        case .active: return "play.circle.fill"
        case .completed: return "checkmark.circle.fill"
        case .paused: return "pause.circle.fill"
        case .abandoned: return "xmark.circle.fill"
        }
    }

    var color: String {
        switch self {
        case .active: return "4A90E2"
        case .completed: return "4ECB71"
        case .paused: return "FF9F43"
        case .abandoned: return "FF6B6B"
        }
    }
}

struct CreateGoalRequest: Encodable {
    let goalType: String
    let targetWeight: Double?
    let targetWaist: Double?
    let targetChest: Double?
    let targetHips: Double?
    let targetWorkoutsPerWeek: Int?
    let totalWeeks: Int?
    let targetDate: String?
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case goalType = "goal_type"
        case targetWeight = "target_weight"
        case targetWaist = "target_waist"
        case targetChest = "target_chest"
        case targetHips = "target_hips"
        case targetWorkoutsPerWeek = "target_workouts_per_week"
        case totalWeeks = "total_weeks"
        case targetDate = "target_date"
        case notes
    }
}

struct UpdateGoalStatusRequest: Encodable {
    let status: String
}

struct GoalProgressResponse: Decodable {
    let success: Bool
    let message: String?
    let data: GoalProgressData?
}

struct GoalProgressData: Decodable {
    let progress: Double
    let weeksCompleted: Int
    let status: GoalStatus
    let newAchievements: [String]?

    enum CodingKeys: String, CodingKey {
        case progress
        case weeksCompleted = "weeks_completed"
        case status
        case newAchievements = "new_achievements"
    }
}

// MARK: - Achievement Models
struct Achievement: Codable, Identifiable {
    let id: Int
    let key: String
    let name: String
    let description: String
    let icon: String?
    let points: Int
    let category: AchievementCategory
    let earned: Bool?
    let earnedAt: String?
    let earnedByCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, key, name, description, icon, points, category, earned
        case earnedAt = "earned_at"
        case earnedByCount = "earned_by_count"
    }
}

enum AchievementCategory: String, Codable {
    case workout
    case consistency
    case milestone
    case nutrition
    case special
}

struct AchievementsResponse: Decodable {
    let success: Bool
    let data: AchievementsData
}

struct AchievementsData: Decodable {
    let achievements: [Achievement]
    let byCategory: [String: [Achievement]]?
    let totalPoints: Int
    let totalEarned: Int
    let totalAvailable: Int

    enum CodingKeys: String, CodingKey {
        case achievements
        case byCategory = "by_category"
        case totalPoints = "total_points"
        case totalEarned = "total_earned"
        case totalAvailable = "total_available"
    }
}

struct LeaderboardResponse: Decodable {
    let success: Bool
    let data: LeaderboardData
}

struct LeaderboardData: Decodable {
    let leaderboard: [LeaderboardEntry]
    let currentUser: CurrentUserRank

    enum CodingKeys: String, CodingKey {
        case leaderboard
        case currentUser = "current_user"
    }
}

struct LeaderboardEntry: Decodable, Identifiable {
    var id: Int { userId }
    let userId: Int
    let name: String
    let totalPoints: Int
    let achievementCount: Int

    enum CodingKeys: String, CodingKey {
        case userId = "id"
        case name
        case totalPoints = "total_points"
        case achievementCount = "achievement_count"
    }
}

struct CurrentUserRank: Decodable {
    let rank: Int
    let totalPoints: Int
    let achievementCount: Int

    enum CodingKeys: String, CodingKey {
        case rank
        case totalPoints = "total_points"
        case achievementCount = "achievement_count"
    }
}

// MARK: - Post Models
struct Post: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String?
    let excerpt: String?
    let slug: String
    let featuredImage: String?
    let author: String?
    let publishedAt: String
    let readingTime: Int?

    enum CodingKeys: String, CodingKey {
        case id, title, content, excerpt, slug, author
        case featuredImage = "featured_image"
        case publishedAt = "published_at"
        case readingTime = "reading_time"
    }
}

struct PostsResponse: Decodable {
    let success: Bool
    let data: [Post]
    let meta: PaginationMeta?
}

struct PaginationMeta: Decodable {
    let currentPage: Int
    let lastPage: Int
    let perPage: Int
    let total: Int

    enum CodingKeys: String, CodingKey {
        case currentPage = "current_page"
        case lastPage = "last_page"
        case perPage = "per_page"
        case total
    }
}

// MARK: - Dashboard Extended Models
struct DashboardFullResponse: Decodable {
    let success: Bool
    let stats: DashboardStats
    let chart: ChartData
    let myLatestProgress: [UserProgress]
    let activeGoal: ActiveGoalData?
    let achievements: AchievementSummary
    let latestPosts: [PostSummary]

    enum CodingKeys: String, CodingKey {
        case success, stats, chart, achievements
        case myLatestProgress = "my_latest_progress"
        case activeGoal = "active_goal"
        case latestPosts = "latest_posts"
    }
}

struct ActiveGoalData: Decodable {
    let id: Int
    let goalType: GoalType
    let progress: Double
    let isOnTrack: Bool
    let weeksCompleted: Int
    let totalWeeks: Int
    let targetDate: String?

    enum CodingKeys: String, CodingKey {
        case id, progress
        case goalType = "goal_type"
        case isOnTrack = "is_on_track"
        case weeksCompleted = "weeks_completed"
        case totalWeeks = "total_weeks"
        case targetDate = "target_date"
    }
}

struct AchievementSummary: Decodable {
    let totalEarned: Int
    let totalPoints: Int
    let recent: [RecentAchievement]

    enum CodingKeys: String, CodingKey {
        case totalEarned = "total_earned"
        case totalPoints = "total_points"
        case recent
    }
}

struct RecentAchievement: Decodable, Identifiable {
    let id: Int
    let name: String
    let icon: String?
    let points: Int
    let earnedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, icon, points
        case earnedAt = "earned_at"
    }
}

struct PostSummary: Decodable, Identifiable {
    let id: Int
    let title: String
    let slug: String
    let featuredImage: String?
    let publishedAt: String

    enum CodingKeys: String, CodingKey {
        case id, title, slug
        case featuredImage = "featured_image"
        case publishedAt = "published_at"
    }
}

// MARK: - Generic API Response
struct GenericAPIResponse<T: Decodable>: Decodable {
    let success: Bool
    let data: T
    let message: String?
}

// Generic API Response with optional data (for endpoints that may return null data)
struct GenericAPIResponseOptional<T: Decodable>: Decodable {
    let success: Bool
    let data: T?
    let message: String?
}

// MARK: - Feedback Models

/// Categories of feedback questions
enum FeedbackCategory: String, Codable, CaseIterable, Identifiable {
    case footballGoalkeeper = "football_goalkeeper"
    case footballDefender = "football_defender"
    case footballMidfielder = "football_midfielder"
    case footballAttacker = "football_attacker"
    case footballAfterMatch = "football_after_match"
    case footballWeeklyNoClub = "football_weekly_no_club"
    case fitnessWomen = "fitness_women"
    case fitnessMen = "fitness_men"
    case fitnessWeekly = "fitness_weekly"
    case nutritionWeightLoss = "nutrition_weight_loss"
    case nutritionMuscleGain = "nutrition_muscle_gain"
    case nutritionMaintain = "nutrition_maintain"
    case nutritionProphetic = "nutrition_prophetic"
    case injuryFitness = "injury_fitness"
    case injuryFootball = "injury_football"
    case cognitive = "cognitive"

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .footballGoalkeeper: return "feedback.category.goalkeeper".localizedString
        case .footballDefender: return "feedback.category.defender".localizedString
        case .footballMidfielder: return "feedback.category.midfielder".localizedString
        case .footballAttacker: return "feedback.category.attacker".localizedString
        case .footballAfterMatch: return "feedback.category.after_match".localizedString
        case .footballWeeklyNoClub: return "feedback.category.weekly_no_club".localizedString
        case .fitnessWomen: return "feedback.category.fitness_women".localizedString
        case .fitnessMen: return "feedback.category.fitness_men".localizedString
        case .fitnessWeekly: return "feedback.category.fitness_weekly".localizedString
        case .nutritionWeightLoss: return "feedback.category.nutrition_weight_loss".localizedString
        case .nutritionMuscleGain: return "feedback.category.nutrition_muscle_gain".localizedString
        case .nutritionMaintain: return "feedback.category.nutrition_maintain".localizedString
        case .nutritionProphetic: return "feedback.category.nutrition_prophetic".localizedString
        case .injuryFitness: return "feedback.category.injury_fitness".localizedString
        case .injuryFootball: return "feedback.category.injury_football".localizedString
        case .cognitive: return "feedback.category.cognitive".localizedString
        }
    }

    var icon: String {
        switch self {
        case .footballGoalkeeper: return "hand.raised.fill"
        case .footballDefender: return "shield.fill"
        case .footballMidfielder: return "arrow.left.arrow.right"
        case .footballAttacker: return "sportscourt.fill"
        case .footballAfterMatch: return "flag.checkered"
        case .footballWeeklyNoClub: return "calendar.badge.clock"
        case .fitnessWomen: return "figure.cooldown"
        case .fitnessMen: return "figure.strengthtraining.traditional"
        case .fitnessWeekly: return "chart.bar.fill"
        case .nutritionWeightLoss: return "scalemass.fill"
        case .nutritionMuscleGain: return "bolt.fill"
        case .nutritionMaintain: return "heart.fill"
        case .nutritionProphetic: return "leaf.fill"
        case .injuryFitness, .injuryFootball: return "bandage.fill"
        case .cognitive: return "brain.head.profile"
        }
    }

    /// Returns relevant categories based on user's discipline and goal
    static func relevantCategories(discipline: String?, goal: String?, position: String?, hasInjury: Bool?) -> [FeedbackCategory] {
        var categories: [FeedbackCategory] = []

        if discipline == "football" {
            // Add position-specific feedback
            switch position?.lowercased() {
            case "goalkeeper", "gardien":
                categories.append(.footballGoalkeeper)
            case "defender", "défenseur":
                categories.append(.footballDefender)
            case "midfielder", "milieu":
                categories.append(.footballMidfielder)
            case "attacker", "attaquant":
                categories.append(.footballAttacker)
            default:
                break
            }
            categories.append(.footballAfterMatch)
            categories.append(.footballWeeklyNoClub)

            if hasInjury == true {
                categories.append(.injuryFootball)
            }
        } else {
            // Fitness categories
            categories.append(.fitnessWeekly)

            if hasInjury == true {
                categories.append(.injuryFitness)
            }
        }

        // Add nutrition feedback based on goal
        switch goal?.lowercased() {
        case "weight_loss", "perte_poids", "perte de poids":
            categories.append(.nutritionWeightLoss)
        case "muscle_gain", "masse_musculaire", "prise de masse":
            categories.append(.nutritionMuscleGain)
        case "maintain", "maintien":
            categories.append(.nutritionMaintain)
        default:
            break
        }

        // Always available
        categories.append(.nutritionProphetic)
        categories.append(.cognitive)

        return categories
    }
}

/// A single feedback question
struct FeedbackQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let category: FeedbackCategory
    let questionFr: String
    let questionEn: String?
    let questionAr: String?
    let answerType: FeedbackAnswerType
    let sortOrder: Int?

    enum CodingKeys: String, CodingKey {
        case id, category
        case questionFr = "question_fr"
        case questionEn = "question_en"
        case questionAr = "question_ar"
        case answerType = "answer_type"
        case sortOrder = "sort_order"
    }

    /// Returns the localized question based on current language
    var localizedQuestion: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .arabic:
            return questionAr ?? questionFr
        case .english, .system:
            return questionEn ?? questionFr
        case .french:
            return questionFr
        }
    }
}

/// Types of answers for feedback questions
enum FeedbackAnswerType: String, Codable {
    case scale = "scale"           // 1-10 rating
    case yesNo = "yes_no"          // Boolean
    case text = "text"             // Free text
    case multiChoice = "multi"     // Multiple choice

    var displayOptions: [String]? {
        switch self {
        case .yesNo:
            return ["feedback.answer.yes".localizedString, "feedback.answer.no".localizedString]
        case .scale:
            return nil // Use slider
        default:
            return nil
        }
    }
}

/// User's answer to a feedback question
struct FeedbackAnswer: Codable, Identifiable {
    let id: Int?
    let questionId: Int
    let userId: Int?
    let answerValue: String
    let answerDate: String?
    let sessionId: String?

    enum CodingKeys: String, CodingKey {
        case id
        case questionId = "question_id"
        case userId = "user_id"
        case answerValue = "answer_value"
        case answerDate = "answer_date"
        case sessionId = "session_id"
    }
}

/// Request to submit feedback answers
struct SubmitFeedbackRequest: Encodable {
    let categoryKey: String
    let answers: [FeedbackAnswerInput]
    let sessionId: String?

    enum CodingKeys: String, CodingKey {
        case categoryKey = "category_key"
        case answers
        case sessionId = "session_id"
    }
}

struct FeedbackAnswerInput: Encodable {
    let questionId: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case value
    }
}

/// Response for feedback questions
struct FeedbackQuestionsResponse: Decodable {
    let success: Bool
    let data: [FeedbackQuestion]
}

/// Response for submitting feedback
struct SubmitFeedbackResponse: Decodable {
    let success: Bool
    let message: String?
    let data: FeedbackSummary?
}

/// Summary of feedback session
struct FeedbackSummary: Decodable, Identifiable {
    let id: Int
    let category: FeedbackCategory
    let totalQuestions: Int
    let answeredQuestions: Int
    let averageScore: Double?
    let completedAt: String?
    let insights: [String]?

    enum CodingKeys: String, CodingKey {
        case id, category
        case totalQuestions = "total_questions"
        case answeredQuestions = "answered_questions"
        case averageScore = "average_score"
        case completedAt = "completed_at"
        case insights
    }
}

/// History of feedback sessions
struct FeedbackHistory: Decodable {
    let success: Bool
    let data: [FeedbackSummary]
}

/// API response for feedback categories
struct FeedbackCategoriesResponse: Decodable {
    let success: Bool
    let data: [FeedbackCategoryAPI]
}

/// Category as returned from the API
struct FeedbackCategoryAPI: Decodable {
    let key: String
    let name: String
    let nameFr: String?
    let nameEn: String?
    let nameAr: String?
    let icon: String?
    let questionsCount: Int?

    enum CodingKeys: String, CodingKey {
        case key, name, icon
        case nameFr = "name_fr"
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case questionsCount = "questions_count"
    }
}

/// Feedback statistics response
struct FeedbackStatsResponse: Decodable {
    let success: Bool
    let data: FeedbackStats
}

struct FeedbackStats: Decodable {
    let totalSessions: Int
    let overallAverageScore: Double?
    let byCategory: [FeedbackCategoryStat]

    enum CodingKeys: String, CodingKey {
        case totalSessions = "total_sessions"
        case overallAverageScore = "overall_average_score"
        case byCategory = "by_category"
    }
}

struct FeedbackCategoryStat: Decodable {
    let category: String?
    let categoryName: String?
    let sessionsCount: Int
    let averageScore: Double?

    enum CodingKeys: String, CodingKey {
        case category
        case categoryName = "category_name"
        case sessionsCount = "sessions_count"
        case averageScore = "average_score"
    }
}

// MARK: - Workout Feedback Models

/// Response for fetching post-workout questions from API
struct PostWorkoutQuestionsResponse: Decodable {
    let success: Bool
    let data: PostWorkoutQuestionsData?
}

struct PostWorkoutQuestionsData: Decodable {
    let category: PostWorkoutCategoryInfo
    let questions: [PostWorkoutQuestion]
}

struct PostWorkoutCategoryInfo: Decodable {
    let key: String
    let nameFr: String?
    let nameEn: String?
    let nameAr: String?
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case key, icon
        case nameFr = "name_fr"
        case nameEn = "name_en"
        case nameAr = "name_ar"
    }
}

/// A single post-workout question from the database
struct PostWorkoutQuestion: Decodable, Identifiable, Hashable {
    let id: Int
    let category: String?
    let questionFr: String
    let questionEn: String?
    let questionAr: String?
    let answerType: String        // "scale", "yes_no", "text", "multi"
    let answerOptions: [String: String]?
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id, category
        case questionFr = "question_fr"
        case questionEn = "question_en"
        case questionAr = "question_ar"
        case answerType = "answer_type"
        case answerOptions = "answer_options"
        case sortOrder = "sort_order"
    }

    /// Returns localized question text
    var localizedQuestion: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .arabic:
            return questionAr ?? questionFr
        case .english, .system:
            return questionEn ?? questionFr
        case .french:
            return questionFr
        }
    }
}

/// Request to submit post-workout feedback (supports both modes)
struct WorkoutFeedbackRequest: Encodable {
    let sessionDay: String
    let sessionTheme: String
    let exercisesCompleted: Int
    let elapsedSeconds: Int
    // Questionnaire answers (primary mode — dynamic questions)
    let answers: [WorkoutFeedbackAnswerInput]?
    // Legacy flat fields (fallback)
    let difficultyRating: Int?
    let energyLevel: Int?
    let enjoymentRating: Int?
    let muscleSoreness: Int?
    let soreAreas: [String]?
    let completedAllSets: Bool?
    let skippedReason: String?
    let notes: String?
    let preferredAdjustment: String?

    enum CodingKeys: String, CodingKey {
        case sessionDay = "session_day"
        case sessionTheme = "session_theme"
        case exercisesCompleted = "exercises_completed"
        case elapsedSeconds = "elapsed_seconds"
        case answers
        case difficultyRating = "difficulty_rating"
        case energyLevel = "energy_level"
        case enjoymentRating = "enjoyment_rating"
        case muscleSoreness = "muscle_soreness"
        case soreAreas = "sore_areas"
        case completedAllSets = "completed_all_sets"
        case skippedReason = "skipped_reason"
        case notes
        case preferredAdjustment = "preferred_adjustment"
    }
}

/// A single answer to a questionnaire question
struct WorkoutFeedbackAnswerInput: Encodable {
    let questionId: Int
    let value: String

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case value
    }
}

/// Response from workout feedback submission
struct WorkoutFeedbackResponse: Decodable {
    let success: Bool
    let message: String?
    let data: WorkoutFeedbackData?
}

struct WorkoutFeedbackData: Decodable {
    let feedback: WorkoutFeedbackItem?
    let recommendation: String?
    let adjustments: WorkoutAdjustmentsData?
    let stats: WorkoutFeedbackStats?
}

struct WorkoutAdjustmentsData: Decodable {
    let intensityModifier: Double?
    let exerciseCountDelta: Int?
    let restTimeModifier: Double?
    let confidence: Double?

    enum CodingKeys: String, CodingKey {
        case intensityModifier = "intensity_modifier"
        case exerciseCountDelta = "exercise_count_delta"
        case restTimeModifier = "rest_time_modifier"
        case confidence
    }
}

struct WorkoutFeedbackStats: Decodable {
    let avgDifficulty: Double?
    let avgEnergy: Double?
    let avgEnjoyment: Double?
    let avgSoreness: Double?

    enum CodingKeys: String, CodingKey {
        case avgDifficulty = "avg_difficulty"
        case avgEnergy = "avg_energy"
        case avgEnjoyment = "avg_enjoyment"
        case avgSoreness = "avg_soreness"
    }
}

struct WorkoutFeedbackItem: Decodable, Identifiable {
    let id: Int
    let sessionDay: String
    let sessionTheme: String
    let exercisesCompleted: Int
    let elapsedSeconds: Int
    let difficultyRating: Int?
    let energyLevel: Int?
    let enjoymentRating: Int?
    let muscleSoreness: Int?
    let soreAreas: [String]?
    let completedAllSets: Bool?
    let skippedReason: String?
    let notes: String?
    let preferredAdjustment: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case sessionDay = "session_day"
        case sessionTheme = "session_theme"
        case exercisesCompleted = "exercises_completed"
        case elapsedSeconds = "elapsed_seconds"
        case difficultyRating = "difficulty_rating"
        case energyLevel = "energy_level"
        case enjoymentRating = "enjoyment_rating"
        case muscleSoreness = "muscle_soreness"
        case soreAreas = "sore_areas"
        case completedAllSets = "completed_all_sets"
        case skippedReason = "skipped_reason"
        case notes
        case preferredAdjustment = "preferred_adjustment"
        case createdAt = "created_at"
    }
}

/// Workout adjustment options
enum WorkoutAdjustment: String, CaseIterable {
    case increaseIntensity = "increase_intensity"
    case decreaseIntensity = "decrease_intensity"
    case moreRest = "more_rest"
    case fewerExercises = "fewer_exercises"
    case moreVariety = "more_variety"
    case keepSame = "keep_same"

    var displayName: String {
        switch self {
        case .increaseIntensity: return "workout_feedback.adjust.increase".localizedString
        case .decreaseIntensity: return "workout_feedback.adjust.decrease".localizedString
        case .moreRest: return "workout_feedback.adjust.more_rest".localizedString
        case .fewerExercises: return "workout_feedback.adjust.fewer".localizedString
        case .moreVariety: return "workout_feedback.adjust.variety".localizedString
        case .keepSame: return "workout_feedback.adjust.keep_same".localizedString
        }
    }

    var icon: String {
        switch self {
        case .increaseIntensity: return "arrow.up.circle.fill"
        case .decreaseIntensity: return "arrow.down.circle.fill"
        case .moreRest: return "bed.double.fill"
        case .fewerExercises: return "minus.circle.fill"
        case .moreVariety: return "shuffle"
        case .keepSame: return "checkmark.circle.fill"
        }
    }
}

// MARK: - Health Assessment Models

/// Health Assessment Category
struct HealthAssessmentCategory: Codable, Identifiable, Hashable {
    let id: Int
    let key: String
    let nameFr: String
    let nameEn: String
    let nameAr: String?
    let icon: String?
    let discipline: String?
    let questionsCount: Int?

    enum CodingKeys: String, CodingKey {
        case id, key, icon, discipline
        case nameFr = "name_fr"
        case nameEn = "name_en"
        case nameAr = "name_ar"
        case questionsCount = "questions_count"
    }

    /// Returns localized name based on current language
    var localizedName: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .arabic:
            return nameAr ?? nameFr
        case .english, .system:
            return nameEn
        case .french:
            return nameFr
        }
    }
}

/// Health Assessment Question
struct HealthAssessmentQuestion: Codable, Identifiable, Hashable {
    let id: Int
    let questionFr: String
    let questionEn: String
    let questionAr: String?
    let answerType: String
    let answerOptions: [String: String]?
    let isCritical: Bool
    let sortOrder: Int

    enum CodingKeys: String, CodingKey {
        case id
        case questionFr = "question_fr"
        case questionEn = "question_en"
        case questionAr = "question_ar"
        case answerType = "answer_type"
        case answerOptions = "answer_options"
        case isCritical = "is_critical"
        case sortOrder = "sort_order"
    }

    /// Returns localized question based on current language
    var localizedQuestion: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .arabic:
            return questionAr ?? questionFr
        case .english, .system:
            return questionEn
        case .french:
            return questionFr
        }
    }
}

/// Health Assessment Session
struct HealthAssessmentSession: Codable, Identifiable {
    let id: Int
    let status: String
    let totalQuestions: Int
    let answeredQuestions: Int
    let progressPercentage: Double
    let insights: [String]?
    let recommendations: [String]?
    let startedAt: String?
    let completedAt: String?

    enum CodingKeys: String, CodingKey {
        case id, status, insights, recommendations
        case totalQuestions = "total_questions"
        case answeredQuestions = "answered_questions"
        case progressPercentage = "progress_percentage"
        case startedAt = "started_at"
        case completedAt = "completed_at"
    }

    var isComplete: Bool {
        status == "completed"
    }

    var isInProgress: Bool {
        status == "in_progress" || status == "started"
    }
}

/// Health Assessment Answer Input
struct HealthAssessmentAnswerInput: Encodable {
    let questionId: Int
    let answerValue: String

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case answerValue = "answer_value"
    }
}

/// Submit Health Assessment Request
struct SubmitHealthAssessmentRequest: Encodable {
    let sessionId: Int
    let answers: [HealthAssessmentAnswerInput]
    let isComplete: Bool

    enum CodingKeys: String, CodingKey {
        case sessionId = "session_id"
        case answers
        case isComplete = "is_complete"
    }
}

/// Health Assessment Categories Response
struct HealthAssessmentCategoriesResponse: Decodable {
    let success: Bool
    let data: [HealthAssessmentCategory]
}

/// Health Assessment Questions Response
struct HealthAssessmentQuestionsResponse: Decodable {
    let success: Bool
    let data: HealthAssessmentQuestionsData
}

struct HealthAssessmentQuestionsData: Decodable {
    let category: HealthAssessmentCategory
    let questions: [HealthAssessmentQuestion]
}

/// Full Health Assessment Response (all categories with questions)
struct HealthAssessmentFullResponse: Decodable {
    let success: Bool
    let data: [HealthAssessmentCategoryWithQuestions]
}

struct HealthAssessmentCategoryWithQuestions: Decodable, Identifiable {
    let id: Int
    let key: String
    let nameFr: String
    let nameEn: String
    let nameAr: String?
    let icon: String?
    let discipline: String?
    let questions: [HealthAssessmentQuestion]

    enum CodingKeys: String, CodingKey {
        case id, key, icon, discipline, questions
        case nameFr = "name_fr"
        case nameEn = "name_en"
        case nameAr = "name_ar"
    }

    var localizedName: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .arabic:
            return nameAr ?? nameFr
        case .english, .system:
            return nameEn
        case .french:
            return nameFr
        }
    }
}

/// Start Session Response
struct HealthAssessmentStartResponse: Decodable {
    let success: Bool
    let message: String?
    let data: HealthAssessmentSession
}

/// Submit Session Response
struct HealthAssessmentSubmitResponse: Decodable {
    let success: Bool
    let message: String?
    let data: HealthAssessmentSession
}

/// Health Assessment History Response
struct HealthAssessmentHistoryResponse: Decodable {
    let success: Bool
    let data: [HealthAssessmentSession]
}

/// Health Assessment Session Detail Response
struct HealthAssessmentSessionDetailResponse: Decodable {
    let success: Bool
    let data: HealthAssessmentSessionDetail
}

struct HealthAssessmentSessionDetail: Decodable {
    let session: HealthAssessmentSession
    let answersByCategory: [String: HealthAssessmentCategoryAnswers]

    enum CodingKeys: String, CodingKey {
        case session
        case answersByCategory = "answers_by_category"
    }
}

struct HealthAssessmentCategoryAnswers: Decodable {
    let category: HealthAssessmentCategoryInfo?
    let answers: [HealthAssessmentAnswerDetail]
}

struct HealthAssessmentCategoryInfo: Decodable {
    let key: String
    let nameFr: String
    let nameEn: String
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case key, icon
        case nameFr = "name_fr"
        case nameEn = "name_en"
    }
}

struct HealthAssessmentAnswerDetail: Decodable {
    let questionId: Int
    let questionFr: String
    let questionEn: String
    let answerValue: String
    let isPositive: Bool

    enum CodingKeys: String, CodingKey {
        case questionId = "question_id"
        case questionFr = "question_fr"
        case questionEn = "question_en"
        case answerValue = "answer_value"
        case isPositive = "is_positive"
    }
}

/// Health Assessment Insights Response
struct HealthAssessmentInsightsResponse: Decodable {
    let success: Bool
    let data: HealthAssessmentInsights
}

struct HealthAssessmentInsights: Decodable {
    let hasAssessment: Bool
    let message: String?
    let completedAt: String?
    let totalQuestions: Int?
    let concernsCount: Int?
    let criticalConcerns: [HealthCriticalConcern]?
    let insights: [String]?
    let recommendations: [String]?

    enum CodingKeys: String, CodingKey {
        case hasAssessment = "has_assessment"
        case message
        case completedAt = "completed_at"
        case totalQuestions = "total_questions"
        case concernsCount = "concerns_count"
        case criticalConcerns = "critical_concerns"
        case insights, recommendations
    }
}

struct HealthCriticalConcern: Decodable {
    let questionFr: String
    let questionEn: String
    let category: String

    enum CodingKeys: String, CodingKey {
        case questionFr = "question_fr"
        case questionEn = "question_en"
        case category
    }

    var localizedQuestion: String {
        let language = LanguageManager.shared.selected
        switch language {
        case .english, .system:
            return questionEn
        default:
            return questionFr
        }
    }
}

// MARK: - Intensity Zones
struct IntensityZone: Codable, Identifiable {
    let id: Int
    let color: String
    let name: String
    let intensityRange: String
    let description: String
    let rpeMin: Int?
    let rpeMax: Int?

    enum CodingKeys: String, CodingKey {
        case id, color, name, description
        case intensityRange = "intensity_range"
        case rpeMin = "rpe_min"
        case rpeMax = "rpe_max"
    }
}

// MARK: - Sleep & Recovery
struct SleepProtocol: Codable, Identifiable {
    let id: Int
    let conditionKey: String
    let conditionName: String
    let cyclesMin: Int
    let cyclesMax: Int
    let totalSleep: String
    let objective: String
    let category: String

    enum CodingKeys: String, CodingKey {
        case id, objective, category
        case conditionKey = "condition_key"
        case conditionName = "condition_name"
        case cyclesMin = "cycles_min"
        case cyclesMax = "cycles_max"
        case totalSleep = "total_sleep"
    }
}

struct Chronotype: Codable, Identifiable {
    let id: Int
    let key: String
    let name: String
    let wakeTime: String
    let peakStart: String
    let peakEnd: String
    let bedtime: String
    let description: String
    let character: String
    let icon: String?

    enum CodingKeys: String, CodingKey {
        case id, key, name, bedtime, description, character, icon
        case wakeTime = "wake_time"
        case peakStart = "peak_start"
        case peakEnd = "peak_end"
    }
}

struct SleepCalculation: Codable {
    let wakeTime: String
    let recommendedBedtime: String
    let cycles: Int
    let totalSleep: String
    let options: [SleepOption]

    enum CodingKeys: String, CodingKey {
        case cycles, options
        case wakeTime = "wake_time"
        case recommendedBedtime = "recommended_bedtime"
        case totalSleep = "total_sleep"
    }
}

struct SleepOption: Codable {
    let cycles: Int
    let totalSleep: String
    let bedtime: String

    enum CodingKeys: String, CodingKey {
        case cycles, bedtime
        case totalSleep = "total_sleep"
    }
}

// MARK: - Prophetic Medicine
struct PropheticCondition: Codable, Identifiable {
    var id: String { conditionKey }
    let conditionKey: String
    let conditionName: String
    let remedyCount: Int

    enum CodingKeys: String, CodingKey {
        case conditionKey = "condition_key"
        case conditionName = "condition_name"
        case remedyCount = "remedy_count"
    }
}

struct PropheticRemedy: Codable, Identifiable {
    let id: Int
    let conditionKey: String
    let conditionName: String
    let elementName: String
    let mechanism: String
    let recipe: String
    let notes: String?

    enum CodingKeys: String, CodingKey {
        case id, mechanism, recipe, notes
        case conditionKey = "condition_key"
        case conditionName = "condition_name"
        case elementName = "element_name"
    }
}

// MARK: - Workout Feedback Recommendation
struct WorkoutFeedbackRecommendation: Decodable {
    let recommendation: String?
    let adjustments: WorkoutAdjustmentsData?
    let stats: WorkoutFeedbackRecommendationStats?
}

struct WorkoutFeedbackRecommendationStats: Decodable {
    let averageDifficulty: Double?
    let averageEnergy: Double?
    let averageEnjoyment: Double?
    let totalSessions: Int?

    enum CodingKeys: String, CodingKey {
        case averageDifficulty = "average_difficulty"
        case averageEnergy = "average_energy"
        case averageEnjoyment = "average_enjoyment"
        case totalSessions = "total_sessions"
    }
}

// MARK: - Account / GDPR Models
struct UserDataExport: Decodable {
    let account: UserDataExportAccount?
    let profile: APIProfile?
    let goals: [Goal]?
    let progress: [UserProgress]?
    let exportedAt: String?

    enum CodingKeys: String, CodingKey {
        case account, profile, goals, progress
        case exportedAt = "exported_at"
    }
}

struct UserDataExportAccount: Decodable {
    let id: Int
    let name: String?
    let email: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id, name, email
        case createdAt = "created_at"
    }
}

struct PrivacyInfo: Decodable {
    let privacyPolicyUrl: String?
    let termsOfServiceUrl: String?
    let dataRetention: DataRetentionInfo?
    let contactEmail: String?

    enum CodingKeys: String, CodingKey {
        case privacyPolicyUrl = "privacy_policy_url"
        case termsOfServiceUrl = "terms_of_service_url"
        case dataRetention = "data_retention"
        case contactEmail = "contact_email"
    }
}

struct DataRetentionInfo: Decodable {
    let accountData: String?
    let healthData: String?
    let workoutData: String?
    let feedbackData: String?

    enum CodingKeys: String, CodingKey {
        case accountData = "account_data"
        case healthData = "health_data"
        case workoutData = "workout_data"
        case feedbackData = "feedback_data"
    }
}

struct UserWithProfile: Decodable {
    let user: APIUser
}

// MARK: - Workout Session Metadata
struct WorkoutSessionMetadata: Codable {
    let zoneColor: String?
    let displayName: String?
    let qualityMethod: String?
    let rpe: Int?
    let mets: Double?
    let estimatedLoad: Int?
    let sleepRecommendation: String?
    let hydrationRecommendation: String?
    let isPrincipalTheme: Bool?
    let supercompWindow: String?
    let gainPrediction: String?
    let injuryRisk: String?
    let freshness24h: Double?
    let weeklyLoadSoFar: Int?

    enum CodingKeys: String, CodingKey {
        case rpe, mets
        case zoneColor = "zone_color"
        case displayName = "display_name"
        case qualityMethod = "quality_method"
        case estimatedLoad = "estimated_load"
        case sleepRecommendation = "sleep_recommendation"
        case hydrationRecommendation = "hydration_recommendation"
        case isPrincipalTheme = "is_principal_theme"
        case supercompWindow = "supercomp_window"
        case gainPrediction = "gain_prediction"
        case injuryRisk = "injury_risk"
        case freshness24h = "freshness_24h"
        case weeklyLoadSoFar = "weekly_load_so_far"
    }

    /// SwiftUI Color corresponding to the training zone.
    var zoneSwiftUIColor: Color {
        switch zoneColor?.lowercased() {
        case "red": return .red
        case "orange": return .orange
        case "yellow": return .yellow
        case "green": return .green
        case "blue": return .blue
        default: return Color.appTheme.primary
        }
    }

    /// SF Symbol icon appropriate for the zone intensity level.
    var zoneIcon: String {
        switch zoneColor?.lowercased() {
        case "red": return "flame.fill"             // Max intensity
        case "orange": return "bolt.fill"            // High intensity
        case "yellow": return "figure.run"           // Medium intensity
        case "green": return "leaf.fill"             // Aerobic / endurance
        case "blue": return "drop.fill"              // Recovery
        default: return "circle.fill"
        }
    }

    /// Localized zone name for display.
    var zoneName: String {
        switch zoneColor?.lowercased() {
        case "red": return "zone.red".localizedString
        case "orange": return "zone.orange".localizedString
        case "yellow": return "zone.yellow".localizedString
        case "green": return "zone.green".localizedString
        case "blue": return "zone.blue".localizedString
        default: return ""
        }
    }

    /// RPE description text for display (e.g., "8/10 - Hard").
    var rpeDescription: String {
        guard let rpe = rpe else { return "" }
        let label: String
        switch rpe {
        case 1...2: label = "workout.rpe.very_easy".localizedString
        case 3...4: label = "workout.rpe.easy".localizedString
        case 5...6: label = "workout.rpe.moderate".localizedString
        case 7...8: label = "workout.rpe.hard".localizedString
        case 9...10: label = "workout.rpe.maximum".localizedString
        default: label = ""
        }
        return "\(rpe)/10 - \(label)"
    }
}
