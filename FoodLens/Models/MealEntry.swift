// MealEntry.swift
// FoodLens - SwiftData Model
//
// Represents a logged meal entry

import Foundation
import SwiftData

@Model
final class MealEntry {
    // MARK: - Properties
    
    /// Unique identifier
    var id: UUID
    
    /// When this meal was logged
    var timestamp: Date
    
    /// Meal type (breakfast, lunch, dinner, snack)
    var mealType: MealType
    
    // MARK: - Food Details
    
    /// Name of the food (snapshot at time of logging)
    var foodName: String
    
    /// Food group (snapshot)
    var foodGroup: String
    
    /// Serving description (snapshot)
    var servingDescription: String
    
    /// Number of servings consumed
    var servingMultiplier: Double
    
    // MARK: - Macros (calculated at time of logging)
    
    var proteinGrams: Double
    var carbsGrams: Double
    var fatGrams: Double
    var calories: Double
    
    // MARK: - Relationships
    
    /// Reference to original food item (optional, may be deleted)
    var foodItemID: UUID?
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        timestamp: Date = Date(),
        mealType: MealType,
        foodName: String,
        foodGroup: String,
        servingDescription: String,
        servingMultiplier: Double,
        proteinGrams: Double,
        carbsGrams: Double,
        fatGrams: Double,
        calories: Double,
        foodItemID: UUID? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.mealType = mealType
        self.foodName = foodName
        self.foodGroup = foodGroup
        self.servingDescription = servingDescription
        self.servingMultiplier = servingMultiplier
        self.proteinGrams = proteinGrams
        self.carbsGrams = carbsGrams
        self.fatGrams = fatGrams
        self.calories = calories
        self.foodItemID = foodItemID
    }
    
    // MARK: - Convenience Initializer (from FoodItem)
    
    convenience init(
        foodItem: FoodItem,
        servingMultiplier: Double,
        mealType: MealType
    ) {
        let macros = foodItem.macros(servings: servingMultiplier)
        
        self.init(
            timestamp: Date(),
            mealType: mealType,
            foodName: foodItem.foodName,
            foodGroup: foodItem.foodGroup,
            servingDescription: foodItem.servingDescription,
            servingMultiplier: servingMultiplier,
            proteinGrams: macros.protein,
            carbsGrams: macros.carbs,
            fatGrams: macros.fat,
            calories: macros.calories,
            foodItemID: foodItem.id
        )
    }
    
    // MARK: - Computed Properties
    
    /// Display text for serving size
    var servingSizeText: String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 1
        
        let servingText = formatter.string(from: servingMultiplier as NSNumber) ?? "\(servingMultiplier)"
        return "\(servingText)× \(servingDescription)"
    }
    
    /// Short time display (e.g., "9:30 AM")
    var timeDisplay: String {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
}

// MARK: - MealType Enum

enum MealType: String, Codable, CaseIterable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var emoji: String {
        switch self {
        case .breakfast: return "🌅"
        case .lunch: return "☀️"
        case .dinner: return "🌙"
        case .snack: return "🍪"
        }
    }
    
    var displayName: String {
        "\(emoji) \(rawValue)"
    }
}

// MARK: - Sample Data

extension MealEntry {
    static let sample = MealEntry(
        mealType: .breakfast,
        foodName: "Chapati, wheat, plain",
        foodGroup: "Cereals and Millets",
        servingDescription: "1 medium chapati (40g)",
        servingMultiplier: 2.0,
        proteinGrams: 7.3,
        carbsGrams: 38.6,
        fatGrams: 5.4,
        calories: 237
    )
    
    static let samples: [MealEntry] = [
        MealEntry(
            timestamp: Date().addingTimeInterval(-3600 * 8),
            mealType: .breakfast,
            foodName: "Chapati, wheat, plain",
            foodGroup: "Cereals and Millets",
            servingDescription: "1 medium chapati (40g)",
            servingMultiplier: 2.0,
            proteinGrams: 7.3,
            carbsGrams: 38.6,
            fatGrams: 5.4,
            calories: 237
        ),
        MealEntry(
            timestamp: Date().addingTimeInterval(-3600 * 4),
            mealType: .lunch,
            foodName: "Paneer, cow milk",
            foodGroup: "Milk and Milk Products",
            servingDescription: "1 cube (30g)",
            servingMultiplier: 4.0,
            proteinGrams: 21.9,
            carbsGrams: 1.4,
            fatGrams: 25.0,
            calories: 318
        ),
        MealEntry(
            timestamp: Date().addingTimeInterval(-3600 * 1),
            mealType: .snack,
            foodName: "Dal, moong, whole, cooked",
            foodGroup: "Pulses and Legumes",
            servingDescription: "1 katori (150g)",
            servingMultiplier: 1.0,
            proteinGrams: 14.1,
            carbsGrams: 27.0,
            fatGrams: 0.6,
            calories: 168
        )
    ]
}
