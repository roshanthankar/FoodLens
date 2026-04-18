// MealRowView.swift
// FoodLens Design System - Reusable Component
//
// A reusable meal entry row following HIG

import SwiftUI

struct MealRowView: View {
    // MARK: - Properties
    
    let meal: MealEntry
    let onDelete: (() -> Void)?
    
    // MARK: - Computed Properties
    
    private var macros: (protein: Double, carbs: Double, fat: Double) {
        (meal.proteinGrams, meal.carbsGrams, meal.fatGrams)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            // Title and serving info
            HStack(alignment: .top, spacing: DesignTokens.Spacing.small) {
                Text(meal.foodName)
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .lineLimit(2)
                
                Spacer(minLength: DesignTokens.Spacing.xSmall)
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text(meal.servingSizeText)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                    
                    Text(meal.timeDisplay)
                        .font(DesignTokens.Typography.caption2)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                }
            }
            
            // Macro chips
            HStack(spacing: DesignTokens.Spacing.xSmall) {
                MacroChipView(value: macros.protein, color: DesignTokens.Colors.protein)
                MacroChipView(value: macros.carbs, color: DesignTokens.Colors.carbs)
                MacroChipView(value: macros.fat, color: DesignTokens.Colors.fat)
            }
        }
        .padding(.vertical, DesignTokens.Spacing.xSmall)
        .contentShape(Rectangle())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(meal.foodName)
        .accessibilityValue("\(meal.servingSizeText), \(meal.timeDisplay), \(Int(macros.protein)) grams protein, \(Int(macros.carbs)) grams carbs, \(Int(macros.fat)) grams fat")
    }
}

// MARK: - Macro Chip Component

struct MacroChipView: View {
    let value: Double
    let color: Color
    
    var body: some View {
        Text("\(Int(value))g")
            .font(DesignTokens.Typography.caption1.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, DesignTokens.Spacing.xSmall + 2)
            .padding(.vertical, DesignTokens.Spacing.xxSmall + 2)
            .background(color.opacity(DesignTokens.Opacity.light))
            .clipShape(Capsule())
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
                carbsGrams: 0,
                fatGrams: 5,
                calories: 225
            ),
            onDelete: nil
        )
    }
}
