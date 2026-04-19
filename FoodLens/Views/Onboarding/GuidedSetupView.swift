import SwiftUI
import SwiftData

struct GuidedSetupView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    // Step
    @State private var step: Step = .profile
    @State private var saveError: String?

    // Profile inputs
    @State private var age: Int = 25
    @State private var gender: Gender = .male
    @State private var weightKg: Double = 70
    @State private var heightCm: Double = 170
    @State private var activityLevel: ActivityLevel = .moderatelyActive
    @State private var goal: FitnessGoal = .maintain

    // Confirmed targets (set on results step)
    @State private var confirmedProtein: Double = 0
    @State private var confirmedCarbs: Double = 0
    @State private var confirmedFat: Double = 0

    enum Step: Int, CaseIterable {
        case profile, body, activity, goal, results

        var title: String {
            switch self {
            case .profile:  return "About You"
            case .body:     return "Body Metrics"
            case .activity: return "Activity Level"
            case .goal:     return "Your Goal"
            case .results:  return "Your Targets"
            }
        }

        var next: Step? {
            Step(rawValue: rawValue + 1)
        }

        var previous: Step? {
            Step(rawValue: rawValue - 1)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            progressBar
                .padding(.horizontal)
                .padding(.top, 8)
                .padding(.bottom, 4)

            Form {
                switch step {
                case .profile:  profileSection
                case .body:     bodySection
                case .activity: activitySection
                case .goal:     goalSection
                case .results:  resultsSection
                }

                navigationButtons
            }
        }
        .navigationTitle(step.title)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(step == .profile ? false : true)
        .toolbar {
            if step != .profile, let _ = step.previous {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Back") { goBack() }
                }
            }
        }
        .animation(.easeInOut(duration: 0.2), value: step)
        .alert("Couldn't Save Settings", isPresented: Binding(
            get: { saveError != nil },
            set: { if !$0 { saveError = nil } }
        )) {
            Button("OK") { saveError = nil }
        } message: {
            Text(saveError ?? "")
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 4)

                Capsule()
                    .fill(Color.green)
                    .frame(width: geo.size.width * progress, height: 4)
                    .animation(.easeInOut, value: step)
            }
        }
        .frame(height: 4)
    }

    private var progress: Double {
        Double(step.rawValue + 1) / Double(Step.allCases.count)
    }

    // MARK: - Sections

    @ViewBuilder
    private var profileSection: some View {
        Section("Age") {
            Stepper("\(age) years old", value: $age, in: 13...100)
        }

        Section("Gender") {
            Picker("Gender", selection: $gender) {
                ForEach(Gender.allCases, id: \.self) { g in
                    Text(g.rawValue).tag(g)
                }
            }
            .pickerStyle(.segmented)
            .listRowBackground(Color.clear)
            .listRowInsets(EdgeInsets(top: 4, leading: 0, bottom: 4, trailing: 0))
        }
    }

    @ViewBuilder
    private var bodySection: some View {
        Section("Weight") {
            HStack {
                Text("Weight")
                Spacer()
                Text("\(weightKg, specifier: "%.1f") kg")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $weightKg, in: 30...200, step: 0.5)
                .tint(.green)
        }

        Section("Height") {
            HStack {
                Text("Height")
                Spacer()
                Text("\(Int(heightCm)) cm")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Slider(value: $heightCm, in: 100...220, step: 1)
                .tint(.green)
        }
    }

    @ViewBuilder
    private var activitySection: some View {
        Section {
            ForEach(ActivityLevel.allCases, id: \.self) { level in
                SelectionRow(
                    title: level.rawValue,
                    subtitle: activityDescription(level),
                    isSelected: activityLevel == level
                ) {
                    activityLevel = level
                }
            }
        }
    }

    @ViewBuilder
    private var goalSection: some View {
        Section {
            ForEach(FitnessGoal.allCases, id: \.self) { g in
                SelectionRow(
                    title: g.rawValue,
                    subtitle: goalDescription(g),
                    isSelected: goal == g
                ) {
                    goal = g
                }
            }
        }
    }

    @ViewBuilder
    private var resultsSection: some View {
        Section {
            Text("Based on your profile, here are your suggested daily targets.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .listRowBackground(Color.clear)

        Section("Suggested Targets") {
            ResultRow(label: "Protein", value: confirmedProtein, tint: .green)
            ResultRow(label: "Carbs",   value: confirmedCarbs,   tint: .blue)
            ResultRow(label: "Fat",     value: confirmedFat,     tint: .orange)

            LabeledContent("Calories") {
                Text("\(Int((confirmedProtein * 4) + (confirmedCarbs * 4) + (confirmedFat * 9))) kcal")
                    .font(.body.weight(.semibold))
                    .monospacedDigit()
            }
        }

        Section("Based on") {
            LabeledContent("Goal",     value: goal.rawValue)
            LabeledContent("Activity", value: activityLevel.rawValue)
        }
    }

    // MARK: - Navigation Buttons

    @ViewBuilder
    private var navigationButtons: some View {
        Section {
            if step == .results {
                Button {
                    completeOnboarding()
                } label: {
                    Text("Start Tracking")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            } else {
                Button {
                    goForward()
                } label: {
                    Text("Next")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
            }
        }
        .listRowBackground(Color.clear)
        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 0, trailing: 0))
    }

    // MARK: - Navigation Logic

    private func goForward() {
        guard let next = step.next else { return }
        if next == .results { calculateTargets() }
        step = next
    }

    private func goBack() {
        guard let previous = step.previous else { return }
        step = previous
    }

    // MARK: - Target Calculation

    private func calculateTargets() {
        // Build a temporary settings object to use its TDEE calculation
        let temp = UserSettings(
            age: age,
            weightKg: weightKg,
            heightCm: heightCm,
            gender: gender,
            activityLevel: activityLevel,
            goal: goal
        )

        let calories = temp.calculateSuggestedCalories() ?? 2000

        // Standard macro split:
        // Protein: 1.8g per kg bodyweight
        // Fat: 25% of total calories
        // Carbs: remainder
        let protein = (1.8 * weightKg).rounded()
        let fat = ((calories * 0.25) / 9).rounded()
        let carbs = max(((calories - (protein * 4) - (fat * 9)) / 4).rounded(), 50)

        confirmedProtein = protein
        confirmedCarbs = carbs
        confirmedFat = fat
    }

    // MARK: - Save

    private func completeOnboarding() {
        guard let settings = appState.userSettings else { return }

        settings.age = age
        settings.gender = gender
        settings.weightKg = weightKg
        settings.heightCm = heightCm
        settings.activityLevel = activityLevel
        settings.goal = goal
        settings.proteinTarget = confirmedProtein
        settings.carbsTarget = confirmedCarbs
        settings.fatTarget = confirmedFat
        settings.onboardingPath = .guided
        settings.hasCompletedOnboarding = true

        do {
            try modelContext.save()
            appState.userSettings = settings
            appState.routing = .today
        } catch {
            saveError = error.localizedDescription
        }
    }

    // MARK: - Helpers

    private func activityDescription(_ level: ActivityLevel) -> String {
        switch level {
        case .sedentary:        return "Desk job, little or no exercise"
        case .lightlyActive:    return "Light exercise 1–3 days/week"
        case .moderatelyActive: return "Moderate exercise 3–5 days/week"
        case .veryActive:       return "Hard exercise 6–7 days/week"
        case .extremelyActive:  return "Physical job or twice-a-day training"
        }
    }

    private func goalDescription(_ g: FitnessGoal) -> String {
        switch g {
        case .lose:     return "Calorie deficit — burn more than you eat"
        case .maintain: return "Calorie balance — eat what you burn"
        case .gain:     return "Calorie surplus — fuel muscle growth"
        }
    }
}

// MARK: - Supporting Views

private struct SelectionRow: View {
    let title: String
    let subtitle: String
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body.weight(.medium))
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                }
            }
            .padding(.vertical, 4)
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}

private struct ResultRow: View {
    let label: String
    let value: Double
    let tint: Color

    var body: some View {
        LabeledContent(label) {
            Text("\(Int(value))g")
                .font(.body.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(tint)
        }
    }
}

#Preview {
    NavigationStack {
        GuidedSetupView()
    }
    .environment(AppState.shared)
}
