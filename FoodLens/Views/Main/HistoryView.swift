import SwiftUI
import SwiftData

struct HistoryView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext

    @State private var summaries: [HistoryDaySummary] = []
    @State private var isLoading = false
    @State private var hasLoaded = false

    private var macroTargets: MacroTargets {
        guard let settings = appState.userSettings else { return .default }
        return MacroTargets(
            protein: settings.proteinTarget,
            carbs: settings.carbsTarget,
            fat: settings.fatTarget
        )
    }

    private var averages: (protein: Double, carbs: Double, fat: Double) {
        guard !summaries.isEmpty else { return (0, 0, 0) }
        let n = Double(summaries.count)
        return (
            summaries.reduce(0) { $0 + $1.protein } / n,
            summaries.reduce(0) { $0 + $1.carbs }   / n,
            summaries.reduce(0) { $0 + $1.fat }     / n
        )
    }

    private var chartLogs: [DailyLog] {
        summaries.map {
            DailyLog(
                date: $0.date,
                totalProtein: $0.protein,
                totalCarbs: $0.carbs,
                totalFat: $0.fat,
                totalCalories: $0.calories,
                mealCount: $0.entryCount
            )
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading && summaries.isEmpty {
                    ProgressView("Loading history…")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section {
                            ViewThatFits {
                                HStack(alignment: .top, spacing: 24) {
                                    HistoryMetricText(title: "Avg Protein", value: "\(Int(averages.protein))g", tint: .green)
                                    HistoryMetricText(title: "Avg Carbs",   value: "\(Int(averages.carbs))g",   tint: .blue)
                                    HistoryMetricText(title: "Avg Fat",     value: "\(Int(averages.fat))g",     tint: .orange)
                                    Spacer(minLength: 0)
                                }

                                VStack(alignment: .leading, spacing: 12) {
                                    HistoryMetricText(title: "Avg Protein", value: "\(Int(averages.protein))g", tint: .green)
                                    HistoryMetricText(title: "Avg Carbs",   value: "\(Int(averages.carbs))g",   tint: .blue)
                                    HistoryMetricText(title: "Avg Fat",     value: "\(Int(averages.fat))g",     tint: .orange)
                                }
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color.clear)

                        Section("Protein Trend") {
                            WeeklyProteinChart(
                                dailyLogs: chartLogs,
                                target: macroTargets.protein
                            )
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)

                        Section("Daily Breakdown") {
                            if summaries.isEmpty {
                                ContentUnavailableView(
                                    "No History Yet",
                                    systemImage: "chart.bar.xaxis",
                                    description: Text("Logged meals will show up here over time.")
                                )
                            } else {
                                ForEach(summaries.reversed()) { summary in
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(summary.title)
                                                    .font(.headline)
                                                    .foregroundStyle(.primary)
                                                Text("\(summary.entryCount) meal\(summary.entryCount == 1 ? "" : "s")")
                                                    .font(.subheadline)
                                                    .foregroundStyle(.secondary)
                                            }

                                            Spacer()

                                            Text("\(Int(summary.calories)) kcal")
                                                .font(.subheadline.weight(.semibold))
                                                .foregroundStyle(.secondary)
                                                .monospacedDigit()
                                        }

                                        HStack(spacing: 8) {
                                            HistoryMacroPill(label: "P", value: summary.protein, tint: .green)
                                            HistoryMacroPill(label: "C", value: summary.carbs,   tint: .blue)
                                            HistoryMacroPill(label: "F", value: summary.fat,     tint: .orange)
                                        }
                                    }
                                    .padding(.vertical, 4)
                                    .accessibilityElement(children: .ignore)
                                    .accessibilityLabel(summary.title)
                                    .accessibilityValue("\(summary.entryCount) meals, \(Int(summary.calories)) kcal, \(Int(summary.protein))g protein, \(Int(summary.carbs))g carbs, \(Int(summary.fat))g fat")
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                    .refreshable { await loadHistory(force: true) }
                }
            }
            .navigationTitle("History")
            .task { await loadHistory() }
        }
    }

    private func loadHistory(force: Bool = false) async {
        guard !isLoading else { return }
        guard force || !hasLoaded else { return }

        isLoading = true
        defer { isLoading = false }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: today) else { return }

        let descriptor = FetchDescriptor<MealEntry>(
            predicate: #Predicate { meal in meal.timestamp >= startDate },
            sortBy: [SortDescriptor(\.timestamp)]
        )

        do {
            let meals = try modelContext.fetch(descriptor)
            let groupedMeals = Dictionary(grouping: meals) { meal in
                calendar.startOfDay(for: meal.timestamp)
            }

            summaries = (0..<7).compactMap { offset in
                guard let date = calendar.date(byAdding: .day, value: offset, to: startDate) else { return nil }
                let entries = groupedMeals[date] ?? []
                return HistoryDaySummary(
                    date: date,
                    protein: entries.reduce(0) { $0 + $1.proteinGrams },
                    carbs:   entries.reduce(0) { $0 + $1.carbsGrams },
                    fat:     entries.reduce(0) { $0 + $1.fatGrams },
                    calories: entries.reduce(0) { $0 + $1.calories },
                    entryCount: entries.count
                )
            }
            hasLoaded = true
        } catch {
            appState.setError(.databaseError(error.localizedDescription))
        }
    }
}

// MARK: - Supporting types

private struct HistoryDaySummary: Identifiable {
    let date: Date
    let protein: Double
    let carbs: Double
    let fat: Double
    let calories: Double
    let entryCount: Int

    var id: Date { date }

    var title: String {
        if Calendar.current.isDateInToday(date)     { return "Today" }
        if Calendar.current.isDateInYesterday(date) { return "Yesterday" }
        return date.formatted(.dateTime.weekday(.wide))
    }
}

private struct HistoryMetricText: View {
    let title: String
    let value: String
    let tint: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title2.weight(.semibold))
                .foregroundStyle(tint)
                .monospacedDigit()
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(title)
        .accessibilityValue(value)
    }
}

private struct HistoryMacroPill: View {
    let label: String
    let value: Double
    let tint: Color

    var body: some View {
        Text("\(label) \(Int(value))g")
            .font(.caption.weight(.semibold))
            .foregroundStyle(tint)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(tint.opacity(0.12))
            .clipShape(Capsule())
    }
}
