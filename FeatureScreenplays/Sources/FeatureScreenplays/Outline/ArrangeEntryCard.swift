import SwiftUI
import DesignSystem

/// The hub's way into the Arrange screen: a slim card under the three acts,
/// with a "Custom order" badge once the writer has rearranged anything.
struct ArrangeEntryCard: View {
    @Environment(\.appPalette) private var palette
    let isCustomOrder: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.up.arrow.down")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(palette.accent)
                .frame(width: 36, height: 36)
                .background(palette.accent.opacity(0.12), in: Circle())
                .accessibilityHidden(true)
            VStack(alignment: .leading, spacing: 2) {
                Text(L10n.ArrangeCopy.openButton)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(L10n.ArrangeCopy.openCaption)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
            Spacer(minLength: 4)
            if isCustomOrder { badge }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted.opacity(0.6))
        }
        .padding(14)
        .background(palette.cardSurface, in: shape)
        .overlay(shape.stroke(palette.cardStroke, lineWidth: 1))
        .padding(.leading, 44)
    }

    private var shape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
    }

    private var badge: some View {
        Text(L10n.ArrangeCopy.customOrderBadge)
            .font(.caption2.weight(.semibold))
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(palette.accent.opacity(0.14), in: Capsule())
    }
}
