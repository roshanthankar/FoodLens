// UserSettings.swift
// FoodLens - SwiftData Model
//
// User preferences and macro targets

import Foundation
import SwiftData

@Model
final class UserSettings {
    // MARK: - Properties
    
    var id: UUID
    
    // MARK: - Onboarding State
    
    /// Whether user has completed onboarding
    var hasCompletedOnboarding: Bool
    
    /// Onboarding path taken (quick or guided)
    var onboardingPath: OnboardingPath?
    
    // MARK: - Macro Targets
    
    var proteinTarget: Double
    var carbsTarget: Double
    var fatTarget: Double
    
    // MARK: - User Profile (from Guided Setup)
    
    var age: Int?
    var weightKg: Double?
    var heightCm: Double?
    var gender: Gender?
    var activityLevel: ActivityLevel?
    var goal: FitnessGoal?
    
    // MARK: - Preferences
    
    /// Preferred macro display unit
    var displayUnit: DisplayUnit
    
    /// Whether to show fiber tracking
    var showFiber: Bool
    
    /// Whether to enable haptic feedback
    var enableHaptics: Bool
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        hasCompletedOnboarding: Bool = false,
        onboardingPath: OnboardingPath? = nil,
        proteinTarget: Double = 150,
        carbsTarget: Double = 200,
        fatTarget: Double = 60,
        age: Int? = nil,
        weightKg: Double? = nil,
        heightCm: Double? = nil,
        gender: Gender? = nil,
        activityLevel: ActivityLevel? = nil,
        goal: FitnessGoal? = nil,
        displayUnit: DisplayUnit = .grams,
        showFiber: Bool = false,
        enableHaptics: Bool = true
    ) {
        self.id = id
        self.hasCompletedOnboarding = hasCompletedOnboarding
        self.onboardingPath = onboardingPath
        self.proteinTarget = proteinTarget
        self.carbsTarget = carbsTarget
        self.fatTarget = fatTarget
        self.age = age
        self.weightKg = weightKg
        self.heightCm = heightCm
        self.gender = gender
        self.activityLevel = activityLevel
        self.goal = goal
        self.displayUnit = displayUnit
        self.showFiber = showFiber
        self.enableHaptics = enableHaptics
    }
    
    // MARK: - Computed Properties
    
    /// Total calorie target
    var calorieTarget: Double {
        (proteinTarget * 4) + (carbsTarget * 4) + (fatTarget * 9)
    }
    
    /// Protein per kg body weight (if weight is set)
    var proteinPerKg: Double? {
        guard let weight = weightKg else { return nil }
        return proteinTarget / weight
    }
}

// MARK: - Supporting Enums

enum OnboardingPath: String, Codable {
    case quick = "quick"
    case guided = "guided"
}

enum Gender: String, Codable, CaseIterable {
    case male = "Male"
    case female = "Female"
    case other = "Other"
}

enum ActivityLevel: String, Codable, CaseIterable {
    case sedentary = "Sedentary"
    case lightlyActive = "Lightly Active"
    case moderatelyActive = "Moderately Active"
    case veryActive = "Very Active"
    case extremelyActive = "Extremely Active"
    
    var multiplier: Double {
        switch self {
        case .sedentary: return 1.2
        case .lightlyActive: return 1.375
        case .moderatelyActive: return 1.55
        case .veryActive: return 1.725
        case .extremelyActive: return 1.9
        }
    }
}

enum FitnessGoal: String, Codable, CaseIterable {
    case lose = "Lose Weight"
    case maintain = "Maintain Weight"
    case gain = "Gain Muscle"
    
    var calorieModifier: Double {
        switch self {
        case .lose: return 0.8
        case .maintain: return 1.0
        case .gain: return 1.15
        }
    }
}

enum DisplayUnit: String, Codable, CaseIterable {
    case grams = "Grams"
    case percentage = "Percentage"
}

// MARK: - BMR Calculation Helper

extension UserSettings {
    /// Calculate Basal Metabolic Rate (Harris-Benedict equation)
    func calculateBMR() -> Double? {
        guard let age = age,
              let weight = weightKg,
              let height = heightCm,
              let gender = gender else {
            return nil
        }
        
        // Harris-Benedict equation
        switch gender {
        case .male:
            return 88.362 + (13.397 * weight) + (4.799 * height) - (5.677 * Double(age))
        case .female, .other:
            return 447.593 + (9.247 * weight) + (3.098 * height) - (4.330 * Double(age))
        }
    }
    
    /// Calculate Total Daily Energy Expenditure (TDEE)
    func calculateTDEE() -> Double? {
        guard let bmr = calculateBMR(),
              let activity = activityLevel else {
            return nil
        }
        
        return bmr * activity.multiplier
    }
    
    /// Calculate suggested calorie target based on goal
    func calculateSuggestedCalories() -> Double? {
        guard let tdee = calculateTDEE(),
              let goal = goal else {
            return nil
        }
        
        return tdee * goal.calorieModifier
    }
}

// MARK: - Sample Data

extension UserSettings {
    static let sample = UserSettings(
        hasCompletedOnboarding: true,
        onboardingPath: .guided,
        proteinTarget: 150,
        carbsTarget: 200,
        fatTarget: 60,
        age: 28,
        weightKg: 75,
        heightCm: 175,
        gender: .male,
        activityLevel: .moderatelyActive,
        goal: .gain
    )
    
    static let quickSetup = UserSettings(
        hasCompletedOnboarding: true,
        onboardingPath: .quick,
        proteinTarget: 120,
        carbsTarget: 180,
        fatTarget: 50
    )
}
