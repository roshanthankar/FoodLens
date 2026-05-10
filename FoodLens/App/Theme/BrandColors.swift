import SwiftUI

enum MacroTheme: String, CaseIterable, Identifiable, Hashable {
    case carbs, protein, fats

    var id: String { rawValue }

    var label: String {
        switch self {
        case .carbs:   "Carbs"
        case .protein: "Protein"
        case .fats:    "Fats"
        }
    }

    var avgLabel: String {
        switch self {
        case .carbs:   "Avg Carbs"
        case .protein: "Avg Protein"
        case .fats:    "Avg Fats"
        }
    }

    var initialLetter: String {
        String(label.first!)
    }

    var tint: Color {
        switch self {
        case .carbs:   .macroCarbs
        case .protein: .macroProtein
        case .fats:    .macroFats
        }
    }

    var headerTopColor: Color {
        switch self {
        case .carbs:   .headerCarbsTop
        case .protein: .headerProteinTop
        case .fats:    .headerFatsTop
        }
    }
}

extension LinearGradient {
    static let homeHeader = LinearGradient(
        colors: [.headerHomeTop, .surfaceBackground],
        startPoint: .top,
        endPoint: .bottom
    )

    static func macroHeader(_ macro: MacroTheme) -> LinearGradient {
        LinearGradient(
            colors: [macro.headerTopColor, .surfaceBackground],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}
