//
//  FootballAppTests.swift
//  FootballAppTests
//
//  Comprehensive API and Model tests for FootballApp
//

import XCTest
@testable import FootballApp

// MARK: - API Model Decoding Tests

final class APIModelDecodingTests: XCTestCase {

    // MARK: - Auth Response Tests

    func testAuthResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "message": "Login successful",
            "data": {
                "token": "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9...",
                "user": {
                    "id": 1,
                    "name": "Test User",
                    "email": "test@example.com",
                    "role": "user",
                    "profile": null
                }
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AuthResponse.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Login successful")
        XCTAssertFalse(response.token.isEmpty)
        XCTAssertEqual(response.user.id, 1)
        XCTAssertEqual(response.user.name, "Test User")
        XCTAssertEqual(response.user.email, "test@example.com")
        XCTAssertEqual(response.user.role, "user")
    }

    func testAuthResponseWithProfile() throws {
        let json = """
        {
            "success": true,
            "message": "Login successful",
            "data": {
                "token": "test_token",
                "user": {
                    "id": 1,
                    "name": "Test User",
                    "email": "test@example.com",
                    "role": "user",
                    "profile": {
                        "id": 1,
                        "user_id": 1,
                        "is_onboarding_complete": true,
                        "discipline": "Football",
                        "level": "Intermediate",
                        "goal": "Performance",
                        "height": 180.0,
                        "weight": 75.0,
                        "age": 25
                    }
                }
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AuthResponse.self, from: json)

        XCTAssertNotNil(response.user.profile)
        XCTAssertEqual(response.user.profile?.discipline, "Football")
        XCTAssertEqual(response.user.profile?.level, "Intermediate")
        XCTAssertEqual(response.user.profile?.height, 180.0)
        XCTAssertEqual(response.user.profile?.weight, 75.0)
        XCTAssertEqual(response.user.profile?.is_onboarding_complete, true)
    }

    // MARK: - Goal Tests

    func testGoalDecoding() throws {
        let json = """
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
            "target_chest": null,
            "target_hips": null,
            "start_weight": 80.0,
            "start_waist": 90.0,
            "target_workouts_per_week": 4,
            "start_date": "2025-01-01",
            "target_date": "2025-04-01",
            "completed_at": null,
            "weeks_completed": 5,
            "total_weeks": 12,
            "achievements": ["first_week", "consistency_3"],
            "notes": "My fitness goal",
            "created_at": "2025-01-01T10:00:00Z"
        }
        """.data(using: .utf8)!

        let goal = try JSONDecoder().decode(Goal.self, from: json)

        XCTAssertEqual(goal.id, 1)
        XCTAssertEqual(goal.goalType, .weightLoss)
        XCTAssertEqual(goal.goalTypeLabel, "Weight Loss")
        XCTAssertEqual(goal.status, .active)
        XCTAssertEqual(goal.progress, 45.5, accuracy: 0.01)
        XCTAssertEqual(goal.expectedProgress, 50.0)
        XCTAssertEqual(goal.isOnTrack, false)
        XCTAssertEqual(goal.targetWeight, 70.0)
        XCTAssertEqual(goal.targetWaist, 80.0)
        XCTAssertNil(goal.targetChest)
        XCTAssertNil(goal.targetHips)
        XCTAssertEqual(goal.startWeight, 80.0)
        XCTAssertEqual(goal.startWaist, 90.0)
        XCTAssertEqual(goal.targetWorkoutsPerWeek, 4)
        XCTAssertEqual(goal.startDate, "2025-01-01")
        XCTAssertEqual(goal.targetDate, "2025-04-01")
        XCTAssertNil(goal.completedAt)
        XCTAssertEqual(goal.weeksCompleted, 5)
        XCTAssertEqual(goal.totalWeeks, 12)
        XCTAssertEqual(goal.achievements?.count, 2)
        XCTAssertEqual(goal.notes, "My fitness goal")
    }

    func testGoalTypeDecoding() throws {
        XCTAssertEqual(try JSONDecoder().decode(GoalType.self, from: "\"weight_loss\"".data(using: .utf8)!), .weightLoss)
        XCTAssertEqual(try JSONDecoder().decode(GoalType.self, from: "\"muscle_gain\"".data(using: .utf8)!), .muscleGain)
        XCTAssertEqual(try JSONDecoder().decode(GoalType.self, from: "\"maintain\"".data(using: .utf8)!), .maintain)
        XCTAssertEqual(try JSONDecoder().decode(GoalType.self, from: "\"custom\"".data(using: .utf8)!), .custom)
    }

    func testGoalStatusDecoding() throws {
        XCTAssertEqual(try JSONDecoder().decode(GoalStatus.self, from: "\"active\"".data(using: .utf8)!), .active)
        XCTAssertEqual(try JSONDecoder().decode(GoalStatus.self, from: "\"completed\"".data(using: .utf8)!), .completed)
        XCTAssertEqual(try JSONDecoder().decode(GoalStatus.self, from: "\"paused\"".data(using: .utf8)!), .paused)
        XCTAssertEqual(try JSONDecoder().decode(GoalStatus.self, from: "\"abandoned\"".data(using: .utf8)!), .abandoned)
    }

    func testGoalStatusProperties() {
        // Test icons
        XCTAssertEqual(GoalStatus.active.icon, "play.circle.fill")
        XCTAssertEqual(GoalStatus.completed.icon, "checkmark.circle.fill")
        XCTAssertEqual(GoalStatus.paused.icon, "pause.circle.fill")
        XCTAssertEqual(GoalStatus.abandoned.icon, "xmark.circle.fill")

        // Test colors
        XCTAssertEqual(GoalStatus.active.color, "4A90E2")
        XCTAssertEqual(GoalStatus.completed.color, "4ECB71")
        XCTAssertEqual(GoalStatus.paused.color, "FF9F43")
        XCTAssertEqual(GoalStatus.abandoned.color, "FF6B6B")
    }

    // MARK: - Achievement Tests

    func testAchievementDecoding() throws {
        let json = """
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
        }
        """.data(using: .utf8)!

        let achievement = try JSONDecoder().decode(Achievement.self, from: json)

        XCTAssertEqual(achievement.id, 1)
        XCTAssertEqual(achievement.key, "first_workout")
        XCTAssertEqual(achievement.name, "First Workout")
        XCTAssertEqual(achievement.description, "Complete your first workout")
        XCTAssertEqual(achievement.icon, "flame.fill")
        XCTAssertEqual(achievement.points, 10)
        XCTAssertEqual(achievement.category, .workout)
        XCTAssertEqual(achievement.earned, true)
        XCTAssertEqual(achievement.earnedAt, "2025-01-15T10:30:00Z")
        XCTAssertEqual(achievement.earnedByCount, 150)
    }

    func testAchievementCategoryDecoding() throws {
        XCTAssertEqual(try JSONDecoder().decode(AchievementCategory.self, from: "\"workout\"".data(using: .utf8)!), .workout)
        XCTAssertEqual(try JSONDecoder().decode(AchievementCategory.self, from: "\"consistency\"".data(using: .utf8)!), .consistency)
        XCTAssertEqual(try JSONDecoder().decode(AchievementCategory.self, from: "\"milestone\"".data(using: .utf8)!), .milestone)
        XCTAssertEqual(try JSONDecoder().decode(AchievementCategory.self, from: "\"nutrition\"".data(using: .utf8)!), .nutrition)
        XCTAssertEqual(try JSONDecoder().decode(AchievementCategory.self, from: "\"special\"".data(using: .utf8)!), .special)
    }

    func testAchievementsResponseDecoding() throws {
        let json = """
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
                    }
                ],
                "by_category": {
                    "workout": []
                },
                "total_points": 250,
                "total_earned": 12,
                "total_available": 50
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(AchievementsResponse.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data.achievements.count, 1)
        XCTAssertEqual(response.data.totalPoints, 250)
        XCTAssertEqual(response.data.totalEarned, 12)
        XCTAssertEqual(response.data.totalAvailable, 50)
    }

    func testLeaderboardResponseDecoding() throws {
        let json = """
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
                    }
                ],
                "current_user": {
                    "rank": 15,
                    "total_points": 250,
                    "achievement_count": 12
                }
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(LeaderboardResponse.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data.leaderboard.count, 2)
        XCTAssertEqual(response.data.leaderboard[0].name, "John Doe")
        XCTAssertEqual(response.data.leaderboard[0].totalPoints, 500)
        XCTAssertEqual(response.data.currentUser.rank, 15)
        XCTAssertEqual(response.data.currentUser.totalPoints, 250)
    }

    // MARK: - Post Tests

    func testPostDecoding() throws {
        let json = """
        {
            "id": 1,
            "title": "How to Improve Your Fitness",
            "content": "Full article content here...",
            "excerpt": "A short summary of the article",
            "slug": "how-to-improve-fitness",
            "featured_image": "https://example.com/image.jpg",
            "author": "Admin",
            "published_at": "2025-01-10T09:00:00Z",
            "reading_time": 5
        }
        """.data(using: .utf8)!

        let post = try JSONDecoder().decode(Post.self, from: json)

        XCTAssertEqual(post.id, 1)
        XCTAssertEqual(post.title, "How to Improve Your Fitness")
        XCTAssertEqual(post.content, "Full article content here...")
        XCTAssertEqual(post.excerpt, "A short summary of the article")
        XCTAssertEqual(post.slug, "how-to-improve-fitness")
        XCTAssertEqual(post.featuredImage, "https://example.com/image.jpg")
        XCTAssertEqual(post.author, "Admin")
        XCTAssertEqual(post.publishedAt, "2025-01-10T09:00:00Z")
        XCTAssertEqual(post.readingTime, 5)
    }

    func testPostsResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "data": [
                {
                    "id": 1,
                    "title": "Post 1",
                    "content": "Content 1",
                    "excerpt": "Excerpt 1",
                    "slug": "post-1",
                    "featured_image": null,
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
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(PostsResponse.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data.count, 1)
        XCTAssertEqual(response.meta?.currentPage, 1)
        XCTAssertEqual(response.meta?.lastPage, 5)
        XCTAssertEqual(response.meta?.perPage, 10)
        XCTAssertEqual(response.meta?.total, 50)
    }

    // MARK: - Workout Tests

    func testWorkoutSessionDecoding() throws {
        let json = """
        {
            "id": 1,
            "day": "Monday",
            "theme": "Strength Training",
            "warmup": "5 min jogging, dynamic stretches",
            "finisher": "Cool down stretching",
            "is_completed": false,
            "completion_date": null,
            "exercises": [
                {
                    "id": 1,
                    "name": "Squats",
                    "sets": "4 sets",
                    "reps": "12 reps",
                    "recovery": "60s",
                    "video_url": "https://example.com/squats.mp4",
                    "is_completed": false
                }
            ]
        }
        """.data(using: .utf8)!

        let session = try JSONDecoder().decode(WorkoutSession.self, from: json)

        XCTAssertEqual(session.id, 1)
        XCTAssertEqual(session.day, "Monday")
        XCTAssertEqual(session.theme, "Strength Training")
        XCTAssertEqual(session.warmup, "5 min jogging, dynamic stretches")
        XCTAssertEqual(session.finisher, "Cool down stretching")
        XCTAssertEqual(session.is_completed, false)
        XCTAssertNil(session.completion_date)
        XCTAssertEqual(session.exercises?.count, 1)
        XCTAssertEqual(session.exercises?.first?.name, "Squats")
    }

    func testWorkoutExerciseComputedProperties() throws {
        let json = """
        {
            "id": 1,
            "name": "Squats",
            "sets": "4 sets",
            "reps": "12 reps",
            "recovery": "60s",
            "video_url": null,
            "is_completed": false
        }
        """.data(using: .utf8)!

        let exercise = try JSONDecoder().decode(WorkoutExercise.self, from: json)

        XCTAssertEqual(exercise.series, 4)
        XCTAssertEqual(exercise.repetitions, 12)
    }

    // MARK: - Nutrition Tests

    func testNutritionPlanDecoding() throws {
        let json = """
        {
            "daily_calorie_intake": 2500.0,
            "macros": {
                "protein": 150.0,
                "carbs": 300.0,
                "fat": 80.0
            },
            "daily_meals": [
                {
                    "name": "Breakfast",
                    "items": ["Oatmeal", "Eggs", "Orange juice"]
                },
                {
                    "name": "Lunch",
                    "items": ["Chicken", "Rice", "Vegetables"]
                }
            ],
            "advice": [
                {
                    "condition_name": "Performance",
                    "foods_to_avoid": ["Processed foods", "Sugar"],
                    "foods_to_eat": ["Lean protein", "Whole grains"],
                    "prophetic_advice_fr": "Conseil prophétique",
                    "prophetic_advice_ar": "نصيحة نبوية"
                }
            ]
        }
        """.data(using: .utf8)!

        let plan = try JSONDecoder().decode(AppNutritionPlan.self, from: json)

        XCTAssertEqual(plan.daily_calorie_intake, 2500.0)
        XCTAssertEqual(plan.macros?["protein"], 150.0)
        XCTAssertEqual(plan.macros?["carbs"], 300.0)
        XCTAssertEqual(plan.macros?["fat"], 80.0)
        XCTAssertEqual(plan.daily_meals?.count, 2)
        XCTAssertEqual(plan.daily_meals?.first?.name, "Breakfast")
        XCTAssertEqual(plan.advice?.count, 1)
        XCTAssertEqual(plan.advice?.first?.condition_name, "Performance")
    }

    // MARK: - User Progress Tests

    func testUserProgressDecoding() throws {
        let json = """
        {
            "id": 1,
            "user_id": 1,
            "date": "2025-12-12",
            "weight": 75.5,
            "waist": 85.0,
            "chest": 100.0,
            "hips": 95.0,
            "mood": "energized",
            "notes": "Felt great today!",
            "workout_completed": "Monday Strength"
        }
        """.data(using: .utf8)!

        let progress = try JSONDecoder().decode(UserProgress.self, from: json)

        XCTAssertEqual(progress.id, 1)
        XCTAssertEqual(progress.user_id, 1)
        XCTAssertEqual(progress.date, "2025-12-12")
        XCTAssertEqual(progress.weight, 75.5)
        XCTAssertEqual(progress.waist, 85.0)
        XCTAssertEqual(progress.chest, 100.0)
        XCTAssertEqual(progress.hips, 95.0)
        XCTAssertEqual(progress.mood, "energized")
        XCTAssertEqual(progress.notes, "Felt great today!")
        XCTAssertEqual(progress.workout_completed, "Monday Strength")
    }

    // MARK: - Dashboard Tests

    func testDashboardMetricsDecoding() throws {
        let json = """
        {
            "stats": {
                "total_users": 100,
                "new_users_week": 10,
                "total_progress_logs": 500,
                "published_posts": 25
            },
            "chart": {
                "labels": ["Mon", "Tue", "Wed", "Thu", "Fri"],
                "data": [10, 15, 12, 18, 20]
            },
            "my_latest_progress": []
        }
        """.data(using: .utf8)!

        let metrics = try JSONDecoder().decode(DashboardMetrics.self, from: json)

        XCTAssertEqual(metrics.stats?.total_users, 100)
        XCTAssertEqual(metrics.stats?.new_users_week, 10)
        XCTAssertEqual(metrics.chart?.labels.count, 5)
        XCTAssertEqual(metrics.chart?.data.count, 5)
    }

    // MARK: - Goal Progress Response Tests

    func testGoalProgressResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "message": "Progress updated successfully",
            "data": {
                "progress": 55.0,
                "weeks_completed": 6,
                "status": "active",
                "new_achievements": ["consistency_5", "halfway_there"]
            }
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GoalProgressResponse.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.message, "Progress updated successfully")
        XCTAssertEqual(response.data?.progress, 55.0)
        XCTAssertEqual(response.data?.weeksCompleted, 6)
        XCTAssertEqual(response.data?.status, .active)
        XCTAssertEqual(response.data?.newAchievements?.count, 2)
    }

    // MARK: - Onboarding Data Tests

    func testOnboardingDataEncoding() throws {
        let data = OnboardingData(
            discipline: "Football",
            position: "Midfielder",
            inClub: true,
            matchDay: "Saturday",
            trainingDays: ["Monday", "Wednesday", "Friday"],
            trainingFocus: "Technical",
            level: "Intermediate",
            hasInjury: false,
            injuryLocation: nil,
            trainingLocation: "Gym",
            gymPreferences: ["Strength", "Cardio"],
            cardioPreferences: ["Running"],
            outdoorPreferences: ["Field Training"],
            homePreferences: ["Bodyweight"],
            name: "Test User",
            gender: "male",
            height: 180,
            weight: 75,
            age: 25,
            country: "France",
            region: "Ile-de-France",
            proLevel: "Amateur",
            idealWeight: 73,
            birthDate: nil,
            activityLevel: "Moderate",
            goal: "Performance",
            morphology: "Athletic"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let jsonData = try encoder.encode(data)
        let jsonString = String(data: jsonData, encoding: .utf8)!

        XCTAssertTrue(jsonString.contains("\"discipline\":\"Football\""))
        XCTAssertTrue(jsonString.contains("\"in_club\":true"))
        XCTAssertTrue(jsonString.contains("\"training_days\":["))
        XCTAssertTrue(jsonString.contains("\"gym_preferences\":["))
    }

    // MARK: - Create Goal Request Tests

    func testCreateGoalRequestEncoding() throws {
        let request = CreateGoalRequest(
            goalType: "weight_loss",
            targetWeight: 70.0,
            targetWaist: 80.0,
            targetChest: nil,
            targetHips: nil,
            targetWorkoutsPerWeek: 4,
            totalWeeks: 12,
            targetDate: nil,
            notes: "Test goal"
        )

        let encoder = JSONEncoder()
        let jsonData = try encoder.encode(request)
        let jsonDict = try JSONSerialization.jsonObject(with: jsonData) as! [String: Any]

        XCTAssertEqual(jsonDict["goal_type"] as? String, "weight_loss")
        XCTAssertEqual(jsonDict["target_weight"] as? Double, 70.0)
        XCTAssertEqual(jsonDict["target_waist"] as? Double, 80.0)
        XCTAssertEqual(jsonDict["target_workouts_per_week"] as? Int, 4)
        XCTAssertEqual(jsonDict["total_weeks"] as? Int, 12)
        XCTAssertEqual(jsonDict["notes"] as? String, "Test goal")
    }

    // MARK: - Generic API Response Tests

    func testGenericAPIResponseDecoding() throws {
        let json = """
        {
            "success": true,
            "data": [1, 2, 3, 4, 5],
            "message": "Data fetched successfully"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GenericAPIResponse<[Int]>.self, from: json)

        XCTAssertTrue(response.success)
        XCTAssertEqual(response.data, [1, 2, 3, 4, 5])
        XCTAssertEqual(response.message, "Data fetched successfully")
    }
}

// MARK: - JSON Structure Validation Tests

final class JSONStructureValidationTests: XCTestCase {

    /// Test that Goal model handles all optional fields gracefully
    func testGoalWithMinimalFields() throws {
        let json = """
        {
            "id": 1,
            "goal_type": "weight_loss",
            "status": "active",
            "progress": 0
        }
        """.data(using: .utf8)!

        let goal = try JSONDecoder().decode(Goal.self, from: json)

        XCTAssertEqual(goal.id, 1)
        XCTAssertEqual(goal.goalType, .weightLoss)
        XCTAssertEqual(goal.status, .active)
        XCTAssertEqual(goal.progress, 0)
        XCTAssertNil(goal.expectedProgress)
        XCTAssertNil(goal.isOnTrack)
        XCTAssertNil(goal.targetWeight)
        XCTAssertNil(goal.weeksCompleted)
    }

    /// Test that Achievement model handles all optional fields
    func testAchievementWithMinimalFields() throws {
        let json = """
        {
            "id": 1,
            "key": "test_achievement",
            "name": "Test",
            "description": "Test description",
            "points": 10,
            "category": "workout"
        }
        """.data(using: .utf8)!

        let achievement = try JSONDecoder().decode(Achievement.self, from: json)

        XCTAssertEqual(achievement.id, 1)
        XCTAssertNil(achievement.icon)
        XCTAssertNil(achievement.earned)
        XCTAssertNil(achievement.earnedAt)
        XCTAssertNil(achievement.earnedByCount)
    }

    /// Test that Post model handles null values
    func testPostWithNullValues() throws {
        let json = """
        {
            "id": 1,
            "title": "Test Post",
            "content": null,
            "excerpt": null,
            "slug": "test-post",
            "featured_image": null,
            "author": null,
            "published_at": "2025-01-10T09:00:00Z",
            "reading_time": null
        }
        """.data(using: .utf8)!

        let post = try JSONDecoder().decode(Post.self, from: json)

        XCTAssertEqual(post.id, 1)
        XCTAssertEqual(post.title, "Test Post")
        XCTAssertNil(post.content)
        XCTAssertNil(post.excerpt)
        XCTAssertNil(post.featuredImage)
        XCTAssertNil(post.author)
        XCTAssertNil(post.readingTime)
    }
}

// MARK: - API Error Handling Tests

final class APIErrorHandlingTests: XCTestCase {

    func testAPIErrorDecoding() throws {
        let json = """
        {
            "message": "The given data was invalid.",
            "errors": {
                "email": ["The email field is required."],
                "password": ["The password must be at least 8 characters."]
            }
        }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(APIError.self, from: json)

        XCTAssertEqual(error.message, "The given data was invalid.")
        XCTAssertNotNil(error.errors)
        XCTAssertEqual(error.errors?["email"]?.first, "The email field is required.")
        XCTAssertEqual(error.errors?["password"]?.first, "The password must be at least 8 characters.")
    }

    func testAPIErrorWithoutValidationErrors() throws {
        let json = """
        {
            "message": "Unauthenticated."
        }
        """.data(using: .utf8)!

        let error = try JSONDecoder().decode(APIError.self, from: json)

        XCTAssertEqual(error.message, "Unauthenticated.")
        XCTAssertNil(error.errors)
    }
}

// MARK: - Performance Tests

final class APIModelPerformanceTests: XCTestCase {

    func testGoalDecodingPerformance() throws {
        let json = """
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
            "target_workouts_per_week": 4,
            "start_date": "2025-01-01",
            "target_date": "2025-04-01",
            "weeks_completed": 5,
            "total_weeks": 12,
            "achievements": ["first_week"],
            "notes": "Test"
        }
        """.data(using: .utf8)!

        measure {
            for _ in 0..<1000 {
                _ = try? JSONDecoder().decode(Goal.self, from: json)
            }
        }
    }

    func testAchievementsResponseDecodingPerformance() throws {
        // Create a large achievements response
        var achievements: [[String: Any]] = []
        for i in 0..<100 {
            achievements.append([
                "id": i,
                "key": "achievement_\(i)",
                "name": "Achievement \(i)",
                "description": "Description for achievement \(i)",
                "icon": "star.fill",
                "points": 10,
                "category": "workout",
                "earned": i % 2 == 0,
                "earned_at": "2025-01-15T10:30:00Z",
                "earned_by_count": 100
            ])
        }

        let response: [String: Any] = [
            "success": true,
            "data": [
                "achievements": achievements,
                "total_points": 500,
                "total_earned": 50,
                "total_available": 100
            ]
        ]

        let json = try JSONSerialization.data(withJSONObject: response)

        measure {
            _ = try? JSONDecoder().decode(AchievementsResponse.self, from: json)
        }
    }
}
