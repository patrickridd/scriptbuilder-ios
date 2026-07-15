import SwiftUI

/// A full-screen, glassy loading veil shown while an authentication request is
/// in flight. It dims the form behind a soft scrim and presents a centered
/// card with a shimmering badge plus a status line — communicating progress
/// with a premium, on-brand feel.
///
/// This is a thin wrapper over the FeatureAuth-local ``AuthLoadingCard``: there
/// is a single loading component within the module, and Auth supplies its own
/// tokens (derived from ``AuthTheme``) plus a badge **injected by the host
/// app** — FeatureAuth ships no brand artwork of its own, keeping the module
/// fully reusable and free of any external design dependency.
///
/// Respects **Reduce Motion** (the shimmer renders calmly) and is announced to
/// VoiceOver as a single, polite status element.
public struct AuthLoadingOverlay: View {

    /// Status text shown under the skeleton (e.g. "Signing you in…").
    let message: String
    /// Host-supplied brand mark shown in the badge. `nil` renders no badge, so
    /// FeatureAuth never depends on any specific app's artwork.
    let badge: Image?

    public init(message: String, badge: Image? = nil) {
        self.message = message
        self.badge = badge
    }

    public var body: some View {
        AuthLoadingCard(
            message: message,
            badge: badge,
            style: Self.authGlassStyle
        )
    }

    /// The frosted-glass style built from Auth's own design tokens, matching
    /// the original hand-rolled overlay exactly.
    private static var authGlassStyle: AuthLoadingCardStyle {
        AuthLoadingCardStyle(
            scrimGradient: AuthTheme.backgroundGradient,
            scrimOpacity: 0.55,
            cardFill: AuthTheme.fieldGlass,
            cardStroke: AuthTheme.socialStroke,
            skeletonFill: AuthTheme.separator,
            textColor: AuthTheme.textPrimary,
            shadowColor: AuthTheme.brandSecondary,
            badgePlate: AuthTheme.logoBadge
        )
    }
}

#Preview("Loading Overlay — Light") {
    ZStack {
        AuthBackground()
        AuthLoadingOverlay(message: "Signing you in…")
    }
    .preferredColorScheme(.light)
}

#Preview("Loading Overlay — Dark") {
    ZStack {
        AuthBackground()
        AuthLoadingOverlay(message: "Creating your account…")
    }
    .preferredColorScheme(.dark)
}
