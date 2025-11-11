import SwiftUI

extension String {
    /// Returns a LocalizedStringKey for use in SwiftUI Text views.
    var localized: LocalizedStringKey {
        LocalizedStringKey(self)
    }
    
    /// Returns a LocalizedStringKey formatted with the given arguments.
    /// Usage: Text("greeting %@" .localized(with: name))
    func localized(with arguments: CVarArg...) -> LocalizedStringKey {
        let format = self
        let formattedString = String(format: format, locale: Locale.current, arguments: arguments)
        return LocalizedStringKey(formattedString)
    }
}
