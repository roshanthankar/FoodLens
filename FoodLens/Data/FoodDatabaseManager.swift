// FoodDatabaseManager.swift
// FoodLens - Cached Food Search
//
// Keeps a lightweight in-memory cache over the SwiftData-backed food database.

import Foundation
import SwiftData

@MainActor
@Observable
final class FoodDatabaseManager {
    private let modelContext: ModelContext

    /// In-memory cache for faster search and quick-log surfaces.
    private var foodCache: [FoodItem] = []

    private(set) var isReady: Bool = false
    private(set) var isLoading: Bool = false

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    // MARK: - Startup

    func seedAndLoadCache() async {
        isLoading = true
        defer {
            isLoading = false
            isReady = true
        }

        let existingCount = (try? modelContext.fetchCount(FetchDescriptor<FoodItem>())) ?? 0

        if existingCount == 0 {
            do {
                try await seedDatabase()
            } catch {
                print("❌ Failed to seed food database: \(error)")
            }
        }

        loadCache()
    }

    // MARK: - Search

    func search(query: String, limit: Int = 20) -> [FoodItem] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        guard !trimmed.isEmpty else {
            return Array(foodCache.prefix(limit))
        }

        return foodCache
            .map { ($0, relevanceScore(food: $0, query: trimmed)) }
            .filter { $0.1 > 0 }
            .sorted { lhs, rhs in
                if lhs.1 == rhs.1 {
                    return lhs.0.foodName < rhs.0.foodName
                }
                return lhs.1 > rhs.1
            }
            .prefix(limit)
            .map(\.0)
    }

    func recents(limit: Int = 15) -> [FoodItem] {
        foodCache
            .filter { $0.lastUsedDate != nil }
            .sorted { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
            .prefix(limit)
            .map { $0 }
    }

    func favorites() -> [FoodItem] {
        foodCache
            .filter(\.isFavorite)
            .sorted { lhs, rhs in
                if lhs.useCount == rhs.useCount {
                    return lhs.foodName < rhs.foodName
                }
                return lhs.useCount > rhs.useCount
            }
    }

    func markUsed(_ food: FoodItem) {
        food.lastUsedDate = .now
        food.useCount += 1
        try? modelContext.save()
    }

    func toggleFavorite(_ food: FoodItem) {
        food.isFavorite.toggle()
        try? modelContext.save()
    }

    // MARK: - Private

    private func seedDatabase() async throws {
        guard let url = Bundle.main.url(forResource: "foodlens-food-database", withExtension: "json") else {
            throw FoodDatabaseError.fileNotFound("foodlens-food-database.json")
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()

        let jsonFoods: [FoodItem.JSONFormat]
        if let document = try? decoder.decode(FoodDatabaseDocument.self, from: data) {
            jsonFoods = document.foods
        } else {
            jsonFoods = try decoder.decode([FoodItem.JSONFormat].self, from: data)
        }

        for jsonFood in jsonFoods {
            modelContext.insert(jsonFood.toFoodItem())
        }

        try modelContext.save()
        print("✅ Seeded \(jsonFoods.count) foods")
    }

    private func loadCache() {
        let descriptor = FetchDescriptor<FoodItem>(
            sortBy: [SortDescriptor(\.foodName)]
        )
        foodCache = (try? modelContext.fetch(descriptor)) ?? []
    }

    private func relevanceScore(food: FoodItem, query: String) -> Int {
        let name = food.foodName.lowercased()
        let group = food.foodGroup.lowercased()
        let searchable = food.searchableText

        if name == query { return 100 }
        if name.hasPrefix(query) { return 80 }
        if group == query { return 70 }
        if group.hasPrefix(query) { return 60 }
        if name.contains(query) { return 40 }
        if searchable.contains(query) { return 20 }
        return 0
    }
}

private struct FoodDatabaseDocument: Decodable {
    let foods: [FoodItem.JSONFormat]
}

enum FoodDatabaseError: LocalizedError {
    case fileNotFound(String)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let fileName):
            return "File not found: \(fileName)"
        }
    }
}
