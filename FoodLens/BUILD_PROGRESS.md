# FoodLens — Build Progress

## Done

**Foundation**
- [x] AppState.swift
- [x] FoodLensApp.swift — entry point, DI, routing, SwiftData setup

**Models**
- [x] FoodItem.swift
- [x] MealEntry.swift
- [x] DailyLog.swift
- [x] UserSettings.swift

**Repositories**
- [x] FoodRepository.swift — search, CRUD, favorites, recently used
- [x] MealLogRepository.swift — save, fetch today, history, daily logs

**Interactors**
- [x] FoodSearchInteractor.swift — fuzzy search, group filter, favorites, discovery
- [x] MealLoggingInteractor.swift — log, quick log, bulk log, edit, delete, undo
- [x] SettingsInteractor.swift — macro target updates, preset apply, BMR/TDEE recalculation, validation

**Views — Main**
- [x] TodayView.swift — calories pill, macro gauges, quick log, meal rows, swipe delete
- [x] HistoryView.swift — 7-day breakdown, avg macros, weekly protein chart
- [x] FoodSearchView.swift — search bar, favorites section, recents section
- [x] LogMealSheet.swift — food search → serving detail → log button
- [x] SettingsView.swift — macro targets, presets, display unit, haptics toggle

**Views — Onboarding**
- [x] OnboardingWelcomeView.swift — SF Symbol icon, tagline, feature bullets, two entry paths
- [x] QuickSetupView.swift — enter protein/carbs/fat directly, live calorie calc
- [x] GuidedSetupView.swift — 5-step flow (profile → body → activity → goal → results), auto-calculates targets

**Components**
- [x] MacroGaugeCard.swift — linear + circular variants
- [x] WeeklyProteinChart.swift

**Utilities**
- [x] HapticManager.swift

**Assets**
- [x] App icon — light, dark, tinted variants (SF Symbol fork.knife.circle.fill, 1024×1024)

**Data**
- [x] foodlens-food-database.json — 542 IFCT 2017 Indian foods

**Docs / Store**
- [x] docs/privacy-policy.html — hosted via GitHub Pages

---

## To Do

**App Store submission**
- [ ] Enable GitHub Pages (so privacy policy URL is live)
- [ ] App Store Connect — create listing
- [ ] TestFlight — build, upload, test on real device
- [ ] Screenshots — 6.5" and 5.5" iPhone
- [ ] App metadata — description, keywords, category

---

## Stats

- Swift files built: ~22
- Food items in database: 542
- Screens working: Today, History, Log Meal, Food Search, Settings, Onboarding (3 screens)
- Screens pending: none
