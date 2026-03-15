//
//  APITester.swift
//  FootballApp
//
//  API endpoint testing logic - Full JSON data analysis
//

import Foundation
import Combine
import os.log

// MARK: - API Endpoint Definition
struct APIEndpoint: Identifiable {
    let id = UUID()
    let name: String
    let path: String
    let method: String
    let requiresAuth: Bool
    let expectedFormat: String
    let testBody: [String: Any]?
    let category: EndpointCategory

    init(name: String, path: String, method: String = "GET", requiresAuth: Bool = true, expectedFormat: String, testBody: [String: Any]? = nil, category: EndpointCategory = .other) {
        self.name = name
        self.path = path
        self.method = method
        self.requiresAuth = requiresAuth
        self.expectedFormat = expectedFormat
        self.testBody = testBody
        self.category = category
    }
}

enum EndpointCategory: String, CaseIterable {
    case auth = "Authentication"
    case user = "User & Profile"
    case workout = "Workouts"
    case nutrition = "Nutrition"
    case goals = "Goals"
    case achievements = "Achievements"
    case posts = "Posts & Blog"
    case kine = "Kine Exercises"
    case settings = "Settings"
    case other = "Other"
}

// MARK: - Test Result
struct TestResult {
    let success: Bool
    let statusCode: Int?
    let error: String?
    let responseData: String?
    let rawData: Data?
    let responseTime: TimeInterval
    let timestamp: Date
    let jsonAnalysis: JSONAnalysis?
}

// MARK: - JSON Analysis
struct JSONAnalysis {
    let isValidJSON: Bool
    let rootType: String // "object", "array", "null", etc.
    let fieldCount: Int
    let arrayCount: Int?
    let fields: [JSONField]
    let nestedObjects: [String: JSONAnalysis]

    var summary: String {
        var lines: [String] = []
        lines.append("Root Type: \(rootType)")
        lines.append("Fields: \(fieldCount)")
        if let count = arrayCount {
            lines.append("Array Items: \(count)")
        }
        return lines.joined(separator: "\n")
    }
}

struct JSONField {
    let name: String
    let type: String
    let value: String
    let isNull: Bool
}

// MARK: - API Tester
class APITester: ObservableObject {
    @Published var results: [UUID: TestResult] = [:]
    @Published var isTesting = false
    @Published var hasToken: Bool = false
    @Published var currentTestingEndpoint: String?
    @Published var testProgress: Double = 0.0

    private let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "com.app", category: "APITester")
    private var cancellables = Set<AnyCancellable>()

    // Define all endpoints to test - aligned with Laravel API routes
    let endpoints: [APIEndpoint] = [
        // ========================================
        // 1. PUBLIC AUTH ROUTES (No login needed)
        // ========================================

        APIEndpoint(
            name: "Register User",
            path: "/api/auth/register",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "success": true,
              "message": "Registration successful",
              "data": {
                "token": "...",
                "user": {...}
              }
            }
            """,
            testBody: [
                "name": "Test User",
                "email": "a\(Int.random(in: 1000...9999))@a.com",
                "password": "TestPass123!",
                "password_confirmation": "TestPass123!"
            ],
            category: .auth
        ),

        APIEndpoint(
            name: "Login User",
            path: "/api/auth/login",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "success": true,
              "message": "Login successful",
              "data": {
                "token": "...",
                "user": {...}
              }
            }
            """,
            testBody: [
                "email": "test@example.com",
                "password": "TestPass123!"
            ],
            category: .auth
        ),

        APIEndpoint(
            name: "Forgot Password",
            path: "/api/auth/forgot-password",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "message": "Password reset link sent"
            }
            """,
            testBody: [
                "email": "a@a.com"
            ],
            category: .auth
        ),

        // ========================================
        // 2. ONBOARDING DATA (No login needed)
        // ========================================

        APIEndpoint(
            name: "Get Onboarding Data",
            path: "/api/onboarding-data",
            method: "GET",
            requiresAuth: false,
            expectedFormat: """
            {
              "discipline": [...],
              "level": [...],
              "goal": [...],
              "location": [...],
              "injury_location": [...],
              "morphology": [...],
              "activity_level": [...],
              "gym_preferences": [...],
              "cardio_preferences": [...],
              "outdoor_preferences": [...],
              "home_preferences": [...]
            }
            """,
            category: .other
        ),

        // ========================================
        // 3. USER & PROFILE
        // ========================================

        APIEndpoint(
            name: "Get Current User",
            path: "/api/user",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "id": 1,
              "name": "User Name",
              "email": "user@example.com",
              "role": "user",
              "profile": {
                "id": 1,
                "user_id": 1,
                "is_onboarding_complete": true,
                "discipline": "Football",
                "level": "Intermediate",
                "goal": "Performance",
                ...
              }
            }
            """,
            category: .user
        ),

        APIEndpoint(
            name: "Update User Profile",
            path: "/api/user/profile",
            method: "PUT",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Profile updated successfully",
              "user": {...}
            }
            """,
            testBody: [
                "name": "Updated Name",
                "birth_date": "1990-01-01",
                "height": 175,
                "weight": 75
            ],
            category: .user
        ),

        // ========================================
        // 4. DASHBOARD
        // ========================================

        APIEndpoint(
            name: "Get Dashboard Metrics",
            path: "/api/dashboard-metrics",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "stats": {...},
              "chart": {...},
              "my_latest_progress": [...],
              "active_goal": {...},
              "achievements": {...},
              "latest_posts": [...]
            }
            """,
            category: .other
        ),

        // ========================================
        // 5. GOALS
        // ========================================

        APIEndpoint(
            name: "Get All Goals",
            path: "/api/goals",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": [
                {
                  "id": 1,
                  "goal_type": "weight_loss",
                  "goal_type_label": "Weight Loss",
                  "status": "active",
                  "progress": 45.5,
                  "expected_progress": 50.0,
                  "is_on_track": false,
                  "target_weight": 70.0,
                  "target_waist": 80.0,
                  "start_weight": 80.0,
                  "start_waist": 90.0,
                  "target_workouts_per_week": 4,
                  "start_date": "2025-01-01",
                  "target_date": "2025-04-01",
                  "weeks_completed": 5,
                  "total_weeks": 12,
                  "notes": "My fitness goal"
                }
              ]
            }
            """,
            category: .goals
        ),

        APIEndpoint(
            name: "Get Active Goal",
            path: "/api/goals/active",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": {
                "id": 1,
                "goal_type": "weight_loss",
                "status": "active",
                "progress": 45.5,
                "expected_progress": 50.0,
                "is_on_track": false,
                ...
              }
            }
            """,
            category: .goals
        ),

        APIEndpoint(
            name: "Create Goal",
            path: "/api/goals",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": {
                "id": 1,
                "goal_type": "weight_loss",
                "status": "active",
                ...
              }
            }
            """,
            testBody: [
                "goal_type": "weight_loss",
                "target_weight": 70.0,
                "target_waist": 80.0,
                "target_workouts_per_week": 4,
                "total_weeks": 12,
                "notes": "Test goal from API tester"
            ],
            category: .goals
        ),

        APIEndpoint(
            name: "Update Goal Progress",
            path: "/api/goals/1/progress",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "message": "Progress updated",
              "data": {
                "progress": 50.0,
                "weeks_completed": 6,
                "status": "active",
                "new_achievements": ["first_week", "consistency_3"]
              }
            }
            """,
            category: .goals
        ),

        // ========================================
        // 6. ACHIEVEMENTS
        // ========================================

        APIEndpoint(
            name: "Get All Achievements",
            path: "/api/achievements",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": {
                "achievements": [
                  {
                    "id": 1,
                    "key": "first_workout",
                    "name": "First Workout",
                    "description": "Complete your first workout",
                    "icon": "🏋️",
                    "points": 10,
                    "category": "workout",
                    "earned": true,
                    "earned_at": "2025-01-15T10:30:00Z",
                    "earned_by_count": 150
                  }
                ],
                "by_category": {
                  "workout": [...],
                  "consistency": [...],
                  "milestone": [...]
                },
                "total_points": 250,
                "total_earned": 12,
                "total_available": 50
              }
            }
            """,
            category: .achievements
        ),

        APIEndpoint(
            name: "Get Earned Achievements",
            path: "/api/achievements/earned",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": [
                {
                  "id": 1,
                  "key": "first_workout",
                  "name": "First Workout",
                  "description": "Complete your first workout",
                  "icon": "🏋️",
                  "points": 10,
                  "category": "workout",
                  "earned": true,
                  "earned_at": "2025-01-15T10:30:00Z"
                }
              ]
            }
            """,
            category: .achievements
        ),

        APIEndpoint(
            name: "Get Leaderboard",
            path: "/api/achievements/leaderboard",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": {
                "leaderboard": [
                  {
                    "id": 1,
                    "name": "John Doe",
                    "total_points": 500,
                    "achievement_count": 25
                  }
                ],
                "current_user": {
                  "rank": 15,
                  "total_points": 250,
                  "achievement_count": 12
                }
              }
            }
            """,
            category: .achievements
        ),

        // ========================================
        // 7. POSTS & BLOG
        // ========================================

        APIEndpoint(
            name: "Get All Posts",
            path: "/api/posts",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": [
                {
                  "id": 1,
                  "title": "How to Improve Your Fitness",
                  "content": "...",
                  "excerpt": "A short summary...",
                  "slug": "how-to-improve-fitness",
                  "featured_image": "https://...",
                  "author": "Admin",
                  "published_at": "2025-01-10T09:00:00Z",
                  "reading_time": 5
                }
              ],
              "meta": {
                "current_page": 1,
                "last_page": 5,
                "per_page": 10,
                "total": 50
              }
            }
            """,
            category: .posts
        ),

        APIEndpoint(
            name: "Get Post by Slug",
            path: "/api/posts/how-to-improve-fitness",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "success": true,
              "data": {
                "id": 1,
                "title": "How to Improve Your Fitness",
                "content": "Full content here...",
                "excerpt": "A short summary...",
                "slug": "how-to-improve-fitness",
                "featured_image": "https://...",
                "author": "Admin",
                "published_at": "2025-01-10T09:00:00Z",
                "reading_time": 5
              }
            }
            """,
            category: .posts
        ),

        // ========================================
        // 8. NUTRITION
        // ========================================

        APIEndpoint(
            name: "Get/Generate Nutrition Plan",
            path: "/api/nutrition-plan",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "daily_calorie_intake": 2500,
              "macros": {
                "protein": 150,
                "carbs": 300,
                "fat": 80
              },
              "daily_meals": [
                {
                  "name": "Breakfast",
                  "items": ["Oatmeal", "Eggs", "Orange juice"]
                }
              ],
              "advice": [
                {
                  "condition_name": "Performance",
                  "foods_to_avoid": ["..."],
                  "foods_to_eat": ["..."],
                  "prophetic_advice_fr": "...",
                  "prophetic_advice_ar": "..."
                }
              ]
            }
            """,
            category: .nutrition
        ),

        // ========================================
        // 9. WORKOUTS
        // ========================================

        APIEndpoint(
            name: "Generate Workout Plan",
            path: "/api/workout-plan/generate",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Workout plan generated successfully"
            }
            """,
            category: .workout
        ),

        APIEndpoint(
            name: "Get Weekly Workout Plan",
            path: "/api/workout-plan",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            [
              {
                "id": 1,
                "day": "Monday",
                "theme": "Strength",
                "warmup": "5 min jogging",
                "finisher": "Stretching",
                "is_completed": false,
                "exercises": [
                  {
                    "id": 1,
                    "name": "Squats",
                    "sets": "4 sets",
                    "reps": "12 reps",
                    "recovery": "60s",
                    "video_url": "https://...",
                    "is_completed": false
                  }
                ]
              }
            ]
            """,
            category: .workout
        ),

        APIEndpoint(
            name: "Log Progress",
            path: "/api/user-progress",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "id": 1,
              "user_id": 1,
              "date": "2025-12-12",
              "weight": 75.5,
              "waist": 85.0,
              "mood": "energized",
              "workout_completed": "Monday"
            }
            """,
            testBody: [
                "date": {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    return formatter.string(from: Date())
                }(),
                "workout_completed": "Monday Test",
                "weight": 75.5,
                "mood": "energized"
            ],
            category: .workout
        ),

        APIEndpoint(
            name: "Get User Progress History",
            path: "/api/user-progress",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            [
              {
                "id": 1,
                "user_id": 1,
                "date": "2025-12-12",
                "weight": 75.5,
                "waist": 85.0,
                "chest": 100.0,
                "hips": 95.0,
                "mood": "energized",
                "notes": "Felt great!",
                "workout_completed": "Monday"
              }
            ]
            """,
            category: .workout
        ),

        // ========================================
        // 10. KINE TAB
        // ========================================

        APIEndpoint(
            name: "Get Kine Exercise Data",
            path: "/api/kine-data",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "KINE MOBILITÉ": [
                {
                  "id": 1,
                  "name": "Hamstring Stretch",
                  "category": "KINE MOBILITÉ",
                  "sub_category": "Legs",
                  "description": "...",
                  "video_url": "https://...",
                  "met_value": 2.5
                }
              ],
              "KINE RENFORCEMENT": [...]
            }
            """,
            category: .kine
        ),

        APIEndpoint(
            name: "Get Kine Favorites",
            path: "/api/kine-favorites",
            method: "GET",
            requiresAuth: true,
            expectedFormat: "[1, 3, 5]",
            category: .kine
        ),

        APIEndpoint(
            name: "Toggle Kine Favorite",
            path: "/api/kine-favorites/toggle",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "status": "attached",
              "attached": true
            }
            """,
            testBody: [
                "exercise_id": 1
            ],
            category: .kine
        ),

        // ========================================
        // 11. SETTINGS
        // ========================================

        APIEndpoint(
            name: "Get Reminder Settings",
            path: "/api/settings/reminders",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "id": 1,
              "breakfast_enabled": true,
              "breakfast_time": "08:00:00",
              "lunch_enabled": true,
              "lunch_time": "12:00:00",
              "dinner_enabled": true,
              "dinner_time": "19:00:00",
              "workout_enabled": true,
              "workout_time": "07:00:00"
            }
            """,
            category: .settings
        ),

        APIEndpoint(
            name: "Update Reminder Settings",
            path: "/api/settings/reminders",
            method: "PUT",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Settings updated successfully"
            }
            """,
            testBody: [
                "breakfast_enabled": true,
                "breakfast_time": "08:00:00",
                "lunch_enabled": false,
                "lunch_time": "12:00:00",
                "dinner_enabled": true,
                "dinner_time": "19:00:00",
                "workout_enabled": true,
                "workout_time": "07:00:00"
            ],
            category: .settings
        ),

        // ========================================
        // 12. LOGOUT (LAST - invalidates token)
        // ========================================

        APIEndpoint(
            name: "Logout User",
            path: "/api/auth/logout",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Logged out successfully"
            }
            """,
            category: .auth
        )
    ]

    // Group endpoints by category
    var endpointsByCategory: [EndpointCategory: [APIEndpoint]] {
        Dictionary(grouping: endpoints, by: { $0.category })
    }

    init() {
        checkToken()
    }

    func checkToken() {
        hasToken = APITokenManager.shared.currentToken != nil
        #if DEBUG
        logger.info("Token status: \(self.hasToken ? "available" : "missing")")
        #endif
    }

    // Test all endpoints
    func testAllEndpoints() async {
        print("\n" + String(repeating: "=", count: 80))
        print("🧪 STARTING COMPREHENSIVE API TEST SUITE")
        print(String(repeating: "=", count: 80))
        print("⏰ Start Time: \(Date())")
        print("🔐 Token Status: \(hasToken ? "✅ Available" : "❌ Missing")")
        print(String(repeating: "=", count: 80) + "\n")

        logger.info("🧪 Starting full API test suite")

        await MainActor.run {
            isTesting = true
            testProgress = 0.0
        }

        // Test in smart order: public first, then setup, then protected
        let publicEndpoints = endpoints.filter { !$0.requiresAuth }
        let protectedEndpoints = endpoints.filter { $0.requiresAuth }

        print("📊 Test Plan:")
        print("   - Public endpoints: \(publicEndpoints.count)")
        print("   - Protected endpoints: \(protectedEndpoints.count)")
        print("   - Total: \(endpoints.count)\n")

        let totalEndpoints = endpoints.count
        var completedEndpoints = 0

        // 1. Test public endpoints first
        print("📋 PHASE 1: Testing Public Endpoints (\(publicEndpoints.count) tests)")
        print(String(repeating: "-", count: 80))

        for endpoint in publicEndpoints {
            await MainActor.run {
                currentTestingEndpoint = endpoint.name
            }
            await testEndpoint(endpoint)
            completedEndpoints += 1
            await MainActor.run {
                testProgress = Double(completedEndpoints) / Double(totalEndpoints)
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }

        // 2. Check if we have a token now
        checkToken()

        print("\n" + String(repeating: "=", count: 80))
        print("🔄 TOKEN CHECK AFTER PUBLIC TESTS")
        print(String(repeating: "=", count: 80))

        if !hasToken {
            print("⚠️  WARNING: No authentication token available")
            print("💡 TIP: Protected endpoints will likely fail with 401 errors")
        } else {
            print("✅ Authentication token is available")
        }

        print(String(repeating: "=", count: 80) + "\n")

        // 3. Test protected endpoints
        print("📋 PHASE 2: Testing Protected Endpoints (\(protectedEndpoints.count) tests)")
        print(String(repeating: "-", count: 80))

        for endpoint in protectedEndpoints {
            await MainActor.run {
                currentTestingEndpoint = endpoint.name
            }
            await testEndpoint(endpoint)
            completedEndpoints += 1
            await MainActor.run {
                testProgress = Double(completedEndpoints) / Double(totalEndpoints)
            }
            try? await Task.sleep(nanoseconds: 300_000_000)
        }

        // Final summary
        await MainActor.run {
            isTesting = false
            currentTestingEndpoint = nil

            let passed = results.values.filter { $0.success }.count
            let failed = results.values.filter { !$0.success }.count
            let total = results.count

            print("\n" + String(repeating: "=", count: 80))
            print("📊 FINAL TEST RESULTS")
            print(String(repeating: "=", count: 80))
            print("⏰ Completion Time: \(Date())")
            print("📈 Results: \(passed) passed, \(failed) failed, \(total) total")
            print("📊 Success Rate: \(total > 0 ? String(format: "%.1f%%", Double(passed) / Double(total) * 100) : "0%")")
            print(String(repeating: "=", count: 80))

            // Results by category
            print("\n📁 RESULTS BY CATEGORY:")
            for category in EndpointCategory.allCases {
                let categoryEndpoints = endpoints.filter { $0.category == category }
                if categoryEndpoints.isEmpty { continue }

                let categoryPassed = categoryEndpoints.filter { results[$0.id]?.success == true }.count
                let categoryTotal = categoryEndpoints.count
                let emoji = categoryPassed == categoryTotal ? "✅" : (categoryPassed > 0 ? "⚠️" : "❌")
                print("   \(emoji) \(category.rawValue): \(categoryPassed)/\(categoryTotal)")
            }

            print(String(repeating: "=", count: 80) + "\n")

            logger.info("✅ Test suite completed: \(passed)/\(total) passed")
        }
    }

    // Test single endpoint with full JSON analysis
    func testEndpoint(_ endpoint: APIEndpoint) async {
        print("\n" + String(repeating: "-", count: 60))
        print("🔍 Testing: \(endpoint.name)")
        print("   📍 \(endpoint.method) \(endpoint.path)")
        print("   🔐 Auth Required: \(endpoint.requiresAuth ? "Yes" : "No")")
        print("   📁 Category: \(endpoint.category.rawValue)")

        logger.info("🧪 Testing: \(endpoint.method) \(endpoint.path)")

        let startTime = Date()

        do {
            // Use the centralized base URL from APIConstants
            let baseURL: String = {
                let full = APIConstants.baseURL
                // Strip "/api" suffix since endpoint paths already include "/api/"
                if full.hasSuffix("/api") {
                    return String(full.dropLast(4))
                }
                return full
            }()

            print("   🌐 URL: \(baseURL)\(endpoint.path)")

            guard let url = URL(string: baseURL + endpoint.path) else {
                print("   ❌ FAILED: Invalid URL")
                await recordResult(for: endpoint, success: false, statusCode: nil, error: "Invalid URL", data: nil, rawData: nil, startTime: startTime, analysis: nil)
                return
            }

            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            request.setValue(APIConstants.appKey, forHTTPHeaderField: "X-App-Key")

            // Add auth token if required
            if endpoint.requiresAuth {
                guard let token = APITokenManager.shared.currentToken else {
                    print("   ❌ FAILED: No auth token available")
                    await recordResult(for: endpoint, success: false, statusCode: 401, error: "No auth token available", data: nil, rawData: nil, startTime: startTime, analysis: nil)
                    return
                }
                print("   🔑 Auth token: present")
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }

            // Add body for POST/PUT requests
            if (endpoint.method == "POST" || endpoint.method == "PUT"), let testBody = endpoint.testBody {
                request.httpBody = try? JSONSerialization.data(withJSONObject: testBody)
                if let bodyData = request.httpBody,
                   let bodyString = String(data: bodyData, encoding: .utf8) {
                    print("   📦 Request Body: \(bodyString.prefix(200))\(bodyString.count > 200 ? "..." : "")")
                }
            }

            print("   ⏳ Sending request...")

            // Make request
            let (data, response) = try await URLSession.shared.data(for: request)

            guard let httpResponse = response as? HTTPURLResponse else {
                print("   ❌ FAILED: Invalid response type")
                await recordResult(for: endpoint, success: false, statusCode: nil, error: "Invalid response", data: nil, rawData: nil, startTime: startTime, analysis: nil)
                return
            }

            let responseTime = Date().timeIntervalSince(startTime)
            let responseTimeMs = Int(responseTime * 1000)

            print("   📥 Response: HTTP \(httpResponse.statusCode) (\(responseTimeMs)ms)")

            let prettyJSON = prettyPrintJSON(data)
            let jsonAnalysis = analyzeJSON(data)

            if (200...299).contains(httpResponse.statusCode) {
                print("   ✅ SUCCESS: HTTP \(httpResponse.statusCode)")
                print("   ⏱️  Response Time: \(responseTimeMs)ms")

                // Show JSON analysis
                if let analysis = jsonAnalysis {
                    print("   📊 JSON Analysis:")
                    print("      - Root Type: \(analysis.rootType)")
                    print("      - Fields: \(analysis.fieldCount)")
                    if let arrayCount = analysis.arrayCount {
                        print("      - Array Items: \(arrayCount)")
                    }

                    // Show field details
                    print("   📋 Fields:")
                    for field in analysis.fields.prefix(10) {
                        let valuePreview = field.value.prefix(50)
                        print("      • \(field.name): \(field.type) = \(valuePreview)\(field.value.count > 50 ? "..." : "")")
                    }
                    if analysis.fields.count > 10 {
                        print("      ... and \(analysis.fields.count - 10) more fields")
                    }
                }

                // 📋 LOG FULL JSON RESPONSE TO CONSOLE
                print("\n   ╔══════════════════════════════════════════════════════════════════╗")
                print("   ║ 📄 FULL JSON RESPONSE - \(endpoint.name)")
                print("   ╚══════════════════════════════════════════════════════════════════╝")
                print(prettyJSON)
                print("   ╔══════════════════════════════════════════════════════════════════╗")
                print("   ║ 📄 END OF JSON - \(endpoint.name)")
                print("   ╚══════════════════════════════════════════════════════════════════╝\n")

                // Special handling for login/register endpoints
                if endpoint.path.contains("/login") || endpoint.path.contains("/register") {
                    extractAndStoreToken(from: data)
                }

                logger.info("✅ \(endpoint.name): Success (\(httpResponse.statusCode))")
                await recordResult(for: endpoint, success: true, statusCode: httpResponse.statusCode, error: nil, data: prettyJSON, rawData: data, startTime: startTime, analysis: jsonAnalysis)
            } else {
                // Extract error message from response
                var errorMsg = "HTTP \(httpResponse.statusCode)"
                if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let message = errorData["message"] as? String {
                        errorMsg += ": \(message)"
                    } else if let error = errorData["error"] as? String {
                        errorMsg += ": \(error)"
                    }
                }

                print("   ❌ FAILED: \(errorMsg)")

                // 📋 LOG FULL ERROR JSON RESPONSE TO CONSOLE
                print("\n   ╔══════════════════════════════════════════════════════════════════╗")
                print("   ║ ❌ FULL ERROR RESPONSE - \(endpoint.name)")
                print("   ╚══════════════════════════════════════════════════════════════════╝")
                print(prettyJSON)
                print("   ╔══════════════════════════════════════════════════════════════════╗")
                print("   ║ ❌ END OF ERROR - \(endpoint.name)")
                print("   ╚══════════════════════════════════════════════════════════════════╝\n")

                logger.error("❌ \(endpoint.name): \(errorMsg)")
                await recordResult(for: endpoint, success: false, statusCode: httpResponse.statusCode, error: errorMsg, data: prettyJSON, rawData: data, startTime: startTime, analysis: jsonAnalysis)
            }

        } catch {
            let responseTime = Date().timeIntervalSince(startTime)
            let responseTimeMs = Int(responseTime * 1000)

            print("   ❌ EXCEPTION: \(error.localizedDescription)")
            print("   ⏱️  Time: \(responseTimeMs)ms")

            logger.error("❌ \(endpoint.name): \(error.localizedDescription)")
            await recordResult(for: endpoint, success: false, statusCode: nil, error: error.localizedDescription, data: nil, rawData: nil, startTime: startTime, analysis: nil)
        }
    }

    private func extractAndStoreToken(from data: Data) {
        // Try nested structure first: { "data": { "token": "..." } }
        if let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            if let dataObj = jsonObject["data"] as? [String: Any],
               let token = dataObj["token"] as? String {
                #if DEBUG
                print("   🔑 Token extracted (nested)")
                #endif
                Task { @MainActor in
                    APITokenManager.shared.currentToken = token
                    self.checkToken()
                }
                return
            }
            // Try flat structure: { "token": "..." }
            if let token = jsonObject["token"] as? String {
                #if DEBUG
                print("   🔑 Token extracted (flat)")
                #endif
                Task { @MainActor in
                    APITokenManager.shared.currentToken = token
                    self.checkToken()
                }
            }
        }
    }

    private func recordResult(for endpoint: APIEndpoint, success: Bool, statusCode: Int?, error: String?, data: String?, rawData: Data?, startTime: Date, analysis: JSONAnalysis?) async {
        let responseTime = Date().timeIntervalSince(startTime)

        let result = TestResult(
            success: success,
            statusCode: statusCode,
            error: error,
            responseData: data,
            rawData: rawData,
            responseTime: responseTime,
            timestamp: Date(),
            jsonAnalysis: analysis
        )

        await MainActor.run {
            results[endpoint.id] = result
        }
    }

    private func prettyPrintJSON(_ data: Data) -> String {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data),
              let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
              let prettyString = String(data: prettyData, encoding: .utf8) else {
            return String(data: data, encoding: .utf8) ?? "Unable to decode"
        }
        return prettyString
    }

    // MARK: - JSON Analysis

    private func analyzeJSON(_ data: Data) -> JSONAnalysis? {
        guard let jsonObject = try? JSONSerialization.jsonObject(with: data) else {
            return nil
        }

        return analyzeJSONValue(jsonObject)
    }

    private func analyzeJSONValue(_ value: Any) -> JSONAnalysis {
        var fields: [JSONField] = []
        var nestedObjects: [String: JSONAnalysis] = [:]
        var rootType = "unknown"
        var arrayCount: Int? = nil

        if let dict = value as? [String: Any] {
            rootType = "object"
            for (key, val) in dict.sorted(by: { $0.key < $1.key }) {
                let field = createJSONField(name: key, value: val)
                fields.append(field)

                // Analyze nested objects
                if let nestedDict = val as? [String: Any] {
                    nestedObjects[key] = analyzeJSONValue(nestedDict)
                } else if let nestedArray = val as? [[String: Any]], let first = nestedArray.first {
                    nestedObjects[key] = analyzeJSONValue(first)
                }
            }
        } else if let array = value as? [Any] {
            rootType = "array"
            arrayCount = array.count

            // Analyze first item structure
            if let firstItem = array.first as? [String: Any] {
                for (key, val) in firstItem.sorted(by: { $0.key < $1.key }) {
                    let field = createJSONField(name: key, value: val)
                    fields.append(field)
                }
            }
        } else if value is NSNull {
            rootType = "null"
        } else if value is String {
            rootType = "string"
        } else if value is NSNumber {
            rootType = "number"
        } else if value is Bool {
            rootType = "boolean"
        }

        return JSONAnalysis(
            isValidJSON: true,
            rootType: rootType,
            fieldCount: fields.count,
            arrayCount: arrayCount,
            fields: fields,
            nestedObjects: nestedObjects
        )
    }

    private func createJSONField(name: String, value: Any) -> JSONField {
        let type: String
        let stringValue: String
        let isNull: Bool

        if value is NSNull {
            type = "null"
            stringValue = "null"
            isNull = true
        } else if let str = value as? String {
            type = "string"
            stringValue = "\"\(str)\""
            isNull = false
        } else if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() {
                type = "boolean"
                stringValue = num.boolValue ? "true" : "false"
            } else {
                type = "number"
                stringValue = "\(num)"
            }
            isNull = false
        } else if let arr = value as? [Any] {
            type = "array[\(arr.count)]"
            stringValue = "[\(arr.count) items]"
            isNull = false
        } else if value is [String: Any] {
            type = "object"
            stringValue = "{...}"
            isNull = false
        } else {
            type = "unknown"
            stringValue = "\(value)"
            isNull = false
        }

        return JSONField(name: name, type: type, value: stringValue, isNull: isNull)
    }

    // MARK: - Log All JSON to Console

    func logAllJSONToConsole() {
        print("\n" + String(repeating: "═", count: 80))
        print("📋 LOGGING ALL JSON RESPONSES TO CONSOLE")
        print(String(repeating: "═", count: 80))
        print("⏰ Timestamp: \(Date())")
        print("📊 Total Endpoints: \(results.count)")
        print(String(repeating: "═", count: 80) + "\n")

        for endpoint in endpoints {
            guard let result = results[endpoint.id] else { continue }

            print("\n" + String(repeating: "─", count: 80))
            print("[\(result.success ? "✅ PASS" : "❌ FAIL")] \(endpoint.name)")
            print(String(repeating: "─", count: 80))
            print("📍 \(endpoint.method) \(endpoint.path)")
            print("📁 Category: \(endpoint.category.rawValue)")
            print("🔐 Auth Required: \(endpoint.requiresAuth ? "Yes" : "No")")
            print("📡 Status: \(result.statusCode.map { "HTTP \($0)" } ?? "N/A")")
            print("⏱️  Response Time: \(Int(result.responseTime * 1000))ms")

            if let error = result.error {
                print("❌ Error: \(error)")
            }

            if let analysis = result.jsonAnalysis {
                print("\n📊 JSON Structure:")
                print("   Root Type: \(analysis.rootType)")
                print("   Fields: \(analysis.fieldCount)")
                if let arrayCount = analysis.arrayCount {
                    print("   Array Items: \(arrayCount)")
                }
                print("\n   Field Details:")
                for field in analysis.fields {
                    print("   • \(field.name): \(field.type) = \(field.value.prefix(100))\(field.value.count > 100 ? "..." : "")")
                }
            }

            if let responseData = result.responseData {
                print("\n╔══════════════════════════════════════════════════════════════════════════════╗")
                print("║ 📄 FULL JSON DATA")
                print("╚══════════════════════════════════════════════════════════════════════════════╝")
                print(responseData)
                print("╔══════════════════════════════════════════════════════════════════════════════╗")
                print("║ 📄 END OF JSON")
                print("╚══════════════════════════════════════════════════════════════════════════════╝")
            }
        }

        print("\n" + String(repeating: "═", count: 80))
        print("📋 END OF ALL JSON RESPONSES")
        print(String(repeating: "═", count: 80) + "\n")
    }

    // MARK: - Generate Full Report

    func generateFullReport() -> String {
        let timestamp = Date()
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .medium

        var report = """
        ════════════════════════════════════════════════════════════════════════════════
        📊 COMPREHENSIVE API TEST REPORT
        ════════════════════════════════════════════════════════════════════════════════
        Generated: \(formatter.string(from: timestamp))

        🔐 AUTHENTICATION STATUS
        ────────────────────────────────────────────────────────────────────────────────
        Token Available: \(hasToken ? "✅ Yes" : "❌ No")

        📈 SUMMARY
        ────────────────────────────────────────────────────────────────────────────────
        Total Tests: \(results.count)
        Passed: \(results.values.filter { $0.success }.count) ✅
        Failed: \(results.values.filter { !$0.success }.count) ❌
        Success Rate: \(results.count > 0 ? String(format: "%.1f%%", Double(results.values.filter { $0.success }.count) / Double(results.count) * 100) : "0%")

        📁 RESULTS BY CATEGORY
        ────────────────────────────────────────────────────────────────────────────────

        """

        for category in EndpointCategory.allCases {
            let categoryEndpoints = endpoints.filter { $0.category == category }
            if categoryEndpoints.isEmpty { continue }

            let categoryPassed = categoryEndpoints.filter { results[$0.id]?.success == true }.count
            let categoryTotal = categoryEndpoints.count

            report += "\n▶ \(category.rawValue.uppercased())\n"
            report += "  Passed: \(categoryPassed)/\(categoryTotal)\n"

            for endpoint in categoryEndpoints {
                if let result = results[endpoint.id] {
                    let status = result.success ? "✅" : "❌"
                    let time = Int(result.responseTime * 1000)
                    let httpCode = result.statusCode.map { "HTTP \($0)" } ?? "N/A"

                    report += "  \(status) \(endpoint.name) [\(httpCode), \(time)ms]\n"

                    if !result.success, let error = result.error {
                        report += "     └─ Error: \(error)\n"
                    }

                    // Include JSON analysis for successful requests
                    if result.success, let analysis = result.jsonAnalysis {
                        report += "     └─ JSON: \(analysis.rootType), \(analysis.fieldCount) fields"
                        if let arrayCount = analysis.arrayCount {
                            report += ", \(arrayCount) items"
                        }
                        report += "\n"
                    }
                } else {
                    report += "  ⏸ \(endpoint.name) [Not tested]\n"
                }
            }
        }

        report += """

        ════════════════════════════════════════════════════════════════════════════════
        📋 DETAILED JSON RESPONSES
        ════════════════════════════════════════════════════════════════════════════════

        """

        for endpoint in endpoints {
            guard let result = results[endpoint.id] else { continue }

            report += """

            ────────────────────────────────────────────────────────────────────────────────
            [\(result.success ? "✅ PASS" : "❌ FAIL")] \(endpoint.name)
            ────────────────────────────────────────────────────────────────────────────────
            Method: \(endpoint.method)
            Path: \(endpoint.path)
            Category: \(endpoint.category.rawValue)
            Requires Auth: \(endpoint.requiresAuth ? "Yes" : "No")
            Status: \(result.statusCode.map { "HTTP \($0)" } ?? "N/A")
            Response Time: \(Int(result.responseTime * 1000))ms

            """

            if let error = result.error {
                report += "ERROR: \(error)\n\n"
            }

            if let analysis = result.jsonAnalysis {
                report += "JSON STRUCTURE:\n"
                report += "  Root Type: \(analysis.rootType)\n"
                report += "  Field Count: \(analysis.fieldCount)\n"
                if let arrayCount = analysis.arrayCount {
                    report += "  Array Items: \(arrayCount)\n"
                }
                report += "\n  Fields:\n"
                for field in analysis.fields {
                    report += "    • \(field.name): \(field.type)\n"
                }
                report += "\n"
            }

            if let responseData = result.responseData {
                // Limit response to 1000 chars per endpoint
                let truncatedData = responseData.count > 1000 ?
                    String(responseData.prefix(1000)) + "\n... [truncated, \(responseData.count) total chars]" :
                    responseData
                report += "RESPONSE DATA:\n\(truncatedData)\n"
            }
        }

        report += """

        ════════════════════════════════════════════════════════════════════════════════
        END OF REPORT
        ════════════════════════════════════════════════════════════════════════════════

        """

        return report
    }
}
