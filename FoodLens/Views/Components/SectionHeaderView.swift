// SectionHeaderView.swift
// FoodLens Design System - Reusable Component
//
// Section header with label, plus optional native iOS segmented control.

import SwiftUI

struct SectionHeaderSegment<Value: Hashable>: Identifiable {
    let id: Value
    let systemImage: String
    let accessibilityLabel: String

    init(id: Value, systemImage: String, accessibilityLabel: String) {
        self.id = id
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
    }
}

struct SectionHeaderView<Segment: Hashable>: View {
    let title: String

    private let segments: [SectionHeaderSegment<Segment>]
    private let selection: Binding<Segment>?

    // Variant 1: with segmented control
    init(
        title: String,
        segments: [SectionHeaderSegment<Segment>],
        selection: Binding<Segment>
    ) {
        self.title = title
        self.segments = segments
        self.selection = selection
    }

    var body: some View {
        HStack(spacing: DesignTokens.Spacing.small) {
            Text(title)
                .font(.momoSans(16, weight: .medium))
                .foregroundStyle(DesignTokens.Colors.secondary)

            Spacer(minLength: DesignTokens.Spacing.small)

            if let selection, !segments.isEmpty {
                Picker("", selection: selection) {
                    ForEach(segments) { segment in
                        Image(systemName: segment.systemImage)
                            .accessibilityLabel(segment.accessibilityLabel)
                            .tag(segment.id)
                    }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }
        }
    }
}

// Variant 2: no segmented control. `Segment == Never` is awkward to construct,
// so we provide this concrete overload.
extension SectionHeaderView where Segment == Int {
    init(title: String) {
        self.title = title
        self.segments = []
        self.selection = nil
    }
}

// MARK: - Preview

private enum PreviewTimeOfDay: Hashable {
    case morning, afternoon, night
}

#Preview {
    @Previewable @State var time: PreviewTimeOfDay = .morning

    VStack(spacing: 24) {
        SectionHeaderView(title: "Label")

        SectionHeaderView(
            title: "Label",
            segments: [
                .init(id: PreviewTimeOfDay.morning,   systemImage: "sun.horizon.fill", accessibilityLabel: "Morning"),
                .init(id: PreviewTimeOfDay.afternoon, systemImage: "sun.max.fill",     accessibilityLabel: "Afternoon"),
                .init(id: PreviewTimeOfDay.night,     systemImage: "moon.fill",        accessibilityLabel: "Night")
            ],
            selection: $time
        )
    }
    .padding(.horizontal, 20)
}
