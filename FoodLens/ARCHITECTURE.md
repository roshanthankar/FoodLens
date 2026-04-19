# FoodLens — Architecture

## Layers

```
Views  →  Interactors  →  Repositories  →  SwiftData
```

**Views** — SwiftUI screens. Read from `AppState`, call Interactors for actions. No business logic.

**Interactors** — Business logic. Validate input, call Repositories, update `AppState`, trigger haptics.

**Repositories** — SwiftData CRUD. No logic, just reads and writes.

**AppState** — Single source of truth. `@Observable` singleton. All views react to it automatically.

---

## Data Flow

```
User taps something
    → View calls Interactor
    → Interactor calls Repository
    → Repository reads/writes SwiftData
    → Interactor updates AppState
    → View re-renders automatically
```

---

## File Map

```
FoodLens/
├── App/
│   ├── FoodLensApp.swift           # Entry point, DI setup, routing
│   └── AppState.swift              # Centralized state (Redux-like)
│
├── Models/                         # SwiftData entities
│   ├── FoodItem.swift
│   ├── MealEntry.swift
│   ├── DailyLog.swift
│   └── UserSettings.swift
│
├── Repositories/                   # Data access layer
│   ├── FoodRepository.swift
│   └── MealLogRepository.swift
│
├── Interactors/                    # Business logic layer
│   ├── FoodSearchInteractor.swift
│   ├── MealLoggingInteractor.swift
│   └── SettingsInteractor.swift
│
├── Views/
│   ├── Main/
│   │   ├── TodayView.swift
│   │   ├── HistoryView.swift
│   │   ├── SettingsView.swift
│   │   ├── FoodSearchView.swift
│   │   └── LogMealSheet.swift
│   ├── Onboarding/
│   │   ├── OnboardingWelcomeView.swift
│   │   ├── QuickSetupView.swift
│   │   └── GuidedSetupView.swift
│   └── Components/
│       ├── MacroGaugeCard.swift
│       └── WeeklyProteinChart.swift
│
├── Utilities/
│   └── HapticManager.swift
│
└── Data/
    └── foodlens-food-database.json  # 542 IFCT foods
```

---

## Key Patterns

**AppState** — Singleton, `@MainActor @Observable`. Holds today's meals, macro totals, recents, favorites, routing, errors. Views never write to it directly — only Interactors do.

**Dependency Injection** — Everything passed via `@Environment`. `FoodLensApp` creates all repositories and interactors, injects them at the root.

**Meal logging flow:**
1. User picks food in `LogMealSheet`
2. Taps log → calls `mealLoggingInteractor.logMeal(...)`
3. Interactor creates `MealEntry`, saves via `MealLogRepository`
4. Calls `foodRepository.markAsUsed(food)`
5. Fetches updated today's meals, pushes to `AppState`
6. View re-renders, haptic fires

**Search flow:**
1. User types in `FoodSearchView`
2. 180ms debounce → calls `foodSearchInteractor.search(query:)`
3. Interactor calls `foodRepository.search(query:)`
4. Repository does fuzzy match (contains + prefix sort) over all 542 foods
5. Results stored in `foodSearchInteractor.searchResults`

**Onboarding routing** — On launch, `FoodLensApp` checks `UserSettings.hasCompletedOnboarding`. If false, sets `appState.routing = .onboarding`. `ContentView` switches between `OnboardingCoordinator` and the main `TabView` based on this.
