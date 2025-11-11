//
//  ThemeManager.swift
//  FootballApp
//
//  Created by Symeon Lampadarios on 12/11/2025.
//

import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    @Published var selectedColorScheme: ColorScheme?
    @Published var accentColor: Color?
    
    init() {
        // Default to system color scheme (nil means follow system)
        self.selectedColorScheme = nil
        self.accentColor = nil
    }
    
    func setColorScheme(_ scheme: ColorScheme?) {
        selectedColorScheme = scheme
    }
    
    func setAccentColor(_ color: Color?) {
        accentColor = color
    }
}
