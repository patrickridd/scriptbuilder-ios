import SwiftUI
import Domain
import DesignSystem

/// A single screenplay tile in the grid: gradient cover, title, scene count,
/// and an optional lock badge when the item is restricted (IAP gated).
struct ScreenplayCard: View {
    @Environment(\.appPalette) private var palette
    let screenplay: Screenplay
    let isRestricted: Bool
    /// Optional namespace used to drive the iOS 18 "zoom" navigation
    /// transition so this card's cover expands into the editor.
    var transitionNamespace: Namespace.ID? = nil
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            onTap()
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                cover
                info
            }
        }
        .buttonStyle(.pressableCard)
    }

    private var cover: some View {
        CoverArtwork(title: screenplay.title)
            .aspectRatio(8.5 / 11.0, contentMode: .fit)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous))
            .overlay(alignment: .bottomTrailing) { lockBadge }
            .screenplayZoomSource(id: screenplay.id, in: transitionNamespace)
    }

    @ViewBuilder
    private var lockBadge: some View {
        if isRestricted {
            Image(systemName: "lock.fill")
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
                .padding(7)
                .background(.black.opacity(0.35), in: Circle())
                .padding(8)
        }
    }

    private var info: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(screenplay.title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
            Text(sceneSummary)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
                .lineLimit(1)
        }
        .padding(.horizontal, 2)
    }

    private var sceneSummary: String {
        let count = screenplay.allScenes.count
        return count == 1 ? "1 scene" : "\(count) scenes"
    }
}
