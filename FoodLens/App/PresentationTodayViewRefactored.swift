// TodayView+Refactored.swift
// FoodLens - Presentation Layer (Professional Refactor)
//
// Clean, component-based architecture following HIG

import SwiftUI
import SwiftData

struct TodayViewRefactored: View {
    // MARK: - Environment
    
    @Environment(AppState.self) private var appState
    @Environment(MealLoggingInteractor.self) private var mealLoggingInteractor
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - State
    
    @State private var showLogMealSheet = false
    @State private var selectedMealType: MealType = .breakfast
    
    // MARK: - Computed Properties
    
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
    
    // MARK: - Body

    var body: some View {
        NavigationStack {
            List {
                caloriesSection
                macrosSection
                quickLogSection
                mealsSection
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
    
    // MARK: - View Components
    
    
    private var caloriesSection: some View {
        Section {
            CaloriesPillView(
                current: Int(appState.todayTotals.calories),
                target: Int(macroTargets.calories)
            )
        }
        .listRowInsets(EdgeInsets(
            top: DesignTokens.Spacing.xSmall,
            leading: DesignTokens.Spacing.medium,
            bottom: DesignTokens.Spacing.xSmall,
            trailing: DesignTokens.Spacing.medium
        ))
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var macrosSection: some View {
        Section {
            MacroGaugeView(
                carbs: MacroData(
                    label: "Carbs",
                    value: appState.todayTotals.carbs,
                    target: macroTargets.carbs,
                    color: Color(hex: "B7383C")
                ),
                protein: MacroData(
                    label: "Protein",
                    value: appState.todayTotals.protein,
                    target: macroTargets.protein,
                    color: Color(hex: "007A2F")
                ),
                fats: MacroData(
                    label: "Fats",
                    value: appState.todayTotals.fat,
                    target: macroTargets.fat,
                    color: Color(hex: "515BBB")
                ),
                calories: MacroData(
                    label: "Calories",
                    value: appState.todayTotals.calories,
                    target: macroTargets.calories,
                    color: .primary,
                    showIcon: false
                ),
                showDivider: true
            )
            .padding(.horizontal, DesignTokens.Spacing.large)
        }
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
    
    private var quickLogSection: some View {
        Section {
            if appState.recentFoods.isEmpty {
                EmptyStateView(
                    systemImage: "clock",
                    title: "No Recent Foods",
                    description: "Your recently logged foods will show up here."
                )
            } else {
                ForEach(appState.recentFoods.prefix(3)) { food in
                    QuickLogRowView(food: food) {
                        Task {
                            await mealLoggingInteractor.quickLog(
                                food: food,
                                mealType: mealLoggingInteractor.suggestedMealType()
                            )
                            await refreshData()
                        }
                    }
                }
            }
        } header: {
            SectionHeaderView(title: "Quick Log")
        }
    }
    
    private var mealsSection: some View {
        Group {
            if appState.todayMeals.isEmpty {
                Section {
                    EmptyStateView(
                        systemImage: "fork.knife",
                        title: "No Meals Logged",
                        description: "Tap the add button to log your first meal today."
                    )
                }
            } else {
                ForEach(MealType.allCases, id: \.self) { mealType in
                    if let meals = todayMealsByType[mealType], !meals.isEmpty {
                        Section {
                            ForEach(meals.sorted(by: { $0.timestamp < $1.timestamp })) { meal in
                                MealRowView(meal: meal) {
                                    Task {
                                        await mealLoggingInteractor.deleteMeal(meal)
                                        await refreshData()
                                    }
                                }
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
                        } header: {
                            SectionHeaderView(title: mealType.rawValue)
                        }
                    }
                }
            }
        }
    }
    
    // MARK: - Data Management
    
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

// MARK: - Quick Log Row Component

private struct QuickLogRowView: View {
    let food: FoodItem
    let onTap: () -> Void
    
    private var macros: (protein: Double, carbs: Double, fat: Double, calories: Double) {
        food.macros(servings: 1)
    }
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: DesignTokens.Spacing.small) {
                VStack(alignment: .leading, spacing: DesignTokens.Spacing.xxSmall) {
                    Text(food.foodName)
                        .font(DesignTokens.Typography.bodyEmphasized)
                        .foregroundStyle(DesignTokens.Colors.primary)
                        .lineLimit(2)
                    
                    Text(food.servingDescription)
                        .font(DesignTokens.Typography.caption1)
                        .foregroundStyle(DesignTokens.Colors.secondary)
                }
                
                Spacer()
                
                Text("+\(macros.protein, specifier: "%.1f")g P")
                    .font(DesignTokens.Typography.caption1.weight(.semibold))
                    .foregroundStyle(DesignTokens.Colors.protein)
                    .padding(.horizontal, DesignTokens.Spacing.xSmall)
                    .padding(.vertical, DesignTokens.Spacing.xxSmall + 2)
                    .background(DesignTokens.Colors.protein.opacity(DesignTokens.Opacity.light))
                    .clipShape(Capsule())
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    let container = try! ModelContainer(
        for: FoodItem.self, MealEntry.self, DailyLog.self, UserSettings.self,
        configurations: ModelConfiguration(isStoredInMemoryOnly: true)
    )
    let appState = AppState.shared
    let mealLogRepo = MealLogRepository(modelContext: container.mainContext)
    let foodRepo = FoodRepository(modelContext: container.mainContext)
    let interactor = MealLoggingInteractor(
        appState: appState,
        mealLogRepository: mealLogRepo,
        foodRepository: foodRepo
    )

    return TodayViewRefactored()
        .environment(appState)
        .environment(interactor)
        .modelContainer(container)
}
