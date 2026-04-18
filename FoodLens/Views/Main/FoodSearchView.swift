import SwiftUI

struct FoodSearchView: View {
    @Environment(AppState.self) private var appState
    @Environment(FoodSearchInteractor.self) private var foodSearchInteractor

    @Binding var searchText: String
    let onSelectFood: (FoodItem) -> Void

    @State private var searchTask: Task<Void, Never>?

    private var trimmedSearchText: String {
        searchText.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    var body: some View {
        List {
            if trimmedSearchText.isEmpty {
                if !appState.favoriteFoods.isEmpty {
                    Section("Favorites") {
                        ForEach(appState.favoriteFoods) { food in
                            FoodSearchRow(
                                food: food,
                                isFavorite: true,
                                onSelect: { onSelectFood(food) },
                                onToggleFavorite: { toggleFavorite(food) }
                            )
                        }
                    }
                }

                if !appState.recentFoods.isEmpty {
                    Section("Recent") {
                        ForEach(appState.recentFoods) { food in
                            FoodSearchRow(
                                food: food,
                                isFavorite: appState.favoriteFoods.contains(where: { $0.id == food.id }),
                                onSelect: { onSelectFood(food) },
                                onToggleFavorite: { toggleFavorite(food) }
                            )
                        }
                    }
                }

                if appState.favoriteFoods.isEmpty && appState.recentFoods.isEmpty {
                    ContentUnavailableView(
                        "Search Foods",
                        systemImage: "magnifyingglass",
                        description: Text("Find a food to log your first meal.")
                    )
                    .listRowBackground(Color.clear)
                }
            } else {
                if foodSearchInteractor.isSearching {
                    Section {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    }
                } else if foodSearchInteractor.searchResults.isEmpty {
                    ContentUnavailableView.search(text: trimmedSearchText)
                        .listRowBackground(Color.clear)
                } else {
                    Section(foodSearchInteractor.resultSummary()) {
                        ForEach(foodSearchInteractor.searchResults) { food in
                            FoodSearchRow(
                                food: food,
                                isFavorite: appState.favoriteFoods.contains(where: { $0.id == food.id }),
                                onSelect: { onSelectFood(food) },
                                onToggleFavorite: { toggleFavorite(food) }
                            )
                        }
                    }
                }
            }
        }
        .listStyle(.insetGrouped)
        .searchable(
            text: $searchText,
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: "Search foods"
        )
        .navigationTitle("Log Meal")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            foodSearchInteractor.loadDefaults()
        }
        .onDisappear {
            searchTask?.cancel()
        }
        .onChange(of: searchText) { _, newValue in
            searchTask?.cancel()
            let query = newValue.trimmingCharacters(in: .whitespacesAndNewlines)

            searchTask = Task {
                try? await Task.sleep(for: .milliseconds(180))
                guard !Task.isCancelled else { return }
                await foodSearchInteractor.search(query: query)
            }
        }
    }

    private func toggleFavorite(_ food: FoodItem) {
        Task {
            await foodSearchInteractor.toggleFavorite(food)
            if trimmedSearchText.isEmpty {
                foodSearchInteractor.loadDefaults()
            } else {
                await foodSearchInteractor.search(query: trimmedSearchText)
            }
        }
    }
}

private struct FoodSearchRow: View {
    let food: FoodItem
    let isFavorite: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void

    private var servingMacros: (protein: Double, carbs: Double, fat: Double, calories: Double) {
        food.macros(servings: 1)
    }

    var body: some View {
        HStack(spacing: 12) {
            Button(action: onSelect) {
                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(food.foodName)
                            .font(.body.weight(.medium))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.leading)

                        Text("\(food.servingDescription) • \(Int(servingMacros.calories)) kcal")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        Text("\(servingMacros.protein, specifier: "%.1f")g protein")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.green)

                        Text(food.foodGroup)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                    }
                }
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .accessibilityLabel(food.foodName)
            .accessibilityValue("\(food.servingDescription), \(Int(servingMacros.calories)) calories, \(servingMacros.protein, specifier: "%.1f") grams protein")

            Button(action: onToggleFavorite) {
                Image(systemName: isFavorite ? "heart.fill" : "heart")
                    .foregroundStyle(isFavorite ? .pink : .secondary)
            }
            .buttonStyle(.borderless)
            .accessibilityLabel(isFavorite ? "Remove favorite" : "Add favorite")
        }
    }
}
