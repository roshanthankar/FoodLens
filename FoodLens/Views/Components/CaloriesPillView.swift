// CaloriesPillView.swift
// FoodLens Design System - Reusable Component
//
// A reusable calories summary component following HIG

import SwiftUI

struct CaloriesPillView: View {
    // MARK: - Properties
    
    let current: Int
    let target: Int
    
    // MARK: - Computed Properties
    
    private var percentage: Int {
        guard target > 0 else { return 0 }
        return Int((Double(current) / Double(target)) * 100)
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .lastTextBaseline, spacing: DesignTokens.Spacing.medium) { // 16px gap, bottom baseline alignment
            // Left side: Percentage display
            HStack(alignment: .lastTextBaseline, spacing: 4) { // 4px gap, baseline aligned
                Text("\(percentage)")
                    .font(.momoSans(64, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.primary)

                Text("%")
                    .font(.momoSans(28, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.primary)
            }
            
            Spacer()
            
            // Right side: Calorie fraction (aligned to bottom baseline)
            HStack(spacing: 4) { // 4px gap between fraction and kcal
                Text("\(current)/\(target)")
                    .font(.momoSans(18, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.secondary)

                Text("kcal")
                    .font(.momoSans(18, weight: .medium))
                    .foregroundStyle(DesignTokens.Colors.secondary)
            }
        }
        .frame(maxWidth: .infinity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calories")
        .accessibilityValue("\(percentage) percent, \(current) of \(target) kilocalories")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        CaloriesPillView(current: 2000, target: 2385)
        CaloriesPillView(current: 850, target: 2000)
        CaloriesPillView(current: 2100, target: 2000)
    }
    .padding()
    .background(Color(uiColor: .systemBackground))
}
