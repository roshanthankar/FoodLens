// SectionHeaderView.swift
// FoodLens Design System - Reusable Component
//
// A reusable section header following HIG

import SwiftUI

struct SectionHeaderView: View {
    // MARK: - Properties
    
    let title: String
    let subtitle: String?
    let action: (() -> Void)?
    let actionLabel: String?
    
    // MARK: - Initializers
    
    init(
        title: String,
        subtitle: String? = nil,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.action = action
        self.actionLabel = actionLabel
    }
    
    // MARK: - Body
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxSmall) {
                Text(title)
                    .font(DesignTokens.Typography.headline)
                    .foregroundStyle(DesignTokens.Colors.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(DesignTokens.Typography.callout)
                        .foregroundStyle(DesignTokens.Colors.accent)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 24) {
        SectionHeaderView(title: "Quick Log")
        
        SectionHeaderView(
            title: "Recent Foods",
            subtitle: "Your last 10 foods"
        )
        
        SectionHeaderView(
            title: "Breakfast",
            action: { },
            actionLabel: "Add"
        )
    }
    .padding()
}
