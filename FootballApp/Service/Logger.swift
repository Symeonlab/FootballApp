//
//  Logger.swift.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 14/11/2025.
//

import Foundation
import os.log

extension Logger {
    /// The bundle identifier of the app.
    private static var subsystem = Bundle.main.bundleIdentifier!

    /// A logger for the API networking layer.
    static let api = Logger(subsystem: subsystem, category: "API")
    
    /// A logger for the Authentication flow.
    static let auth = Logger(subsystem: subsystem, category: "Auth")
    
    /// A logger for the Onboarding flow.
    static let onboarding = Logger(subsystem: subsystem, category: "Onboarding")
    
    /// A logger for the Workout generation/fetching.
    static let workout = Logger(subsystem: subsystem, category: "Workout")
    
    /// A logger for the Nutrition generation/fetching.
    static let nutrition = Logger(subsystem: subsystem, category: "Nutrition")
}
