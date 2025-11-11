//
//  APITester.swift
//  FootballApp
//
//  API endpoint testing logic
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
    
    init(name: String, path: String, method: String = "GET", requiresAuth: Bool = true, expectedFormat: String, testBody: [String: Any]? = nil) {
        self.name = name
        self.path = path
        self.method = method
        self.requiresAuth = requiresAuth
        self.expectedFormat = expectedFormat
        self.testBody = testBody
    }
}

// MARK: - Test Result
struct TestResult {
    let success: Bool
    let error: String?
    let responseData: String?
    let responseTime: TimeInterval
    let timestamp: Date
}

// MARK: - API Tester
class APITester: ObservableObject {
    @Published var results: [UUID: TestResult] = [:]
    @Published var isTesting = false
    @Published var hasToken: Bool = false
    
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
              "token": "...",
              "user": {...}
            }
            """,
            testBody: [
                "name": "Test User",
                "email": "test\(Int.random(in: 1000...9999))@example.com",
                "password": "Password123",
                "password_confirmation": "Password123"
            ]
        ),
        
        APIEndpoint(
            name: "Login User",
            path: "/api/auth/login",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "token": "...",
              "user": {...}
            }
            """,
            testBody: [
                "email": "user@example.com",
                "password": "password"
            ]
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
                "email": "user@example.com"
            ]
        ),
        
        APIEndpoint(
            name: "Social Login - Google",
            path: "/api/auth/google/login",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "token": "...",
              "user": {...}
            }
            """,
            testBody: [
                "token": "fake-google-token-for-testing"
            ]
        ),
        
        APIEndpoint(
            name: "Social Login - Apple",
            path: "/api/auth/apple/login",
            method: "POST",
            requiresAuth: false,
            expectedFormat: """
            {
              "token": "...",
              "user": {...}
            }
            """,
            testBody: [
                "token": "fake-apple-token-for-testing"
            ]
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
              "goal": [...]
            }
            """
        ),
        
        // ========================================
        // 3. PROTECTED ROUTES (Requires API Token)
        // ========================================
        
        // --- Auth ---
        APIEndpoint(
            name: "Logout User",
            path: "/api/auth/logout",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Logged out successfully"
            }
            """
        ),
        
        // --- User & Profile ---
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
              "profile": {...}
            }
            """
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
            ]
        ),
        
        // --- Dashboard ---
        APIEndpoint(
            name: "Get Dashboard Metrics",
            path: "/api/dashboard-metrics",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "stats": {...},
              "chart": {...},
              "my_latest_progress": [...]
            }
            """
        ),
        
        // --- Nutrition ---
        APIEndpoint(
            name: "Get/Generate Nutrition Plan",
            path: "/api/nutrition-plan",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "daily_calorie_intake": 2500,
              "macros": {...},
              "daily_meals": [...],
              "advice": [...]
            }
            """
        ),
        
        // --- Workouts ---
        APIEndpoint(
            name: "Generate Workout Plan",
            path: "/api/workout-plan/generate",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "message": "Workout plan generated successfully"
            }
            """
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
                "day": "Lundi",
                "theme": "Force",
                "warmup": "5 min",
                "finisher": "Stretching",
                "exercises": [...]
              }
            ]
            """
        ),
        
        APIEndpoint(
            name: "Log Progress",
            path: "/api/user-progress",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "id": 1,
              "date": "2025-12-12",
              "workout_completed": "Lundi"
            }
            """,
            testBody: [
                "date": "2025-12-12",
                "workout_completed": "Monday Test",
                "mood": "energized"
            ]
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
                "date": "2025-12-12",
                "workout_completed": "Lundi",
                "weight": 75.5
              }
            ]
            """
        ),
        
        // --- Kine Tab ---
        APIEndpoint(
            name: "Get Kine Exercise Data",
            path: "/api/kine-data",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "Group Name 1": [
                {
                  "id": 1,
                  "name": "Exercise Name",
                  "category": "KINE MOBILITÉ",
                  ...
                }
              ]
            }
            """
        ),
        
        APIEndpoint(
            name: "Get Kine Favorites",
            path: "/api/kine-favorites",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            [1, 3, 5]
            """
        ),
        
        APIEndpoint(
            name: "Toggle Kine Favorite",
            path: "/api/kine-favorites/toggle",
            method: "POST",
            requiresAuth: true,
            expectedFormat: """
            {
              "attached": true
            }
            """,
            testBody: [
                "exercise_id": 1
            ]
        ),
        
        // --- Settings ---
        APIEndpoint(
            name: "Get Reminder Settings",
            path: "/api/settings/reminders",
            method: "GET",
            requiresAuth: true,
            expectedFormat: """
            {
              "id": 1,
              "breakfast_enabled": true,
              "lunch_enabled": true,
              "dinner_enabled": true,
              "workout_enabled": true
            }
            """
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
                "lunch_enabled": false,
                "dinner_enabled": true,
                "workout_enabled": true
            ]
        )
    ]
    
    init() {
        checkToken()
    }
    
    func checkToken() {
        hasToken = APITokenManager.shared.currentToken != nil
        if let token = APITokenManager.shared.currentToken {
            logger.info("✅ Token found: \(token.prefix(20))...")
        } else {
            logger.warning("❌ No token found")
        }
    }
    
    // Test all endpoints
    func testAllEndpoints() async {
        logger.info("🧪 Starting full API test suite")
        isTesting = true
        
        for endpoint in endpoints {
            await testEndpoint(endpoint)
            try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 second delay between tests
        }
        
        await MainActor.run {
            isTesting = false
            logger.info("✅ Test suite completed")
        }
    }
    
    // Test single endpoint
    func testEndpoint(_ endpoint: APIEndpoint) async {
        logger.info("🧪 Testing: \(endpoint.method) \(endpoint.path)")
        
        let startTime = Date()
        
        do {
            // Create request
            guard let url = URL(string: "http://localhost" + endpoint.path) else {
                await recordResult(for: endpoint, success: false, error: "Invalid URL", data: nil, startTime: startTime)
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = endpoint.method
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.setValue("application/json", forHTTPHeaderField: "Accept")
            
            // Add auth token if required
            if endpoint.requiresAuth {
                guard let token = APITokenManager.shared.currentToken else {
                    await recordResult(for: endpoint, success: false, error: "No auth token available", data: nil, startTime: startTime)
                    return
                }
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
            
            // Add body for POST/PUT requests
            if (endpoint.method == "POST" || endpoint.method == "PUT"), let testBody = endpoint.testBody {
                request.httpBody = try? JSONSerialization.data(withJSONObject: testBody)
            }
            
            // Make request
            let (data, response) = try await URLSession.shared.data(for: request)
            
            guard let httpResponse = response as? HTTPURLResponse else {
                await recordResult(for: endpoint, success: false, error: "Invalid response", data: nil, startTime: startTime)
                return
            }
            
            _ = String(data: data, encoding: .utf8) ?? "Unable to decode response"
            let prettyJSON = prettyPrintJSON(data)
            
            if (200...299).contains(httpResponse.statusCode) {
                logger.info("✅ \(endpoint.name): Success (\(httpResponse.statusCode))")
                await recordResult(for: endpoint, success: true, error: nil, data: prettyJSON, startTime: startTime)
            } else {
                logger.error("❌ \(endpoint.name): Failed (\(httpResponse.statusCode))")
                await recordResult(for: endpoint, success: false, error: "HTTP \(httpResponse.statusCode)", data: prettyJSON, startTime: startTime)
            }
            
        } catch {
            logger.error("❌ \(endpoint.name): \(error.localizedDescription)")
            await recordResult(for: endpoint, success: false, error: error.localizedDescription, data: nil, startTime: startTime)
        }
    }
    
    private func recordResult(for endpoint: APIEndpoint, success: Bool, error: String?, data: String?, startTime: Date) async {
        let responseTime = Date().timeIntervalSince(startTime)
        
        let result = TestResult(
            success: success,
            error: error,
            responseData: data,
            responseTime: responseTime,
            timestamp: Date()
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
}
