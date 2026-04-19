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
    @State private var deletedMealName: String?
    @State private var showDeleteToast = false

    private var macroTargets: MacroTargets {
        guard let settings = appState.userSettings else { return .default }
        return MacroTargets(
            protein: settings.proteinTarget,
            carbs: settings.carbsTarget,
            fat: settings.fatTarget
        )
    }

    private var todayMealsByType: [MealType: [MealEntry]] {
        Dictionary(grouping: appState.todayMeals) { $0.mealType }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Today, \(formattedDate)")
                        .font(.largeTitle.weight(.bold))
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
                }
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                caloriesSummarySection
                macroGaugesSection
                quickActionsSection

                if appState.todayMeals.isEmpty {
                    emptyMealsSection
                } else {
                    mealsSection
                }
            }
            .listStyle(.insetGrouped)
            .navigationBarHidden(true)
            .sheet(isPresented: $showLogMealSheet) {
                LogMealSheet(initialMealType: selectedMealType) {
                    Task { await refreshData() }
                }
            }
            .refreshable {
                await refreshData()
            }
            .overlay(alignment: .bottom) {
                if showDeleteToast, let name = deletedMealName {
                    DeleteToast(name: name)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                        .padding(.bottom, 12)
                }
            }
            .animation(.spring(duration: 0.3), value: showDeleteToast)
        }
    }

    // MARK: - Sections

    private var caloriesSummarySection: some View {
        Section {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Image(systemName: "flame.fill")
                        .font(.body)
                        .foregroundStyle(.orange)
                        .accessibilityHidden(true)

                    Text("Calories")
                        .font(.body)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Text("\(Int(appState.todayTotals.calories))/\(Int(macroTargets.calories))")
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)

                Text("kcal")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 14)
            .frame(maxWidth: .infinity)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(Capsule())
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Calories")
            .accessibilityValue("\(Int(appState.todayTotals.calories)) of \(Int(macroTargets.calories)) kilocalories")
        }
        .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }

    private var macroGaugesSection: some View {
        Section {
            VStack(spacing: 14) {
                MacroGaugeCard(label: "Protein", value: appState.todayTotals.protein, target: macroTargets.protein, color: .green)
                MacroGaugeCard(label: "Carbs",   value: appState.todayTotals.carbs,   target: macroTargets.carbs,   color: .blue)
                MacroGaugeCard(label: "Fat",     value: appState.todayTotals.fat,     target: macroTargets.fat,     color: .orange)
            }
            .padding(.vertical, 4)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var quickActionsSection: some View {
        Section("Quick Log") {
            if appState.recentFoods.isEmpty {
                Text("Your recently logged foods will appear here.")
                    .font(.body)
                    .foregroundStyle(.secondary)
            } else {
                ForEach(appState.recentFoods.prefix(3)) { food in
                    Button {
                        Task {
                            await mealLoggingInteractor.quickLog(
                                food: food,
                                mealType: mealLoggingInteractor.suggestedMealType()
                            )
                            await refreshData()
                        }
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 3) {
                                Text(food.foodName)
                                    .font(.body.weight(.medium))
                                    .foregroundStyle(.primary)
                                    .lineLimit(2)

                                Text(food.servingDescription)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Text("+\(food.macros(servings: 1).protein, specifier: "%.1f")g P")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.green)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 6)
                                .background(Color.green.opacity(0.12))
                                .clipShape(Capsule())
                        }
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Quick log \(food.foodName)")
                    .accessibilityHint("Logs one serving to \(mealLoggingInteractor.suggestedMealType().displayName)")
                }
            }
        }
    }

    private var mealsSection: some View {
        ForEach(MealType.allCases, id: \.self) { mealType in
            if let meals = todayMealsByType[mealType], !meals.isEmpty {
                Section(mealType.rawValue) {
                    ForEach(meals.sorted(by: { $0.timestamp < $1.timestamp })) { meal in
                        MealRow(meal: meal)
                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                Button(role: .destructive) {
                                    deletedMealName = meal.foodName
                                    Task {
                                        await mealLoggingInteractor.deleteMeal(meal)
                                        await refreshData()
                                        showDeleteToast = true
                                        try? await Task.sleep(for: .seconds(2.5))
                                        showDeleteToast = false
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
            }
        }
    }

    private var emptyMealsSection: some View {
        Section {
            ContentUnavailableView(
                "No Meals Logged",
                systemImage: "fork.knife",
                description: Text("Tap + to log your first meal. Swipe left on any meal to delete it.")
            )
        }
    }

    private var formattedDate: String {
        Date.now.formatted(.dateTime.day().month(.abbreviated))
    }

    private func refreshData() async {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())

        let todayDescriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { meal in meal.timestamp >= startOfDay },
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
            let todayMeals    = try modelContext.fetch(todayDescriptor)
            let recentFoods   = try modelContext.fetch(recentFoodsDescriptor)
            let favoriteFoods = try modelContext.fetch(favoriteFoodsDescriptor)

            appState.updateTodayMeals(todayMeals)
            appState.updateRecentFoods(recentFoods)
            appState.updateFavoriteFoods(favoriteFoods)
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}

// MARK: - Delete Toast

private struct DeleteToast: View {
    let name: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "trash")
                .font(.subheadline)
            Text("\(name) deleted")
                .font(.subheadline.weight(.medium))
        }
        .foregroundStyle(.white)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(.primary.opacity(0.9), in: Capsule())
    }
}

// MARK: - Meal Row

struct MealRow: View {
    let meal: MealEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                Text(meal.foodName)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.primary)
                    .lineLimit(2)

                Spacer(minLength: 8)

                HStack(spacing: 4) {
                    Text(meal.servingSizeText)
                    Text("•")
                    Text(meal.timeDisplay)
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .lineLimit(1)
            }

            HStack(spacing: 8) {
                MacroChip(label: "Protein", value: meal.proteinGrams, color: .green)
                MacroChip(label: "Carbs",   value: meal.carbsGrams,   color: .blue)
                MacroChip(label: "Fat",     value: meal.fatGrams,     color: .orange)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(meal.foodName)
        .accessibilityValue("\(meal.servingSizeText), \(meal.timeDisplay), \(Int(meal.proteinGrams))g protein, \(Int(meal.carbsGrams))g carbs, \(Int(meal.fatGrams))g fat")
    }
}

// MARK: - Macro Chip

struct MacroChip: View {
    let label: String
    let value: Double
    let color: Color

    var body: some View {
        Text("\(Int(value))g")
            .font(.caption.weight(.semibold))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(color.opacity(0.12))
            .clipShape(Capsule())
            .accessibilityLabel("\(label): \(Int(value)) grams")
    }
}

#Preview {
    TodayView()
}
