import SwiftUI
import DesignSystem

/// Interface-style picker (System / Light / Dark). Reports changes upward via
/// the configuration closure so the app persists and applies them.
struct AppearanceCard: View {
    @Environment(\.appPalette) private var palette
    @Binding var selection: ProfileInterfaceStyle
    let onChange: (ProfileInterfaceStyle) -> Void

    var body: some View {
        ProfileCard(title: L10n.Card.appearance) {
            VStack(spacing: 12) {
                Picker(L10n.Field.theme, selection: $selection) {
                    ForEach(ProfileInterfaceStyle.allCases) { style in
                        Label(style.title, systemImage: style.symbolName)
                            .tag(style)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: selection) { _, newValue in
                    Haptics.selection()
                    onChange(newValue)
                }
            }
            .padding(16)
        }
    }
}
