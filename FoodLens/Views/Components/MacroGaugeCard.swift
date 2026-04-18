// MacroGaugeCard.swift
// FoodLens - Native UI Component
//
// Macro display using native Gauge API (iOS 16+)

import SwiftUI

struct MacroGaugeCard: View {
    let label: String
    let value: Double
    let target: Double
    let color: Color
    let unit: String

    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(value / target, 1.0)
    }

    private var isOverTarget: Bool {
        value > target
    }

    private var statusColor: Color {
        if isOverTarget {
            return .orange
        } else if progress >= 0.9 {
            return color
        } else {
            return color.opacity(0.6)
        }
    }

    init(
        label: String,
        value: Double,
        target: Double,
        color: Color,
        unit: String = "g"
    ) {
        self.label = label
        self.value = value
        self.target = target
        self.color = color
        self.unit = unit
    }

    var body: some View {
        GroupBox {
            VStack(alignment: .leading, spacing: 12) {
                HStack(alignment: .firstTextBaseline) {
                    Text(label)
                        .font(.headline)
                        .foregroundStyle(.primary)

                    Spacer(minLength: 12)

                    Text("\(Int(value))/\(Int(target))\(unit)")
                        .font(.headline.weight(.semibold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                }

                ProgressView(value: progress)
                    .progressViewStyle(.linear)
                    .tint(statusColor)
                    .accessibilityHidden(true)

                if isOverTarget {
                    Label("Over target", systemImage: "exclamationmark.triangle.fill")
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if progress >= 0.9 {
                    Label("Almost there!", systemImage: "checkmark.circle.fill")
                        .font(.caption)
                        .foregroundStyle(color)
                }
            }
            .padding(.vertical, 4)
        }
        .backgroundStyle(Color(uiColor: .secondarySystemGroupedBackground))
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(label)
        .accessibilityValue("\(Int(value)) of \(Int(target)) \(unit)")
    }
}

// MARK: - Circular Gauge Variant

struct MacroGaugeCircular: View {
    let label: String
    let value: Double
    let target: Double
    let color: Color
    
    private var progress: Double {
        guard target > 0 else { return 0 }
        return min(value / target, 1.0)
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Circular Gauge
            Gauge(value: progress) {
                Text(label)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(color)
            .scaleEffect(1.5)
            
            // Label
            Text(label)
                .font(.caption)
                .fontWeight(.medium)
            
            // Values
            Text("\(Int(value))/\(Int(target))g")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(color.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Previews

#Preview("Linear Gauge") {
    VStack(spacing: 16) {
        MacroGaugeCard(
            label: "Protein",
            value: 145,
            target: 150,
            color: .green
        )
        
        MacroGaugeCard(
            label: "Carbs",
            value: 180,
            target: 200,
            color: .blue
        )
        
        MacroGaugeCard(
            label: "Fat",
            value: 65,
            target: 60,
            color: .orange
        )
    }
    .padding()
}

#Preview("Circular Gauges") {
    HStack(spacing: 12) {
        MacroGaugeCircular(
            label: "Protein",
            value: 145,
            target: 150,
            color: .green
        )
        
        MacroGaugeCircular(
            label: "Carbs",
            value: 180,
            target: 200,
            color: .blue
        )
        
        MacroGaugeCircular(
            label: "Fat",
            value: 65,
            target: 60,
            color: .orange
        )
    }
    .padding()
}
