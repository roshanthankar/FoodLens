import SwiftUI

struct ProfileButton: View {
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(.surfaceCard)
                    .shadow(color: .black.opacity(0.08), radius: 6, x: 0, y: 2)

                Image(systemName: "person.fill")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(.primary)
            }
            .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("Profile")
    }
}

#Preview {
    ProfileButton {}
        .padding()
        .background(Color.headerHomeTop)
}
