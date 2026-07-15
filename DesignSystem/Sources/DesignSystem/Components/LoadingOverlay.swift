import SwiftUI

/// Visual configuration for ``LoadingOverlay``. Each feature can construct its
/// own style so the overlay matches that surface exactly — Auth passes its
/// glass tokens and logo badge, Screenplays can pass palette-derived colors and
/// an SF Symbol (or no badge at all).
///
/// A convenience initializer derives a faithful style straight from an
/// ``AppPalette``, so most callers only need to supply an optional badge.
public struct LoadingOverlayStyle {

    /// Fill behind the whole overlay (dimmed + blurred as a scrim).
    public var scrimGradient: LinearGradient
    /// Opacity applied to the scrim gradient.
    public var scrimOpacity: Double
    /// Glass fill of the centered card.
    public var cardFill: Color
    /// Stroke around the centered card.
    public var cardStroke: Color
    /// Fill of the shimmering skeleton bars.
    public var skeletonFill: Color
    /// Primary status text color.
    public var textColor: Color
    /// Color used for the card's soft drop shadow.
    public var shadowColor: Color
    /// Optional fill behind the badge image. When `nil`, no badge plate shows.
    public var badgePlate: Color?

    public init(
        scrimGradient: LinearGradient,
        scrimOpacity: Double = 0.55,
        cardFill: Color,
        cardStroke: Color,
        skeletonFill: Color,
        textColor: Color,
        shadowColor: Color,
        badgePlate: Color? = nil
    ) {
        self.scrimGradient = scrimGradient
        self.scrimOpacity = scrimOpacity
        self.cardFill = cardFill
        self.cardStroke = cardStroke
        self.skeletonFill = skeletonFill
        self.textColor = textColor
        self.shadowColor = shadowColor
        self.badgePlate = badgePlate
    }

    /// Builds a faithful style from a shared ``AppPalette``.
    public static func palette(_ palette: AppPalette, badgePlate: Color? = nil) -> LoadingOverlayStyle {
        LoadingOverlayStyle(
            scrimGradient: palette.backgroundGradient,
            cardFill: palette.cardSurface,
            cardStroke: palette.cardStroke,
            skeletonFill: palette.separator,
            textColor: palette.textPrimary,
            shadowColor: palette.brandSecondary,
            badgePlate: badgePlate
        )
    }

    /// Builds the premium, frosted-glass style that FeatureAuth uses — a
    /// translucent card, hairline stroke, and a bright plate behind the badge
    /// so a shimmering logo always reads clearly. Colors adapt to light/dark
    /// and are derived to match Auth's `fieldGlass` / `socialStroke` / logo
    /// badge tokens, while brand-tinted values still flow from the palette.
    public static func glass(_ palette: AppPalette) -> LoadingOverlayStyle {
        LoadingOverlayStyle(
            scrimGradient: palette.backgroundGradient,
            cardFill: AppPalette.dynamic(
                light: Color.white.opacity(0.85),
                dark: Color.white.opacity(0.10)
            ),
            cardStroke: AppPalette.dynamic(
                light: Color(red: 0.62, green: 0.68, blue: 0.74),
                dark: Color.white.opacity(0.18)
            ),
            skeletonFill: palette.separator,
            textColor: palette.textPrimary,
            shadowColor: palette.brandSecondary,
            badgePlate: .white
        )
    }
}

/// A full-screen, glassy loading veil shown while a request is in flight. It
/// dims the content behind a soft scrim and presents a centered card with an
/// optional shimmering badge, "skeleton" bars, and a status line —
/// communicating progress with a premium, on-brand feel.
///
/// Colors come from an injected ``LoadingOverlayStyle`` so each feature can
/// match its own surface. The copy (`message`) is injected per context, e.g.
/// "Signing you in…" or "Loading Screenplays…".
///
/// Respects **Reduce Motion** (the shimmer renders calmly) and is announced to
/// VoiceOver as a single, polite status element.
public struct LoadingOverlay: View {

    /// Status text shown under the skeleton (e.g. "Signing you in…").
    private let message: String
    /// Optional badge image shown above the skeleton (e.g. an app logo).
    private let badge: Image?
    /// Visual configuration for the overlay.
    private let style: LoadingOverlayStyle

    public init(message: String, badge: Image? = nil, style: LoadingOverlayStyle) {
        self.message = message
        self.badge = badge
        self.style = style
    }

    public var body: some View {
        ZStack {
            scrim
            card
        }
        .transition(.opacity)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(message)
        .accessibilityAddTraits(.updatesFrequently)
    }

    private var scrim: some View {
        style.scrimGradient
            .opacity(style.scrimOpacity)
            .background(.ultraThinMaterial)
            .ignoresSafeArea()
    }

    private var card: some View {
        VStack(spacing: 18) {
            if let badge { badgeView(badge) }
            skeletonBars
            Text(message)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(style.textColor)
                .multilineTextAlignment(.center)
        }
        .padding(28)
        .frame(maxWidth: 280)
        .background(style.cardFill,
                    in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(style.cardStroke, lineWidth: 1)
        )
        .shadow(color: style.shadowColor.opacity(0.35), radius: 24, y: 12)
    }

    @ViewBuilder
    private func badgeView(_ image: Image) -> some View {
        let shape = RoundedRectangle(cornerRadius: 18, style: .continuous)
        image
            .resizable().scaledToFit()
            .frame(width: 48, height: 48)
            .padding(14)
            .background(badgeBackground(shape))
            .clipShape(shape)
            .shimmer(duration: 1.4, pause: 0.2, intensity: 0.5)
    }

    @ViewBuilder
    private func badgeBackground(_ shape: RoundedRectangle) -> some View {
        if let plate = style.badgePlate {
            shape.fill(plate)
        }
    }

    private var skeletonBars: some View {
        VStack(spacing: 10) {
            skeletonBar(width: 160)
            skeletonBar(width: 120)
        }
    }

    private func skeletonBar(width: CGFloat) -> some View {
        RoundedRectangle(cornerRadius: 6, style: .continuous)
            .fill(style.skeletonFill)
            .frame(width: width, height: 12)
            .shimmer(duration: 1.4, pause: 0.2, intensity: 0.6)
    }
}

#Preview("Loading Overlay — Light") {
    ZStack {
        AppBackground()
        LoadingOverlay(message: "Loading…", style: .palette(.default))
    }
    .preferredColorScheme(.light)
}

#Preview("Loading Overlay — Dark") {
    ZStack {
        AppBackground()
        LoadingOverlay(message: "Loading…", style: .palette(.default))
    }
    .preferredColorScheme(.dark)
}
