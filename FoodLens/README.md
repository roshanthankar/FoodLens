# FoodLens

An iOS macro tracking app built for Indians who eat Indian food.

Demo Video - https://drive.google.com/file/d/1kddSJvSywgCy6idM9lNZZv3Qoz8SESqt/view?usp=sharing
---

## What it does

- Log Indian meals and track daily protein, carbs, and fat
- No login required — everything stays on your phone
- Works offline — no internet needed
- 542 Indian dishes from IFCT 2017 (India's official nutrition data)

---

## Architecture — 3 layers

```
Views  →  Interactors  →  Repositories  →  SwiftData (local storage)
```

| Layer | What it does | Files |
|---|---|---|
| **Views** | Screens the user sees | TodayView, HistoryView, SettingsView, FoodSearchView, LogMealSheet |
| **Interactors** | Business logic (calculations, rules) | MealLoggingInteractor, FoodSearchInteractor, HistoryInteractor, SettingsInteractor |
| **Repositories** | Reads and writes data | FoodRepository, MealLogRepository |

All state lives in one place: `AppState.swift`. Views read from it, Interactors write to it.

---

## File structure

```
FoodLens/
├── App/
│   ├── FoodLensApp.swift           # Entry point + routing
│   └── AppState.swift              # Central state
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
│   ├── MealLoggingInteractor.swift
│   ├── FoodSearchInteractor.swift
│   ├── HistoryInteractor.swift
│   └── SettingsInteractor.swift
│
├── Views/
│   ├── Main/
│   │   ├── TodayView.swift
│   │   ├── HistoryView.swift
│   │   ├── SettingsView.swift
│   │   ├── LogMealSheet.swift
│   │   └── FoodSearchView.swift
│   ├── Components/
│   │   ├── MacroGaugeCard.swift
│   │   ├── WeeklyProteinChart.swift
│   │   └── MealListSection.swift
│   └── Onboarding/
│       ├── OnboardingCoordinator.swift
│       ├── OnboardingPathSelectionView.swift
│       ├── QuickSetupView.swift
│       └── GuidedSetupView.swift
│
├── Utilities/
│   ├── HapticManager.swift
│   └── Extensions.swift
│
└── Resources/
    └── foodlens-food-database.json  # 542 IFCT foods
```

---

## Onboarding

Two paths for new users:

- **I know my macros** — enter protein/carbs/fat directly (~30 seconds)
- **Calculate for me** — enter age, weight, height, and goal. App calculates targets (~90 seconds)

---

## Tech stack

| What | Tool |
|---|---|
| Language | Swift |
| UI | SwiftUI (native iOS components) |
| Local storage | SwiftData |
| Food database | IFCT 2017 JSON (seeded on first launch) |
| Charts | Apple Charts framework |

---

## Build status

| Area | Status |
|---|---|
| Architecture + AppState | Done |
| Food database (542 dishes) | Done |
| Onboarding screens | Done |
| TodayView + MealLoggingInteractor | Done |
| HistoryView, SettingsView, FoodSearchView, LogMealSheet | To do |
| HistoryInteractor, SettingsInteractor | To do |
| Privacy policy (required for App Store) | To do |

---

## Getting started

```bash
# Open in Xcode
open FoodLens.xcodeproj
```

Start by reading these files in order:
1. `AppState.swift` — understand how state flows
2. `MealLoggingInteractor.swift` — the pattern every interactor follows
3. `TodayView.swift` — the pattern every view follows

Then build the remaining files by copying those same patterns.
