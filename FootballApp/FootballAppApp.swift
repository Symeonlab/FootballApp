//
//  FootballAppApp.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//

import SwiftUI

@main
struct FootballAppApp: App {
    // 1. Create the ViewModels as StateObjects
    @StateObject private var authViewModel = AuthViewModel()
    
    // 2. You must copy LanguageManager.swift from your old project
    @StateObject private var languageManager = LanguageManager()
    
    // 3. You must copy ThemeManager.swift from your old project
    @StateObject private var themeManager = ThemeManager()

    var body: some Scene {
        WindowGroup {
            // 4. Use ContentView as the root
            ContentView()
                // 5. Pass ALL EnvironmentObjects to all child views
                .environmentObject(authViewModel)
                .environmentObject(languageManager)
                .environmentObject(themeManager)
        }
    }
}



