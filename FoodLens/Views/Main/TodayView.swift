// TodayView.swift
// FoodLens - Presentation Layer

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(AppState.self) private var appState
    @Environment(MealLoggingInteractor.self) private var mealLoggingInteractor
    @Environment(\.modelContext) private var modelContext
    @State private var showLogMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    @State private var selectedDate: Date = .now
    @State private var showingProfile = false
    @State private var dayMeals: [MealEntry] = []
    @State private var selectedTimeOfDay: TimeOfDay = .morning

    enum TimeOfDay: Hashable {
        case morning, afternoon, night

        var displayName: String {
            switch self {
            case .morning:   "Morning"
            case .afternoon: "Afternoon"
            case .night:     "Night"
            }
        }
    }

    private var timeOfDaySegments: [SectionHeaderSegment<TimeOfDay>] {
        [
            .init(id: .morning,   systemImage: "sun.horizon.fill", accessibilityLabel: "Morning"),
            .init(id: .afternoon, systemImage: "sun.max.fill",     accessibilityLabel: "Afternoon"),
            .init(id: .night,     systemImage: "moon.fill",        accessibilityLabel: "Night")
        ]
    }

    private var macroTargets: MacroTargets {
        guard let settings = appState.userSettings else { return .default }
        return MacroTargets(
            protein: settings.proteinTarget,
            carbs: settings.carbsTarget,
            fat: settings.fatTarget
        )
    }

    private var dayTotals: MacroTotals {
        MacroTotals(
            protein: dayMeals.reduce(0) { $0 + $1.proteinGrams },
            carbs:   dayMeals.reduce(0) { $0 + $1.carbsGrams },
            fat:     dayMeals.reduce(0) { $0 + $1.fatGrams }
        )
    }

    private var dayMealsByType: [MealType: [MealEntry]] {
        Dictionary(grouping: dayMeals) { $0.mealType }
    }

    private var mealsForSelectedTime: [MealEntry] {
        dayMeals
            .filter { meal in
                let hour = Calendar.current.component(.hour, from: meal.timestamp)
                switch selectedTimeOfDay {
                case .morning:   return hour >= 5  && hour < 12
                case .afternoon: return hour >= 12 && hour < 17
                case .night:     return hour >= 17 || hour < 5
                }
            }
            .sorted { $0.timestamp < $1.timestamp }
    }

    var body: some View {
        NavigationStack {
            List {
                caloriesSummarySection
                macroGaugesSection

                if dayMeals.isEmpty {
                    emptyMealsSection
                } else {
                    mealsSection
                }
            }
            .task(id: selectedDate) {
                await refreshData()
            }
            .listStyle(.insetGrouped)
            .listSectionSpacing(32)
            .scrollIndicators(.hidden)
            .scrollContentBackground(.hidden)
            .background(alignment: .top) {
                GradientHeader(gradient: .homeHeader)
                    .frame(height: 420)
            }
            .background(Color.surfaceBackground.ignoresSafeArea())
            .navigationBarHidden(true)
            .sheet(isPresented: $showLogMealSheet) {
                LogMealSheet(initialMealType: selectedMealType) {
                    Task { await refreshData() }
                }
            }
            .refreshable {
                await refreshData()
            }
            .sheet(isPresented: $showingProfile) {
                ProfileView()
            }
        }
    }

    // MARK: - Sections

    private var caloriesSummarySection: some View {
        Section {
            CaloriesPillView(
                current: Int(dayTotals.calories),
                target: Int(macroTargets.calories)
            )
            .listRowInsets(EdgeInsets(top: 125, leading: 16, bottom: 8, trailing: 16))
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } header: {
            TopNavigationBar(
                selectedDate: $selectedDate,
                onProfileTap: { showingProfile = true }
            )
            .textCase(nil)
            .listRowInsets(EdgeInsets())
        }
    }

    private var macroGaugesSection: some View {
        Section {
            MacroGaugeView(
                carbs: MacroData(label: "Carbs", value: dayTotals.carbs, target: macroTargets.carbs, color: .macroCarbs),
                protein: MacroData(label: "Protein", value: dayTotals.protein, target: macroTargets.protein, color: .macroProtein),
                fats: MacroData(label: "Fats", value: dayTotals.fat, target: macroTargets.fat, color: .macroFats)
            )
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .listRowInsets(EdgeInsets())
            .listRowBackground(Color.clear)
            .listRowSeparator(.hidden)
        } header: {
            SectionHeaderView(title: "Macros")
                .textCase(nil)
                .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
        }
    }

    private var mealsSection: some View {
        Section {
            if mealsForSelectedTime.isEmpty {
                ContentUnavailableView(
                    "No \(selectedTimeOfDay.displayName) Meals",
                    systemImage: "fork.knife",
                    description: Text("Nothing logged for \(selectedTimeOfDay.displayName.lowercased()) yet. Tap + to log a meal.")
                )
            } else {
                ForEach(mealsForSelectedTime) { meal in
                    MealRowView(meal: meal, onDelete: nil)
                        .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                            Button(role: .destructive) {
                                Task {
                                    await mealLoggingInteractor.deleteMeal(meal)
                                    await refreshData()
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        } header: {
            SectionHeaderView(
                title: "Meals",
                segments: timeOfDaySegments,
                selection: $selectedTimeOfDay
            )
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
        }
        .listSectionSpacing(40)
    }

    private var emptyMealsSection: some View {
        Section {
            ContentUnavailableView(
                "No Meals Logged",
                systemImage: "fork.knife",
                description: Text("Tap + to log your first meal. Swipe left on any meal to delete it.")
            )
        } header: {
            SectionHeaderView(
                title: "Meals",
                segments: timeOfDaySegments,
                selection: $selectedTimeOfDay
            )
            .textCase(nil)
            .listRowInsets(EdgeInsets(top: 0, leading: 20, bottom: 12, trailing: 20))
        }
        .listSectionSpacing(40)
    }

    private func refreshData() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? startOfDay

        let dayDescriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { meal in
                meal.timestamp >= startOfDay && meal.timestamp < endOfDay
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        var recentFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in food.lastUsedDate != nil },
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        recentFoodsDescriptor.fetchLimit = 10

        let favoriteFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in food.isFavorite == true },
            sortBy: [SortDescriptor(\.foodName)]
        )

        do {
            let meals         = try modelContext.fetch(dayDescriptor)
            let recentFoods   = try modelContext.fetch(recentFoodsDescriptor)
            let favoriteFoods = try modelContext.fetch(favoriteFoodsDescriptor)

            dayMeals = meals
            appState.updateRecentFoods(recentFoods)
            appState.updateFavoriteFoods(favoriteFoods)

            if calendar.isDateInToday(selectedDate) {
                appState.updateTodayMeals(meals)
            }
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}

#Preview {
    TodayView()
}
