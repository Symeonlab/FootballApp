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
}

final class LanguageManager: ObservableObject {
    @Published var selected: AppLanguage {
        didSet { 
            save()
            // Force UI update by posting on main thread
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }

    init() {
        if let raw = UserDefaults.standard.string(forKey: Self.storageKey),
           let lang = AppLanguage(rawValue: raw) {
            self.selected = lang
        } else {
            self.selected = .system
        }
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
    }

    private static let storageKey = "app.language"
}
