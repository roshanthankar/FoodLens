import SwiftUI

struct OnboardingWelcomeView: View {
    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // Icon
            Image(systemName: "fork.knife.circle.fill")
                .font(.system(size: 80))
                .foregroundStyle(.green)
                .padding(.bottom, 24)

            // Headline
            VStack(spacing: 8) {
                Text("FoodLens")
                    .font(.largeTitle.weight(.bold))

                Text("Track your macros,\nthe Indian way.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.bottom, 40)

            // Feature bullets
            VStack(alignment: .leading, spacing: 16) {
                FeatureBullet(icon: "leaf.fill",          color: .green,  text: "542 Indian foods from IFCT 2017")
                FeatureBullet(icon: "iphone",             color: .blue,   text: "Everything stays on your phone")
                FeatureBullet(icon: "bolt.fill",          color: .orange, text: "Log a meal in under 10 seconds")
            }
            .padding(.horizontal, 40)

            Spacer()

            // CTAs
            VStack(spacing: 12) {
                NavigationLink {
                    GuidedSetupView()
                } label: {
                    Text("Calculate my targets")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)

                NavigationLink {
                    QuickSetupView()
                } label: {
                    Text("I know my macros")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.primary)
                .controlSize(.large)
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 48)
        }
        .navigationBarHidden(true)
    }
}

private struct FeatureBullet: View {
    let icon: String
    let color: Color
    let text: String

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.body.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 24)

            Text(text)
                .font(.body)
                .foregroundStyle(.primary)
        }
    }
}

#Preview {
    NavigationStack {
        OnboardingWelcomeView()
    }
    .environment(AppState.shared)
}
