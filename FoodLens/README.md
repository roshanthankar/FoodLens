# FoodLens

An iOS macro tracking app built for Indians who eat Indian food.

Demo video — [watch here](https://drive.google.com/file/d/1kddSJvSywgCy6idM9lNZZv3Qoz8SESqt/view?usp=sharing)

---

## What it does

- Log Indian meals and track daily protein, carbs, and fat
- No login required — everything stays on your phone
- Works offline — no internet needed
- 542 Indian dishes from IFCT 2017 (India's official nutrition data)

---

## Architecture — 3 layers

Views talk to Interactors. Interactors talk to Repositories. Repositories read and write from SwiftData (local storage on the phone). All shared state lives in `AppState.swift` — views read from it, interactors write to it.

- **Views** — screens the user sees (TodayView, HistoryView, SettingsView, FoodSearchView, LogMealSheet)
- **Interactors** — business logic and calculations (MealLoggingInteractor, FoodSearchInteractor, HistoryInteractor, SettingsInteractor)
- **Repositories** — reads and writes data (FoodRepository, MealLogRepository)

---

## File structure

```
FoodLens/
├── App/
│   ├── FoodLensApp.swift
│   ├── AppState.swift
│   ├── DesignSystemDesignTokens.swift
│   ├── DesignSystemCaloriesPillView.swift
│   ├── DesignSystemEmptyStateView.swift
│   ├── DesignSystemMacroGaugeView.swift
│   ├── DesignSystemMealRowView.swift
│   └── DesignSystemSectionHeaderView.swift
│
├── Data/
│   ├── FoodDatabaseManager.swift       # old — to be removed
│   ├── MealLogManager.swift            # old — to be removed
│   └── foodlens-food-database.json    # 542 IFCT foods
│
├── Models/
│   ├── FoodItem.swift
│   ├── MealEntry.swift
│   ├── DailyLog.swift
│   └── UserSettings.swift
│
├── Repositories/
│   ├── FoodRepository.swift
│   └── MealLogRepository.swift
│
├── Interactors/
│   ├── MealLoggingInteractor.swift     # done
│   ├── FoodSearchInteractor.swift      # done
│   ├── HistoryInteractor.swift         # to do
│   └── SettingsInteractor.swift        # to do
│
├── Views/
│   ├── Main/
│   │   ├── TodayView.swift             # done
│   │   ├── FoodSearchView.swift        # to do
│   │   ├── LogMealSheet.swift          # to do
│   │   ├── HistoryView.swift           # to do
│   │   └── SettingsView.swift          # to do
│   └── Components/
│       ├── MacroGaugeCard.swift
│       └── WeeklyProteinChart.swift
│
└── Utilities/
    └── HapticManager.swift
```

---

## Onboarding

Two paths for new users:

- **I know my macros** — enter protein/carbs/fat directly (~30 seconds)
- **Calculate for me** — enter age, weight, height, and goal. App calculates targets (~90 seconds)

---

## Tech stack

- **Language** — Swift
- **UI** — SwiftUI (native iOS components)
- **Local storage** — SwiftData
- **Food database** — IFCT 2017 JSON, seeded on first launch
- **Charts** — Apple Charts framework

---

## Build status

Done:
- Architecture + AppState
- Food database (542 dishes)
- DesignSystem components
- TodayView
- MealLoggingInteractor
- FoodSearchInteractor

To do:
- FoodSearchView + LogMealSheet (core logging flow — highest priority)
- SettingsView + SettingsInteractor
- HistoryView + HistoryInteractor
- Clean up old Data/ managers (FoodDatabaseManager, MealLogManager)
- Privacy policy (required for App Store)

---

## Getting started

```bash
open FoodLens.xcodeproj
```

Read these files in order to understand the patterns before building anything new:

1. `AppState.swift` — how state flows through the app
2. `MealLoggingInteractor.swift` — the pattern every interactor follows
3. `TodayView.swift` — the pattern every view follows
