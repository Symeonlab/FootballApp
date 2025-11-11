public enum MaterialSelection: Hashable {
    case none
    case ultraThin
    case thin
    case regular
    case thick
}

import SwiftUI

private struct AppMaterialSelectionKey: EnvironmentKey {
    static let defaultValue: MaterialSelection = .none
}

public extension EnvironmentValues {
    var appMaterialSelection: MaterialSelection {
        get { self[AppMaterialSelectionKey.self] }
        set { self[AppMaterialSelectionKey.self] = newValue }
    }
}
