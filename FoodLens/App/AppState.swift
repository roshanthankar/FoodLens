// AppState.swift
// FoodLens — Centralized State Management
//
// Single source of truth for the entire app.
// Inspired by Redux pattern from clean-architecture-swiftui

import Foundation
import SwiftUI
import Combine

@MainActor
@Observable
final class AppState {
    // MARK: - Singleton
    
    static let shared = AppState()
    
    // MARK: - App State
    
    /// Current screen being displayed
    var routing: Routing = .today
    
    /// User settings and preferences
    var userSettings: UserSettings?
    
    /// Today's meal entries (cached for performance)
    var todayMeals: [MealEntry] = []
    
    /// Today's macro totals (computed from todayMeals)
    var todayTotals: MacroTotals = .empty
    
    /// Recent food items (for quick access)
    var recentFoods: [FoodItem] = []
    
    /// Favorite food items
    var favoriteFoods: [FoodItem] = []
    
    /// Loading states
    var isLoading: LoadingState = .idle
    
    /// Error state
    var error: AppError?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - State Updates
    
    func updateTodayMeals(_ meals: [MealEntry]) {
        self.todayMeals = meals
        self.todayTotals = MacroTotals(
            protein: meals.reduce(0) { $0 + $1.proteinGrams },
            carbs: meals.reduce(0) { $0 + $1.carbsGrams },
            fat: meals.reduce(0) { $0 + $1.fatGrams }
        )
    }
    
    func updateRecentFoods(_ foods: [FoodItem]) {
        self.recentFoods = foods
    }
    
    func updateFavoriteFoods(_ foods: [FoodItem]) {
        self.favoriteFoods = foods
    }
    
    func setLoading(_ state: LoadingState) {
        self.isLoading = state
    }
    
    func setError(_ error: AppError) {
        self.error = error
    }
    
    func clearError() {
        self.error = nil
    }
}

// MARK: - Supporting Types

extension AppState {
    enum Routing {
        case onboarding
        case today
        case add        // Middle tab - triggers add meal sheet
        case history
        case settings
    }
    
    enum LoadingState {
        case idle
        case loading
        case loaded
    }
}

// MARK: - Macro Totals

struct MacroTotals: Equatable {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var calories: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }
    
    static let empty = MacroTotals(protein: 0, carbs: 0, fat: 0)
    
    func progress(target: MacroTargets) -> MacroProgress {
        MacroProgress(
            protein: protein / target.protein,
            carbs: carbs / target.carbs,
            fat: fat / target.fat
        )
    }
}

struct MacroTargets {
    let protein: Double
    let carbs: Double
    let fat: Double
    
    var calories: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }

    static let `default` = MacroTargets(protein: 150, carbs: 200, fat: 60)
    static let fatLoss = MacroTargets(protein: 140, carbs: 150, fat: 50)
    static let maintenance = MacroTargets(protein: 100, carbs: 260, fat: 60)
    static let muscleGain = MacroTargets(protein: 150, carbs: 300, fat: 65)
}

struct MacroProgress {
    let protein: Double  // 0.0 to 1.0+
    let carbs: Double
    let fat: Double
    
    func clamped() -> MacroProgress {
        MacroProgress(
            protein: min(protein, 1.0),
            carbs: min(carbs, 1.0),
            fat: min(fat, 1.0)
        )
    }
}

// MARK: - App Error

enum AppError: LocalizedError, Identifiable {
    case databaseError(String)
    case networkError(String)
    case validationError(String)
    case unknown(String)
    
    var id: String {
        switch self {
        case .databaseError(let msg): return "db_\(msg)"
        case .networkError(let msg): return "net_\(msg)"
        case .validationError(let msg): return "val_\(msg)"
        case .unknown(let msg): return "unk_\(msg)"
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .databaseError(let msg): return "Database Error: \(msg)"
        case .networkError(let msg): return "Network Error: \(msg)"
        case .validationError(let msg): return "Validation Error: \(msg)"
        case .unknown(let msg): return "Error: \(msg)"
        }
    }
}
