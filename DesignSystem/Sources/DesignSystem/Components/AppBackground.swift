import SwiftUI

/// The signature 3-stop gradient background with a soft radial accent glow.
/// Reusable across every feature so screens share one ambient look.
public struct AppBackground: View {
    @Environment(\.appPalette) private var palette

    public init() {}

    public var body: some View {
        ZStack {
            palette.backgroundGradient
            palette.accentGlow
                .blendMode(.plusLighter)
        }
        .ignoresSafeArea()
    }
}

/// A frosted, rounded surface used for cards and grouped content. Adapts to
/// light/dark via the injected palette.
public struct GlassCard<Content: View>: View {
    @Environment(\.appPalette) private var palette
    private let content: Content

    public init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }

    public var body: some View {
        content
            .background(surface)
            .overlay(stroke)
            .clipShape(RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous))
    }

    private var surface: some View {
        RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous)
            .fill(palette.cardSurface)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous))
    }

    private var stroke: some View {
        RoundedRectangle(cornerRadius: palette.cornerRadius, style: .continuous)
            .stroke(palette.cardStroke, lineWidth: 1)
    }
}
