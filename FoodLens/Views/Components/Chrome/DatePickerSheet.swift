import SwiftUI

/// Native iOS bottom-sheet date picker.
/// Uses `DatePicker(.graphical)` — system calendar grid, month-stepper arrows,
/// tint-colored selection.
struct DatePickerSheet: View {
    let title: String
    @Binding var selection: Date
    var range: ClosedRange<Date>? = nil

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                datePicker
                    .padding(.horizontal, 8)
                    .padding(.top, 4)

                Spacer(minLength: 0)

                HStack {
                    Button {
                        selection = Date()
                        dismiss()
                    } label: {
                        Text("Today")
                            .font(.momoSans(17, weight: .semibold))
                            .foregroundStyle(.brandTeal)
                    }
                    .accessibilityLabel("Jump to today")

                    Spacer()
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
            .frame(maxHeight: .infinity, alignment: .top)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundStyle(DesignTokens.Colors.primary)
                    }
                    .tint(DesignTokens.Colors.primary)
                    .accessibilityLabel("Close")
                }
            }
        }
        .presentationDetents([.fraction(0.6)])
        .presentationDragIndicator(.visible)
        .presentationCornerRadius(28)
        .presentationBackground(.regularMaterial)
    }

    @ViewBuilder
    private var datePicker: some View {
        Group {
            if let range {
                DatePicker("", selection: $selection, in: range, displayedComponents: .date)
            } else {
                DatePicker("", selection: $selection, displayedComponents: .date)
            }
        }
        .datePickerStyle(.graphical)
        .labelsHidden()
        .tint(.brandTeal)
        .environment(\.font, .momoSans(17))
    }
}

#Preview {
    @Previewable @State var date = Date()

    Color.gray.opacity(0.2)
        .ignoresSafeArea()
        .sheet(isPresented: .constant(true)) {
            DatePickerSheet(title: "Select Date", selection: $date)
        }
}
