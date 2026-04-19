// SettingsInteractor.swift
// FoodLens - Business Logic Layer
//
// Handles settings validation, macro target updates, and profile management

import Foundation
import SwiftData

@MainActor
@Observable
final class SettingsInteractor {

    // MARK: - Dependencies

    private let appState: AppState
    private let modelContext: ModelContext

    // MARK: - Initialization

    init(appState: AppState, modelContext: ModelContext) {
        self.appState = appState
        self.modelContext = modelContext
    }

    // MARK: - Macro Targets

    /// Update macro targets with validation
    func updateMacroTargets(protein: Double, carbs: Double, fat: Double) {
        guard let settings = appState.userSettings else { return }

        guard isValidMacro(protein) && isValidMacro(carbs) && isValidMacro(fat) else {
            appState.setError(.validationError("Macro targets must be greater than 0"))
            return
        }

        settings.proteinTarget = protein
        settings.carbsTarget = carbs
        settings.fatTarget = fat
        save(settings)
    }

    /// Apply a preset (fat loss / maintenance / muscle gain)
    func applyPreset(_ targets: MacroTargets) {
        guard let settings = appState.userSettings else { return }
        settings.proteinTarget = targets.protein
        settings.carbsTarget = targets.carbs
        settings.fatTarget = targets.fat
        save(settings)
    }

    // MARK: - Profile

    /// Update user profile and optionally recalculate macro targets
    func updateProfile(
        age: Int?,
        weightKg: Double?,
        heightCm: Double?,
        gender: Gender?,
        activityLevel: ActivityLevel?,
        goal: FitnessGoal?,
        recalculateTargets: Bool = false
    ) {
        guard let settings = appState.userSettings else { return }

        settings.age = age
        settings.weightKg = weightKg
        settings.heightCm = heightCm
        settings.gender = gender
        settings.activityLevel = activityLevel
        settings.goal = goal

        if recalculateTargets {
            applyCalculatedTargets(to: settings)
        }

        save(settings)
    }

    /// Recalculate and apply macro targets from the current profile
    func recalculateTargets() {
        guard let settings = appState.userSettings else { return }
        applyCalculatedTargets(to: settings)
        save(settings)
    }

    // MARK: - Preferences

    func updateDisplayUnit(_ unit: DisplayUnit) {
        guard let settings = appState.userSettings else { return }
        settings.displayUnit = unit
        save(settings)
    }

    func updateShowFiber(_ value: Bool) {
        guard let settings = appState.userSettings else { return }
        settings.showFiber = value
        save(settings)
    }

    func updateHaptics(_ value: Bool) {
        guard let settings = appState.userSettings else { return }
        settings.enableHaptics = value
        save(settings)
    }

    // MARK: - Computed Info

    /// Returns suggested calorie target based on profile, or nil if profile is incomplete
    var suggestedCalories: Double? {
        appState.userSettings?.calculateSuggestedCalories()
    }

    /// Returns protein per kg body weight, or nil if weight not set
    var proteinPerKg: Double? {
        appState.userSettings?.proteinPerKg
    }

    // MARK: - Validation

    func isValidMacro(_ value: Double) -> Bool {
        value >= 1 && value <= 1000
    }

    func macroValidationError(protein: Double, carbs: Double, fat: Double) -> String? {
        if protein < 1 { return "Protein must be at least 1g" }
        if carbs < 1   { return "Carbs must be at least 1g" }
        if fat < 1     { return "Fat must be at least 1g" }
        return nil
    }

    // MARK: - Private

    private func applyCalculatedTargets(to settings: UserSettings) {
        guard let calories = settings.calculateSuggestedCalories(),
              let weight = settings.weightKg else { return }

        let protein = (1.8 * weight).rounded()
        let fat     = ((calories * 0.25) / 9).rounded()
        let carbs   = max(((calories - (protein * 4) - (fat * 9)) / 4).rounded(), 50)

        settings.proteinTarget = protein
        settings.carbsTarget   = carbs
        settings.fatTarget     = fat
    }

    private func save(_ settings: UserSettings) {
        do {
            try modelContext.save()
            appState.userSettings = settings
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}
