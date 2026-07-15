import SwiftUI
import DesignSystem

/// A single toggle that turns tactile feedback on or off for the whole app.
/// The preference is stored globally by `Haptics`, so flipping it here silences
/// every haptic across every feature. When switched back on we fire a short
/// selection tick so the user immediately feels it working again.
struct HapticsCard: View {
    @Environment(\.appPalette) private var palette
    @State private var isEnabled: Bool = Haptics.isEnabled

    var body: some View {
        ProfileCard(title: L10n.Card.haptics) {
            ProfileRow(icon: "hand.tap.fill", title: L10n.Card.haptics) {
                Toggle("", isOn: $isEnabled)
                    .labelsHidden()
                    .tint(palette.brandPrimary)
            }
        }
        .onChange(of: isEnabled) { _, newValue in
            Haptics.isEnabled = newValue
            if newValue { Haptics.selection() }
        }
    }
}
