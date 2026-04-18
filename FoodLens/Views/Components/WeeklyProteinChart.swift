// WeeklyProteinChart.swift
// FoodLens - Native UI Component
//
// Weekly protein tracking using native Charts framework (iOS 16+)

import SwiftUI
import Charts

struct WeeklyProteinChart: View {
    // MARK: - Properties
    
    let dailyLogs: [DailyLog]
    let target: Double
    
    // MARK: - Computed Properties
    
    private var chartData: [ChartDataPoint] {
        dailyLogs.map { log in
            ChartDataPoint(
                date: log.date,
                protein: log.totalProtein,
                label: shortDateLabel(for: log.date)
            )
        }
    }
    
    private var averageProtein: Double {
        guard !dailyLogs.isEmpty else { return 0 }
        return dailyLogs.map(\.totalProtein).reduce(0, +) / Double(dailyLogs.count)
    }
    
    private var maxProtein: Double {
        max(dailyLogs.map(\.totalProtein).max() ?? target, target) * 1.1
    }
    
    // MARK: - Body
    
    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 16) {
                HStack(alignment: .firstTextBaseline) {
                    Text("Average \(Int(averageProtein))g")
                        .font(.subheadline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)

                    Spacer()

                    Text("Target \(Int(target))g")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Chart {
                    ForEach(chartData) { dataPoint in
                        BarMark(
                            x: .value("Day", dataPoint.label),
                            y: .value("Protein", dataPoint.protein)
                        )
                        .foregroundStyle(barColor(for: dataPoint.protein))
                    }

                    RuleMark(y: .value("Target", target))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 2, dash: [5, 5]))
                }
                .frame(height: 200)
                .frame(maxWidth: .infinity)
                .chartYScale(domain: 0...maxProtein)
                .chartXAxis {
                    AxisMarks(values: .automatic) { _ in
                        AxisValueLabel()
                            .font(.caption2)
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let intValue = value.as(Int.self) {
                                Text("\(intValue)g")
                                    .font(.caption2)
                            }
                        }
                    }
                }

                ViewThatFits {
                    HStack(spacing: 12) {
                        LegendItem(color: .green, label: "Hit target")
                        LegendItem(color: .green.opacity(0.6), label: "Under target")
                        LegendItem(color: .orange, label: "Over target")
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        LegendItem(color: .green, label: "Hit target")
                        LegendItem(color: .green.opacity(0.6), label: "Under target")
                        LegendItem(color: .orange, label: "Over target")
                    }
                }
                .font(.caption)
            }
            .padding(16)
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("Weekly protein chart")
        .accessibilityValue("Average \(Int(averageProtein)) grams. Target \(Int(target)) grams.")
    }
    
    // MARK: - Helper Methods
    
    private func barColor(for protein: Double) -> Color {
        if protein >= target {
            return protein > target * 1.2 ? .orange : .green
        } else {
            return .green.opacity(0.6)
        }
    }
    
    private func shortDateLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE" // Mon, Tue, Wed
        return formatter.string(from: date)
    }
}

// MARK: - Chart Data Model

struct ChartDataPoint: Identifiable {
    let id = UUID()
    let date: Date
    let protein: Double
    let label: String
}

// MARK: - Legend Item

struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            RoundedRectangle(cornerRadius: 2)
                .fill(color)
                .frame(width: 12, height: 12)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Compact Variant (for smaller spaces)

struct WeeklyProteinChartCompact: View {
    let dailyLogs: [DailyLog]
    let target: Double
    
    private var chartData: [ChartDataPoint] {
        dailyLogs.map { log in
            ChartDataPoint(
                date: log.date,
                protein: log.totalProtein,
                label: String(Calendar.current.component(.day, from: log.date))
            )
        }
    }
    
    var body: some View {
        Chart {
            ForEach(chartData) { dataPoint in
                BarMark(
                    x: .value("Day", dataPoint.label),
                    y: .value("Protein", dataPoint.protein)
                )
                .foregroundStyle(.green.gradient)
            }
            
            RuleMark(y: .value("Target", target))
                .foregroundStyle(.green.opacity(0.5))
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
        }
        .frame(height: 100)
        .chartXAxis(.hidden)
        .chartYAxis(.hidden)
    }
}

// MARK: - Previews

#Preview("Full Chart") {
    WeeklyProteinChart(
        dailyLogs: DailyLog.samples(days: 7),
        target: 150
    )
    .padding()
}

#Preview("Compact Chart") {
    WeeklyProteinChartCompact(
        dailyLogs: DailyLog.samples(days: 7),
        target: 150
    )
    .padding()
}
