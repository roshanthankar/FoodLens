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
                // Header section (scrollable)
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
        }
        .task {
            await refreshData()
        }
    }

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
                MacroGaugeCard(label: "Carbs", value: appState.todayTotals.carbs, target: macroTargets.carbs, color: .blue)
                MacroGaugeCard(label: "Fat", value: appState.todayTotals.fat, target: macroTargets.fat, color: .orange)
            }
            .padding(.vertical, 4)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
    }

    private var quickActionsSection: some View {
        Section("Quick Log") {
            if appState.recentFoods.isEmpty {
                Text("Your recently logged foods will show up here.")
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
            }
        }
    }

    private var emptyMealsSection: some View {
        Section {
            ContentUnavailableView(
                "No Meals Logged",
                systemImage: "fork.knife",
                description: Text("Tap the add button to log your first meal today.")
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
            predicate: #Predicate { meal in
                meal.timestamp >= startOfDay
            },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        var recentFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in
                food.lastUsedDate != nil
            },
            sortBy: [SortDescriptor(\.lastUsedDate, order: .reverse)]
        )
        recentFoodsDescriptor.fetchLimit = 10

        let favoriteFoodsDescriptor = FetchDescriptor<FoodItem>(
            predicate: #Predicate { food in
                food.isFavorite == true
            },
            sortBy: [SortDescriptor(\.foodName)]
        )

        do {
            let todayMeals = try modelContext.fetch(todayDescriptor)
            let recentFoods = try modelContext.fetch(recentFoodsDescriptor)
            let favoriteFoods = try modelContext.fetch(favoriteFoodsDescriptor)

            await MainActor.run {
                appState.updateTodayMeals(todayMeals)
                appState.updateRecentFoods(recentFoods)
                appState.updateFavoriteFoods(favoriteFoods)
            }
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}

private struct GlassIconButton: View {
    let systemImage: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(systemName: systemImage)
                .font(.headline.weight(.semibold))
                .foregroundStyle(.primary)
                .frame(width: 42, height: 42)
                .background(.ultraThinMaterial, in: Circle())
                .overlay(
                    Circle()
                        .stroke(Color.white.opacity(0.35), lineWidth: 1)
                )
        }
        .buttonStyle(.plain)
    }
}

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
                MacroChip(value: meal.proteinGrams, color: .green)
                MacroChip(value: meal.carbsGrams, color: .blue)
                MacroChip(value: meal.fatGrams, color: .orange)
            }
        }
        .padding(.vertical, 6)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(meal.foodName)
        .accessibilityValue("\(meal.servingSizeText), \(meal.timeDisplay), \(Int(meal.proteinGrams)) grams protein, \(Int(meal.carbsGrams)) grams carbs, \(Int(meal.fatGrams)) grams fat")
    }
}

struct MacroChip: View {
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
    }
}

#Preview {
    TodayView()
}
