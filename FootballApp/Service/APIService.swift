import Foundation
import Combine
import os.log

// MARK: - 1. API Error Struct
// This error struct helps in decoding error messages from your Laravel API
struct APIError: Decodable, Error, LocalizedError {
    let message: String
    let errors: [String: [String]]? // For validation errors
    var errorDescription: String? {
        // Return the first validation error if it exists
        return errors?.first?.value.first ?? message
    }
}

// MARK: - 2. API Token Manager
// This class holds your API token in the Keychain
class APITokenManager: ObservableObject {
    static let shared = APITokenManager()
    
    // You MUST copy 'KeychainService.swift' into your project for this to work
    private let keychainKey = "com.personaltrainer.apiToken"
    
    @Published var currentToken: String? {
        didSet {
            if let token = currentToken {
                KeychainService.shared.save(token, forKey: keychainKey)
            } else {
                KeychainService.shared.delete(forKey: keychainKey)
            }
        }
    }
    
    init() {
        self.currentToken = KeychainService.shared.load(forKey: keychainKey)
    }
}

// MARK: - 3. API Service
// This is your main networking service
class APIService: NSObject {
    static let shared = APIService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "API")

    /// Base URL from centralized config (supports debug/release switching)
    private var baseURL: String {
        // Strip "/api" suffix since endpoints already include "/api/"
        let full = APIConstants.baseURL
        if full.hasSuffix("/api") {
            return String(full.dropLast(4))
        }
        return full
    }

    /// Lazy URLSession with SSL pinning delegate (when configured)
    private lazy var pinnedSession: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = APIConstants.requestTimeout
        config.timeoutIntervalForResource = APIConstants.resourceTimeout
        if SSLPins.isEnabled {
            return URLSession(configuration: config, delegate: self, delegateQueue: nil)
        }
        return URLSession(configuration: config)
    }()

    /// The core Combine-based request function.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true,
        language: String = "en" // This will be passed from your LanguageManager
    ) -> AnyPublisher<T, Error> {
        
        guard let url = URL(string: baseURL + endpoint) else {
            logger.error("❌ Invalid URL: \(self.baseURL)\(endpoint)")
            return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(language, forHTTPHeaderField: "Accept-Language")

        // App key header - proves this request comes from the official iOS app
        request.setValue(APIConstants.appKey, forHTTPHeaderField: "X-App-Key")
        // ---

        if requiresAuth {
            guard let token = APITokenManager.shared.currentToken, !token.isEmpty else {
                return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        })

        if let body = body {
            if let httpBody = try? encoder.encode(body) {
                request.httpBody = httpBody
            }
        }

        #if DEBUG
        logger.debug("[\(method)] \(url.path)")
        #endif
        
        // --- Custom Decoder ---
        let decoder = JSONDecoder()
        // This tells the decoder how to convert a "YYYY-MM-DD" string into a Swift 'Date' object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return pinnedSession.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }

                if !(200...299).contains(httpResponse.statusCode) {
                    self?.logger.error("[\(method)] \(url.path) failed: \(httpResponse.statusCode)")
                    if httpResponse.statusCode == 401 {
                        throw URLError(.userAuthenticationRequired)
                    }
                    if httpResponse.statusCode == 403 {
                        // App key rejected or forbidden
                        throw URLError(.userAuthenticationRequired)
                    }
                    if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                        throw apiError
                    }
                    throw URLError(.init(rawValue: httpResponse.statusCode))
                }

                #if DEBUG
                self?.logger.info("[\(method)] \(url.path) OK")
                #endif
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Async/Await Wrappers (for modern Swift code)

    /// A modern async/await wrapper for the Combine-based request function.
    /// Uses UserDefaults to get language preference (set by LanguageManager) to avoid creating new instances.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {

        // Get the current language from UserDefaults (set by LanguageManager)
        // This avoids creating a new LanguageManager instance on every request
        let lang = UserDefaults.standard.string(forKey: "AppLanguage") ?? "en"

        return try await withCheckedThrowingContinuation { continuation in
            var cancellable: AnyCancellable?

            cancellable = self.request(
                endpoint: endpoint,
                method: method,
                body: body,
                requiresAuth: requiresAuth,
                language: lang
            )
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    continuation.resume(throwing: error)
                }
                _ = cancellable // Keep cancellable alive
            }, receiveValue: { (value: T) in
                continuation.resume(returning: value)
            })
        }
    }

    // MARK: - Specific API Call Functions (Convenience)
    
    // MARK: - Auth Endpoints (Public - No Token Required)
    
    /// Register a new user
    /// POST /api/auth/register
    func register(name: String, email: String, password: String, passwordConfirmation: String) async throws -> AuthResponse {
        struct RegisterRequest: Encodable {
            let name: String
            let email: String
            let password: String
            let password_confirmation: String
        }
        
        let body = RegisterRequest(
            name: name,
            email: email,
            password: password,
            password_confirmation: passwordConfirmation
        )
        
        return try await request(
            endpoint: "/api/auth/register",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    /// Login user
    /// POST /api/auth/login
    func login(email: String, password: String) async throws -> AuthResponse {
        struct LoginRequest: Encodable {
            let email: String
            let password: String
        }
        
        let body = LoginRequest(email: email, password: password)
        
        return try await request(
            endpoint: "/api/auth/login",
            method: "POST",
            body: body,
            requiresAuth: false
        )
    }
    
    /// Forgot password
    /// POST /api/auth/forgot-password
    func forgotPassword(email: String) async throws -> APIResponseMessage {
        struct ForgotPasswordRequest: Encodable {
            let email: String
        }
        
        return try await request(
            endpoint: "/api/auth/forgot-password",
            method: "POST",
            body: ForgotPasswordRequest(email: email),
            requiresAuth: false
        )
    }
    
    /// Social login (Google, Facebook, Apple)
    /// POST /api/auth/{provider}/login
    func socialLogin(provider: String, token: String) async throws -> AuthResponse {
        struct SocialLoginRequest: Encodable {
            let token: String
        }
        
        return try await request(
            endpoint: "/api/auth/\(provider)/login",
            method: "POST",
            body: SocialLoginRequest(token: token),
            requiresAuth: false
        )
    }
    
    /// Logout user
    /// POST /api/auth/logout
    func logout() async throws -> APIResponseMessage {
        try await request(
            endpoint: "/api/auth/logout",
            method: "POST",
            requiresAuth: true
        )
    }
    
    // MARK: - Onboarding (Public - No Token Required)
    
    /// Get onboarding data (dropdown options, etc.)
    /// GET /api/onboarding-data
    func getOnboardingData() async throws -> OnboardingDataResponse {
        try await request(
            endpoint: "/api/onboarding-data",
            method: "GET",
            requiresAuth: false
        )
    }
    
    // MARK: - User & Profile (Protected)
    
    /// Get current user info
    /// GET /api/user
    func getUser() async throws -> APIUser {
        let response: GenericAPIResponse<APIUser> = try await request(endpoint: "/api/user", method: "GET")
        return response.data
    }

    /// Update user profile (at end of onboarding)
    /// PUT /api/user/profile
    func updateUserProfile(_ data: OnboardingData) async throws -> UserProfileUpdateResponse {
        try await request(endpoint: "/api/user/profile", method: "PUT", body: data)
    }
    
    // MARK: - Dashboard (Protected)
    
    /// Get dashboard metrics
    /// GET /api/dashboard-metrics
    func getDashboardMetrics() async throws -> DashboardMetrics {
        try await request(endpoint: "/api/dashboard-metrics", method: "GET")
    }
    
    // MARK: - Nutrition (Protected)
    
    /// Get nutrition plan
    /// GET /api/nutrition-plan
    func getNutritionPlan() async throws -> AppNutritionPlan {
        let response: GenericAPIResponse<AppNutritionPlan> = try await request(endpoint: "/api/nutrition-plan", method: "GET")
        return response.data
    }
    
    // MARK: - Workouts (Protected)
    
    /// Generate new workout plan
    /// POST /api/workout-plan/generate
    func generateWorkoutPlan() async throws -> APIResponseMessage {
        try await request(endpoint: "/api/workout-plan/generate", method: "POST")
    }
    
    /// Get weekly workout plan
    /// GET /api/workout-plan
    func getWorkoutPlan() async throws -> [WorkoutSession] {
        let response: GenericAPIResponse<[WorkoutSession]> = try await request(endpoint: "/api/workout-plan", method: "GET")
        return response.data
    }
    
    /// Log workout progress
    /// POST /api/user-progress
    func logProgress(_ data: UserProgress) async throws -> UserProgress {
        let response: GenericAPIResponse<UserProgress> = try await request(endpoint: "/api/user-progress", method: "POST", body: data)
        return response.data
    }
    
    /// Get user progress history
    /// GET /api/user-progress
    func getProgress() async throws -> [UserProgress] {
        let response: GenericAPIResponse<[UserProgress]> = try await request(endpoint: "/api/user-progress", method: "GET")
        return response.data
    }
    
    // MARK: - Kine/Recovery (Protected)
    
    /// Get kine exercise data
    /// GET /api/kine-data
    func getKineData() async throws -> [String: [APIExercise]] {
        let response: GenericAPIResponse<[String: [APIExercise]]> = try await request(endpoint: "/api/kine-data", method: "GET")
        return response.data
    }

    /// Get favorite exercises
    /// GET /api/kine-favorites
    func getKineFavorites() async throws -> [Int] {
        let response: GenericAPIResponse<[Int]> = try await request(endpoint: "/api/kine-favorites", method: "GET")
        return response.data
    }
    
    /// Toggle favorite exercise
    /// POST /api/kine-favorites/toggle
    func toggleKineFavorite(exerciseID: Int) async throws -> ToggleFavoriteResponse {
        try await request(
            endpoint: "/api/kine-favorites/toggle",
            method: "POST",
            body: ["exercise_id": exerciseID]
        )
    }
    
    // MARK: - Settings (Protected)
    
    /// Get reminder settings
    /// GET /api/settings/reminders
    func getReminderSettings() async throws -> ReminderSettings {
        let response: GenericAPIResponse<ReminderSettings> = try await request(endpoint: "/api/settings/reminders", method: "GET")
        return response.data
    }

    /// Update reminder settings
    /// PUT /api/settings/reminders
    func updateReminderSettings(_ settings: ReminderSettings) async throws -> APIResponseMessage {
        try await request(endpoint: "/api/settings/reminders", method: "PUT", body: settings)
    }

    // MARK: - Goals (Protected)

    /// Get all goals
    /// GET /api/goals
    func getAllGoals() async throws -> [Goal] {
        let response: GenericAPIResponse<[Goal]> = try await request(
            endpoint: APIEndpoints.goals,
            method: "GET"
        )
        return response.data
    }

    /// Get active goal
    /// GET /api/goals/active
    func getActiveGoal() async throws -> Goal? {
        let response: GenericAPIResponse<Goal?> = try await request(
            endpoint: APIEndpoints.activeGoal,
            method: "GET"
        )
        return response.data
    }

    /// Create a new goal
    /// POST /api/goals
    func createGoal(_ request: CreateGoalRequest) async throws -> Goal {
        let response: GenericAPIResponse<Goal> = try await self.request(
            endpoint: APIEndpoints.goals,
            method: "POST",
            body: request
        )
        return response.data
    }

    /// Update goal progress
    /// POST /api/goals/{id}/progress
    func updateGoalProgress(goalId: Int) async throws -> GoalProgressData {
        let response: GoalProgressResponse = try await request(
            endpoint: APIEndpoints.goalProgress(id: goalId),
            method: "POST"
        )
        guard let data = response.data else {
            throw URLError(.badServerResponse)
        }
        return data
    }

    /// Update goal status
    /// PUT /api/goals/{id}/status
    func updateGoalStatus(goalId: Int, status: GoalStatus) async throws {
        let _: APIResponseMessage = try await request(
            endpoint: APIEndpoints.goalStatus(id: goalId),
            method: "PUT",
            body: UpdateGoalStatusRequest(status: status.rawValue)
        )
    }

    // MARK: - Achievements (Protected)

    /// Get all achievements
    /// GET /api/achievements
    func getAllAchievements() async throws -> AchievementsData {
        let response: AchievementsResponse = try await request(
            endpoint: APIEndpoints.achievements,
            method: "GET"
        )
        return response.data
    }

    /// Get earned achievements
    /// GET /api/achievements/earned
    func getEarnedAchievements() async throws -> [Achievement] {
        let response: GenericAPIResponse<[Achievement]> = try await request(
            endpoint: APIEndpoints.achievementsEarned,
            method: "GET"
        )
        return response.data
    }

    /// Get leaderboard
    /// GET /api/achievements/leaderboard
    func getLeaderboard(limit: Int = 10) async throws -> LeaderboardData {
        let response: LeaderboardResponse = try await request(
            endpoint: "\(APIEndpoints.achievementsLeaderboard)?limit=\(limit)",
            method: "GET"
        )
        return response.data
    }

    // MARK: - Posts (Protected)

    /// Get all posts with pagination
    /// GET /api/posts
    func getPosts(page: Int = 1, perPage: Int = 10) async throws -> (posts: [Post], meta: PaginationMeta?) {
        let response: PostsResponse = try await request(
            endpoint: "\(APIEndpoints.posts)?page=\(page)&per_page=\(perPage)",
            method: "GET"
        )
        return (response.data, response.meta)
    }

    /// Get latest posts
    /// GET /api/posts/latest
    func getLatestPosts(limit: Int = 5) async throws -> [Post] {
        let response: GenericAPIResponse<[Post]> = try await request(
            endpoint: "\(APIEndpoints.postsLatest)?limit=\(limit)",
            method: "GET"
        )
        return response.data
    }

    /// Get single post by slug
    /// GET /api/posts/{slug}
    func getPost(slug: String) async throws -> Post {
        let response: GenericAPIResponse<Post> = try await request(
            endpoint: APIEndpoints.post(slug: slug),
            method: "GET"
        )
        return response.data
    }

    // MARK: - Feedback (Protected)

    /// Get feedback questions for a category
    /// GET /api/feedback/questions/{category}
    func getFeedbackQuestions(category: String) async throws -> [FeedbackQuestion] {
        let response: FeedbackQuestionsResponse = try await request(
            endpoint: APIEndpoints.feedbackQuestionsForCategory(category: category),
            method: "GET"
        )
        return response.data
    }

    /// Submit feedback answers
    /// POST /api/feedback/submit
    func submitFeedback(_ feedbackRequest: SubmitFeedbackRequest) async throws -> SubmitFeedbackResponse {
        try await request(
            endpoint: APIEndpoints.feedbackSubmit,
            method: "POST",
            body: feedbackRequest
        )
    }

    /// Get feedback history
    /// GET /api/feedback/history
    func getFeedbackHistory() async throws -> [FeedbackSummary] {
        let response: FeedbackHistory = try await request(
            endpoint: APIEndpoints.feedbackHistory,
            method: "GET"
        )
        return response.data
    }

    /// Get feedback session details
    /// GET /api/feedback/sessions/{id}
    func getFeedbackSession(id: Int) async throws -> FeedbackSummary {
        let response: GenericAPIResponse<FeedbackSummary> = try await request(
            endpoint: APIEndpoints.feedbackSession(id: id),
            method: "GET"
        )
        return response.data
    }

    // MARK: - Sleep & Recovery

    /// Get sleep protocols
    /// GET /api/sleep/protocols
    func getSleepProtocols() async throws -> [SleepProtocol] {
        let response: GenericAPIResponse<[SleepProtocol]> = try await request(
            endpoint: APIEndpoints.sleepProtocols,
            method: "GET"
        )
        return response.data
    }

    /// Get chronotypes
    /// GET /api/sleep/chronotypes
    func getChronotypes() async throws -> [Chronotype] {
        let response: GenericAPIResponse<[Chronotype]> = try await request(
            endpoint: APIEndpoints.sleepChronotypes,
            method: "GET"
        )
        return response.data
    }

    /// Calculate bedtime based on wake time and optional chronotype
    /// GET /api/sleep/calculate
    func calculateBedtime(wakeTime: String, chronotype: String? = nil) async throws -> SleepCalculation {
        var endpoint = APIEndpoints.sleepCalculate + "?wake_time=\(wakeTime)"
        if let chronotype = chronotype {
            endpoint += "&chronotype=\(chronotype)"
        }
        let response: GenericAPIResponse<SleepCalculation> = try await request(
            endpoint: endpoint,
            method: "GET"
        )
        return response.data
    }

    // MARK: - Health Assessment

    /// Get health assessment categories
    /// GET /api/health-assessment/categories
    func getHealthAssessmentCategories(discipline: String? = nil) async throws -> [HealthAssessmentCategory] {
        var endpoint = APIEndpoints.healthAssessmentCategories
        if let discipline = discipline {
            endpoint += "?discipline=\(discipline)"
        }
        let response: HealthAssessmentCategoriesResponse = try await request(
            endpoint: endpoint,
            method: "GET"
        )
        return response.data
    }

    /// Get health assessment questions for a category
    /// GET /api/health-assessment/questions/{category}
    func getHealthAssessmentQuestions(category: String) async throws -> HealthAssessmentQuestionsData {
        let response: HealthAssessmentQuestionsResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentQuestions(category: category),
            method: "GET"
        )
        return response.data
    }

    /// Get full health assessment (all categories with questions)
    /// GET /api/health-assessment/full
    func getFullHealthAssessment(discipline: String? = nil) async throws -> [HealthAssessmentCategoryWithQuestions] {
        var endpoint = APIEndpoints.healthAssessmentFull
        if let discipline = discipline {
            endpoint += "?discipline=\(discipline)"
        }
        let response: HealthAssessmentFullResponse = try await request(
            endpoint: endpoint,
            method: "GET"
        )
        return response.data
    }

    /// Start a health assessment session
    /// POST /api/health-assessment/start
    func startHealthAssessment() async throws -> HealthAssessmentSession {
        let response: HealthAssessmentStartResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentStart,
            method: "POST"
        )
        return response.data
    }

    /// Submit health assessment answers
    /// POST /api/health-assessment/submit
    func submitHealthAssessmentAnswers(_ body: SubmitHealthAssessmentRequest) async throws -> HealthAssessmentSession {
        let response: HealthAssessmentSubmitResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentSubmit,
            method: "POST",
            body: body
        )
        return response.data
    }

    /// Get health assessment history
    /// GET /api/health-assessment/history
    func getHealthAssessmentHistory() async throws -> [HealthAssessmentSession] {
        let response: HealthAssessmentHistoryResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentHistory,
            method: "GET"
        )
        return response.data
    }

    /// Get health assessment insights
    /// GET /api/health-assessment/insights
    func getHealthAssessmentInsights() async throws -> HealthAssessmentInsights {
        let response: HealthAssessmentInsightsResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentInsights,
            method: "GET"
        )
        return response.data
    }

    /// Get health assessment session detail
    /// GET /api/health-assessment/sessions/{id}
    func getHealthAssessmentSession(id: Int) async throws -> HealthAssessmentSessionDetail {
        let response: HealthAssessmentSessionDetailResponse = try await request(
            endpoint: APIEndpoints.healthAssessmentSession(id: id),
            method: "GET"
        )
        return response.data
    }

    // MARK: - Workout Feedback

    /// Get post-workout feedback questions
    /// GET /api/workout-feedback/questions
    func getWorkoutFeedbackQuestions() async throws -> PostWorkoutQuestionsData? {
        let response: PostWorkoutQuestionsResponse = try await request(
            endpoint: APIEndpoints.workoutFeedbackQuestions,
            method: "GET"
        )
        return response.data
    }

    /// Submit workout feedback
    /// POST /api/workout-feedback
    func submitWorkoutFeedback(_ body: WorkoutFeedbackRequest) async throws -> WorkoutFeedbackData? {
        let response: WorkoutFeedbackResponse = try await request(
            endpoint: APIEndpoints.workoutFeedbackSubmit,
            method: "POST",
            body: body
        )
        return response.data
    }

    /// Get workout feedback history
    /// GET /api/workout-feedback/history
    func getWorkoutFeedbackHistory() async throws -> [WorkoutFeedbackItem] {
        let response: GenericAPIResponse<[WorkoutFeedbackItem]> = try await request(
            endpoint: APIEndpoints.workoutFeedbackHistory,
            method: "GET"
        )
        return response.data
    }

    /// Get workout feedback recommendation for a theme
    /// GET /api/workout-feedback/recommendation/{theme}
    func getWorkoutFeedbackRecommendation(theme: String) async throws -> WorkoutFeedbackRecommendation {
        let response: GenericAPIResponse<WorkoutFeedbackRecommendation> = try await request(
            endpoint: APIEndpoints.workoutFeedbackRecommendation(theme: theme),
            method: "GET"
        )
        return response.data
    }

    // MARK: - Prophetic Medicine

    /// Get all prophetic medicine conditions
    /// GET /api/prophetic-medicine
    func getPropheticMedicine() async throws -> [PropheticCondition] {
        let response: GenericAPIResponse<[PropheticCondition]> = try await request(
            endpoint: APIEndpoints.propheticMedicine,
            method: "GET"
        )
        return response.data
    }

    /// Get remedies for a specific condition
    /// GET /api/prophetic-medicine/{condition}
    func getPropheticRemedies(condition: String) async throws -> [PropheticRemedy] {
        let response: GenericAPIResponse<[PropheticRemedy]> = try await request(
            endpoint: "\(APIEndpoints.propheticMedicine)/\(condition)",
            method: "GET"
        )
        return response.data
    }

    // MARK: - Intensity Zones

    /// Get intensity zones
    /// GET /api/intensity-zones
    func getIntensityZones() async throws -> [IntensityZone] {
        let response: GenericAPIResponse<[IntensityZone]> = try await request(
            endpoint: APIEndpoints.intensityZones,
            method: "GET"
        )
        return response.data
    }

    // MARK: - Account / GDPR

    /// Export all user data (GDPR)
    /// GET /api/account/export
    func exportUserData() async throws -> UserDataExport {
        let response: GenericAPIResponse<UserDataExport> = try await request(
            endpoint: APIEndpoints.accountExport,
            method: "GET"
        )
        return response.data
    }

    /// Delete user account
    /// DELETE /api/account
    func deleteAccount(password: String) async throws -> APIResponseMessage {
        struct DeleteAccountRequest: Encodable {
            let password: String
            let confirmation: String
        }
        return try await request(
            endpoint: APIEndpoints.accountDelete,
            method: "DELETE",
            body: DeleteAccountRequest(password: password, confirmation: "DELETE")
        )
    }

    /// Get privacy information
    /// GET /api/privacy
    func getPrivacyInfo() async throws -> PrivacyInfo {
        let response: GenericAPIResponse<PrivacyInfo> = try await request(
            endpoint: APIEndpoints.privacyInfo,
            method: "GET"
        )
        return response.data
    }

    /// Logout from all devices
    /// POST /api/auth/logout-all
    func logoutAll() async throws -> APIResponseMessage {
        try await request(
            endpoint: APIEndpoints.logoutAll,
            method: "POST"
        )
    }

    /// Change password
    /// PUT /api/auth/password
    func changePassword(currentPassword: String, newPassword: String, confirmation: String) async throws -> APIResponseMessage {
        struct ChangePasswordRequest: Encodable {
            let current_password: String
            let password: String
            let password_confirmation: String
        }
        return try await request(
            endpoint: APIEndpoints.changePassword,
            method: "PUT",
            body: ChangePasswordRequest(
                current_password: currentPassword,
                password: newPassword,
                password_confirmation: confirmation
            )
        )
    }

    /// Get authenticated user with profile
    /// GET /api/auth/me
    func getAuthMe() async throws -> UserWithProfile {
        let response: GenericAPIResponse<UserWithProfile> = try await request(
            endpoint: APIEndpoints.authMe,
            method: "GET"
        )
        return response.data
    }
}

// MARK: - SSL Pinning (URLSessionDelegate)
extension APIService: URLSessionDelegate {
    /// Validates the server's TLS certificate against pinned public key hashes.
    /// This prevents man-in-the-middle attacks even if a CA is compromised.
    func urlSession(
        _ session: URLSession,
        didReceive challenge: URLAuthenticationChallenge,
        completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void
    ) {
        guard SSLPins.isEnabled,
              challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.performDefaultHandling, nil)
            return
        }

        // Evaluate the server trust
        var error: CFError?
        guard SecTrustEvaluateWithError(serverTrust, &error) else {
            logger.error("SSL: Server trust evaluation failed")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Extract the server's public key and compute its SHA-256 hash
        guard let certificateChain = SecTrustCopyCertificateChain(serverTrust) as? [SecCertificate],
              let serverCertificate = certificateChain.first else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        guard let serverPublicKey = SecCertificateCopyKey(serverCertificate),
              let serverPublicKeyData = SecKeyCopyExternalRepresentation(serverPublicKey, nil) as Data? else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Compute SHA-256 hash of the public key
        let keyHash = serverPublicKeyData.sha256Base64()

        // Check if the hash matches any of our pinned keys
        if SSLPins.pins.contains(keyHash) {
            completionHandler(.useCredential, URLCredential(trust: serverTrust))
        } else {
            logger.error("SSL: Certificate pin mismatch. Rejecting connection.")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }
}

// MARK: - Data SHA-256 Helper
import CommonCrypto

private extension Data {
    func sha256Base64() -> String {
        var hash = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        withUnsafeBytes { buffer in
            _ = CC_SHA256(buffer.baseAddress, CC_LONG(count), &hash)
        }
        return Data(hash).base64EncodedString()
    }
}

