import SwiftUI

enum AppearancePreference: String, CaseIterable, Identifiable {
    case system, light, dark

    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: "System"
        case .light:  "Light"
        case .dark:   "Dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light:  .light
        case .dark:   .dark
        }
    }
}

@Observable
final class AppTheme {
    var appearance: AppearancePreference {
        didSet {
            UserDefaults.standard.set(appearance.rawValue, forKey: Self.appearanceKey)
        }
    }

    init() {
        let stored = UserDefaults.standard.string(forKey: Self.appearanceKey)
        self.appearance = stored.flatMap(AppearancePreference.init(rawValue:)) ?? .system
    }

    private static let appearanceKey = "FoodLens.AppearancePreference"
}
