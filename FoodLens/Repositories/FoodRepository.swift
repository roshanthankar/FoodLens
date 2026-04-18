// FoodRepository.swift
// FoodLens - Data Access Layer
//
// Handles all food database operations (CRUD + search)

import Foundation
import SwiftData

private struct FoodDatabaseDocument: Decodable {
    let foods: [FoodItem.JSONFormat]
}

@MainActor
final class FoodRepository {
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Database Seeding
    
    /// Load 542 IFCT foods from JSON into database
    func seedDatabase() async throws {
        // Check if already seeded
        let count = try modelContext.fetchCount(FetchDescriptor<FoodItem>())
        guard count == 0 else {
            print("✅ Database already seeded with \(count) foods")
            return
        }
        
        print("🌱 Seeding database with IFCT foods...")
        
        // Load JSON file
        guard let url = Bundle.main.url(forResource: "foodlens-food-database", withExtension: "json") else {
            throw RepositoryError.fileNotFound("foodlens-food-database.json")
        }
        
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let jsonFoods: [FoodItem.JSONFormat]

        if let document = try? decoder.decode(FoodDatabaseDocument.self, from: data) {
            jsonFoods = document.foods
        } else {
            jsonFoods = try decoder.decode([FoodItem.JSONFormat].self, from: data)
        }
        
        // Insert into database
        for jsonFood in jsonFoods {
            let food = jsonFood.toFoodItem()
            modelContext.insert(food)
        }
        
        try modelContext.save()
        print("✅ Seeded \(jsonFoods.count) foods into database")
    }
    
    // MARK: - Search Operations
    
    /// Search foods by name or group (fuzzy matching)
    func search(query: String) async throws -> [FoodItem] {
        guard !query.isEmpty else {
            return try fetchAll()
        }
        
        let lowercaseQuery = query.lowercased()
        let allFoods = try fetchAll()
        
        // Fuzzy search implementation
        let results = allFoods.filter { food in
            food.searchableText.contains(lowercaseQuery)
        }
        
        // Sort by relevance (starts with query > contains query)
        return results.sorted { food1, food2 in
            let name1 = food1.foodName.lowercased()
            let name2 = food2.foodName.lowercased()
            
            let starts1 = name1.hasPrefix(lowercaseQuery)
            let starts2 = name2.hasPrefix(lowercaseQuery)
            
            if starts1 && !starts2 {
                return true
            } else if !starts1 && starts2 {
                return false
            } else {
                // If both start with or both don't, sort alphabetically
                return name1 < name2
            }
        }
    }
    
    /// Get all foods (for browse/filter)
    func fetchAll() throws -> [FoodItem] {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.foodName)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    /// Get foods by group
    func fetchByGroup(_ group: String) throws -> [FoodItem] {
        let predicate = #Predicate<FoodItem> { food in
            food.foodGroup == group
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.foodName)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Recently Used Foods
    
    /// Get recently used foods (sorted by last used date)
    func fetchRecentFoods(limit: Int = 10) throws -> [FoodItem] {
        let predicate = #Predicate<FoodItem> { food in
            food.lastUsedDate != nil
        }
        
        var descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        descriptor.fetchLimit = limit
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Mark food as used (updates use count and last used date)
    func markAsUsed(_ food: FoodItem) throws {
        food.useCount += 1
        food.lastUsedDate = Date()
        try modelContext.save()
    }
    
    // MARK: - Favorites
    
    /// Get favorite foods
    func fetchFavorites() throws -> [FoodItem] {
        let predicate = #Predicate<FoodItem> { food in
            food.isFavorite == true
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.foodName)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Toggle favorite status
    func toggleFavorite(_ food: FoodItem) throws {
        food.isFavorite.toggle()
        try modelContext.save()
    }
    
    // MARK: - CRUD Operations
    
    /// Get food by ID
    func fetchByID(_ id: UUID) throws -> FoodItem? {
        let predicate = #Predicate<FoodItem> { food in
            food.id == id
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        return try modelContext.fetch(descriptor).first
    }
    
    /// Update food (if custom foods feature added later)
    func update(_ food: FoodItem) throws {
        try modelContext.save()
    }
    
    /// Delete food (if custom foods feature added later)
    func delete(_ food: FoodItem) throws {
        modelContext.delete(food)
        try modelContext.save()
    }
}

// MARK: - Repository Error

enum RepositoryError: LocalizedError {
    case fileNotFound(String)
    case decodingFailed(String)
    case databaseError(String)
    
    var errorDescription: String? {
        switch self {
        case .fileNotFound(let file):
            return "File not found: \(file)"
        case .decodingFailed(let reason):
            return "Failed to decode: \(reason)"
        case .databaseError(let reason):
            return "Database error: \(reason)"
        }
    }
}
