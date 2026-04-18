// FoodItem.swift
// FoodLens - SwiftData Model
//
// Represents food items from the IFCT 2017 database (542 Indian foods)

import Foundation
import SwiftData

@Model
final class FoodItem {
    // MARK: - Properties
    
    /// Unique identifier
    var id: UUID
    
    /// Food name (e.g., "Chapati, wheat, plain")
    var foodName: String
    
    /// Food group (e.g., "Cereals and Millets")
    var foodGroup: String
    
    /// Standard serving description (e.g., "1 medium chapati (40g)")
    var servingDescription: String
    
    /// Standard serving size in grams
    var servingSizeGrams: Double
    
    // MARK: - Macros (per 100g)
    
    var proteinPer100g: Double
    var carbsPer100g: Double
    var fatPer100g: Double
    var fiberPer100g: Double
    var caloriesPer100g: Double
    
    // MARK: - Usage Tracking
    
    /// Number of times this food has been logged
    var useCount: Int
    
    /// Last time this food was used
    var lastUsedDate: Date?
    
    /// Whether user marked this as favorite
    var isFavorite: Bool
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        foodName: String,
        foodGroup: String,
        servingDescription: String,
        servingSizeGrams: Double,
        proteinPer100g: Double,
        carbsPer100g: Double,
        fatPer100g: Double,
        fiberPer100g: Double,
        caloriesPer100g: Double,
        useCount: Int = 0,
        lastUsedDate: Date? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.foodName = foodName
        self.foodGroup = foodGroup
        self.servingDescription = servingDescription
        self.servingSizeGrams = servingSizeGrams
        self.proteinPer100g = proteinPer100g
        self.carbsPer100g = carbsPer100g
        self.fatPer100g = fatPer100g
        self.fiberPer100g = fiberPer100g
        self.caloriesPer100g = caloriesPer100g
        self.useCount = useCount
        self.lastUsedDate = lastUsedDate
        self.isFavorite = isFavorite
    }
    
    // MARK: - Computed Properties
    
    /// Calculate macros for a given serving multiplier
    func macros(servings: Double) -> (protein: Double, carbs: Double, fat: Double, calories: Double) {
        let grams = servingSizeGrams * servings
        let multiplier = grams / 100.0
        
        return (
            protein: proteinPer100g * multiplier,
            carbs: carbsPer100g * multiplier,
            fat: fatPer100g * multiplier,
            calories: caloriesPer100g * multiplier
        )
    }
    
    /// Search-friendly text (for fuzzy matching)
    var searchableText: String {
        "\(foodName) \(foodGroup)".lowercased()
    }
}

// MARK: - Codable Support (for JSON import)

extension FoodItem {
    /// Struct for decoding from JSON
    struct JSONFormat: Decodable {
        let foodName: String
        let foodGroup: String
        let servingDescription: String
        let servingSizeGrams: Double
        let proteinPer100g: Double
        let carbsPer100g: Double
        let fatPer100g: Double
        let fiberPer100g: Double
        let caloriesPer100g: Double

        private enum CodingKeys: String, CodingKey {
            case foodName
            case foodGroup
            case servingDescription
            case servingSizeGrams
            case proteinPer100g
            case carbsPer100g
            case fatPer100g
            case fiberPer100g
            case caloriesPer100g
            case name
            case category
            case defaultServing
            case per100g
        }

        private enum ServingKeys: String, CodingKey {
            case grams
            case label
        }

        private enum MacroKeys: String, CodingKey {
            case calories
            case protein
            case carbs
            case fat
            case fiber
        }

        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)

            if container.contains(.foodName) {
                foodName = try container.decode(String.self, forKey: .foodName)
                foodGroup = try container.decode(String.self, forKey: .foodGroup)
                servingDescription = try container.decode(String.self, forKey: .servingDescription)
                servingSizeGrams = try container.decode(Double.self, forKey: .servingSizeGrams)
                proteinPer100g = try container.decode(Double.self, forKey: .proteinPer100g)
                carbsPer100g = try container.decode(Double.self, forKey: .carbsPer100g)
                fatPer100g = try container.decode(Double.self, forKey: .fatPer100g)
                fiberPer100g = try container.decode(Double.self, forKey: .fiberPer100g)
                caloriesPer100g = try container.decode(Double.self, forKey: .caloriesPer100g)
                return
            }

            let servingContainer = try container.nestedContainer(keyedBy: ServingKeys.self, forKey: .defaultServing)
            let macroContainer = try container.nestedContainer(keyedBy: MacroKeys.self, forKey: .per100g)

            foodName = try container.decode(String.self, forKey: .name)
            foodGroup = try container.decode(String.self, forKey: .category)
            servingDescription = try servingContainer.decode(String.self, forKey: .label)
            servingSizeGrams = try servingContainer.decode(Double.self, forKey: .grams)
            proteinPer100g = try macroContainer.decode(Double.self, forKey: .protein)
            carbsPer100g = try macroContainer.decode(Double.self, forKey: .carbs)
            fatPer100g = try macroContainer.decode(Double.self, forKey: .fat)
            fiberPer100g = try macroContainer.decode(Double.self, forKey: .fiber)
            caloriesPer100g = try macroContainer.decode(Double.self, forKey: .calories)
        }
        
        func toFoodItem() -> FoodItem {
            FoodItem(
                foodName: foodName,
                foodGroup: foodGroup,
                servingDescription: servingDescription,
                servingSizeGrams: servingSizeGrams,
                proteinPer100g: proteinPer100g,
                carbsPer100g: carbsPer100g,
                fatPer100g: fatPer100g,
                fiberPer100g: fiberPer100g,
                caloriesPer100g: caloriesPer100g
            )
        }
    }
}

// MARK: - Sample Data (for previews)

extension FoodItem {
    static let sample = FoodItem(
        foodName: "Chapati, wheat, plain",
        foodGroup: "Cereals and Millets",
        servingDescription: "1 medium chapati (40g)",
        servingSizeGrams: 40,
        proteinPer100g: 9.1,
        carbsPer100g: 48.2,
        fatPer100g: 6.7,
        fiberPer100g: 2.9,
        caloriesPer100g: 297
    )
    
    static let paneer = FoodItem(
        foodName: "Paneer, cow milk",
        foodGroup: "Milk and Milk Products",
        servingDescription: "1 cube (30g)",
        servingSizeGrams: 30,
        proteinPer100g: 18.3,
        carbsPer100g: 1.2,
        fatPer100g: 20.8,
        fiberPer100g: 0.0,
        caloriesPer100g: 265
    )
}
