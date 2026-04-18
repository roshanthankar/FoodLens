// MealLoggingInteractor.swift
// FoodLens - Business Logic Layer
//
// Handles all meal logging business logic

import Foundation
import SwiftData

@MainActor
@Observable
final class MealLoggingInteractor {
    // MARK: - Dependencies
    
    private let appState: AppState
    private let mealLogRepository: MealLogRepository
    private let foodRepository: FoodRepository
    private let hapticManager: HapticManager
    
    // MARK: - State
    
    var isLogging: Bool = false
    var lastLoggedMeal: MealEntry?
    
    // MARK: - Initialization
    
    init(
        appState: AppState,
        mealLogRepository: MealLogRepository,
        foodRepository: FoodRepository,
        hapticManager: HapticManager = HapticManager()
    ) {
        self.appState = appState
        self.mealLogRepository = mealLogRepository
        self.foodRepository = foodRepository
        self.hapticManager = hapticManager
    }
    
    // MARK: - Main Operations
    
    /// Log a meal (primary business logic)
    func logMeal(
        food: FoodItem,
        servings: Double,
        mealType: MealType
    ) async {
        guard !isLogging else { return }
        isLogging = true
        appState.setLoading(.loading)
        
        do {
            // 1. Create meal entry
            let entry = MealEntry(
                foodItem: food,
                servingMultiplier: servings,
                mealType: mealType
            )
            
            // 2. Save via repository
            try mealLogRepository.save(entry)
            
            // 3. Update food usage tracking
            try foodRepository.markAsUsed(food)
            
            // 4. Refresh today's meals in AppState
            let todayMeals = try mealLogRepository.fetchToday()
            appState.updateTodayMeals(todayMeals)
            
            // 5. Update recent foods
            let recentFoods = try foodRepository.fetchRecentFoods()
            appState.updateRecentFoods(recentFoods)
            
            // 6. Store last logged meal
            lastLoggedMeal = entry
            
            // 7. Success feedback
            hapticManager.success()
            
            appState.setLoading(.loaded)
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            hapticManager.error()
        }
        
        isLogging = false
    }
    
    /// Quick log (use last serving size for this food)
    func quickLog(food: FoodItem, mealType: MealType) async {
        // Use default 1 serving for quick log
        await logMeal(food: food, servings: 1.0, mealType: mealType)
    }
    
    /// Log multiple foods at once (bulk logging)
    func logMultipleMeals(_ entries: [(food: FoodItem, servings: Double, mealType: MealType)]) async {
        guard !isLogging else { return }
        isLogging = true
        appState.setLoading(.loading)
        
        do {
            // Create all entries
            let mealEntries = entries.map { (food, servings, mealType) in
                MealEntry(foodItem: food, servingMultiplier: servings, mealType: mealType)
            }
            
            // Save all at once
            try mealLogRepository.saveAll(mealEntries)
            
            // Update food usage for all
            for (food, _, _) in entries {
                try foodRepository.markAsUsed(food)
            }
            
            // Refresh state
            let todayMeals = try mealLogRepository.fetchToday()
            appState.updateTodayMeals(todayMeals)
            
            let recentFoods = try foodRepository.fetchRecentFoods()
            appState.updateRecentFoods(recentFoods)
            
            hapticManager.success()
            appState.setLoading(.loaded)
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            hapticManager.error()
        }
        
        isLogging = false
    }
    
    // MARK: - Editing Operations
    
    /// Update an existing meal entry
    func updateMeal(_ entry: MealEntry, newServings: Double) async {
        do {
            // Recalculate macros with new serving size
            guard let foodID = entry.foodItemID,
                  let food = try foodRepository.fetchByID(foodID) else {
                throw InteractorError.foodNotFound
            }
            
            let macros = food.macros(servings: newServings)
            entry.servingMultiplier = newServings
            entry.proteinGrams = macros.protein
            entry.carbsGrams = macros.carbs
            entry.fatGrams = macros.fat
            entry.calories = macros.calories
            
            try mealLogRepository.update(entry)
            
            // Refresh state
            let todayMeals = try mealLogRepository.fetchToday()
            appState.updateTodayMeals(todayMeals)
            
            hapticManager.light()
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            hapticManager.error()
        }
    }
    
    /// Delete a meal entry
    func deleteMeal(_ entry: MealEntry) async {
        do {
            try mealLogRepository.delete(entry)
            
            // Refresh state
            let todayMeals = try mealLogRepository.fetchToday()
            appState.updateTodayMeals(todayMeals)
            
            hapticManager.light()
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            hapticManager.error()
        }
    }
    
    // MARK: - Undo Operations
    
    /// Undo last logged meal
    func undoLastMeal() async {
        guard let lastMeal = lastLoggedMeal else { return }
        
        await deleteMeal(lastMeal)
        lastLoggedMeal = nil
    }
    
    // MARK: - Meal Type Suggestions
    
    /// Suggest meal type based on time of day
    func suggestedMealType() -> MealType {
        let hour = Calendar.current.component(.hour, from: Date())
        
        switch hour {
        case 5..<11:
            return .breakfast
        case 11..<16:
            return .lunch
        case 16..<22:
            return .dinner
        default:
            return .snack
        }
    }
    
    // MARK: - Validation
    
    /// Validate serving size
    func isValidServingSize(_ servings: Double) -> Bool {
        servings > 0 && servings <= 20 // Max 20 servings seems reasonable
    }
    
    /// Get validation error message
    func servingSizeError(for servings: Double) -> String? {
        if servings <= 0 {
            return "Serving size must be greater than 0"
        }
        if servings > 20 {
            return "Serving size seems too large (max 20)"
        }
        return nil
    }
}

// MARK: - Interactor Error

enum InteractorError: LocalizedError {
    case foodNotFound
    case invalidInput(String)
    case operationFailed(String)
    
    var errorDescription: String? {
        switch self {
        case .foodNotFound:
            return "Food item not found"
        case .invalidInput(let reason):
            return "Invalid input: \(reason)"
        case .operationFailed(let reason):
            return "Operation failed: \(reason)"
        }
    }
}
