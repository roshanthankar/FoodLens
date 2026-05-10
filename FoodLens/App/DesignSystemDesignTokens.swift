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
        // Display styles (for large metrics and numbers)
        enum Display {
            // 60px with weight 600 (semibold)
            static let large: Font = {
                #if os(iOS)
                return Font(UIFont(name: "MomoTrustSans-SemiBold", size: 60) ?? 
                           UIFont.systemFont(ofSize: 60, weight: .init(rawValue: 600)))
                #elseif os(macOS)
                return Font(NSFont(name: "MomoTrustSans-SemiBold", size: 60) ?? 
                           NSFont.systemFont(ofSize: 60, weight: .init(rawValue: 600)))
                #endif
            }()
            
            // 24px with weight 500 (medium)
            static let medium: Font = {
                #if os(iOS)
                return Font(UIFont(name: "MomoTrustSans-Medium", size: 24) ?? 
                           UIFont.systemFont(ofSize: 24, weight: .init(rawValue: 500)))
                #elseif os(macOS)
                return Font(NSFont(name: "MomoTrustSans-Medium", size: 24) ?? 
                           NSFont.systemFont(ofSize: 24, weight: .init(rawValue: 500)))
                #endif
            }()
        }
        
        // Body styles
        enum Body {
            // 16px with weight 500 (medium)
            static let medium: Font = {
                #if os(iOS)
                return Font(UIFont(name: "MomoTrustSans-Medium", size: 16) ?? 
                           UIFont.systemFont(ofSize: 16, weight: .init(rawValue: 500)))
                #elseif os(macOS)
                return Font(NSFont(name: "MomoTrustSans-Medium", size: 16) ?? 
                           NSFont.systemFont(ofSize: 16, weight: .init(rawValue: 500)))
                #endif
            }()
        }
        
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
        static let secondary = Color(hex: "707070") // Secondary text color
        
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

extension Color {
    /// Initialize Color from hex string
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

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
