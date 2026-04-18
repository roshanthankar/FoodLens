# FoodLens Clean Architecture

## 🏗️ Architecture Layers

```
┌─────────────────────────────────────────────┐
│              Presentation Layer              │
│         (SwiftUI Views - Pure UI)           │
├─────────────────────────────────────────────┤
│           Business Logic Layer               │
│        (Interactors - Side Effects)         │
├─────────────────────────────────────────────┤
│            Data Access Layer                 │
│      (Repositories - CRUD Operations)       │
├─────────────────────────────────────────────┤
│              Persistence Layer               │
│         (SwiftData Models + JSON)           │
└─────────────────────────────────────────────┘
```

## 📊 Data Flow

```
User Action (Tap)
    ↓
SwiftUI View
    ↓
Interactor (Business Logic)
    ↓
Repository (Data Access)
    ↓
SwiftData / JSON
    ↓
Repository Returns Data
    ↓
Interactor Updates AppState
    ↓
View Re-renders (Automatic)
```

## 🎯 Key Patterns Applied

### 1. Single Source of Truth (AppState)
- All app state lives in `AppState.swift`
- Views are pure functions of state
- No local `@State` for shared data

### 2. Dependency Injection
- Native `@Environment` for DI
- All dependencies injected via environment
- Easy to mock for testing

### 3. Separation of Concerns
- **Views**: Only UI, no business logic
- **Interactors**: Only business logic, no UI
- **Repositories**: Only data access, no business logic

### 4. Testability
- Every layer can be tested independently
- Interactors can be tested without UI
- Views can be tested with ViewInspector

## 📦 File Organization

```
FoodLens/
├── App/
│   ├── FoodLensApp.swift      # Entry point + routing
│   └── AppState.swift          # Centralized state
├── Models/
│   ├── FoodItem.swift          # SwiftData model
│   ├── MealEntry.swift         # SwiftData model
│   ├── DailyLog.swift          # SwiftData model
│   └── UserSettings.swift      # SwiftData model
├── Repositories/
│   ├── FoodRepository.swift    # Food DB operations
│   └── MealLogRepository.swift # Meal logging operations
├── Interactors/
│   ├── FoodSearchInteractor.swift
│   ├── MealLoggingInteractor.swift
│   ├── HistoryInteractor.swift
│   └── SettingsInteractor.swift
├── Views/
│   ├── Main/
│   │   ├── TodayView.swift
│   │   ├── HistoryView.swift
│   │   └── SettingsView.swift
│   ├── Components/
│   │   ├── MacroGaugeCard.swift
│   │   ├── WeeklyProteinChart.swift
│   │   └── MealListSection.swift
│   └── Onboarding/
│       └── [4 onboarding views]
└── Utilities/
    ├── HapticManager.swift
    └── Extensions.swift
```

## 🔄 Example Flow: Logging a Meal

```swift
// 1. User taps "Log" button in LogMealSheet
Button("Log") {
    Task {
        await mealLoggingInteractor.logMeal(
            food: selectedFood,
            servings: servingCount,
            mealType: .lunch
        )
    }
}

// 2. Interactor processes the business logic
func logMeal(...) async {
    // Create meal entry
    let entry = MealEntry(...)
    
    // Save via repository
    try await mealLogRepository.save(entry)
    
    // Update AppState (triggers UI update)
    await MainActor.run {
        appState.updateTodayMeals(fetchTodayMeals())
    }
    
    // Mark food as recently used
    await foodRepository.markAsUsed(food)
    
    // Trigger haptics
    hapticManager.success()
}

// 3. View automatically re-renders (state changed)
// No manual refresh needed!
```

## ✅ Benefits of This Architecture

1. **Testable**: Every component can be unit tested
2. **Maintainable**: Clear responsibilities per layer
3. **Scalable**: Easy to add new features
4. **Debuggable**: Clear data flow
5. **HIG-Compliant**: Native iOS patterns throughout
6. **Type-Safe**: Compile-time safety everywhere

## 🎓 Inspired By

- [Clean Architecture SwiftUI](https://github.com/nalexn/clean-architecture-swiftui)
- Apple's HIG recommendations
- Redux/Flux state management patterns
