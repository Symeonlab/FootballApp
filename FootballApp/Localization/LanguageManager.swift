//
//  LanguageManager.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 11/11/2025.
//
import SwiftUI
import Combine

// This enum MUST conform to Hashable for the Picker to work
enum AppLanguage: String, CaseIterable, Identifiable, Hashable {
    case system
    case french = "fr"
    case english = "en"
    case arabic = "ar"

    var id: String { rawValue }

    // For the login view picker
    var localizedDisplayNameWithFlag: String {
        switch self {
        case .system: return "🌐 System"
        case .french: return "🇫🇷 Français"
        case .english: return "🇬🇧 English"
        case .arabic: return "🇦🇪 العربية"
        }
    }

    /// Returns the language code for bundle lookup
    var languageCode: String? {
        switch self {
        case .system: return nil
        case .french: return "fr"
        case .english: return "en"
        case .arabic: return "ar"
        }
    }
}

final class LanguageManager: ObservableObject {
    /// Published property that triggers UI updates when changed
    @Published var selected: AppLanguage {
        didSet {
            guard oldValue != selected else { return }
            save()
            updateBundle()
            // Trigger UI refresh on the main thread
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.refreshID = UUID()
            }
        }
    }

    /// Used to force SwiftUI view refresh when language changes
    @Published var refreshID = UUID()

    /// The bundle to use for localized strings
    @Published private(set) var bundle: Bundle = .main

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let lang = AppLanguage(rawValue: raw) {
            self.selected = lang
        } else {
            self.selected = .system
        }
        // Initialize bundle on startup
        updateBundle()
    }

    var locale: Locale {
        switch selected {
        case .system:
            return .autoupdatingCurrent
        case .french:
            return Locale(identifier: "fr")
        case .english:
            return Locale(identifier: "en")
        case .arabic:
            return Locale(identifier: "ar")
        }
    }

    var layoutDirection: LayoutDirection {
        switch selected {
        case .arabic:
            return .rightToLeft
        default:
            return .leftToRight
        }
    }

    private func save() {
        let value = selected.rawValue
        UserDefaults.standard.setValue(value, forKey: Self.storageKey)
        // Also save the resolved language code for API requests
        let resolvedCode = resolvedLanguageCode
        UserDefaults.standard.setValue(resolvedCode, forKey: "AppLanguage")
        UserDefaults.standard.synchronize()
    }

    /// Updates the bundle to use for localization based on selected language
    private func updateBundle() {
        var targetLanguageCode: String?

        if let languageCode = selected.languageCode {
            // User selected a specific language
            targetLanguageCode = languageCode
        } else {
            // System default - get the preferred language that we support
            let preferredLanguages = Locale.preferredLanguages
            for lang in preferredLanguages {
                let code = String(lang.prefix(2))
                if ["en", "fr", "ar"].contains(code) {
                    targetLanguageCode = code
                    break
                }
            }
            // Fallback to English if no supported language found
            if targetLanguageCode == nil {
                targetLanguageCode = "en"
            }
        }

        // Try multiple ways to find the language bundle
        var foundBundle: Bundle?

        if let languageCode = targetLanguageCode {
            // Method 1: Standard path lookup
            if let path = Bundle.main.path(forResource: languageCode, ofType: "lproj"),
               let bundle = Bundle(path: path) {
                foundBundle = bundle
            }
            // Method 2: URL-based lookup (more reliable in some cases)
            else if let url = Bundle.main.url(forResource: languageCode, withExtension: "lproj"),
                    let bundle = Bundle(url: url) {
                foundBundle = bundle
            }
            // Method 3: Look for Localizable.strings directly
            else if let stringsURL = Bundle.main.url(forResource: "Localizable", withExtension: "strings", subdirectory: nil, localization: languageCode) {
                let bundleURL = stringsURL.deletingLastPathComponent()
                if let bundle = Bundle(url: bundleURL) {
                    foundBundle = bundle
                }
            }
        }

        if let bundle = foundBundle {
            self.bundle = bundle
            // Also set Apple's language override for system components
            if selected != .system {
                UserDefaults.standard.set([targetLanguageCode!], forKey: "AppleLanguages")
            } else {
                UserDefaults.standard.removeObject(forKey: "AppleLanguages")
            }
        } else {
            // Fallback to main bundle - this still uses NSLocalizedString behavior
            self.bundle = .main
            UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        }
    }

    /// Returns the actual language code to use for API requests
    var resolvedLanguageCode: String {
        switch selected {
        case .system:
            return Locale.autoupdatingCurrent.language.languageCode?.identifier ?? "en"
        case .french:
            return "fr"
        case .english:
            return "en"
        case .arabic:
            return "ar"
        }
    }

    /// Localize a string using the current language bundle
    func localize(_ key: String) -> String {
        return bundle.localizedString(forKey: key, value: nil, table: nil)
    }

    /// Localize a string with format arguments
    func localize(_ key: String, with arguments: CVarArg...) -> String {
        let format = bundle.localizedString(forKey: key, value: nil, table: nil)
        return String(format: format, arguments: arguments)
    }

    private static let storageKey = "app.language"

    /// Reset language to system default (useful for sign out)
    func resetToSystemDefault() {
        selected = .system
    }

    /// Clear all language-related UserDefaults (useful for complete reset)
    func clearLanguageSettings() {
        UserDefaults.standard.removeObject(forKey: Self.storageKey)
        UserDefaults.standard.removeObject(forKey: "AppLanguage")
        UserDefaults.standard.removeObject(forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        selected = .system
        bundle = .main
        refreshID = UUID()
    }
}

// MARK: - Global access to LanguageManager for extensions
extension LanguageManager {
    /// Shared instance for use in String extensions
    /// Note: This is a workaround for extensions that can't access EnvironmentObject
    private static var _shared: LanguageManager?
    private static let lock = NSLock()

    static var shared: LanguageManager {
        lock.lock()
        defer { lock.unlock() }

        if _shared == nil {
            // Create a new instance - this will properly initialize the bundle
            _shared = LanguageManager()
        }
        return _shared!
    }

    /// Update the shared instance (call from App startup)
    static func setShared(_ manager: LanguageManager) {
        lock.lock()
        defer { lock.unlock() }
        _shared = manager
    }
}
