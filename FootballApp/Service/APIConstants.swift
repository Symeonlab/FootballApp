import Foundation

// MARK: - API Configuration Constants
enum APIConstants {

    // MARK: - Environment Detection
    /// Set to `true` for App Store / TestFlight builds.
    /// Controlled via Xcode build configuration or scheme environment variable.
    #if DEBUG
    static let isProduction = false
    #else
    static let isProduction = true
    #endif

    // MARK: - Base URL
    /// Production URL uses HTTPS. Local dev uses HTTP for simulator/device testing.
    static var baseURL: String {
        if isProduction {
            return "https://dipodi-api.sliplane.app/api"  // Sliplane production server
        }
        #if targetEnvironment(simulator)
        return "http://127.0.0.1:8000/api"       // Docker on simulator
        #else
        return "http://192.168.1.10:8000/api"     // Local Mac IP for device testing
        #endif
    }

    // MARK: - App Key (X-App-Key header)
    /// This key is sent with every request to prove the request comes from the official iOS app.
    /// The server stores only the SHA-256 hash of this key and compares it.
    /// In production, this should be obfuscated (see AppKeyProvider).
    static let appKey: String = AppKeyProvider.key

    // MARK: - Timeouts
    static let requestTimeout: TimeInterval = 30
    static let resourceTimeout: TimeInterval = 60

    // MARK: - Rate Limits (requests per minute)
    static let standardRateLimit = 60
    static let heavyRateLimit = 10
    static let authRateLimit = 5
}

// MARK: - App Key Provider
/// Obfuscated app key storage. The key is split to avoid appearing as a single string
/// in the compiled binary, making it harder to extract via reverse engineering.
enum AppKeyProvider {
    // Split key into segments to resist basic string scanning of the binary
    private static let s1 = "-WsRJfXZEswLg9bl"
    private static let s2 = "Luflob_heZNntMx_"
    private static let s3 = "bdenW7aTqHGTmITk"
    private static let s4 = "sANil8ENSePaDgtc"

    static var key: String {
        s1 + s2 + s3 + s4
    }
}

// MARK: - SSL Pinning
/// SHA-256 hashes of the server's TLS certificate public keys.
/// When you deploy to production, add your server's certificate pin here.
/// Generate with: openssl s_client -connect api.dipoddi.com:443 | openssl x509 -pubkey -noout | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | openssl enc -base64
enum SSLPins {
    /// Add your production certificate pin(s) here. Include at least one backup pin.
    static let pins: [String] = [
        // "BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB="  // Primary cert pin
        // "CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC="  // Backup cert pin
    ]

    /// Whether SSL pinning is enabled. Only enabled in production when pins are configured.
    static var isEnabled: Bool {
        APIConstants.isProduction && !pins.isEmpty
    }
}

// MARK: - API Endpoints
enum APIEndpoints {
    // Auth
    static let register = "/auth/register"
    static let login = "/auth/login"
    static let logout = "/auth/logout"
    static let logoutAll = "/auth/logout-all"
    static let forgotPassword = "/auth/forgot-password"
    static let changePassword = "/auth/password"
    static let authMe = "/auth/me"
    static func socialLogin(provider: String) -> String { "/auth/\(provider)/login" }

    // User
    static let user = "/user"
    static let userProfile = "/user/profile"
    static let userProgress = "/user-progress"

    // Dashboard
    static let dashboardMetrics = "/dashboard-metrics"

    // Onboarding
    static let onboardingData = "/onboarding-data"

    // Workout
    static let workoutPlan = "/workout-plan"
    static let workoutPlanGenerate = "/workout-plan/generate"

    // Nutrition
    static let nutritionPlan = "/nutrition-plan"

    // Kine
    static let kineData = "/kine-data"
    static let kineFavorites = "/kine-favorites"
    static let kineFavoritesToggle = "/kine-favorites/toggle"

    // Goals
    static let goals = "/goals"
    static let activeGoal = "/goals/active"
    static func goal(id: Int) -> String { "/goals/\(id)" }
    static func goalProgress(id: Int) -> String { "/goals/\(id)/progress" }
    static func goalStatus(id: Int) -> String { "/goals/\(id)/status" }

    // Achievements
    static let achievements = "/achievements"
    static let achievementsEarned = "/achievements/earned"
    static let achievementsLeaderboard = "/achievements/leaderboard"
    static func achievement(id: Int) -> String { "/achievements/\(id)" }

    // Posts
    static let posts = "/posts"
    static let postsLatest = "/posts/latest"
    static func post(slug: String) -> String { "/posts/\(slug)" }

    // Settings
    static let reminderSettings = "/settings/reminders"

    // Export
    static let exportWorkoutPdf = "/export/workout-plan/pdf"
    static let exportWorkoutHtml = "/export/workout-plan/html"

    // Feedback
    static let feedbackCategories = "/feedback/categories"
    static func feedbackQuestionsForCategory(category: String) -> String { "/feedback/questions/\(category)" }
    static let feedbackSubmit = "/feedback/submit"
    static let feedbackHistory = "/feedback/history"
    static let feedbackStats = "/feedback/stats"
    static func feedbackSession(id: Int) -> String { "/feedback/sessions/\(id)" }

    // Workout Feedback
    static let workoutFeedbackQuestions = "/workout-feedback/questions"
    static let workoutFeedbackSubmit = "/workout-feedback"
    static let workoutFeedbackHistory = "/workout-feedback/history"
    static func workoutFeedbackRecommendation(theme: String) -> String { "/workout-feedback/recommendation/\(theme)" }

    // Sleep & Recovery
    static let sleepProtocols = "/sleep/protocols"
    static let sleepChronotypes = "/sleep/chronotypes"
    static let sleepCalculate = "/sleep/calculate"

    // Prophetic Medicine
    static let propheticMedicine = "/prophetic-medicine"

    // Intensity Zones
    static let intensityZones = "/intensity-zones"

    // Account / GDPR
    static let accountExport = "/account/export"
    static let accountDelete = "/account"
    static let privacyInfo = "/privacy"

    // Health Assessment
    static let healthAssessmentCategories = "/health-assessment/categories"
    static func healthAssessmentQuestions(category: String) -> String { "/health-assessment/questions/\(category)" }
    static let healthAssessmentFull = "/health-assessment/full"
    static let healthAssessmentStart = "/health-assessment/start"
    static let healthAssessmentSubmit = "/health-assessment/submit"
    static let healthAssessmentHistory = "/health-assessment/history"
    static let healthAssessmentInsights = "/health-assessment/insights"
    static func healthAssessmentSession(id: Int) -> String { "/health-assessment/sessions/\(id)" }
}
