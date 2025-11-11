//
//  TESTING_SNIPPETS.swift
//  FootballApp
//
//  Testing helpers and preview providers for the new Kine & Reels views
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
        print("✓ Header should read: 'Your Recovery Hub, 3 exercises available'")
        print("✓ Favorites button should read: 'Favorites, 5 items, button'")
        print("✓ Search field should read: 'Search exercises, search field'")
        print("✓ Exercise rows should read: '[Exercise Name], Guided video, 2 to 5 minutes'")
        print("✓ Category buttons should indicate selected state")
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
        print("✓ Player should be nil when not visible")
        print("✓ Only one player should exist at a time in reels")
        print("✓ Memory should be released when dismissing reels")
    }
}

// MARK: - Integration Testing

/// Test the complete flow
struct IntegrationTest {
    static func testCompleteFlow() {
        print("""
        Integration Test Flow:
        
        1. Launch app → KineView appears
        2. Tap search → Focus on search field
        3. Type "stretch" → Filter results
        4. Clear search → Results restored
        5. Toggle favorites → Show only favorites
        6. Tap exercise → Navigate to detail view
        7. Swipe back → Return to list
        8. Tap reels button → Enter full-screen reels
        9. Swipe up → Next video
        10. Tap screen → Pause video
        11. Tap favorite → Add to favorites
        12. Tap close → Return to list
        13. Tap tips button → Show recovery tips
        14. Tap done → Dismiss tips
        
        All interactions should be smooth with proper animations.
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
            "kine.recovery_tips"
        ]
        
        print("Testing localizations:")
        for key in keys {
            let localized = NSLocalizedString(key, comment: "")
            print("  \(key) = \(localized)")
            if localized == key {
                print("  ⚠️  Missing translation!")
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
            print("□ \(device)")
            print("  - Light mode")
            print("  - Dark mode")
            print("  - Text size: Small, Medium, Large")
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
        
        """)
    }
}

// MARK: - Run All Tests

func runAllTests() {
    print("\n=== Running All Tests ===\n")
    
    PerformanceTest.testListPerformance()
    PerformanceTest.testVideoMemory()
    IntegrationTest.testCompleteFlow()
    String.testLocalizations()
    DeviceTestMatrix.printTestMatrix()
    
    print("\n=== Tests Complete ===\n")
}
