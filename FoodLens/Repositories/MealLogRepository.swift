// MealLogRepository.swift
// FoodLens - Data Access Layer
//
// Handles all meal logging operations and history

import Foundation
import SwiftData

@MainActor
final class MealLogRepository {
    // MARK: - Properties
    
    private let modelContext: ModelContext
    
    // MARK: - Initialization
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Create Operations
    
    /// Save a new meal entry
    func save(_ entry: MealEntry) throws {
        modelContext.insert(entry)
        try modelContext.save()
    }
    
    /// Save multiple meal entries (batch)
    func saveAll(_ entries: [MealEntry]) throws {
        for entry in entries {
            modelContext.insert(entry)
        }
        try modelContext.save()
    }
    
    // MARK: - Read Operations - Today
    
    /// Fetch today's meals
    func fetchToday() throws -> [MealEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let predicate = #Predicate<MealEntry> { meal in
            meal.timestamp >= startOfDay
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch today's meals by type
    func fetchToday(mealType: MealType) throws -> [MealEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        
        let predicate = #Predicate<MealEntry> { meal in
            meal.timestamp >= startOfDay && meal.mealType == mealType
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Read Operations - History
    
    /// Fetch meals for a specific date
    func fetchMeals(for date: Date) throws -> [MealEntry] {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<MealEntry> { meal in
            meal.timestamp >= startOfDay && meal.timestamp < endOfDay
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch meals for last N days
    func fetchRecent(days: Int = 7) throws -> [MealEntry] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days, to: Date())!
        let startOfPeriod = calendar.startOfDay(for: startDate)
        
        let predicate = #Predicate<MealEntry> { meal in
            meal.timestamp >= startOfPeriod
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    /// Fetch all meals (for analytics)
    func fetchAll() throws -> [MealEntry] {
        let descriptor = FetchDescriptor<MealEntry>(
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Update Operations
    
    /// Update an existing meal entry
    func update(_ entry: MealEntry) throws {
        try modelContext.save()
    }
    
    // MARK: - Delete Operations
    
    /// Delete a meal entry
    func delete(_ entry: MealEntry) throws {
        modelContext.delete(entry)
        try modelContext.save()
    }
    
    /// Delete multiple entries (batch)
    func deleteAll(_ entries: [MealEntry]) throws {
        for entry in entries {
            modelContext.delete(entry)
        }
        try modelContext.save()
    }
    
    /// Delete all meals for a specific date
    func deleteAllMeals(for date: Date) throws {
        let meals = try fetchMeals(for: date)
        try deleteAll(meals)
    }
    
    // MARK: - Aggregation Operations
    
    /// Calculate daily totals for a date
    func calculateDailyTotals(for date: Date) throws -> (protein: Double, carbs: Double, fat: Double, calories: Double) {
        let meals = try fetchMeals(for: date)
        
        let protein = meals.reduce(0) { $0 + $1.proteinGrams }
        let carbs = meals.reduce(0) { $0 + $1.carbsGrams }
        let fat = meals.reduce(0) { $0 + $1.fatGrams }
        let calories = meals.reduce(0) { $0 + $1.calories }
        
        return (protein, carbs, fat, calories)
    }
    
    /// Get or create daily log for a date
    func getOrCreateDailyLog(for date: Date) throws -> DailyLog {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        
        // Try to fetch existing log
        let predicate = #Predicate<DailyLog> { log in
            log.date == startOfDay
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        if let existingLog = try modelContext.fetch(descriptor).first {
            // Update from meals
            let meals = try fetchMeals(for: date)
            existingLog.update(from: meals)
            try modelContext.save()
            return existingLog
        } else {
            // Create new log
            let meals = try fetchMeals(for: date)
            let log = DailyLog(date: startOfDay)
            log.update(from: meals)
            
            modelContext.insert(log)
            try modelContext.save()
            return log
        }
    }
    
    /// Fetch daily logs for last N days
    func fetchDailyLogs(days: Int = 7) throws -> [DailyLog] {
        let calendar = Calendar.current
        let startDate = calendar.date(byAdding: .day, value: -days + 1, to: Date())!
        let startOfPeriod = calendar.startOfDay(for: startDate)
        
        let predicate = #Predicate<DailyLog> { log in
            log.date >= startOfPeriod
        }
        
        let descriptor = FetchDescriptor(
            predicate: predicate,
            sortBy: [SortDescriptor(\.date)]
        )
        
        return try modelContext.fetch(descriptor)
    }
    
    // MARK: - Analytics
    
    /// Get most logged foods (top N)
    func getMostLoggedFoods(limit: Int = 10) throws -> [(foodName: String, count: Int)] {
        let allMeals = try fetchAll()
        
        // Group by food name
        let grouped = Dictionary(grouping: allMeals) { $0.foodName }
        
        // Count and sort
        let sorted = grouped.map { (foodName: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
            .prefix(limit)
        
        return Array(sorted)
    }
}
