import SwiftUI
import DesignSystem

/// Solid accent capsule used as the call-to-action in empty / no-results
/// states across the editor. Replaces the older dashed "new item" cards: the
/// list itself stays clean, and "add" is always the same blue button.
///
/// When `isLocked` the button keeps its full gradient (it stays tappable and
/// opens the paywall) and swaps its glyph for a lock.
struct AddPillButton: View {
    @Environment(\.appPalette) private var palette

    let title: String
    var isLocked: Bool = false
    var accessibilityHintText: String = ""
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: isLocked ? "lock.fill" : "plus")
                    .font(.subheadline.weight(.bold))
                Text(title)
                    .font(.subheadline.weight(.semibold))
                    .lineLimit(1)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, 22)
            .frame(height: 48)
            .background(palette.primaryButtonGradient, in: Capsule())
            .shadow(color: palette.accent.opacity(0.35), radius: 10, y: 5)
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityHint(accessibilityHintText)
    }
}

#if DEBUG
#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: 16) {
            AddPillButton(title: "New Character") {}
            AddPillButton(title: "New Scene", isLocked: true) {}
        }
    }
}
#endif
