// MealRowView.swift
// FoodLens Design System - Reusable Component
//
// Reusable meal entry row matching TodayView's MealRow styling.

import SwiftUI

struct MealRowView: View {
    let meal: MealEntry
    let onDelete: (() -> Void)?

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(meal.foodName)
                    .font(.momoSans(17, weight: .semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Text(meal.servingSizeText)
                    Text("•")
                    Text(meal.timeDisplay)
                }
                .font(.momoSans(15, weight: .medium))
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            HStack(spacing: 0) {
                MacroChipView(label: "Carbs",   prefix: "C", value: meal.carbsGrams,   color: .macroCarbs)
                Spacer(minLength: 12)
                MacroChipView(label: "Protein", prefix: "P", value: meal.proteinGrams, color: .macroProtein)
                Spacer(minLength: 12)
                MacroChipView(label: "Fats",    prefix: "F", value: meal.fatGrams,     color: .macroFats)
                Spacer(minLength: 0)
            }
        }
        .padding(.vertical, 6)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(meal.foodName)
        .accessibilityValue("\(meal.servingSizeText), \(meal.timeDisplay), \(Int(meal.proteinGrams))g protein, \(Int(meal.carbsGrams))g carbs, \(Int(meal.fatGrams))g fat")
    }
}

// MARK: - Macro Chip Component

struct MacroChipView: View {
    let label: String
    let prefix: String
    let value: Double
    let color: Color

    var body: some View {
        HStack(spacing: 4) {
            Text(prefix)
                .font(.momoSans(15, weight: .medium))
            Text(value, format: .number.precision(.fractionLength(0...1)))
                .font(.momoSans(15, weight: .semibold))
            Text("g")
                .font(.momoSans(15, weight: .semibold))
        }
        .foregroundStyle(color)
        .accessibilityLabel("\(label): \(value) grams")
    }
}

// MARK: - Preview

#Preview {
    List {
        MealRowView(
            meal: MealEntry(
                mealType: .lunch,
                foodName: "Grilled Chicken Breast",
                foodGroup: "Protein",
                servingDescription: "1 breast (100g)",
                servingMultiplier: 1.5,
                proteinGrams: 45,
                carbsGrams: 10,
                fatGrams: 2.3,
                calories: 225
            ),
            onDelete: nil
        )
    }
}
