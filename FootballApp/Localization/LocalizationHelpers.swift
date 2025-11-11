//
//  LocalizationHelpers.swift
//  FootballApp
//
//  Created for DynaTrain Localization
//

import SwiftUI

// MARK: - String Extension for Easy Localization
extension String {
    /// Returns a localized string for the given key
    var fa_localized: String {
        NSLocalizedString(self, comment: "")
    }
    
    /// Returns a localized string with formatted arguments
    /// - Parameter arguments: Values to insert into the localized string
    /// - Returns: Formatted localized string
    func fa_localized(with arguments: CVarArg...) -> String {
        String(format: NSLocalizedString(self, comment: ""), arguments: arguments)
    }
    
    /// Returns a localized string with a default value
    /// - Parameters:
    ///   - defaultValue: Default text if translation is missing
    ///   - comment: Comment for translators
    /// - Returns: Localized string or default
    func fa_localized(default defaultValue: String, comment: String = "") -> String {
        let localized = NSLocalizedString(self, comment: comment)
        return localized == self ? defaultValue : localized
    }
    
    @available(*, deprecated, renamed: "fa_localized(with:)")
    func localizedWith(_ arguments: CVarArg...) -> String {
        fa_localized(with: arguments)
    }

    @available(*, deprecated, renamed: "fa_localized(default:comment:)")
    func localizedDefault(_ defaultValue: String, comment: String = "") -> String {
        fa_localized(default: defaultValue, comment: comment)
    }
}

// MARK: - Localization Keys Namespace
/// Centralized place for all localization keys
/// Makes it easier to find and use keys with autocomplete
enum L10n {
    
    // MARK: - Common
    enum Common {
        static let ok = "common.ok"
        static let cancel = "common.cancel"
        static let done = "common.done"
        static let save = "common.save"
        static let delete = "common.delete"
        static let edit = "common.edit"
        static let add = "common.add"
        static let refresh = "common.refresh"
        static let retry = "common.retry"
        static let skip = "common.skip"
        static let next = "common.next"
        static let back = "common.back"
        static let close = "common.close"
        static let `continue` = "common.continue"
        static let today = "common.today"
        static let loading = "common.loading"
        static let error = "common.error"
        static let yesterday = "common.yesterday"
        static let tomorrow = "common.tomorrow"
        static let submit = "common.submit"
        static let confirm = "common.confirm"
    }
    
    // MARK: - Alert
    enum Alert {
        static let errorTitle = "alert.error.title"
        static let buttonOk = "alert.button.ok"
    }
    
    // MARK: - Splash
    enum Splash {
        static let title = "splash.title"
        static let subtitle = "splash.subtitle"
    }
    
    // MARK: - Intro
    enum Intro {
        static let skip = "intro.skip"
        static let swipe = "intro.swipe"
        
        enum Welcome {
            static let title = "intro.welcome.title"
            static let subtitle = "intro.welcome.subtitle"
        }
        
        enum Features {
            static let header = "intro.features.header"
            static let subheader = "intro.features.subheader"
            
            static let trainingTitle = "intro.features.training.title"
            static let trainingDescription = "intro.features.training.description"
            static let nutritionTitle = "intro.features.nutrition.title"
            static let nutritionDescription = "intro.features.nutrition.description"
            static let recoveryTitle = "intro.features.recovery.title"
            static let recoveryDescription = "intro.features.recovery.description"
            static let progressTitle = "intro.features.progress.title"
            static let progressDescription = "intro.features.progress.description"
        }
        
        enum Language {
            static let title = "intro.language.title"
            static let subtitle = "intro.language.subtitle"
        }
        
        enum Ready {
            static let title = "intro.ready.title"
            static let subtitle = "intro.ready.subtitle"
            static let button = "intro.ready.button"
        }
    }
    
    // MARK: - Onboarding
    enum Onboarding {
        static let skip = "onboarding.skip"
        
        enum Loading {
            static let title = "onboarding.loading.title"
            static let subtitle = "onboarding.loading.subtitle"
        }
        
        enum Error {
            static let title = "onboarding.error.title"
            static let retry = "onboarding.error.retry"
        }
        
        enum Gender {
            static let title = "onboarding.gender.title"
            static let subtitle = "onboarding.gender.subtitle"
            static let male = "onboarding.gender.male"
            static let female = "onboarding.gender.female"
        }
        
        enum Age {
            static let title = "onboarding.age.title"
            static let subtitle = "onboarding.age.subtitle"
            static let years = "onboarding.age.years"
        }
        
        enum Goal {
            static let title = "onboarding.goal.title"
            static let subtitle = "onboarding.goal.subtitle"
            static let loseWeight = "onboarding.goal.lose_weight"
            static let buildMuscle = "onboarding.goal.build_muscle"
            static let maintain = "onboarding.goal.maintain"
            static let improveEndurance = "onboarding.goal.improve_endurance"
        }
    }
    
    // MARK: - Auth
    enum Auth {
        enum Login {
            static let title = "auth.login.title"
            static let subtitle = "auth.login.subtitle"
            static let email = "auth.login.email"
            static let password = "auth.login.password"
            static let button = "auth.login.button"
            static let forgotPassword = "auth.login.forgot_password"
            static let noAccount = "auth.login.no_account"
            static let signUp = "auth.login.sign_up"
        }
        
        enum Register {
            static let title = "auth.register.title"
            static let subtitle = "auth.register.subtitle"
            static let name = "auth.register.name"
            static let email = "auth.register.email"
            static let password = "auth.register.password"
            static let confirmPassword = "auth.register.confirm_password"
            static let button = "auth.register.button"
            static let haveAccount = "auth.register.have_account"
            static let signIn = "auth.register.sign_in"
        }
        
        enum Error {
            static let invalidEmail = "auth.error.invalid_email"
            static let passwordTooShort = "auth.error.password_too_short"
            static let passwordsDontMatch = "auth.error.passwords_dont_match"
            static let fieldsEmpty = "auth.error.fields_empty"
        }
    }
    
    // MARK: - Tabs
    enum Tab {
        static let workout = "tab.workout"
        static let nutrition = "tab.nutrition"
        static let kine = "tab.kine"
        static let profile = "tab.profile"
    }
    
    // MARK: - Workout
    enum Workout {
        static let title = "workout.title"
        static let today = "workout.today"
        static let upcoming = "workout.upcoming"
        static let completed = "workout.completed"
        static let restDay = "workout.rest_day"
        static let start = "workout.start"
        static let `continue` = "workout.continue"
        static let complete = "workout.complete"
        static let exercises = "workout.exercises"
        static let duration = "workout.duration"
        static let calories = "workout.calories"
        static let sets = "workout.sets"
        static let reps = "workout.reps"
        static let kg = "workout.kg"
        static let noWorkouts = "workout.no_workouts"
        static let restAndRecover = "workout.rest_and_recover"
    }
    
    // MARK: - Nutrition
    enum Nutrition {
        static let title = "nutrition.title"
        static let overview = "nutrition.overview"
        static let meals = "nutrition.meals"
        static let advice = "nutrition.advice"
        static let loading = "nutrition.loading"
        static let loadingSubtitle = "nutrition.loading.subtitle"
        static let todayTarget = "nutrition.today_target"
        static let water = "nutrition.water"
        static let macronutrients = "nutrition.macronutrients"
        static let protein = "nutrition.protein"
        static let carbs = "nutrition.carbs"
        static let fats = "nutrition.fats"
        
        enum Overview {
            static let dailyCalorieTarget = "nutrition.overview.daily_calorie_target"
        }
        
        enum Empty {
            static let title = "nutrition.empty.title"
            static let description = "nutrition.empty.description"
            static let button = "nutrition.empty.button"
        }
        
        enum Hydration {
            static let title = "nutrition.hydration.title"
            static let subtitle = "nutrition.hydration.subtitle"
            static let glasses = "nutrition.hydration.glasses"
            static let target = "nutrition.hydration.target"
            static let clear = "nutrition.hydration.clear"
        }
        
        enum Meal {
            static let itemsCount = "nutrition.meal.items_count"
            static let breakfast = "nutrition.meal.breakfast"
            static let lunch = "nutrition.meal.lunch"
            static let dinner = "nutrition.meal.dinner"
            static let snack = "nutrition.meal.snack"
        }
        
        enum Advice {
            static let title = "nutrition.advice.title"
            static let empty = "nutrition.advice.empty"
            static let foodsToAvoid = "nutrition.advice.foods_to_avoid"
            static let foodsToEat = "nutrition.advice.foods_to_eat"
            static let naturalRemedies = "nutrition.advice.natural_remedies"
        }
    }
    
    // MARK: - Kine (Recovery)
    enum Kine {
        static let title = "kine.title"
        static let measurements = "kine.measurements"
        static let health = "kine.health"
        static let sleep = "kine.sleep"
        static let weight = "kine.weight"
        static let bodyFat = "kine.body_fat"
        static let muscleMass = "kine.muscle_mass"
        static let heartRate = "kine.heart_rate"
        static let bloodPressure = "kine.blood_pressure"
        static let hours = "kine.hours"
        static let kg = "kine.kg"
        static let bpm = "kine.bpm"
        static let addMeasurement = "kine.add_measurement"
        static let noData = "kine.no_data"
        static let trackProgress = "kine.track_progress"
    }
    
    // MARK: - Profile
    enum Profile {
        static let title = "profile.title"
        static let settings = "profile.settings"
        static let account = "profile.account"
        static let editProfile = "profile.edit_profile"
        static let preferences = "profile.preferences"
        static let language = "profile.language"
        static let theme = "profile.theme"
        static let notifications = "profile.notifications"
        static let privacy = "profile.privacy"
        static let terms = "profile.terms"
        static let support = "profile.support"
        static let about = "profile.about"
        static let version = "profile.version"
        static let logout = "profile.logout"
        static let deleteAccount = "profile.delete_account"
        
        enum Stats {
            static let workoutsCompleted = "profile.stats.workouts_completed"
            static let caloriesBurned = "profile.stats.calories_burned"
            static let activeDays = "profile.stats.active_days"
            static let currentStreak = "profile.stats.current_streak"
        }
        
        enum Theme {
            static let light = "profile.theme.light"
            static let dark = "profile.theme.dark"
            static let system = "profile.theme.system"
        }
    }
    
    // MARK: - Errors
    enum Error {
        static let network = "error.network"
        static let server = "error.server"
        static let unknown = "error.unknown"
        static let noData = "error.no_data"
        static let loadFailed = "error.load_failed"
        static let saveFailed = "error.save_failed"
        static let deleteFailed = "error.delete_failed"
    }
    
    // MARK: - Units
    enum Units {
        static let kg = "units.kg"
        static let lbs = "units.lbs"
        static let cm = "units.cm"
        static let ft = "units.ft"
        static let kcal = "units.kcal"
        static let g = "units.g"
        static let ml = "units.ml"
        static let oz = "units.oz"
        static let min = "units.min"
        static let sec = "units.sec"
        static let hours = "units.hours"
    }
}

// MARK: - SwiftUI Text Extension
extension Text {
    /// Create a Text view with a localized string key from L10n namespace
    /// Usage: Text(L10n.Common.ok)
    init(_ key: String) {
        self.init(LocalizedStringKey(key))
    }
}

// MARK: - Usage Examples
/*
 
 // Method 1: Direct LocalizedStringKey (Most Common in SwiftUI)
 Text("common.ok")
 Button("common.cancel") { }
 .navigationTitle("profile.title")
 
 // Method 2: Using L10n namespace with autocomplete
 Text(L10n.Common.ok)
 Button(L10n.Common.cancel) { }
 .navigationTitle(L10n.Profile.title)
 
 // Method 3: String extension for UIKit or formatted strings
 let message = "common.ok".localized
 let formatted = "nutrition.meal.items_count".localized(with: itemCount)
 
 // Method 4: With interpolation
 Text("nutrition.viewing_plan \(date)")
 // or
 Text(String(localized: "nutrition.viewing_plan \(date)"))
 
 // Method 5: Button with action
 Button {
     // action
 } label: {
     Text(L10n.Common.done)
 }
 
 // Method 6: For complex formatting
 let text = String(format: NSLocalizedString("nutrition.meal.items_count", comment: ""), itemCount)
 Text(text)
 
 */

