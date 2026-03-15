import Foundation
import Combine
import SwiftUI

class OnboardingViewModel: ObservableObject {

    // This holds all the data we collect
    @Published var data = OnboardingData()

    // This will store all the DYNAMIC options from your API
    @Published var options: OnboardingDataResponse?

    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // For the Height/Weight double-step view
    @Published var heightWeightStep: Int = 0

    /// When true, the user is updating their workout type (skipping personal info)
    var isUpdateMode: Bool = false

    private var cancellables = Set<AnyCancellable>()
    private var apiService = APIService.shared

    init() {
        // Initialize with default values to avoid UI crashes
        self.data.age = 25
        self.data.height = 170.0
        self.data.weight = 70.0
        self.data.gender = "HOMME"
        self.data.matchDay = "AUCUN"
        self.data.birthDate = Date() // Use a Date object
    }

    // MARK: - Load Current Profile (for Update Mode)

    /// Pre-populate the onboarding data from the user's existing profile.
    /// Called when isUpdateMode is true so pickers show current values.
    func loadCurrentProfile(from user: APIUser) {
        guard let profile = user.profile else { return }

        // Personal info (these stay locked in update mode, but we populate them
        // so the PUT /api/user/profile call doesn't overwrite them with nil)
        data.name = user.name
        data.gender = profile.gender
        data.height = profile.height
        data.weight = profile.weight
        data.age = profile.age

        // Sport & Level
        data.discipline = profile.discipline
        data.position = profile.position
        data.inClub = profile.in_club
        data.matchDay = profile.match_day
        data.trainingDays = profile.training_days
        data.trainingFocus = profile.training_focus
        data.level = profile.level
        data.hasInjury = profile.has_injury
        data.injuryLocation = profile.injury_location
        data.trainingLocation = profile.training_location
        data.gymPreferences = profile.gym_preferences
        data.cardioPreferences = profile.cardio_preferences
        data.outdoorPreferences = profile.outdoor_preferences
        data.homePreferences = profile.home_preferences

        // Goals & Nutrition
        data.goal = profile.goal
        data.idealWeight = profile.ideal_weight
        data.activityLevel = profile.activity_level
        data.morphology = profile.morphology
        data.hormonalIssues = profile.hormonal_issues
        data.isVegetarian = profile.is_vegetarian
        data.mealsPerDay = profile.meals_per_day
        data.breakfastPreferences = profile.breakfast_preferences
        data.badHabits = profile.bad_habits
        data.snackingHabits = profile.snacking_habits
        data.vegetableConsumption = profile.vegetable_consumption
        data.fishConsumption = profile.fish_consumption
        data.meatConsumption = profile.meat_consumption
        data.dairyConsumption = profile.dairy_consumption
        data.sugaryFoodConsumption = profile.sugary_food_consumption
        data.cerealConsumption = profile.cereal_consumption
        data.starchyFoodConsumption = profile.starchy_food_consumption
        data.sugaryDrinkConsumption = profile.sugary_drink_consumption
        data.eggConsumption = profile.egg_consumption
        data.fruitConsumption = profile.fruit_consumption

        // Health
        data.takesMedication = profile.takes_medication
        data.hasDiabetes = profile.has_diabetes
        data.familyHistory = profile.family_history
        data.medicalHistory = profile.medical_history

        // Parse birth_date string to Date if available
        if let birthDateStr = profile.birth_date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            data.birthDate = formatter.date(from: birthDateStr) ?? Date()
        }

        #if DEBUG
        print("✅ Pre-populated onboarding data from current profile (update mode)")
        #endif
    }

    // 1. FETCH ONBOARDING DATA
    // Call this from your OnboardingFlow's .onAppear modifier
    func fetchOnboardingData() {
        guard options == nil else { return } // Only fetch once

        isLoading = true

        apiService.request(
            endpoint: "/api/onboarding-data",
            method: "GET",
            requiresAuth: false // This endpoint is public
        )
        .sink(receiveCompletion: { completion in
            self.isLoading = false
            if case .failure(let error) = completion {
                self.errorMessage = error.localizedDescription
                #if DEBUG
                print("Error fetching onboarding data: \(error)")
                #endif
            }
        }, receiveValue: { (response: OnboardingDataResponse) in
            // Save all the dynamic options
            self.options = response

            // Only set defaults if NOT in update mode (update mode already has profile data)
            if !self.isUpdateMode {
                self.data.goal = response.goal?.first?.key
                self.data.level = response.level?.first?.key
                self.data.discipline = response.discipline?.first?.key
                self.data.trainingLocation = response.location?.first?.key
            }
        })
        .store(in: &cancellables)
    }

    // 2. SUBMIT ONBOARDING
    // This is called from your final "Finish" button
    @MainActor
    func submitOnboarding() async -> Bool {
        isLoading = true
        errorMessage = nil

        // Mark onboarding as complete in the data
        data.isOnboardingComplete = true

        // Step 1: Send all collected data to /api/user/profile
        let profileSuccess = await updateProfile()

        guard profileSuccess else {
            isLoading = false
            errorMessage = "Failed to save your profile. Please try again."
            return false
        }

        // Step 2: After profile is saved, generate a new workout plan
        let planSuccess = await generateInitialWorkoutPlan()

        isLoading = false

        if !planSuccess {
            #if DEBUG
            print("Warning: Could not generate workout plan. User can generate it later.")
            #endif
        }

        return true
    }

    // Private helper for Step 1
    private func updateProfile() async -> Bool {
        return await withCheckedContinuation { continuation in
            apiService.request(
                endpoint: "/api/user/profile",
                method: "PUT",
                body: self.data // Send the whole struct
            )
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    #if DEBUG
                    print("Error updating profile: \(error)")
                    #endif
                    continuation.resume(returning: false)
                }
            }, receiveValue: { (response: UserProfileUpdateResponse) in
                #if DEBUG
                print("Profile successfully saved.")
                #endif
                continuation.resume(returning: true)
            })
            .store(in: &cancellables)
        }
    }

    // Private helper for Step 2
    private func generateInitialWorkoutPlan() async -> Bool {
        return await withCheckedContinuation { continuation in
            apiService.request(
                endpoint: "/api/workout-plan/generate",
                method: "POST"
            )
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    #if DEBUG
                    print("Error generating plan: \(error)")
                    #endif
                    continuation.resume(returning: false)
                }
            }, receiveValue: { (response: APIResponseMessage) in
                #if DEBUG
                print("Workout plan generated.")
                #endif
                continuation.resume(returning: true)
            })
            .store(in: &cancellables)
        }
    }
}
