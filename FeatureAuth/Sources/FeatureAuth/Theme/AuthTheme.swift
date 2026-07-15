import SwiftUI

/// Central design tokens for the FeatureAuth experience.
///
/// `AuthTheme` is a thin, convenient accessor over the currently active
/// ``AuthPalette``. By default it reflects ``AuthPalette/default``, but when a
/// client injects a custom palette into the public entry views, `AuthTheme`
/// reflects that palette too — so all internal call sites stay in sync without
/// threading the palette through every view manually.
///
/// All colors adapt automatically between light and dark mode using dynamic
/// `UIColor` providers, so a single token works everywhere. To re-skin the
/// experience, pass your own ``AuthPalette`` to `AuthFlowView`, `LoginView`,
/// or `SignUpView` — do not mutate `current` directly.
public enum AuthTheme {

    /// The palette backing every token below. Set by the public entry views
    /// when a custom theme is supplied. Defaults to ``AuthPalette/default``.
    public static var current: AuthPalette = .default

    // MARK: - Dynamic color helper (kept for source compatibility)

    static func dynamic(light: Color, dark: Color) -> Color {
        AuthPalette.dynamic(light: light, dark: dark)
    }

    // MARK: - Brand Colors

    public static var brandPrimary: Color { current.brandPrimary }
    public static var brandSecondary: Color { current.brandSecondary }
    public static var brandTertiary: Color { current.brandTertiary }
    public static var accent: Color { current.accent }
    public static var facebookBlue: Color { current.facebookBlue }
    public static var googleBlue: Color { current.googleBlue }

    // MARK: - Text

    public static var textPrimary: Color { current.textPrimary }
    public static var textMuted: Color { current.textMuted }
    public static var textOnLight: Color { current.textOnLight }

    // MARK: - Gradient background

    public static var backgroundGradient: LinearGradient { current.backgroundGradient }
    public static var primaryButtonGradient: LinearGradient { current.primaryButtonGradient }
    public static var accentGlow: RadialGradient { current.accentGlow }

    // MARK: - Animated background blobs

    public static var blobTeal: Color { current.blobTeal }
    public static var blobBlue: Color { current.blobBlue }
    public static var blobDeep: Color { current.blobDeep }

    // MARK: - Glassy field surface

    public static var fieldGlass: Color { current.fieldGlass }
    public static var fieldGlassStroke: Color { current.fieldGlassStroke }
    public static var glassPlaceholder: Color { current.glassPlaceholder }
    public static var separator: Color { current.separator }
    public static var socialStroke: Color { current.socialStroke }
    public static var logoBadge: Color { current.logoBadge }

    // MARK: - Metrics

    public static var controlHeight: CGFloat { current.controlHeight }
    public static var cornerRadius: CGFloat { current.cornerRadius }
    public static var horizontalPadding: CGFloat { current.horizontalPadding }
    public static var controlSpacing: CGFloat { current.controlSpacing }
}
