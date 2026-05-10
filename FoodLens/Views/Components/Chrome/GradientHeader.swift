import SwiftUI

struct GradientHeader: View {
    let gradient: LinearGradient

    var body: some View {
        gradient
            .ignoresSafeArea()
    }
}

#Preview("Home") {
    GradientHeader(gradient: .homeHeader)
}

#Preview("Protein") {
    GradientHeader(gradient: .macroHeader(.protein))
}
