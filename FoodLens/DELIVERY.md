# FoodLens — Delivery Notes

## What's built

A working iOS macro tracker for Indian food. All core screens are functional.

**Working right now:**
- Log a meal — search 542 Indian foods, set servings, pick meal type, tap log
- Today screen — see calorie total, macro progress gauges, quick-log recent foods, all meals by type
- History screen — last 7 days, avg protein/carbs/fat, weekly protein chart
- Settings screen — macro targets, profile fields
- Favorites — heart any food to pin it to the top of search
- Data persists locally via SwiftData, no account or internet needed

---

## What's not built yet

**Onboarding** — The `OnboardingCoordinator` is a placeholder (single button that marks onboarding complete). The actual screens — quick setup (enter macros directly) and guided setup (enter profile, calculate targets) — still need to be built.

**SettingsInteractor** — Settings currently writes directly to `UserSettings` via SwiftData. An interactor for validation + BMR/TDEE calculation logic should be added.

**Privacy policy** — Required before App Store submission.

---

## Architecture decisions worth knowing

- All state lives in `AppState.swift`. If something isn't showing up in the UI, check if `AppState` was updated after the data change.
- Macros are **snapshotted at log time** into `MealEntry`. If you later edit or delete a `FoodItem`, past logs are unaffected.
- `FoodRepository.seedDatabase()` only runs when the database has 0 food items. Safe to call on every launch.
- The `+` tab in the tab bar doesn't navigate — it intercepts the tap to present `LogMealSheet` as a sheet. `appState.routing` stays on the current tab.
- Meal type is auto-suggested by time of day (breakfast 5–11am, lunch 11am–4pm, dinner 4–10pm, snack otherwise).

---

## How to continue

To build the onboarding screens:
1. Create views in `Views/Onboarding/`
2. When the user finishes, set `settings.hasCompletedOnboarding = true`, save context, set `appState.routing = .today`
3. The `OnboardingCoordinator` in `FoodLensApp.swift` is where to wire them in

To add a `SettingsInteractor`:
- Follow the same pattern as `MealLoggingInteractor`
- Inject it via `@Environment` in `SettingsView`
- Move the BMR/TDEE calculation from `UserSettings` into the interactor
