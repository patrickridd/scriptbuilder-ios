import SwiftUI
import DesignSystem

/// A generated gradient "cover" for a screenplay — deterministic from its
/// title, so the same script always renders the same artwork. Replaces the
/// flat grey tiles of the legacy collection view.
struct CoverArtwork: View {
    @Environment(\.appPalette) private var palette
    let title: String
    /// When `false`, the initials monogram is hidden — used where the full
    /// screenplay title is drawn on top of the artwork instead.
    var showsTitle: Bool = true

    private var seed: CoverSeed { palette.coverGradient(for: title) }

    private var initials: String {
        let words = title.split(separator: " ").prefix(2)
        let letters = words.compactMap { $0.first }.map(String.init)
        return letters.joined().uppercased()
    }

    var body: some View {
        ZStack {
            seed.gradient
            sheen
            ScriptBinding()
            if showsTitle { titleBlock }
        }
    }

    private var titleBlock: some View {
        VStack(spacing: 7) {
            Text(initials.isEmpty ? "•" : initials)
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white.opacity(0.95))
                .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
            Capsule()
                .fill(.white.opacity(0.45))
                .frame(width: 34, height: 1.5)
        }
        .padding(.leading, 14)
    }

    private var sheen: some View {
        LinearGradient(
            colors: [.white.opacity(0.22), .clear],
            startPoint: .topLeading,
            endPoint: .center
        )
    }
}
