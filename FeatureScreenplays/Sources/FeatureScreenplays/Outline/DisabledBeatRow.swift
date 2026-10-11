import SwiftUI
import DesignSystem

/// A switched-off template beat: a faded, single-line card that keeps the
/// beat's place in the outline and offers one way back — "Enable". The
/// writing inside is kept, so enabling restores it untouched.
struct DisabledBeatRow: View {
    @Environment(\.appPalette) private var palette

    let title: String
    var caption: String = L10n.CustomBeatCopy.disabledCaption
    let onEnable: () -> Void

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "eye.slash")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .accessibilityHidden(true)
            labels
            Spacer(minLength: 8)
            enableButton
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(cardShape.fill(palette.cardSurface.opacity(0.5)))
        .overlay(dashedStroke)
        .accessibilityElement(children: .combine)
    }

    private var labels: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .strikethrough(true, color: palette.textMuted.opacity(0.6))
            Text(caption)
                .font(.caption2)
                .foregroundStyle(palette.textMuted.opacity(0.85))
        }
    }

    private var enableButton: some View {
        Button(action: onEnable) {
            Text(L10n.CustomBeatCopy.enable)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.accent)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Capsule().fill(palette.accent.opacity(0.12)))
        }
        .buttonStyle(.plain)
        .accessibilityLabel(L10n.CustomBeatCopy.enableLabel(title))
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 14, style: .continuous)
    }

    private var dashedStroke: some View {
        cardShape.strokeBorder(
            palette.cardStroke,
            style: StrokeStyle(lineWidth: 1, dash: [6, 4])
        )
    }
}
