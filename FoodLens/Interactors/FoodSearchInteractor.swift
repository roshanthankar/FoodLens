// FoodSearchInteractor.swift
// FoodLens - Business Logic Layer
//
// Handles food search, filtering, and discovery

import Foundation
import SwiftData

@MainActor
@Observable
final class FoodSearchInteractor {
    // MARK: - Dependencies
    
    private let appState: AppState
    private let foodRepository: FoodRepository
    
    // MARK: - Search State
    
    var searchQuery: String = ""
    var searchResults: [FoodItem] = []
    var isSearching: Bool = false
    var selectedGroup: String?
    
    // MARK: - Initialization
    
    init(
        appState: AppState,
        foodRepository: FoodRepository
    ) {
        self.appState = appState
        self.foodRepository = foodRepository
    }
    
    // MARK: - Search Operations
    
    /// Perform search (fuzzy matching)
    func search(query: String) async {
        self.searchQuery = query
        
        guard !query.isEmpty else {
            // Empty query = show recents and favorites
            loadDefaults()
            return
        }
        
        isSearching = true
        
        do {
            let results = try await foodRepository.search(query: query)
            self.searchResults = results
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            self.searchResults = []
        }
        
        isSearching = false
    }
    
    /// Clear search
    func clearSearch() {
        searchQuery = ""
        searchResults = []
        selectedGroup = nil
        loadDefaults()
    }
    
    /// Load defaults (recents + favorites)
    func loadDefaults() {
        do {
            let recents = try foodRepository.fetchRecentFoods(limit: 10)
            let favorites = try foodRepository.fetchFavorites()
            
            // Combine recents and favorites, removing duplicates
            var seen = Set<UUID>()
            var combined: [FoodItem] = []
            
            // Add favorites first
            for food in favorites {
                if !seen.contains(food.id) {
                    combined.append(food)
                    seen.insert(food.id)
                }
            }
            
            // Add recents
            for food in recents {
                if !seen.contains(food.id) {
                    combined.append(food)
                    seen.insert(food.id)
                }
            }
            
            self.searchResults = combined
            
            // Update AppState caches
            appState.updateRecentFoods(recents)
            appState.updateFavoriteFoods(favorites)
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
    
    // MARK: - Filtering
    
    /// Filter by food group
    func filterByGroup(_ group: String) async {
        selectedGroup = group
        isSearching = true
        
        do {
            let results = try await foodRepository.fetchByGroup(group)
            self.searchResults = results
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            self.searchResults = []
        }
        
        isSearching = false
    }
    
    /// Clear group filter
    func clearGroupFilter() {
        selectedGroup = nil
        if searchQuery.isEmpty {
            loadDefaults()
        } else {
            Task {
                await search(query: searchQuery)
            }
        }
    }
    
    // MARK: - Favorites Management
    
    /// Toggle favorite status
    func toggleFavorite(_ food: FoodItem) async {
        do {
            try foodRepository.toggleFavorite(food)
            
            // Refresh favorites in AppState
            let favorites = try foodRepository.fetchFavorites()
            appState.updateFavoriteFoods(favorites)
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
    
    // MARK: - Discovery Features
    
    /// Get random food (for discovery)
    func getRandomFood() async -> FoodItem? {
        do {
            let allFoods = try await foodRepository.fetchAll()
            return allFoods.randomElement()
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            return nil
        }
    }
    
    /// Get foods you haven't tried yet (0 use count)
    func getUntriedFoods(limit: Int = 20) async -> [FoodItem] {
        do {
            let allFoods = try await foodRepository.fetchAll()
            let untried = allFoods.filter { $0.useCount == 0 }
            return Array(untried.shuffled().prefix(limit))
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            return []
        }
    }
    
    /// Get high-protein foods (>20g per 100g)
    func getHighProteinFoods(limit: Int = 20) async -> [FoodItem] {
        do {
            let allFoods = try await foodRepository.fetchAll()
            let highProtein = allFoods.filter { $0.proteinPer100g >= 20 }
            return Array(highProtein.sorted { $0.proteinPer100g > $1.proteinPer100g }.prefix(limit))
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            return []
        }
    }
    
    // MARK: - Food Groups
    
    /// Get all unique food groups
    func getAllFoodGroups() async -> [String] {
        do {
            let allFoods = try await foodRepository.fetchAll()
            let groups = Set(allFoods.map { $0.foodGroup })
            return groups.sorted()
            
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
            return []
        }
    }
    
    // MARK: - Validation
    
    /// Check if search query is valid
    func isValidSearchQuery(_ query: String) -> Bool {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.count >= 2 // At least 2 characters
    }
    
    /// Get search suggestions (prefix matching)
    func getSearchSuggestions(for query: String, limit: Int = 5) async -> [String] {
        do {
            let allFoods = try await foodRepository.fetchAll()
            let lowercaseQuery = query.lowercased()
            
            let matches = allFoods
                .filter { $0.foodName.lowercased().hasPrefix(lowercaseQuery) }
                .map { $0.foodName }
                .prefix(limit)
            
            return Array(matches)
            
        } catch {
            return []
        }
    }
}

// MARK: - Search Helper Extensions

extension FoodSearchInteractor {
    /// Group search results by food group
    func groupedResults() -> [(group: String, foods: [FoodItem])] {
        let grouped = Dictionary(grouping: searchResults) { $0.foodGroup }
        return grouped.map { (group: $0.key, foods: $0.value) }
            .sorted { $0.group < $1.group }
    }
    
    /// Get result count summary
    func resultSummary() -> String {
        let count = searchResults.count
        if count == 0 {
            return "No results"
        } else if count == 1 {
            return "1 result"
        } else {
            return "\(count) results"
        }
    }
}
