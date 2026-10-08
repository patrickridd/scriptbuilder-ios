import SwiftUI
import DesignSystem

/// Dashed "New Scene" card used as the placeholder for an act that has no
/// scenes yet. It is the row-shaped twin of the screenplay library's add tile:
/// dashed accent border, gradient "+" tile, title + caption naming the act.
///
/// When `isLocked` the card keeps its full colour (it stays tappable and opens
/// the paywall) and shows a small "PRO" capsule instead of being greyed out.
struct AddSceneCard: View {
    @Environment(\.appPalette) private var palette

    var title: String = L10n.SceneUI.newScene
    let caption: String
    var isLocked: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 14) {
                plusTile
                textStack
                Spacer(minLength: 0)
                if isLocked { proCapsule }
            }
            .padding(.horizontal, 14)
            .frame(height: 72)
            .frame(maxWidth: .infinity)
            .background(cardBackground)
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityLabel(isLocked ? L10n.Action.withPro(title) : title)
        .accessibilityHint(caption)
    }

    private var plusTile: some View {
        Image(systemName: "plus")
            .font(.title3.weight(.bold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background(
                palette.primaryButtonGradient,
                in: RoundedRectangle(cornerRadius: 14, style: .continuous)
            )
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Text(caption)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
        }
    }

    private var proCapsule: some View {
        Text(L10n.Action.pro)
            .font(.caption2.weight(.black))
            .foregroundStyle(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(palette.accent, in: Capsule())
            .accessibilityHidden(true)
    }

    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(palette.cardSurface.opacity(0.45))
            .overlay(
                RoundedRectangle(cornerRadius: 18, style: .continuous)
                    .strokeBorder(
                        palette.accent.opacity(0.55),
                        style: StrokeStyle(lineWidth: 1.5, dash: [7, 5])
                    )
            )
    }
}

#if DEBUG
#Preview {
    ZStack {
        AppBackground()
        VStack(spacing: 16) {
            AddSceneCard(caption: "Add to Act II") {}
            AddSceneCard(caption: "Add to Act III", isLocked: true) {}
        }
        .padding()
    }
}
#endif
