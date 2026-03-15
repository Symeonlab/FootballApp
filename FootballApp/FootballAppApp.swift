//
//  FootballAppApp.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI

@main
struct FootballAppApp: App {
    // 1. Create the ViewModels as StateObjects at App level to persist across language changes
    @StateObject private var authViewModel = AuthViewModel()

    // 2. LanguageManager for localization
    @StateObject private var languageManager: LanguageManager

    // 3. ThemeManager for appearance
    @StateObject private var themeManager = ThemeManager()

    // 4. App-level view models - persist across language changes
    @StateObject private var workoutsViewModel = WorkoutsViewModel()
    @StateObject private var nutritionViewModel = NutritionViewModel()
    @StateObject private var kineViewModel = KineViewModel()
    @StateObject private var profileViewModel = ProfileViewModel()

    init() {
        // Initialize LanguageManager and set it as the shared instance
        let manager = LanguageManager()
        _languageManager = StateObject(wrappedValue: manager)
        LanguageManager.setShared(manager)
    }

    var body: some Scene {
        WindowGroup {
            // Use refreshID to trigger localization refresh
            // Since all view models are at App level, they persist across refreshes
            ContentView()
                .id(languageManager.refreshID)
                .environmentObject(authViewModel)
                .environmentObject(languageManager)
                .environmentObject(themeManager)
                .environmentObject(workoutsViewModel)
                .environmentObject(nutritionViewModel)
                .environmentObject(kineViewModel)
                .environmentObject(profileViewModel)
                .environment(\.locale, languageManager.locale)
                .environment(\.layoutDirection, languageManager.layoutDirection)
        }
    }
}



