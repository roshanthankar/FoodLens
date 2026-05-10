// BrandColors.swift
// FoodLens Design System
//
// Brand color definitions and semantic color extensions

import SwiftUI

// MARK: - Color Extensions

extension Color {
    // MARK: - Brand Colors
    
    /// Primary brand teal color — #007A6B (light) / #008A7C (dark), from BrandTeal asset
    static let brandTeal = Color("BrandTeal")
    
    /// Brand accent color
    static let brandAccent = brandTeal
    
    // MARK: - Surface Colors
    
    /// Card background surface
    static let surfaceCard = Color(uiColor: .secondarySystemGroupedBackground)
    
    /// Main background surface
    static let surfaceBackground = Color(uiColor: .systemGroupedBackground)
    
    /// Elevated surface
    static let surfaceElevated = Color(uiColor: .systemBackground)
    
    // MARK: - Header Gradients
    
    /// Top color for home header gradient
    static let headerHomeTop = Color(red: 0.0, green: 0.6, blue: 0.6)
    
    /// Bottom color for home header gradient
    static let headerHomeBottom = Color(red: 0.0, green: 0.8, blue: 0.8)
    
    // MARK: - Macro Colors
    
    /// Protein macro color
    static let macroProtein = Color.green
    
    /// Carbs macro color
    static let macroCarbs = Color.blue
    
    /// Fat macro color
    static let macroFat = Color.orange
    
    /// Calories color
    static let macroCalories = Color.orange
    
    // MARK: - Status Colors
    
    /// Success state color
    static let statusSuccess = Color.green
    
    /// Warning state color
    static let statusWarning = Color.orange
    
    /// Error state color
    static let statusError = Color.red
    
    /// Info state color
    static let statusInfo = Color.blue
}

// MARK: - ShapeStyle Extensions

extension ShapeStyle where Self == Color {
    /// Card background surface
    static var surfaceCard: Color { .surfaceCard }
    
    /// Main background surface
    static var surfaceBackground: Color { .surfaceBackground }
    
    /// Elevated surface
    static var surfaceElevated: Color { .surfaceElevated }
}
