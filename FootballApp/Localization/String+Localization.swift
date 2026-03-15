import SwiftUI

extension String {
    /// Returns a LocalizedStringKey for use in SwiftUI Text views.
    /// Note: For dynamic language switching, prefer using `localizedString` property
    /// or the LanguageManager's localize() method.
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }

    /// Returns the localized String value using the current language bundle.
    /// This properly handles dynamic language changes at runtime.
    var localizedString: String {
        // Safety check - ensure manager is available
        let manager = LanguageManager.shared
        let bundle = manager.bundle

        // Use NSLocalizedString which properly searches .lproj bundles
        // First try the language-specific bundle
        let result = NSLocalizedString(self, tableName: nil, bundle: bundle, value: "", comment: "")

        // If the result equals the key, it wasn't found - try main bundle
        if result == self {
            let mainResult = NSLocalizedString(self, tableName: nil, bundle: .main, value: "", comment: "")
            // If main bundle also returns the key, return it as-is
            return mainResult
        }

        return result
    }

    /// Returns a LocalizedStringKey formatted with the given arguments.
    /// Usage: Text("greeting %@".localized(with: name))
    func localized(with arguments: CVarArg...) -> LocalizedStringKey {
        let format = self.localizedString
        let formattedString = String(format: format, locale: LanguageManager.shared.locale, arguments: arguments)
        return LocalizedStringKey(formattedString)
    }

    /// Returns a localized String formatted with the given arguments.
    /// Usage: "greeting %@".localizedString(with: name)
    func localizedString(with arguments: CVarArg...) -> String {
        let format = self.localizedString
        return String(format: format, locale: LanguageManager.shared.locale, arguments: arguments)
    }
}
