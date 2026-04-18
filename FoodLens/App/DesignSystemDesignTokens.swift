// DesignTokens.swift
// FoodLens Design System
//
// Centralized design tokens following Apple's Human Interface Guidelines
// Reference: https://developer.apple.com/design/human-interface-guidelines

import SwiftUI

// MARK: - Design Tokens

enum DesignTokens {
    
    // MARK: - Typography
    
    /// Typography scale following Apple's type system
    enum Typography {
        // Large Titles (34pt)
        static let largeTitle = Font.largeTitle.weight(.bold)
        
        // Titles (28pt, 22pt, 20pt)
        static let title1 = Font.title
        static let title2 = Font.title2
        static let title3 = Font.title3.weight(.semibold)
        
        // Headline (17pt semibold)
        static let headline = Font.headline
        
        // Body (17pt, 15pt)
        static let body = Font.body
        static let bodyEmphasized = Font.body.weight(.semibold)
        static let callout = Font.callout
        
        // Secondary text
        static let subheadline = Font.subheadline
        static let footnote = Font.footnote
        static let caption1 = Font.caption
        static let caption2 = Font.caption2
    }
    
    // MARK: - Spacing
    
    /// Spacing scale using 4pt grid system
    enum Spacing {
        static let xxSmall: CGFloat = 4
        static let xSmall: CGFloat = 8
        static let small: CGFloat = 12
        static let medium: CGFloat = 16
        static let large: CGFloat = 20
        static let xLarge: CGFloat = 24
        static let xxLarge: CGFloat = 32
        static let xxxLarge: CGFloat = 40
    }
    
    // MARK: - Corner Radius
    
    /// Corner radius tokens for consistent rounded corners
    enum CornerRadius {
        static let small: CGFloat = 8
        static let medium: CGFloat = 12
        static let large: CGFloat = 16
        static let xLarge: CGFloat = 20
        static let pill: CGFloat = 999  // For capsule shapes
    }
    
    // MARK: - Icon Sizes
    
    /// Standard icon sizes
    enum IconSize {
        static let small: CGFloat = 16
        static let medium: CGFloat = 20
        static let large: CGFloat = 24
        static let xLarge: CGFloat = 28
    }
    
    // MARK: - Button Heights
    
    /// Standard touch target sizes (minimum 44pt per HIG)
    enum ButtonHeight {
        static let small: CGFloat = 44
        static let medium: CGFloat = 50
        static let large: CGFloat = 56
    }
    
    // MARK: - Shadows
    
    /// Shadow definitions for depth
    enum Shadow {
        static let small = (color: Color.black.opacity(0.1), radius: 4.0, x: 0.0, y: 2.0)
        static let medium = (color: Color.black.opacity(0.15), radius: 8.0, x: 0.0, y: 4.0)
        static let large = (color: Color.black.opacity(0.2), radius: 16.0, x: 0.0, y: 8.0)
    }
    
    // MARK: - Animation
    
    /// Standard animation durations
    enum Animation {
        static let quick: Double = 0.2
        static let standard: Double = 0.3
        static let slow: Double = 0.5
        
        static let springQuick = SwiftUI.Animation.spring(response: 0.3, dampingFraction: 0.7)
        static let springStandard = SwiftUI.Animation.spring(response: 0.4, dampingFraction: 0.75)
    }
    
    // MARK: - Colors
    
    /// Semantic color tokens
    enum Colors {
        // Primary brand colors
        static let accent = Color.accentColor
        static let primary = Color.primary
        static let secondary = Color.secondary
        
        // Macro colors
        static let protein = Color.green
        static let carbs = Color.blue
        static let fat = Color.orange
        static let calories = Color.orange
        
        // Background colors
        static let background = Color(uiColor: .systemBackground)
        static let secondaryBackground = Color(uiColor: .secondarySystemBackground)
        static let tertiaryBackground = Color(uiColor: .tertiarySystemBackground)
        static let groupedBackground = Color(uiColor: .systemGroupedBackground)
        static let secondaryGroupedBackground = Color(uiColor: .secondarySystemGroupedBackground)
        
        // Status colors
        static let success = Color.green
        static let warning = Color.orange
        static let error = Color.red
        static let info = Color.blue
    }
    
    // MARK: - Opacity
    
    /// Standard opacity values
    enum Opacity {
        static let invisible: Double = 0
        static let faint: Double = 0.1
        static let light: Double = 0.2
        static let medium: Double = 0.5
        static let heavy: Double = 0.8
        static let opaque: Double = 1.0
    }
}

// MARK: - Convenience Extensions

extension View {
    /// Apply standard card styling
    func cardStyle() -> some View {
        self
            .background(DesignTokens.Colors.secondaryGroupedBackground)
            .cornerRadius(DesignTokens.CornerRadius.medium)
    }
    
    /// Apply pill/capsule styling
    func pillStyle() -> some View {
        self
            .background(DesignTokens.Colors.secondaryGroupedBackground)
            .clipShape(Capsule())
    }
}
