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
class APIService {
    static let shared = APIService()
    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier!, category: "API")

    // --- IMPORTANT ---
    // For iOS Simulator: Use your Mac's IP address
    // For Real Device: Use your computer's local network IP
    // Find your IP: System Settings > Network > Wi-Fi > Details > TCP/IP
    #if targetEnvironment(simulator)
    private let baseURL = "http://127.0.0.1:80"  // Simulator (your Laravel is on port 80)
    #else
    private let baseURL = "http://192.168.1.10:80"  // Real device - CHANGE THIS to your Mac's IP
    #endif

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
        
        // --- THIS IS THE TRANSLATION KEY ---
        // This tells your Laravel API which language to return
        request.setValue(language, forHTTPHeaderField: "Accept-Language")
        // ---

        if requiresAuth {
            guard let token = APITokenManager.shared.currentToken, !token.isEmpty else {
                logger.warning("❌ Request to \(endpoint) failed: Missing auth token.")
                return Fail(error: URLError(.userAuthenticationRequired)).eraseToAnyPublisher()
            }
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            logger.debug("🔐 Auth header attached for \(endpoint)")
        }

        // --- Custom Encoder for OnboardingData ---
        let encoder = JSONEncoder()
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate] // "YYYY-MM-DD"
        // This tells the encoder how to convert a Swift 'Date' object into a string
        encoder.dateEncodingStrategy = .custom({ date, encoder in
            var container = encoder.singleValueContainer()
            try container.encode(formatter.string(from: date))
        })
        
        if let body = body {
            if let httpBody = try? encoder.encode(body) {
                request.httpBody = httpBody
                // Log the JSON being sent (for debugging)
                // if let jsonString = String(data: httpBody, encoding: .utf8) {
                //     logger.debug("➡️ [\(method)] \(url.path) BODY: \(jsonString)")
                // }
            }
        }
        
        logger.debug("🚀 [\(method)] \(url.path)")
        
        // --- Custom Decoder ---
        let decoder = JSONDecoder()
        // This tells the decoder how to convert a "YYYY-MM-DD" string into a Swift 'Date' object
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)
        decoder.dateDecodingStrategy = .formatted(dateFormatter)

        return URLSession.shared.dataTaskPublisher(for: request)
            .tryMap { [weak self] data, response -> Data in
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw URLError(.badServerResponse)
                }
                
                if !(200...299).contains(httpResponse.statusCode) {
                    self?.logger.error("❌ [\(method)] \(url.path) failed with status code: \(httpResponse.statusCode)")
                    if let bodyString = String(data: data, encoding: .utf8) {
                        self?.logger.error("    Response body: \(bodyString)")
                    }
                    if httpResponse.statusCode == 401 {
                        self?.logger.error("    Unauthorized (401). Token missing/expired or rejected.")
                        throw URLError(.userAuthenticationRequired)
                    }
                    if let apiError = try? JSONDecoder().decode(APIError.self, from: data) {
                        self?.logger.error("    Error message: \(apiError.message)")
                        throw apiError
                    }
                    throw URLError(.init(rawValue: httpResponse.statusCode))
                }
                
                self?.logger.info("✅ [\(method)] \(url.path) success (\(httpResponse.statusCode))")
                return data
            }
            .decode(type: T.self, decoder: decoder)
            .handleEvents(receiveOutput: { [weak self] decoded in
                self?.logger.info("📦 [\(method)] \(url.path) decoded successfully as \(String(describing: T.self))")
            })
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Async/Await Wrappers (for modern Swift code)
    
    /// A modern async/await wrapper for the Combine-based request function.
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: (any Encodable)? = nil,
        requiresAuth: Bool = true
    ) async throws -> T {
        
        // Get the current language from the manager
        let lang = await MainActor.run {
            LanguageManager().locale.language.languageCode?.identifier ?? "en"
        }
        
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
        try await request(endpoint: "/api/user", method: "GET")
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
        try await request(endpoint: "/api/nutrition-plan", method: "GET")
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
        try await request(endpoint: "/api/workout-plan", method: "GET")
    }
    
    /// Log workout progress
    /// POST /api/user-progress
    func logProgress(_ data: UserProgress) async throws -> UserProgress {
        try await request(endpoint: "/api/user-progress", method: "POST", body: data)
    }
    
    /// Get user progress history
    /// GET /api/user-progress
    func getProgress() async throws -> [UserProgress] {
        try await request(endpoint: "/api/user-progress", method: "GET")
    }
    
    // MARK: - Kine/Recovery (Protected)
    
    /// Get kine exercise data
    /// GET /api/kine-data
    func getKineData() async throws -> [String: [APIExercise]] {
        try await request(endpoint: "/api/kine-data", method: "GET")
    }
    
    /// Get favorite exercises
    /// GET /api/kine-favorites
    func getKineFavorites() async throws -> [Int] {
        try await request(endpoint: "/api/kine-favorites", method: "GET")
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
        try await request(endpoint: "/api/settings/reminders", method: "GET")
    }

    /// Update reminder settings
    /// PUT /api/settings/reminders
    func updateReminderSettings(_ settings: ReminderSettings) async throws -> APIResponseMessage {
        try await request(endpoint: "/api/settings/reminders", method: "PUT", body: settings)
    }
}

