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
                print("Error fetching onboarding data: \(error)")
            }
        }, receiveValue: { (response: OnboardingDataResponse) in
            // Save all the dynamic options
            self.options = response
            
            // Set default selections in our data struct (use camelCase)
            self.data.goal = response.goal?.first?.key
            self.data.level = response.level?.first?.key
            self.data.discipline = response.discipline?.first?.key
            self.data.trainingLocation = response.location?.first?.key
        })
        .store(in: &cancellables)
    }

    // 2. SUBMIT ONBOARDING
    // This is called from your final "Finish" button
    @MainActor
    func submitOnboarding() async -> Bool {
        isLoading = true
        errorMessage = nil
        
        // --- PREPARE DATA FOR API ---
        // Get name from AuthViewModel (or add a name field to onboarding)
        // self.data.name = authViewModel.currentUser?.name
        
        // Step 1: Send all collected data to /api/user/profile
        // The APIService encoder will automatically convert the 'birthDate' Date to a string
        let profileSuccess = await updateProfile()
        
        guard profileSuccess else {
            isLoading = false
            errorMessage = "Failed to save your profile. Please try again."
            return false
        }

        // Step 2: After profile is saved, generate the first workout plan
        let planSuccess = await generateInitialWorkoutPlan()
        
        isLoading = false
        if !planSuccess {
            errorMessage = "Failed to generate your workout plan."
        }
        return planSuccess
    }
    
    // Private helper for Step 1
    private func updateProfile() async -> Bool {
        return await withCheckedContinuation { continuation in
            apiService.request(
                endpoint: "/api/user/profile",
                method: "PUT",
                body: self.data // Send the whole struct
            )
            // --- THIS IS THE FIX ---
            // The API returns a {message, user} object, which we defined as UserProfileUpdateResponse
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    print("Error updating profile: \(error)")
                    continuation.resume(returning: false)
                }
            }, receiveValue: { (response: UserProfileUpdateResponse) in
                print("Profile successfully saved.")
                continuation.resume(returning: true)
            })
            // --- END OF FIX ---
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
                    print("Error generating initial plan: \(error)")
                    continuation.resume(returning: false)
                }
            }, receiveValue: { (response: APIResponseMessage) in
                print("Initial workout plan generated.")
                continuation.resume(returning: true)
            })
            .store(in: &cancellables)
        }
    }
}
