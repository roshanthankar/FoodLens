# FoodLens — Architecture

## Layers

```
Views  →  Interactors  →  Repositories  →  SwiftData
   ↑
 Theme (AppTheme, BrandColors, BrandFonts)
```

**Views** — SwiftUI screens. Read from `AppState`, call Interactors for actions. No business logic.

**Interactors** — Business logic. Validate input, call Repositories, update `AppState`, trigger haptics.

**Repositories** — SwiftData CRUD. No logic, just reads and writes.

**AppState** — Single source of truth. `@Observable` singleton. All views react to it automatically.

**Theme** — Cross-cutting visual layer. `AppTheme` (appearance preference), `BrandColors` (asset-catalog tokens + macro tinting), `BrandFonts` (Momo font family + semantic `brand*` styles, plus `BrandFontRegistrar` which programmatically registers bundled `.ttf`s via `CTFontManagerRegisterFontsForURL` because `INFOPLIST_KEY_UIAppFonts` is silently dropped from the generated Info.plist in Xcode 26 synchronized-folder projects). Injected via `@Environment` and consumed by any View.

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
│   ├── FoodLensApp.swift           # Entry point, DI setup, routing, root TabView
│   ├── AppState.swift              # Centralized state (Redux-like)
│   └── Theme/
│       ├── AppTheme.swift          # AppearancePreference + @Observable AppTheme
│       ├── BrandColors.swift       # MacroTheme enum, header gradients
│       └── BrandFonts.swift        # Font.momoSans/Display/Signature + brand* styles
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
│   │   ├── ProfileView.swift       # Appearance / app icon / about (sheet)
│   │   ├── FoodSearchView.swift
│   │   └── LogMealSheet.swift
│   ├── Onboarding/
│   │   ├── OnboardingWelcomeView.swift
│   │   ├── QuickSetupView.swift
│   │   └── GuidedSetupView.swift
│   └── Components/
│       ├── CaloriesPillView.swift      # Hero calories % + current/target fraction
│       ├── MacroGaugeView.swift        # Carbs/Protein/Fats gauge trio with status icons
│       ├── MealRowView.swift           # Meal name + time + C/P/F coloured chips
│       ├── SectionHeaderView.swift     # Section label, optional iOS segmented control (generic over Hashable)
│       ├── EmptyStateView.swift
│       ├── WeeklyProteinChart.swift
│       └── Chrome/
│           ├── DateChip.swift              # Tappable date title with chevron
│           ├── DatePickerSheet.swift       # Calendar sheet with "Today" jump button
│           ├── FloatingTabBar.swift        # MainTab enum + custom pill tab bar
│           ├── GradientHeader.swift        # Reusable gradient header w/ date+profile slots
│           ├── ProfileButton.swift         # Circular profile entry point
│           └── TopNavigationBar.swift      # Scrolling top nav (DateChip + profile button)
│
├── Utilities/
│   └── HapticManager.swift
│
├── Font/                           # Bundled Momo font files
│   ├── MomoSignature/
│   ├── MomoTrustDisplay/
│   └── MomoTrustSans/
│
├── Assets.xcassets/                # Brand color tokens (per-mode colorsets)
│   ├── BrandTeal, MacroCarbs/Protein/Fats
│   ├── SurfaceBackground/Card/Muted
│   └── HeaderHomeTop, HeaderCarbs/Protein/FatsTop
│
└── Data/
    └── foodlens-food-database.json  # 542 IFCT foods
```

---

## Key Patterns

**AppState** — Singleton, `@MainActor @Observable`. Holds today's meals, macro totals, recents, favorites, routing, errors. Views never write to it directly — only Interactors do.

**Dependency Injection** — Everything passed via `@Environment`. `FoodLensApp` creates all repositories, interactors, and `AppTheme`, injects them at the root. `ContentView` reads them and forwards down the tree implicitly.

**Theming** — `AppTheme` is `@Observable` and persists `AppearancePreference` (system/light/dark) to `UserDefaults`. Applied at the root via `.preferredColorScheme(appTheme.appearance.colorScheme)`. `ProfileView` mutates it with `@Bindable`.

**Brand fonts** — `Font.brandTitle`, `brandBody`, `brandHeroNumber`, etc. wrap the Momo font family (`MomoTrustSans` for UI, `MomoTrustDisplay` for big numbers, `MomoSignature` for accents). Views use the semantic `brand*` aliases, never `Font.custom` directly. Fonts are registered at app launch via `BrandFontRegistrar.registerCustomFonts()` (called from `FoodLensApp.init`) — synchronized-folder projects silently drop `INFOPLIST_KEY_UIAppFonts`, so programmatic `CTFontManagerRegisterFontsForURL` is the only reliable path.

**Brand colors** — Asset-catalog `colorset`s with per-mode variants, exposed as `Color.brandTeal`, `.macroCarbs`, `.surfaceCard`, etc. `MacroTheme` enum maps a macro to its tint and header gradient (`LinearGradient.macroHeader(.protein)`).

**Root navigation** — Native `TabView(.sidebarAdaptable)` with three tabs (Home / History / Settings) plus a glass-effect floating `+` button overlaid bottom-center. A `ProfileButton` is overlaid top-trailing on every tab and presents `ProfileView` as a sheet. The standalone `FloatingTabBar` component exists as a custom alternative but is not currently the active chrome.

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

**SwiftData store recovery** — `FoodLensApp.makeModelContainer` catches schema-mismatch errors, deletes the on-disk `default.store*` files, and retries with a clean store. Prevents users from being stuck on incompatible migrations during early development.
