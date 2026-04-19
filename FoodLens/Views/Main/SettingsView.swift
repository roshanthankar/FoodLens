import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(AppState.self) private var appState
    @Environment(SettingsInteractor.self) private var settingsInteractor
    @Environment(\.modelContext) private var modelContext
    @Query private var settings: [UserSettings]

    private var userSettings: UserSettings? { settings.first }

    var body: some View {
        NavigationStack {
            Group {
                if let userSettings {
                    Form {
                        Section("Daily Targets") {
                            LabeledContent("Calories") {
                                Text("\(Int(userSettings.calorieTarget)) kcal")
                                    .font(.headline.weight(.semibold))
                                    .monospacedDigit()
                            }

                            MacroTargetControl(
                                title: "Protein",
                                value: binding(for: \.proteinTarget, defaultValue: 150),
                                range: 50...250,
                                step: 5,
                                tint: .green
                            )

                            MacroTargetControl(
                                title: "Carbs",
                                value: binding(for: \.carbsTarget, defaultValue: 200),
                                range: 50...400,
                                step: 5,
                                tint: .blue
                            )

                            MacroTargetControl(
                                title: "Fat",
                                value: binding(for: \.fatTarget, defaultValue: 60),
                                range: 20...120,
                                step: 5,
                                tint: .orange
                            )
                        }

                        Section("Quick Presets") {
                            ForEach(SettingsPreset.allCases, id: \.self) { preset in
                                HStack(alignment: .top) {
                                    VStack(alignment: .leading, spacing: 2) {
                                        Text(preset.title)
                                            .font(.body.weight(.medium))
                                            .foregroundStyle(.primary)
                                        Text(preset.subtitle)
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    Button("Apply") {
                                        applyPreset(preset.targets)
                                    }
                                    .buttonStyle(.bordered)
                                    .tint(.primary)
                                }
                                .padding(.vertical, 2)
                            }
                        }

                        Section("Preferences") {
                            Picker("Display Unit", selection: binding(for: \.displayUnit, defaultValue: .grams)) {
                                ForEach(DisplayUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue).tag(unit)
                                }
                            }

                            Toggle("Show Fiber", isOn: binding(for: \.showFiber, defaultValue: false))
                            Toggle("Enable Haptics", isOn: binding(for: \.enableHaptics, defaultValue: true))
                        }

                        Section("About") {
                            LabeledContent("Food database", value: "IFCT + Indian dishes")
                            LabeledContent("Storage", value: "On-device")
                        }
                    }
                } else {
                    ContentUnavailableView(
                        "Settings Unavailable",
                        systemImage: "gearshape",
                        description: Text("The app is still preparing your preferences.")
                    )
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func binding<Value>(
        for keyPath: ReferenceWritableKeyPath<UserSettings, Value>,
        defaultValue: Value
    ) -> Binding<Value> {
        Binding(
            get: { userSettings?[keyPath: keyPath] ?? defaultValue },
            set: { newValue in
                userSettings?[keyPath: keyPath] = newValue
                save()
            }
        )
    }

    private func applyPreset(_ targets: MacroTargets) {
        settingsInteractor.applyPreset(targets)
    }

    private func save() {
        guard let s = userSettings else { return }
        settingsInteractor.updateMacroTargets(
            protein: s.proteinTarget,
            carbs: s.carbsTarget,
            fat: s.fatTarget
        )
    }
}

private struct MacroTargetControl: View {
    let title: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let tint: Color

    @State private var draftValue = ""
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center) {
                Text(title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(.primary)

                Spacer()

                TextField("Value", text: $draftValue)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 64)
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(tint)
                    .focused($isFocused)
                    .onSubmit(commitDraftValue)
                    .onChange(of: isFocused) { _, focused in
                        if !focused { commitDraftValue() }
                    }

                Text("g")
                    .font(.body)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Stepper {
                    EmptyView()
                } onIncrement: {
                    updateValue(value + step)
                } onDecrement: {
                    updateValue(value - step)
                }
                .labelsHidden()

                Text("Use stepper or enter a custom value")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Spacer()
            }
        }
        .padding(.vertical, 4)
        .onAppear {
            draftValue = String(Int(value))
        }
        .onChange(of: value) { _, newValue in
            let rendered = String(Int(newValue))
            if draftValue != rendered {
                draftValue = rendered
            }
        }
    }

    private func updateValue(_ newValue: Double) {
        value = min(max(newValue, range.lowerBound), range.upperBound)
    }

    private func commitDraftValue() {
        guard let parsed = Double(draftValue.filter(\.isNumber)) else {
            draftValue = String(Int(value))
            return
        }

        updateValue(parsed)
        draftValue = String(Int(value))
    }
}

private enum SettingsPreset: CaseIterable {
    case fatLoss
    case maintenance
    case muscleGain

    var title: String {
        switch self {
        case .fatLoss: return "Fat Loss"
        case .maintenance: return "Maintenance"
        case .muscleGain: return "Muscle Gain"
        }
    }

    var subtitle: String {
        let targets = targets
        return "P \(Int(targets.protein)) • C \(Int(targets.carbs)) • F \(Int(targets.fat))"
    }

    var targets: MacroTargets {
        switch self {
        case .fatLoss: return .fatLoss
        case .maintenance: return .maintenance
        case .muscleGain: return .muscleGain
        }
    }
}
