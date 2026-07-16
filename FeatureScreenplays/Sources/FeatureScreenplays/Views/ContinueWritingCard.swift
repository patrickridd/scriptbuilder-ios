import SwiftUI
import Domain
import DesignSystem

/// A wide "Continue Writing" card surfacing the most recently edited script so
/// the user can jump straight back in.
struct ContinueWritingCard: View {
    @Environment(\.appPalette) private var palette
    let screenplay: Screenplay
    let onTap: () -> Void

    var body: some View {
        Button {
            Haptics.selection()
            onTap()
        } label: {
            GlassCard {
                HStack(spacing: 14) {
                    CoverArtwork(title: screenplay.title)
                        .frame(width: 54, height: 70)
                        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                    text
                    Spacer(minLength: 0)
                    Image(systemName: "chevron.right")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(palette.textMuted)
                }
                .padding(14)
            }
        }
        .buttonStyle(.pressableCard)
    }

    private var text: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(L10n.Home.continueWriting)
                .font(.caption.weight(.semibold))
                .foregroundStyle(palette.accent)
                .textCase(.uppercase)
            Text(screenplay.title)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
                .lineLimit(1)
            if !screenplay.logLine.isEmpty {
                Text(screenplay.logLine)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(1)
            }
        }
    }
}
