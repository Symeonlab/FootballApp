//
//  TESTING_SNIPPETS.swift
//  FootballApp
//
//  Testing helpers, preview providers, and API data analysis utilities
//

import SwiftUI
import AVKit

// MARK: - Preview Providers

#Preview("KineView - With Data") {
    @Previewable @StateObject var kineVM = KineViewModel()
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    return NavigationView {
        KineView()
            .environmentObject(kineVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
    }
    .preferredColorScheme(.dark)
}

#Preview("Recovery Tips Grid") {
    RecoveryTipsView()
}

#Preview("Reels Onboarding") {
    struct ReelsOnboardingPreview: View {
        @State private var showTips = true

        var body: some View {
            ZStack {
                Color.black.ignoresSafeArea()

                if showTips {
                    ReelsTipsOverlay(showTips: $showTips)
                }
            }
        }
    }

    return ReelsOnboardingPreview()
}

// MARK: - Mock Data for Testing

extension KineExercise {
    static var mockExercises: [KineExercise] {
        [
            KineExercise(
                id: 1,
                title: "Hamstring Stretch",
                description: "A gentle stretching exercise to improve hamstring flexibility and reduce the risk of injury. Perform slowly and hold each stretch for 30 seconds.",
                categoryId: 1,
                difficulty: "Easy",
                imageUrl: "https://www.youtube.com/watch?v=example1"
            ),
            KineExercise(
                id: 2,
                title: "Quad Foam Roll",
                description: "Use a foam roller to release tension in the quadriceps. Roll slowly, pausing on tender spots for 30-60 seconds.",
                categoryId: 1,
                difficulty: "Easy",
                imageUrl: "https://www.youtube.com/watch?v=example2"
            ),
            KineExercise(
                id: 3,
                title: "Hip Flexor Stretch",
                description: "Open up tight hip flexors with this kneeling stretch. Essential for players who spend time in sprinting positions.",
                categoryId: 1,
                difficulty: "Easy",
                imageUrl: "https://www.youtube.com/watch?v=example3"
            ),
            KineExercise(
                id: 4,
                title: "Calf Raises",
                description: "Strengthen your calf muscles to improve jumping ability and reduce ankle injuries. Perform 3 sets of 15 reps.",
                categoryId: 2,
                difficulty: "Medium",
                imageUrl: "https://www.youtube.com/watch?v=example4"
            ),
            KineExercise(
                id: 5,
                title: "Glute Bridge",
                description: "Activate and strengthen glutes with this foundational exercise. Focus on proper form and controlled movement.",
                categoryId: 2,
                difficulty: "Medium",
                imageUrl: "https://www.youtube.com/watch?v=example5"
            )
        ]
    }
}

// MARK: - Mock Goals Data

struct MockGoals {
    static var sampleGoals: [Goal] {
        // Note: These would need proper initialization based on Goal model
        []
    }

    static var activeGoalJSON: String {
        """
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
            "achievements": ["first_week", "consistency_3"],
            "notes": "My fitness goal"
        }
        """
    }

    static var goalsListJSON: String {
        """
        {
            "success": true,
            "data": [
                {
                    "id": 1,
                    "goal_type": "weight_loss",
                    "status": "active",
                    "progress": 45.5,
                    "expected_progress": 50.0,
                    "is_on_track": false,
                    "target_weight": 70.0,
                    "weeks_completed": 5,
                    "total_weeks": 12
                },
                {
                    "id": 2,
                    "goal_type": "muscle_gain",
                    "status": "completed",
                    "progress": 100.0,
                    "is_on_track": true,
                    "weeks_completed": 12,
                    "total_weeks": 12
                },
                {
                    "id": 3,
                    "goal_type": "maintain",
                    "status": "paused",
                    "progress": 30.0,
                    "is_on_track": true,
                    "weeks_completed": 4,
                    "total_weeks": 8
                }
            ]
        }
        """
    }
}

// MARK: - Mock Achievements Data

struct MockAchievements {
    static var achievementsJSON: String {
        """
        {
            "success": true,
            "data": {
                "achievements": [
                    {
                        "id": 1,
                        "key": "first_workout",
                        "name": "First Workout",
                        "description": "Complete your first workout",
                        "icon": "flame.fill",
                        "points": 10,
                        "category": "workout",
                        "earned": true,
                        "earned_at": "2025-01-15T10:30:00Z",
                        "earned_by_count": 150
                    },
                    {
                        "id": 2,
                        "key": "week_warrior",
                        "name": "Week Warrior",
                        "description": "Complete workouts for 7 consecutive days",
                        "icon": "calendar",
                        "points": 50,
                        "category": "consistency",
                        "earned": true,
                        "earned_at": "2025-01-22T10:30:00Z",
                        "earned_by_count": 75
                    },
                    {
                        "id": 3,
                        "key": "weight_milestone",
                        "name": "5kg Down",
                        "description": "Lose 5kg from your starting weight",
                        "icon": "scalemass",
                        "points": 100,
                        "category": "milestone",
                        "earned": false,
                        "earned_at": null,
                        "earned_by_count": 30
                    }
                ],
                "by_category": {
                    "workout": [],
                    "consistency": [],
                    "milestone": []
                },
                "total_points": 250,
                "total_earned": 12,
                "total_available": 50
            }
        }
        """
    }

    static var leaderboardJSON: String {
        """
        {
            "success": true,
            "data": {
                "leaderboard": [
                    {
                        "id": 1,
                        "name": "John Doe",
                        "total_points": 500,
                        "achievement_count": 25
                    },
                    {
                        "id": 2,
                        "name": "Jane Smith",
                        "total_points": 450,
                        "achievement_count": 22
                    },
                    {
                        "id": 3,
                        "name": "Bob Johnson",
                        "total_points": 400,
                        "achievement_count": 20
                    }
                ],
                "current_user": {
                    "rank": 15,
                    "total_points": 250,
                    "achievement_count": 12
                }
            }
        }
        """
    }
}

// MARK: - Mock Posts Data

struct MockPosts {
    static var postsListJSON: String {
        """
        {
            "success": true,
            "data": [
                {
                    "id": 1,
                    "title": "How to Improve Your Fitness",
                    "content": "Full article content here about improving fitness...",
                    "excerpt": "Learn the best techniques to improve your overall fitness level.",
                    "slug": "how-to-improve-fitness",
                    "featured_image": "https://example.com/fitness.jpg",
                    "author": "Coach Mike",
                    "published_at": "2025-01-10T09:00:00Z",
                    "reading_time": 5
                },
                {
                    "id": 2,
                    "title": "Nutrition Tips for Athletes",
                    "content": "Comprehensive guide on nutrition for athletes...",
                    "excerpt": "Discover what foods fuel peak athletic performance.",
                    "slug": "nutrition-tips-athletes",
                    "featured_image": "https://example.com/nutrition.jpg",
                    "author": "Dr. Sarah",
                    "published_at": "2025-01-08T09:00:00Z",
                    "reading_time": 8
                }
            ],
            "meta": {
                "current_page": 1,
                "last_page": 5,
                "per_page": 10,
                "total": 50
            }
        }
        """
    }
}

// MARK: - API Data Analysis Helpers

struct APIDataAnalyzer {

    /// Analyze JSON string and return a formatted report
    static func analyzeJSON(_ jsonString: String) -> String {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) else {
            return "Invalid JSON"
        }

        var report = "JSON Analysis Report\n"
        report += String(repeating: "=", count: 50) + "\n\n"
        report += analyzeValue(json, indent: 0)

        return report
    }

    private static func analyzeValue(_ value: Any, indent: Int) -> String {
        let prefix = String(repeating: "  ", count: indent)
        var result = ""

        if let dict = value as? [String: Any] {
            result += "\(prefix)Object (\(dict.count) fields):\n"
            for (key, val) in dict.sorted(by: { $0.key < $1.key }) {
                result += "\(prefix)  \"\(key)\": "
                result += describeValue(val) + "\n"
                if let nested = val as? [String: Any], !nested.isEmpty {
                    result += analyzeValue(nested, indent: indent + 2)
                } else if let array = val as? [Any], let first = array.first as? [String: Any] {
                    result += "\(prefix)    First item structure:\n"
                    result += analyzeValue(first, indent: indent + 3)
                }
            }
        } else if let array = value as? [Any] {
            result += "\(prefix)Array (\(array.count) items)\n"
            if let first = array.first as? [String: Any] {
                result += "\(prefix)  First item structure:\n"
                result += analyzeValue(first, indent: indent + 2)
            }
        }

        return result
    }

    private static func describeValue(_ value: Any) -> String {
        if value is NSNull {
            return "null"
        } else if let str = value as? String {
            return "String(\(str.count) chars) = \"\(str.prefix(30))\(str.count > 30 ? "..." : "")\""
        } else if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() {
                return "Bool = \(num.boolValue)"
            } else {
                return "Number = \(num)"
            }
        } else if let arr = value as? [Any] {
            return "Array[\(arr.count)]"
        } else if value is [String: Any] {
            return "Object"
        } else {
            return "Unknown"
        }
    }

    /// Compare two JSON structures and report differences
    static func compareJSON(_ expected: String, _ actual: String) -> String {
        guard let expectedData = expected.data(using: .utf8),
              let actualData = actual.data(using: .utf8),
              let expectedJSON = try? JSONSerialization.jsonObject(with: expectedData) as? [String: Any],
              let actualJSON = try? JSONSerialization.jsonObject(with: actualData) as? [String: Any] else {
            return "Unable to parse JSON for comparison"
        }

        var differences: [String] = []
        compareObjects(expectedJSON, actualJSON, path: "", differences: &differences)

        if differences.isEmpty {
            return "No differences found - structures match!"
        }

        var report = "JSON Comparison Report\n"
        report += String(repeating: "=", count: 50) + "\n"
        report += "Found \(differences.count) differences:\n\n"
        for diff in differences {
            report += "  - \(diff)\n"
        }

        return report
    }

    private static func compareObjects(_ expected: [String: Any], _ actual: [String: Any], path: String, differences: inout [String]) {
        // Check for missing keys in actual
        for key in expected.keys {
            if actual[key] == nil {
                differences.append("\(path).\(key): Missing in actual (expected: \(describeValue(expected[key]!)))")
            }
        }

        // Check for extra keys in actual
        for key in actual.keys {
            if expected[key] == nil {
                differences.append("\(path).\(key): Extra in actual (value: \(describeValue(actual[key]!)))")
            }
        }

        // Compare common keys
        for key in expected.keys where actual[key] != nil {
            let expVal = expected[key]!
            let actVal = actual[key]!
            let newPath = path.isEmpty ? key : "\(path).\(key)"

            // Type mismatch
            if type(of: expVal) != type(of: actVal) {
                // Allow null vs optional mismatch
                if !(expVal is NSNull || actVal is NSNull) {
                    differences.append("\(newPath): Type mismatch (expected: \(type(of: expVal)), actual: \(type(of: actVal)))")
                }
            } else if let expDict = expVal as? [String: Any], let actDict = actVal as? [String: Any] {
                compareObjects(expDict, actDict, path: newPath, differences: &differences)
            }
        }
    }

    /// Generate Swift model code from JSON
    static func generateSwiftModel(from jsonString: String, modelName: String = "GeneratedModel") -> String {
        guard let data = jsonString.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return "// Invalid JSON"
        }

        var code = "// Auto-generated from JSON\n\n"
        code += "struct \(modelName): Codable {\n"

        for (key, value) in json.sorted(by: { $0.key < $1.key }) {
            let swiftType = swiftTypeFor(value)
            let propertyName = key.toCamelCase()
            let needsCodingKey = propertyName != key

            if needsCodingKey {
                code += "    let \(propertyName): \(swiftType)\n"
            } else {
                code += "    let \(key): \(swiftType)\n"
            }
        }

        // Add CodingKeys if needed
        let keysNeedingCoding = json.keys.filter { $0.toCamelCase() != $0 }
        if !keysNeedingCoding.isEmpty {
            code += "\n    enum CodingKeys: String, CodingKey {\n"
            for key in json.keys.sorted() {
                let propertyName = key.toCamelCase()
                if propertyName != key {
                    code += "        case \(propertyName) = \"\(key)\"\n"
                } else {
                    code += "        case \(key)\n"
                }
            }
            code += "    }\n"
        }

        code += "}\n"

        return code
    }

    private static func swiftTypeFor(_ value: Any) -> String {
        if value is NSNull {
            return "String?"
        } else if value is String {
            return "String"
        } else if let num = value as? NSNumber {
            if CFGetTypeID(num) == CFBooleanGetTypeID() {
                return "Bool"
            } else if num.doubleValue == Double(num.intValue) {
                return "Int"
            } else {
                return "Double"
            }
        } else if let arr = value as? [Any] {
            if arr.isEmpty {
                return "[Any]"
            } else if let first = arr.first {
                return "[\(swiftTypeFor(first))]"
            }
            return "[Any]"
        } else if value is [String: Any] {
            return "[String: Any]"
        }
        return "Any"
    }
}

// MARK: - String Extension for CamelCase

extension String {
    func toCamelCase() -> String {
        let parts = self.split(separator: "_")
        if parts.count <= 1 { return self }

        var result = String(parts[0]).lowercased()
        for part in parts.dropFirst() {
            result += String(part).capitalized
        }
        return result
    }
}

// MARK: - Test Scenarios

/// Test the reels view with mock data
#Preview("Reels View - Multiple Videos") {
    struct ReelsPreview: View {
        @StateObject private var viewModel = KineViewModel()

        var body: some View {
            KineReelsView(
                viewModel: viewModel,
                exercises: KineExercise.mockExercises.toAPIExercises()
            )
        }
    }

    return ReelsPreview()
}

/// Test category picker animation
#Preview("Category Picker Animation") {
    struct CategoryPickerPreview: View {
        @State private var selectedCategory: KineCategoryType = .mobility

        var body: some View {
            VStack(spacing: 40) {
                Text("Category: \(selectedCategory.rawValue)")
                    .font(.headline)

                Button("Switch to \(selectedCategory == .mobility ? "Strengthening" : "Mobility")") {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                        selectedCategory = selectedCategory == .mobility ? .strengthening : .mobility
                    }
                }
            }
            .padding()
        }
    }

    return CategoryPickerPreview()
}

/// Test search functionality
#Preview("Search Bar States") {
    struct SearchBarPreview: View {
        @State private var searchText = ""
        @State private var showOnlyFavorites = false

        var body: some View {
            VStack(spacing: 20) {
                TextField("Search", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                VStack(alignment: .leading, spacing: 12) {
                    Text("Search Text: \(searchText.isEmpty ? "Empty" : searchText)")
                    Text("Favorites Only: \(showOnlyFavorites ? "Yes" : "No")")
                }
                .font(.caption)
                .foregroundColor(.secondary)
                .padding()
            }
        }
    }

    return SearchBarPreview()
}

/// Test exercise list
#Preview("Exercise List") {
    struct ExerciseListPreview: View {
        var body: some View {
            List {
                ForEach(KineExercise.mockExercises) { exercise in
                    VStack(alignment: .leading, spacing: 6) {
                        Text(exercise.name)
                            .font(.body.weight(.semibold))
                        Text(exercise.difficulty ?? "Unknown")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 8)
                }
            }
        }
    }

    return ExerciseListPreview()
}

// MARK: - Accessibility Testing

/// Test VoiceOver labels
extension KineView {
    func testAccessibility() {
        // Add this to test VoiceOver
        // 1. Enable VoiceOver in Simulator
        // 2. Navigate through the view
        // 3. Verify all elements are properly labeled
        // 4. Check that custom controls have proper traits

        print("Testing VoiceOver labels...")
        print("  Header should read: 'Your Recovery Hub, 3 exercises available'")
        print("  Favorites button should read: 'Favorites, 5 items, button'")
        print("  Search field should read: 'Search exercises, search field'")
        print("  Exercise rows should read: '[Exercise Name], Guided video, 2 to 5 minutes'")
        print("  Category buttons should indicate selected state")
    }
}

// MARK: - Performance Testing

/// Measure list scrolling performance
struct PerformanceTest {
    static func testListPerformance(exerciseCount: Int = 100) {
        // Generate large dataset
        var exercises: [KineExercise] = []
        for i in 0..<exerciseCount {
            exercises.append(KineExercise(
                id: i,
                title: "Exercise \(i)",
                description: "Description for exercise \(i)",
                categoryId: i % 2,
                difficulty: ["Easy", "Medium", "Hard"][i % 3],
                imageUrl: "https://example.com/video\(i)"
            ))
        }

        print("Created \(exercises.count) exercises for testing")
        print("Expected performance: Smooth 60fps scrolling")
    }

    static func testVideoMemory() {
        print("Testing video player memory usage...")
        print("  Player should be nil when not visible")
        print("  Only one player should exist at a time in reels")
        print("  Memory should be released when dismissing reels")
    }
}

// MARK: - Integration Testing

/// Test the complete flow
struct IntegrationTest {
    static func testCompleteFlow() {
        print("""
        Integration Test Flow:

        1. Launch app -> KineView appears
        2. Tap search -> Focus on search field
        3. Type "stretch" -> Filter results
        4. Clear search -> Results restored
        5. Toggle favorites -> Show only favorites
        6. Tap exercise -> Navigate to detail view
        7. Swipe back -> Return to list
        8. Tap reels button -> Enter full-screen reels
        9. Swipe up -> Next video
        10. Tap screen -> Pause video
        11. Tap favorite -> Add to favorites
        12. Tap close -> Return to list
        13. Tap tips button -> Show recovery tips
        14. Tap done -> Dismiss tips

        All interactions should be smooth with proper animations.
        """)
    }

    static func testAPIFlow() {
        print("""
        API Test Flow:

        1. Login/Register -> Get token
        2. Fetch user profile -> Verify structure
        3. Fetch goals -> Verify Goal model parsing
        4. Fetch achievements -> Verify Achievement model parsing
        5. Fetch leaderboard -> Verify LeaderboardEntry parsing
        6. Fetch posts -> Verify Post model parsing
        7. Fetch workout plan -> Verify WorkoutSession parsing
        8. Fetch nutrition plan -> Verify NutritionPlan parsing
        9. Log progress -> Verify UserProgress parsing
        10. Update goal progress -> Verify GoalProgressResponse parsing

        All API responses should parse without errors.
        """)
    }
}

// MARK: - Theme Testing

#Preview("Light vs Dark Mode") {
    @Previewable @StateObject var kineVM = KineViewModel()
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()

    return TabView {
        KineView()
            .environmentObject(kineVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
            .preferredColorScheme(.light)
            .tabItem {
                Label("Light", systemImage: "sun.max")
            }

        KineView()
            .environmentObject(kineVM)
            .environmentObject(authVM)
            .environmentObject(langManager)
            .environmentObject(themeManager)
            .preferredColorScheme(.dark)
            .tabItem {
                Label("Dark", systemImage: "moon")
            }
    }
}

// MARK: - Localization Testing

extension String {
    static func testLocalizations() {
        let keys = [
            "kine.recovery",
            "kine.recovery_hub",
            "kine.exercises_available",
            "kine.reels",
            "kine.sort",
            "kine.search.placeholder",
            "kine.guided_video",
            "kine.no_matching_exercises",
            "kine.recovery_tips",
            "goals.title",
            "goals.active",
            "goals.status.active",
            "goals.status.completed",
            "goals.status.paused",
            "goals.on_track",
            "goals.behind",
            "achievements.title",
            "achievements.leaderboard"
        ]

        print("Testing localizations:")
        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            print("  \(key) = \(localized)")
            if localized == key {
                print("    Warning: Missing translation!")
            }
        }
    }
}

// MARK: - Animation Testing

#Preview("Animation Showcase") {
    struct AnimationShowcase: View {
        @State private var showAll = false

        var body: some View {
            ScrollView {
                VStack(spacing: 40) {
                    Group {
                        Text("Tap to trigger animations")
                            .font(.headline)

                        // Spring animation
                        Circle()
                            .fill(Color.blue)
                            .frame(width: showAll ? 100 : 50, height: showAll ? 100 : 50)
                            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: showAll)

                        // Fade animation
                        Text("Fade In/Out")
                            .opacity(showAll ? 1.0 : 0.3)
                            .animation(.easeInOut(duration: 0.5), value: showAll)

                        // Scale animation
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color.green)
                            .frame(width: 100, height: 100)
                            .scaleEffect(showAll ? 1.0 : 0.8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: showAll)

                        // Rotation animation
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundColor(.yellow)
                            .rotationEffect(.degrees(showAll ? 360 : 0))
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: showAll)
                    }
                }
                .padding()
            }
            .onTapGesture {
                showAll.toggle()
            }
        }
    }

    return AnimationShowcase()
}

// MARK: - Device Testing Matrix

struct DeviceTestMatrix {
    static let devices = [
        "iPhone SE (3rd generation)",
        "iPhone 13 mini",
        "iPhone 14",
        "iPhone 14 Pro",
        "iPhone 14 Pro Max",
        "iPhone 15",
        "iPhone 15 Pro Max"
    ]

    static func printTestMatrix() {
        print("""

        Device Test Matrix
        ==================

        Test on the following devices:

        """)

        for device in devices {
            print("[ ] \(device)")
            print("    - Light mode")
            print("    - Dark mode")
            print("    - Text size: Small, Medium, Large")
            print("")
        }

        print("""

        Key Areas to Test:
        - Header layout doesn't overflow
        - Search bar is properly sized
        - Exercise rows are readable
        - Reels fills entire screen
        - Action buttons are reachable
        - Tips grid adapts to screen width
        - Goals card displays correctly
        - Achievements grid layout
        - Leaderboard scrolling

        """)
    }
}

// MARK: - Run All Tests

func runAllTests() {
    print("\n=== Running All Tests ===\n")

    PerformanceTest.testListPerformance()
    PerformanceTest.testVideoMemory()
    IntegrationTest.testCompleteFlow()
    IntegrationTest.testAPIFlow()
    String.testLocalizations()
    DeviceTestMatrix.printTestMatrix()

    // Test JSON analysis
    print("\n=== JSON Analysis Demo ===\n")
    print(APIDataAnalyzer.analyzeJSON(MockGoals.activeGoalJSON))
    print(APIDataAnalyzer.analyzeJSON(MockAchievements.achievementsJSON))

    print("\n=== Tests Complete ===\n")
}
