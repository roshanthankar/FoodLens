import SwiftUI

struct ProfileView: View {
    @Environment(AppTheme.self) private var theme
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        @Bindable var theme = theme

        NavigationStack {
            Form {
                Section("Appearance") {
                    Picker("Theme", selection: $theme.appearance) {
                        ForEach(AppearancePreference.allCases) { pref in
                            Text(pref.label).tag(pref)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section("App Icon") {
                    HStack {
                        Image(systemName: "app.fill")
                            .foregroundStyle(.brandTeal)
                        Text("Default")
                            .font(.brandBody)
                        Spacer()
                        Text("Coming soon")
                            .font(.brandFootnote)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("About") {
                    LabeledContent("Food database", value: "IFCT + Indian dishes")
                    LabeledContent("Storage",       value: "On-device (SwiftData)")
                    LabeledContent("Version",       value: appVersion)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "—"
    }
}

#Preview {
    ProfileView()
        .environment(AppTheme())
}
