// EmptyStateView.swift
// FoodLens Design System - Reusable Component
//
// A reusable empty state following HIG

import SwiftUI

struct EmptyStateView: View {
    // MARK: - Properties
    
    let systemImage: String
    let title: String
    let description: String
    let action: (() -> Void)?
    let actionLabel: String?
    
    // MARK: - Initializers
    
    init(
        systemImage: String,
        title: String,
        description: String,
        action: (() -> Void)? = nil,
        actionLabel: String? = nil
    ) {
        self.systemImage = systemImage
        self.title = title
        self.description = description
        self.action = action
        self.actionLabel = actionLabel
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: DesignTokens.Spacing.medium) {
            // Icon
            Image(systemName: systemImage)
                .font(.system(size: 48))
                .foregroundStyle(DesignTokens.Colors.secondary.opacity(0.5))
                .padding(.bottom, DesignTokens.Spacing.xSmall)
            
            // Title
            Text(title)
                .font(DesignTokens.Typography.headline)
                .foregroundStyle(DesignTokens.Colors.primary)
                .multilineTextAlignment(.center)
            
            // Description
            Text(description)
                .font(DesignTokens.Typography.callout)
                .foregroundStyle(DesignTokens.Colors.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, DesignTokens.Spacing.xLarge)
            
            // Action button
            if let action = action, let actionLabel = actionLabel {
                Button(action: action) {
                    Text(actionLabel)
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundStyle(.white)
                        .padding(.horizontal, DesignTokens.Spacing.xLarge)
                        .padding(.vertical, DesignTokens.Spacing.small)
                        .background(DesignTokens.Colors.accent)
                        .cornerRadius(DesignTokens.CornerRadius.medium)
                }
                .padding(.top, DesignTokens.Spacing.xSmall)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DesignTokens.Spacing.xxLarge)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 40) {
        EmptyStateView(
            systemImage: "fork.knife",
            title: "No Meals Logged",
            description: "Tap the add button to log your first meal today."
        )
        
        EmptyStateView(
            systemImage: "magnifyingglass",
            title: "Search Foods",
            description: "Find a food to log your first meal.",
            action: { },
            actionLabel: "Browse Foods"
        )
    }
}
