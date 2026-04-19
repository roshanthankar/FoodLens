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

Nothing. The app is feature complete and ready for App Store submission.

---

## Architecture decisions worth knowing

- All state lives in `AppState.swift`. If something isn't showing up in the UI, check if `AppState` was updated after the data change.
- Macros are **snapshotted at log time** into `MealEntry`. If you later edit or delete a `FoodItem`, past logs are unaffected.
- `FoodRepository.seedDatabase()` only runs when the database has 0 food items. Safe to call on every launch.
- The `+` tab in the tab bar doesn't navigate — it intercepts the tap to present `LogMealSheet` as a sheet. `appState.routing` stays on the current tab.
- Meal type is auto-suggested by time of day (breakfast 5–11am, lunch 11am–4pm, dinner 4–10pm, snack otherwise).
- Onboarding routing: on launch, `FoodLensApp` checks `UserSettings.hasCompletedOnboarding`. False → `appState.routing = .onboarding`. Both onboarding exit paths set this to true and route to `.today`.

---

## Next steps (App Store)

1. Enable GitHub Pages on the repo (`docs/` folder) so the privacy policy URL is live
2. Create the app listing in App Store Connect
3. Upload a build via TestFlight and test on a real device
4. Capture screenshots — 6.5" (iPhone 15 Pro Max) and 5.5" (iPhone 8 Plus)
5. Fill in metadata — description, keywords, Health & Fitness category
