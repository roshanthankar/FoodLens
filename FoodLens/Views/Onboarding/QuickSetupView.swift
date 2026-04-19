import SwiftUI
import SwiftData

struct QuickSetupView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var protein: Double = 150
    @State private var carbs: Double = 200
    @State private var fat: Double = 60

    private var calories: Double {
        (protein * 4) + (carbs * 4) + (fat * 9)
    }

    var body: some View {
        Form {
            Section {
                Text("Enter your daily macro targets. You can always change these later in Settings.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0))

            Section("Daily Targets") {
                MacroRow(label: "Protein", value: $protein, range: 50...300, step: 5, tint: .green)
                MacroRow(label: "Carbs",   value: $carbs,   range: 50...500, step: 5, tint: .blue)
                MacroRow(label: "Fat",     value: $fat,     range: 20...150, step: 5, tint: .orange)
            }

            Section {
                LabeledContent("Total Calories") {
                    Text("\(Int(calories)) kcal")
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                }
            }

            Section {
                Button {
                    save()
                } label: {
                    Text("Start Tracking")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
            }
        }
        .navigationTitle("Set Your Targets")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func save() {
        guard let settings = appState.userSettings else { return }
        settings.proteinTarget = protein
        settings.carbsTarget = carbs
        settings.fatTarget = fat
        settings.onboardingPath = .quick
        settings.hasCompletedOnboarding = true
        try? modelContext.save()
        appState.userSettings = settings
        appState.routing = .today
    }
}

private struct MacroRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let tint: Color

    var body: some View {
        HStack {
            Text(label)
                .font(.body.weight(.medium))

            Spacer()

            Text("\(Int(value))g")
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(tint)
                .frame(minWidth: 52, alignment: .trailing)

            Stepper("", value: $value, in: range, step: step)
                .labelsHidden()
        }
    }
}

#Preview {
    NavigationStack {
        QuickSetupView()
    }
    .environment(AppState.shared)
}
