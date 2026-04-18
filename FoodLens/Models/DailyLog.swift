// DailyLog.swift
// FoodLens - SwiftData Model
//
// Daily aggregation of meal entries for history view

import Foundation
import SwiftData

@Model
final class DailyLog {
    // MARK: - Properties
    
    var id: UUID
    
    /// The date this log represents (start of day)
    var date: Date
    
    // MARK: - Aggregated Macros
    
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var totalCalories: Double
    
    // MARK: - Metadata
    
    /// Number of meals logged this day
    var mealCount: Int
    
    /// Date this log was last updated
    var lastUpdated: Date
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        date: Date,
        totalProtein: Double = 0,
        totalCarbs: Double = 0,
        totalFat: Double = 0,
        totalCalories: Double = 0,
        mealCount: Int = 0,
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.date = Calendar.current.startOfDay(for: date)
        self.totalProtein = totalProtein
        self.totalCarbs = totalCarbs
        self.totalFat = totalFat
        self.totalCalories = totalCalories
        self.mealCount = mealCount
        self.lastUpdated = lastUpdated
    }
    
    // MARK: - Update from Meals
    
    /// Recalculate totals from meal entries
    func update(from meals: [MealEntry]) {
        self.totalProtein = meals.reduce(0) { $0 + $1.proteinGrams }
        self.totalCarbs = meals.reduce(0) { $0 + $1.carbsGrams }
        self.totalFat = meals.reduce(0) { $0 + $1.fatGrams }
        self.totalCalories = meals.reduce(0) { $0 + $1.calories }
        self.mealCount = meals.count
        self.lastUpdated = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Display text for the date (e.g., "Mon, Jan 1")
    var dateDisplay: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: date)
    }

    /// Stable day key for persistence and view identity.
    var dateString: String {
        Self.key(for: date)
    }

    /// Backward-compatible alias used by older history code.
    var entryCount: Int {
        mealCount
    }

    /// Backward-compatible aggregate used by older history code.
    var totalMacros: MacroTotals {
        MacroTotals(
            protein: totalProtein,
            carbs: totalCarbs,
            fat: totalFat
        )
    }
    
    /// Whether this is today's log
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    /// Whether this is yesterday's log
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    /// Relative date text (e.g., "Today", "Yesterday", "Mon, Jan 1")
    var relativeDateDisplay: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else {
            return dateDisplay
        }
    }

    static func key(for date: Date) -> String {
        dayKeyFormatter.string(from: Calendar.current.startOfDay(for: date))
    }

    private static let dayKeyFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian)
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = .current
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}

// MARK: - Sample Data

extension DailyLog {
    static let sample = DailyLog(
        date: Date(),
        totalProtein: 145.2,
        totalCarbs: 198.3,
        totalFat: 58.7,
        totalCalories: 1847,
        mealCount: 4
    )
    
    static func samples(days: Int = 7) -> [DailyLog] {
        let calendar = Calendar.current
        let today = Date()
        
        return (0..<days).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: -dayOffset, to: today)!
            let startOfDay = calendar.startOfDay(for: date)
            
            // Simulate varying protein intake
            let baseProtein = 140.0
            let variation = Double.random(in: -20...20)
            let protein = baseProtein + variation
            
            return DailyLog(
                date: startOfDay,
                totalProtein: protein,
                totalCarbs: 180 + Double.random(in: -30...30),
                totalFat: 55 + Double.random(in: -10...10),
                totalCalories: 1800 + Double.random(in: -200...200),
                mealCount: Int.random(in: 3...5)
            )
        }.sorted { $0.date > $1.date } // Most recent first
    }
}

// MARK: - History Analytics

extension Array where Element == DailyLog {
    /// Calculate average protein over the period
    var averageProtein: Double {
        guard !isEmpty else { return 0 }
        return reduce(0) { $0 + $1.totalProtein } / Double(count)
    }
    
    /// Calculate average calories over the period
    var averageCalories: Double {
        guard !isEmpty else { return 0 }
        return reduce(0) { $0 + $1.totalCalories } / Double(count)
    }
    
    /// Get last 7 days of logs (including today)
    func lastWeek() -> [DailyLog] {
        let calendar = Calendar.current
        let sevenDaysAgo = calendar.date(byAdding: .day, value: -6, to: Date())!
        
        return filter { $0.date >= calendar.startOfDay(for: sevenDaysAgo) }
            .sorted { $0.date < $1.date } // Chronological for charts
    }
}
