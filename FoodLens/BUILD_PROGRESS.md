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
- [x] CaloriesPillView — percentage + fraction display
- [x] MacroGaugeView — 3-macro carbs/protein/fats variant with status icons
- [x] MealRowView — colored letter-prefix macro chips (C/P/F)
- [x] SectionHeaderView — label + optional iOS segmented control (icon segments)
- [x] EmptyStateView
- [x] WeeklyProteinChart.swift
- [x] Chrome — TopNavigationBar, DateChip, DatePickerSheet (with "Today" jump), GradientHeader

**Utilities**
- [x] HapticManager.swift

**Assets**
- [x] App icon — light, dark, tinted variants (SF Symbol fork.knife.circle.fill, 1024×1024)
- [x] Brand colorsets — BrandTeal, MacroCarbs/Protein/Fats, Surface/Header tones (per-mode light + dark)
- [x] MomoTrustSans / MomoTrustDisplay / MomoSignature TTFs bundled
- [x] Programmatic font registration via CTFontManager (`INFOPLIST_KEY_UIAppFonts` is silently dropped in synchronized-folder Xcode projects)

**Home screen polish**
- [x] Scrolling top navigation bar (DateChip + profile button) inside the List
- [x] Header gradient pinned to top, matching app background in light/dark
- [x] Macros section header
- [x] Meals section with morning/afternoon/night/(evening) segmented filter
- [x] Date-driven data fetch — `task(id: selectedDate)` rewires per day
- [x] Per-section spacing — 32pt calories↔macros, 40pt macros↔meals

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
