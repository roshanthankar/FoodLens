import SwiftUI

struct LogMealSheet: View {
    @Environment(MealLoggingInteractor.self) private var mealLoggingInteractor
    @Environment(\.dismiss) private var dismiss

    let onLogged: () -> Void

    @State private var searchText = ""
    @State private var selectedFood: FoodItem?
    @State private var servings: Double = 1
    @State private var mealType: MealType

    init(initialMealType: MealType, onLogged: @escaping () -> Void) {
        self.onLogged = onLogged
        _mealType = State(initialValue: initialMealType)
    }

    private var selectedFoodMacros: (protein: Double, carbs: Double, fat: Double, calories: Double)? {
        guard let selectedFood else { return nil }
        return selectedFood.macros(servings: servings)
    }

    var body: some View {
        NavigationStack {
            Group {
                if let selectedFood {
                    servingDetail(for: selectedFood)
                } else {
                    FoodSearchView(searchText: $searchText) { food in
                        selectedFood = food
                        servings = 1
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    if selectedFood != nil {
                        Button("Back") {
                            selectedFood = nil
                        }
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .safeAreaInset(edge: .bottom) {
                if let selectedFood {
                    logButton(for: selectedFood)
                }
            }
        }
        .presentationDetents([.large])
        .presentationDragIndicator(.visible)
    }

    @ViewBuilder
    private func servingDetail(for food: FoodItem) -> some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 6) {
                    Text(food.foodName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.primary)
                    Text(food.foodGroup)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text(food.servingDescription)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.vertical, 4)
            }

            Section("Serving") {
                Stepper(value: $servings, in: 0.5...20, step: 0.5) {
                    LabeledContent("Servings") {
                        Text(servingsText)
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                    }
                }

                LabeledContent("Total amount") {
                    Text("\(food.servingSizeGrams * servings, specifier: "%.0f") g")
                        .monospacedDigit()
                }
            }

            if let macros = selectedFoodMacros {
                Section("Macros") {
                    MacroDetailRow(label: "Protein", value: macros.protein, tint: .green)
                    MacroDetailRow(label: "Carbs", value: macros.carbs, tint: .blue)
                    MacroDetailRow(label: "Fat", value: macros.fat, tint: .orange)
                    LabeledContent("Calories") {
                        Text("\(Int(macros.calories)) kcal")
                            .font(.body.weight(.semibold))
                            .monospacedDigit()
                    }
                }
            }

            Section("Meal") {
                Picker("Meal Type", selection: $mealType) {
                    ForEach(MealType.allCases, id: \.self) { type in
                        Text(type.displayName).tag(type)
                    }
                }
                .pickerStyle(.menu)
            }
        }
        .listStyle(.insetGrouped)
        .navigationTitle("Adjust Meal")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func logButton(for food: FoodItem) -> some View {
        VStack(spacing: 0) {
            Divider()
            Button {
                Task {
                    await mealLoggingInteractor.logMeal(
                        food: food,
                        servings: servings,
                        mealType: mealType
                    )
                    onLogged()
                    dismiss()
                }
            } label: {
                if mealLoggingInteractor.isLogging {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                } else {
                    Text("Log \(servingsText) of \(food.foodName)")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .padding(.horizontal)
            .padding(.top, 12)
            .padding(.bottom, 8)
            .background(.bar)
        }
    }

    private var servingsText: String {
        servings.formatted(.number.precision(.fractionLength(servings == floor(servings) ? 0 : 1)))
    }
}

private struct MacroDetailRow: View {
    let label: String
    let value: Double
    let tint: Color

    var body: some View {
        LabeledContent(label) {
            Text("\(value, specifier: "%.1f") g")
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
    }
}
