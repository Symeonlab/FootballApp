//
//  ContentView.swift
//  FootballApp
//

import SwiftUI
import Combine

struct ContentView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        Group {
            switch authViewModel.appState {
            case .loading:
                LoadingView()

            case .authentication:
                AuthView()

            case .onboarding:
                OnboardingFlow()

            case .mainApp:
                MainTabView()
            }
        }
        .onAppear {
            authViewModel.fetchUser()
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            guard newPhase == .active else { return }
            authViewModel.fetchUser()
        }
    }
}

// MARK: - Subviews

private struct LoadingView: View {
    var body: some View {
        ZStack {
            DarkPurpleAnimatedBackground().ignoresSafeArea()
            VStack(spacing: 16) {
                ProgressView()
                Text("Loading…").font(.headline)
            }
            .padding()
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}

// MARK: - Preview Helper for Full App Experience

private class PreviewAppStateManager: ObservableObject {
    @Published var appState: AppState = .authentication
    @Published var isLoggedIn = false
    
    func login() {
        appState = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.appState = .mainApp
            self.isLoggedIn = true
        }
    }
}

#Preview("Real App - Main Tab with Live Data") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    MainTabView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
}

#Preview("Real App - Auth Flow") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    AuthView()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
}

#Preview("Real App - Onboarding") {
    @Previewable @StateObject var authVM = AuthViewModel()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    OnboardingFlow()
        .environmentObject(authVM)
        .environmentObject(langManager)
        .environmentObject(themeManager)
}

#Preview("Full App Experience - Interactive") {
    @Previewable @StateObject var previewAuth = PreviewAppStateManager()
    @Previewable @StateObject var langManager = LanguageManager()
    @Previewable @StateObject var themeManager = ThemeManager()
    
    ZStack {
        // Simulate the real app flow
        Group {
            switch previewAuth.appState {
            case .loading:
                LoadingView()
                
            case .authentication:
                ZStack {
                    DarkPurpleAnimatedBackground().ignoresSafeArea()
                    
                    VStack(spacing: 14) {
                        Text("FootballApp").font(.largeTitle.bold())
                        Text("Interactive Preview - Tap to Sign In")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        
                        Button {
                            previewAuth.login()
                        } label: {
                            Text("Sign In").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding()
                }
                
            case .onboarding:
                ZStack {
                    DarkPurpleAnimatedBackground().ignoresSafeArea()
                    
                    VStack(spacing: 14) {
                        Text("Welcome").font(.title.bold())
                        Text("Complete onboarding to start using the app.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        
                        Button {
                            previewAuth.appState = .mainApp
                        } label: {
                            Text("Finish Onboarding").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.top, 6)
                    }
                    .padding(24)
                    .background(.ultraThinMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding()
                }
                
            case .mainApp:
                MainAppRootViewWithMockData()
                    .environmentObject(langManager)
                    .environmentObject(themeManager)
            }
        }
    }
}

// Preview version with mock data
private struct MainAppRootViewWithMockData: View {
    @StateObject private var kineViewModel = KineViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()
    @StateObject private var workoutsViewModel = WorkoutsViewModel()
    
    var body: some View {
        TabView {
            WorkoutView()
                .tabItem { Label("Workout", systemImage: "figure.strengthtraining.traditional") }
                .environmentObject(workoutsViewModel)
            
            KineView()
                .tabItem { Label("Recovery", systemImage: "heart.text.square") }
                .environmentObject(kineViewModel)
            
            NutritionView()
                .tabItem { Label("Nutrition", systemImage: "fork.knife") }
                .environmentObject(nutritionViewModel)
            
            ProfileView()
                .tabItem { Label("Profile", systemImage: "person.circle") }
                .environmentObject(profileViewModel)
        }
        .onAppear {
            setupMockData()
        }
    }
    
    private func setupMockData() {
        // Setup KineViewModel mock data
        kineViewModel.loadMockDataForDevelopment()
        
        // Setup NutritionViewModel mock data
        nutritionViewModel.caloriesConsumed = 1850
        nutritionViewModel.proteinConsumed = 125
        nutritionViewModel.carbsConsumed = 195
        nutritionViewModel.fatsConsumed = 55
        nutritionViewModel.waterGlasses = 6
        nutritionViewModel.meals = [
            Meal(id: UUID(), name: "Breakfast", type: "Breakfast", time: "8:00 AM", calories: 450, protein: 25, carbs: 50, fats: 15),
            Meal(id: UUID(), name: "Lunch", type: "Lunch", time: "12:30 PM", calories: 650, protein: 45, carbs: 70, fats: 20),
            Meal(id: UUID(), name: "Snack", type: "Snack", time: "3:00 PM", calories: 250, protein: 15, carbs: 25, fats: 10),
            Meal(id: UUID(), name: "Dinner", type: "Dinner", time: "7:00 PM", calories: 500, protein: 40, carbs: 50, fats: 10)
        ]
        
        // Setup ProfileViewModel mock data
        profileViewModel.stepsToday = 8542
        profileViewModel.caloriesToday = 450
        profileViewModel.latestWeight = 75.5
    }
}


#Preview("Quick - Main App Only") {
    MainAppRootViewWithMockData()
}

#Preview("Individual Tab - Workout") {
    let kineVM = KineViewModel()
    kineVM.loadMockDataForDevelopment()
    let workoutsVM = WorkoutsViewModel()
    
    NavigationStack {
        WorkoutView()
            .environmentObject(workoutsVM)
    }
}

#Preview("Individual Tab - Recovery") {
    let kineVM = KineViewModel()
    kineVM.loadMockDataForDevelopment()
    
    NavigationStack {
        KineView()
            .environmentObject(kineVM)
    }
}

#Preview("Individual Tab - Nutrition") {
    let nutritionVM = NutritionViewModel()
    nutritionVM.caloriesConsumed = 1800
    nutritionVM.proteinConsumed = 120
    nutritionVM.carbsConsumed = 180
    nutritionVM.fatsConsumed = 50
    nutritionVM.waterGlasses = 6
    nutritionVM.meals = [
        Meal(id: UUID(), name: "Breakfast", type: "Breakfast", time: "8:00 AM", calories: 450, protein: 25, carbs: 50, fats: 15),
        Meal(id: UUID(), name: "Lunch", type: "Lunch", time: "12:30 PM", calories: 650, protein: 45, carbs: 70, fats: 20)
    ]
    
    NavigationStack {
        NutritionView()
            .environmentObject(nutritionVM)
    }
}

#Preview("Individual Tab - Profile") {
    let profileVM = ProfileViewModel()
    profileVM.stepsToday = 8542
    profileVM.caloriesToday = 450
    profileVM.latestWeight = 75.5
    
    NavigationStack {
        ProfileView()
            .environmentObject(profileVM)
    }
}


