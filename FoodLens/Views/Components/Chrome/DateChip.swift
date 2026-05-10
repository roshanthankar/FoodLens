import SwiftUI

struct DateChip: View {
    let title: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: DesignTokens.Spacing.xSmall) {
                Text(title)
                    .font(.momoSans(22, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.primary)

                Image(systemName: "chevron.down")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.secondary)
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityHint("Opens date picker")
    }
}

#Preview {
    DateChip(title: "Today, 29 Apr") {}
        .padding()
}
