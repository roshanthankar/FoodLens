// CaloriesPillView.swift
// FoodLens Design System - Reusable Component
//
// A reusable calories summary pill following HIG

import SwiftUI

struct CaloriesPillView: View {
    // MARK: - Properties
    
    let current: Int
    let target: Int
    
    // MARK: - Computed Properties
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return Double(current) / Double(target)
    }
    
    private var progressColor: Color {
        if progress >= 1.0 {
            return DesignTokens.Colors.success
        } else if progress >= 0.8 {
            return DesignTokens.Colors.warning
        } else {
            return DesignTokens.Colors.calories
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            // Leading icon and label
            HStack(spacing: DesignTokens.Spacing.xSmall) {
                Image(systemName: "flame.fill")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(progressColor)
                
                Text("Calories")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondary)
            }
            
            Spacer()
            
            // Trailing values
            HStack(spacing: DesignTokens.Spacing.xxSmall) {
                Text("\(current)/\(target)")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .monospacedDigit()
                    .foregroundStyle(DesignTokens.Colors.primary)
                
                Text("kcal")
                    .font(DesignTokens.Typography.body)
                    .foregroundStyle(DesignTokens.Colors.secondary)
            }
        }
        .padding(.horizontal, DesignTokens.Spacing.medium)
        .padding(.vertical, DesignTokens.Spacing.small + 2)
        .frame(maxWidth: .infinity)
        .background(DesignTokens.Colors.secondaryGroupedBackground)
        .clipShape(Capsule())
        .accessibilityElement(children: .ignore)
        .accessibilityLabel("Calories")
        .accessibilityValue("\(current) of \(target) kilocalories")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        CaloriesPillView(current: 850, target: 2000)
        CaloriesPillView(current: 1650, target: 2000)
        CaloriesPillView(current: 2100, target: 2000)
    }
    .padding()
    .background(DesignTokens.Colors.groupedBackground)
}
