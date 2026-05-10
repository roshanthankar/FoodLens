import SwiftUI

struct TopNavigationBar: View {
    @Binding var selectedDate: Date
    var onProfileTap: () -> Void

    @State private var showingDatePicker = false

    var body: some View {
        HStack(alignment: .center, spacing: DesignTokens.Spacing.medium) {
            DateChip(title: chipTitle) {
                showingDatePicker = true
            }

            Spacer()

            Button(action: onProfileTap) {
                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(DesignTokens.Colors.primary)
                    .frame(width: 44, height: 44)
            }
            .buttonStyle(.plain)
            .glassEffect(.regular.interactive(), in: Circle())
            .accessibilityLabel("Profile")
        }
        .padding(.horizontal, 16)
        .padding(.top, 4)
        .padding(.bottom, 4)
        .sheet(isPresented: $showingDatePicker) {
            DatePickerSheet(title: "Select Date", selection: $selectedDate)
        }
    }

    private var chipTitle: String {
        let calendar = Calendar.current
        let dayMonth = selectedDate.formatted(.dateTime.day().month(.abbreviated))
        if calendar.isDateInToday(selectedDate) {
            return "Today, \(dayMonth)"
        } else if calendar.isDateInYesterday(selectedDate) {
            return "Yesterday, \(dayMonth)"
        } else if calendar.isDateInTomorrow(selectedDate) {
            return "Tomorrow, \(dayMonth)"
        } else {
            return dayMonth
        }
    }
}

#Preview {
    @Previewable @State var date = Date()

    VStack(spacing: 24) {
        TopNavigationBar(
            selectedDate: $date,
            onProfileTap: {}
        )
        Spacer()
    }
    .padding(.top)
    .background(Color.surfaceBackground)
}
