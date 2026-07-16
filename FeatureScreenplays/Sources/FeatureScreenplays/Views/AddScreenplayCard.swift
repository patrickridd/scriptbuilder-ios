import SwiftUI
import DesignSystem

/// A modern "+" tile replacing the legacy magic index-0 add cell. Matches the
/// card grid's footprint and invites a new draft.
struct AddScreenplayCard: View {
    @Environment(\.appPalette) private var palette
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 8) {
                tile
                info
            }
        }
        .buttonStyle(.pressableCard)
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(L10n.Home.newScript)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
            Text(L10n.Home.startFreshDraft)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }

    private var tile: some View {
        RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous)
            .fill(palette.cardSurface)
            .overlay(
                RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous)
                    .strokeBorder(palette.brandPrimary.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [6, 5]))
            )
            .overlay {
                ScriptBinding(showTextLines: false)
                    .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous))
            }
            .overlay {
                Image(systemName: "plus")
                    .font(.system(size: 30, weight: .semibold))
                    .foregroundStyle(palette.brandPrimary)
                    .padding(.leading, 14)
            }
            .aspectRatio(8.5 / 11.0, contentMode: .fit)
    }
}
