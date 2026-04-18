// MealLogManager.swift
// FoodLens — Indian Macro Tracker
//
// Responsible for:
// 1. Logging meals (creating MealEntry + DailyLog)
// 2. Fetching today's log and historical data
// 3. Deleting entries

import Foundation
import SwiftData

@Observable
final class MealLogManager {
    
    private let modelContext: ModelContext
    private let calendar = Calendar.current
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: - Logging
    
    /// Log a food item with a specific serving size and meal type.
    /// This is the core action of the entire app — the "3-tap result."
    @discardableResult
    func logFood(
        _ food: FoodItem,
        servingGrams: Double,
        servingLabel: String,
        servingMultiplier: Double = 1.0,
        mealType: MealType,
        at date: Date = .now
    ) -> MealEntry {
        let resolvedServingMultiplier: Double
        if food.servingSizeGrams > 0, servingGrams > 0 {
            resolvedServingMultiplier = servingGrams / food.servingSizeGrams
        } else {
            resolvedServingMultiplier = servingMultiplier
        }

        let macros = food.macros(servings: resolvedServingMultiplier)

        let entry = MealEntry(
            timestamp: date,
            mealType: mealType,
            foodName: food.foodName,
            foodGroup: food.foodGroup,
            servingDescription: servingLabel.isEmpty ? food.servingDescription : servingLabel,
            servingMultiplier: resolvedServingMultiplier,
            proteinGrams: macros.protein,
            carbsGrams: macros.carbs,
            fatGrams: macros.fat,
            calories: macros.calories,
            foodItemID: food.id
        )

        modelContext.insert(entry)
        syncDailyLog(for: date, createIfMissing: true)
        try? modelContext.save()
        
        return entry
    }
    
    // MARK: - Fetching
    
    /// Returns today's DailyLog, or creates one if it doesn't exist.
    func todayLog() -> DailyLog {
        getOrCreateDailyLog(for: .now)
    }
    
    /// Returns the DailyLog for a specific date, or nil if no entries exist.
    func dailyLog(for date: Date) -> DailyLog? {
        fetchDailyLog(for: date)
    }
    
    /// Returns daily logs for the past N days (for history view).
    /// Returns an array of (Date, DailyLog?) — nil if no entries for that day.
    func history(days: Int = 7) -> [(Date, DailyLog?)] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        
        return (0..<days).map { offset in
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else {
                return (today, nil)
            }
            return (date, dailyLog(for: date))
        }
    }
    
    /// Returns total macros for the past N days (for trend display).
    func weeklyTotals(days: Int = 7) -> [DailyMacroSummary] {
        history(days: days).map { date, log in
            DailyMacroSummary(
                date: date,
                macros: log?.totalMacros ?? .empty,
                entryCount: log?.entryCount ?? 0
            )
        }
    }
    
    // MARK: - Deleting
    
    /// Delete a single meal entry.
    func deleteEntry(_ entry: MealEntry) {
        let date = entry.timestamp
        modelContext.delete(entry)
        syncDailyLog(for: date)
        try? modelContext.save()
    }
    
    /// Delete all entries for a specific meal type today.
    func deleteMeal(_ mealType: MealType, on date: Date = .now) {
        let toDelete = meals(for: date).filter { $0.mealType == mealType }
        guard !toDelete.isEmpty else { return }

        toDelete.forEach { entry in
            modelContext.delete(entry)
        }

        syncDailyLog(for: date)
        try? modelContext.save()
    }
    
    // MARK: - Streaks & Stats
    
    /// Returns the number of consecutive days with at least one logged entry.
    func currentStreak() -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        var streak = 0
        
        for offset in 0..<365 {  // Check up to a year back
            guard let date = calendar.date(byAdding: .day, value: -offset, to: today) else { break }
            if let log = dailyLog(for: date), log.entryCount > 0 {
                streak += 1
            } else if offset > 0 {
                // Allow today to be empty (user might not have logged yet)
                break
            }
        }
        
        return streak
    }
    
    /// Returns today's protein as a percentage of the target.
    func proteinProgress(target: Double) -> Double {
        guard target > 0 else { return 0 }
        let today = todayLog()
        return today.totalProtein / target
    }
    
    // MARK: - Private Helpers
    
    private func getOrCreateDailyLog(for date: Date) -> DailyLog {
        if let existing = fetchDailyLog(for: date) {
            return existing
        }
        
        let newLog = DailyLog(date: calendar.startOfDay(for: date))
        modelContext.insert(newLog)
        return newLog
    }

    private func fetchDailyLog(for date: Date) -> DailyLog? {
        let startOfDay = calendar.startOfDay(for: date)
        let descriptor = FetchDescriptor<DailyLog>(
            predicate: #Predicate { log in
                log.date == startOfDay
            }
        )
        return try? modelContext.fetch(descriptor).first
    }

    private func meals(for date: Date) -> [MealEntry] {
        let startOfDay = calendar.startOfDay(for: date)
        guard let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) else {
            return []
        }

        let descriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { meal in
                meal.timestamp >= startOfDay && meal.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        return (try? modelContext.fetch(descriptor)) ?? []
    }

    private func syncDailyLog(for date: Date, createIfMissing: Bool = false) {
        let mealsForDay = meals(for: date)
        let log = fetchDailyLog(for: date)

        if mealsForDay.isEmpty && !createIfMissing {
            if let log {
                modelContext.delete(log)
            }
            return
        }

        let targetLog = log ?? getOrCreateDailyLog(for: date)
        targetLog.update(from: mealsForDay)
    }
}

// MARK: - Daily Macro Summary

/// Lightweight struct for history/chart display.
struct DailyMacroSummary: Identifiable {
    let date: Date
    let macros: MacroTotals
    let entryCount: Int
    
    var id: String { DailyLog.key(for: date) }
    var hasEntries: Bool { entryCount > 0 }
    
    /// Short day label: "Mon", "Tue", etc.
    var dayLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
    
    /// "Today", "Yesterday", or "Mon 5 Apr"
    var displayLabel: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(date) { return "Today" }
        if calendar.isDateInYesterday(date) { return "Yesterday" }
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE d MMM"
        return formatter.string(from: date)
    }
}
