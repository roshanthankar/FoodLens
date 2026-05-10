// MacroGaugeView.swift
// FoodLens Design System - Reusable Component
//
// A reusable macro gauge component following HIG

import SwiftUI

// MARK: - Macro Data Model

struct MacroData {
    let label: String
    let value: Double
    let target: Double
    let color: Color
    let showIcon: Bool

    init(label: String, value: Double, target: Double, color: Color, showIcon: Bool = true) {
        self.label = label
        self.value = value
        self.target = target
        self.color = color
        self.showIcon = showIcon
    }

    var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((value / target) * 100)
    }

    var status: MacroStatus {
        guard target > 0 else { return .low }
        if value >= target * 0.95 && value <= target * 1.05 {
            return .met
        } else if value > target {
            return .exceeded
        } else {
            return .low
        }
    }
}

enum MacroStatus {
    case met
    case exceeded
    case low

    var systemImage: String {
        switch self {
        case .met: return "checkmark.circle.fill"
        case .exceeded: return "arrow.up.circle.fill"
        case .low: return "arrow.down.circle.fill"
        }
    }
}

// MARK: - MacroGaugeView

struct MacroGaugeView: View {
    let carbs: MacroData
    let protein: MacroData
    let fats: MacroData
    let calories: MacroData?
    let showDivider: Bool

    init(
        carbs: MacroData,
        protein: MacroData,
        fats: MacroData,
        calories: MacroData? = nil,
        showDivider: Bool = true
    ) {
        self.carbs = carbs
        self.protein = protein
        self.fats = fats
        self.calories = calories
        self.showDivider = showDivider
    }

    var body: some View {
        HStack(spacing: 24) {
            macroColumn(for: carbs)
            macroColumn(for: protein)
            macroColumn(for: fats)

            if let calories {
                if showDivider {
                    Rectangle()
                        .fill(Color(uiColor: .separator))
                        .frame(width: 1)
                        .frame(maxHeight: .infinity)
                }
                macroColumn(for: calories)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func macroColumn(for macro: MacroData) -> some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxSmall) {
            Text(macro.label)
                .font(.momoSans(14, weight: .semibold))
                .foregroundStyle(macro.color)

            HStack(alignment: .firstTextBaseline, spacing: 2) {
                Text("\(macro.percentage)")
                    .font(.momoSans(22, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .label))

                Text("%")
                    .font(.momoSans(14, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }

            HStack(spacing: 4) {
                if macro.showIcon {
                    Image(systemName: macro.status.systemImage)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(Color(uiColor: .secondaryLabel))
                }

                Text("\(Int(macro.value)) g")
                    .font(.momoSans(14, weight: .semibold))
                    .foregroundStyle(Color(uiColor: .secondaryLabel))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(macro.label)
        .accessibilityValue("\(macro.percentage) percent, \(Int(macro.value)) of \(Int(macro.target)) grams")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        // Variant 1: low / met / exceeded states
        MacroGaugeView(
            carbs: MacroData(label: "Carbs", value: 84, target: 200, color: .macroCarbs),       // low → 􀁯
            protein: MacroData(label: "Protein", value: 198, target: 200, color: .macroProtein), // met → 􀁣
            fats: MacroData(label: "Fats", value: 75, target: 60, color: .macroFats),            // exceeded → 􀁱
            calories: MacroData(label: "Calories", value: 2000, target: 2385, color: Color(uiColor: .label), showIcon: false),
            showDivider: true
        )

        // Variant 2: no calories, no divider
        MacroGaugeView(
            carbs: MacroData(label: "Carbs", value: 160, target: 200, color: .macroCarbs),
            protein: MacroData(label: "Protein", value: 145, target: 150, color: .macroProtein), // met
            fats: MacroData(label: "Fats", value: 70, target: 60, color: .macroFats)             // exceeded
        )
    }
    .padding(.horizontal, 20)
}
