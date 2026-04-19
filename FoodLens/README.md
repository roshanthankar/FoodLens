# FoodLens

An iOS macro tracker built for Indians who eat Indian food.

Demo — [watch here](https://drive.google.com/file/d/1kddSJvSywgCy6idM9lNZZv3Qoz8SESqt/view?usp=sharing)

---

## What it does

- Log Indian meals and track daily protein, carbs, and fat
- 542 Indian dishes from the IFCT 2017 database
- See macro progress gauges, calorie total, and 7-day history
- Quick-log recently used foods in one tap
- No login, no internet — everything stays on device

---

## Tech stack

| What | Tool |
|---|---|
| Language | Swift |
| UI | SwiftUI |
| Storage | SwiftData |
| Charts | Apple Charts framework |
| Food data | IFCT 2017 JSON (542 items) |

---

## Architecture

```
Views  →  Interactors  →  Repositories  →  SwiftData
```

All shared state lives in `AppState.swift`. Views read from it, Interactors write to it.

See `ARCHITECTURE.md` for the full breakdown.

---

## Build status

| Area | Status |
|---|---|
| AppState + routing | Done |
| SwiftData models (4) | Done |
| Repositories (2) | Done |
| FoodSearchInteractor | Done |
| MealLoggingInteractor | Done |
| TodayView | Done |
| HistoryView | Done |
| FoodSearchView + LogMealSheet | Done |
| SettingsView | Done |
| MacroGaugeCard + WeeklyProteinChart | Done |
| HapticManager | Done |
| Food database (542 dishes) | Done |
| Onboarding screens | To do |
| SettingsInteractor | To do |
| Privacy policy | To do |

---

## Getting started

```bash
open FoodLens.xcodeproj
```

Read these files in order to understand how everything fits together:
1. `App/AppState.swift` — how state flows through the app
2. `Interactors/MealLoggingInteractor.swift` — how business logic is structured
3. `Views/Main/TodayView.swift` — how views consume state and call interactors
