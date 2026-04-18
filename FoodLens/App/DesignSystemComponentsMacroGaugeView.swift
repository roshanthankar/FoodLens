// MacroGaugeView.swift
// FoodLens Design System - Reusable Component
//
// A reusable macro gauge card following HIG

import SwiftUI

struct MacroGaugeView: View {
    // MARK: - Properties
    
    let label: String
    let value: Double
    let target: Double
    let color: Color
    
    // MARK: - Computed Properties
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(value / target, 1.0)
    }
    
    private var percentage: Int {
        Int(progress * 100)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: DesignTokens.Spacing.xSmall) {
            // Header
            HStack {
                Text(label)
                    .font(DesignTokens.Typography.callout)
                    .foregroundStyle(DesignTokens.Colors.secondary)
                
                Spacer()
                
                Text("\(Int(value))g")
                    .font(DesignTokens.Typography.bodyEmphasized)
                    .foregroundStyle(color)
                    .monospacedDigit()
            }
            
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // Background track
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                        .fill(color.opacity(DesignTokens.Opacity.faint))
                        .frame(height: 8)
                    
                    // Progress fill
                    RoundedRectangle(cornerRadius: DesignTokens.CornerRadius.small)
                        .fill(color)
                        .frame(width: geometry.size.width * progress, height: 8)
                        .animation(DesignTokens.Animation.springStandard, value: progress)
                }
            }
            .frame(height: 8)
            
            // Footer
            HStack {
                Text("\(percentage)%")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .monospacedDigit()
                
                Spacer()
                
                Text("of \(Int(target))g")
                    .font(DesignTokens.Typography.caption1)
                    .foregroundStyle(DesignTokens.Colors.secondary)
                    .monospacedDigit()
            }
        }
        .padding(DesignTokens.Spacing.medium)
        .background(DesignTokens.Colors.secondaryGroupedBackground)
        .cornerRadius(DesignTokens.CornerRadius.medium)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value)) of \(Int(target)) grams, \(percentage) percent")
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 16) {
        MacroGaugeView(label: "Protein", value: 85, target: 150, color: .green)
        MacroGaugeView(label: "Carbs", value: 160, target: 200, color: .blue)
        MacroGaugeView(label: "Fat", value: 45, target: 60, color: .orange)
    }
    .padding()
    .background(DesignTokens.Colors.groupedBackground)
}
