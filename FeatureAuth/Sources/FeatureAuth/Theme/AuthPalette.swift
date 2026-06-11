import SwiftUI

/// A complete, injectable set of design tokens for the FeatureAuth screens.
///
/// `FeatureAuth` ships a polished `AuthPalette.default`, but clients can pass
/// their own palette to `AuthFlowView`, `LoginView`, or `SignUpView` to fully
/// re-skin the experience — brand colors, text, surfaces, gradients, and
/// layout metrics — without touching the kit's source.
///
/// ```swift
/// let brand = AuthPalette.default.with(
///     brandPrimary: .purple,
///     brandSecondary: .pink
/// )
/// AuthFlowView(theme: brand)
/// ```
///
/// All colors are plain `Color` values, so you can supply asset-catalog
/// colors (which adapt to light/dark automatically) or build dynamic colors
/// yourself with `AuthPalette.dynamic(light:dark:)`.
public struct AuthPalette: Sendable {

    // MARK: - Brand
    /// The main brand color. Drives the primary CTA gradient start, focus
    /// accents, and key highlights. (FeatureAuth's default is a blue.)
    public var brandPrimary: Color
    /// The secondary brand color. Pairs with `brandPrimary` for the CTA
    /// gradient and button glow. (FeatureAuth's default is a teal.)
    public var brandSecondary: Color
    /// A deeper brand shade used for ambient depth (e.g. dark-mode blobs).
    public var brandTertiary: Color
    public var accent: Color
    public var facebookBlue: Color
    public var googleBlue: Color

    // MARK: - Text
    public var textPrimary: Color
    public var textMuted: Color
    public var textOnLight: Color

    // MARK: - Background gradient stops
    public var backgroundTop: Color
    public var backgroundMid: Color
    public var backgroundBottom: Color
    public var glowAccent: Color

    // MARK: - Animated blobs
    public var blobTeal: Color
    public var blobBlue: Color
    public var blobDeep: Color

    // MARK: - Surfaces
    public var fieldGlass: Color
    public var fieldGlassStroke: Color
    public var glassPlaceholder: Color
    public var separator: Color
    public var socialStroke: Color
    public var logoBadge: Color

    // MARK: - Metrics
    public var controlHeight: CGFloat
    public var cornerRadius: CGFloat
    public var horizontalPadding: CGFloat
    public var controlSpacing: CGFloat

    public init(
        brandPrimary: Color,
        brandSecondary: Color,
        brandTertiary: Color,
        accent: Color,
        facebookBlue: Color,
        googleBlue: Color,
        textPrimary: Color,
        textMuted: Color,
        textOnLight: Color,
        backgroundTop: Color,
        backgroundMid: Color,
        backgroundBottom: Color,
        glowAccent: Color,
        blobTeal: Color,
        blobBlue: Color,
        blobDeep: Color,
        fieldGlass: Color,
        fieldGlassStroke: Color,
        glassPlaceholder: Color,
        separator: Color,
        socialStroke: Color,
        logoBadge: Color,
        controlHeight: CGFloat = 54,
        cornerRadius: CGFloat = 14,
        horizontalPadding: CGFloat = 26,
        controlSpacing: CGFloat = 12
    ) {
        self.brandPrimary = brandPrimary
        self.brandSecondary = brandSecondary
        self.brandTertiary = brandTertiary
        self.accent = accent
        self.facebookBlue = facebookBlue
        self.googleBlue = googleBlue
        self.textPrimary = textPrimary
        self.textMuted = textMuted
        self.textOnLight = textOnLight
        self.backgroundTop = backgroundTop
        self.backgroundMid = backgroundMid
        self.backgroundBottom = backgroundBottom
        self.glowAccent = glowAccent
        self.blobTeal = blobTeal
        self.blobBlue = blobBlue
        self.blobDeep = blobDeep
        self.fieldGlass = fieldGlass
        self.fieldGlassStroke = fieldGlassStroke
        self.glassPlaceholder = glassPlaceholder
        self.separator = separator
        self.socialStroke = socialStroke
        self.logoBadge = logoBadge
        self.controlHeight = controlHeight
        self.cornerRadius = cornerRadius
        self.horizontalPadding = horizontalPadding
        self.controlSpacing = controlSpacing
    }

    // MARK: - Derived gradients

    public var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    public var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandSecondary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    public var accentGlow: RadialGradient {
        RadialGradient(
            colors: [glowAccent, .clear],
            center: .topTrailing,
            startRadius: 0,
            endRadius: 380
        )
    }

    // MARK: - Helpers

    /// Builds a color that resolves differently in light vs dark mode.
    public static func dynamic(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Returns a copy of this palette with the given tokens overridden.
    /// Handy for tweaking just a couple of colors off the default.
    public func with(
        brandPrimary: Color? = nil,
        brandSecondary: Color? = nil,
        brandTertiary: Color? = nil,
        accent: Color? = nil,
        textPrimary: Color? = nil,
        textMuted: Color? = nil,
        backgroundTop: Color? = nil,
        backgroundMid: Color? = nil,
        backgroundBottom: Color? = nil,
        cornerRadius: CGFloat? = nil,
        controlHeight: CGFloat? = nil
    ) -> AuthPalette {
        var copy = self
        if let brandPrimary { copy.brandPrimary = brandPrimary }
        if let brandSecondary { copy.brandSecondary = brandSecondary }
        if let brandTertiary { copy.brandTertiary = brandTertiary }
        if let accent { copy.accent = accent }
        if let textPrimary { copy.textPrimary = textPrimary }
        if let textMuted { copy.textMuted = textMuted }
        if let backgroundTop { copy.backgroundTop = backgroundTop }
        if let backgroundMid { copy.backgroundMid = backgroundMid }
        if let backgroundBottom { copy.backgroundBottom = backgroundBottom }
        if let cornerRadius { copy.cornerRadius = cornerRadius }
        if let controlHeight { copy.controlHeight = controlHeight }
        return copy
    }
}

// MARK: - Default palette (FeatureAuth's signature look)

public extension AuthPalette {
    /// The signature FeatureAuth palette — soft sky-to-periwinkle in light
    /// mode, premium navy-to-teal in dark mode.
    static let `default`: AuthPalette = {
        let brandPrimary = Color(red: 0.16, green: 0.50, blue: 0.92)
        let brandSecondary = Color(red: 0.16, green: 0.78, blue: 0.84)
        let brandTertiary = Color(red: 0.09, green: 0.27, blue: 0.45)

        return AuthPalette(
            brandPrimary: brandPrimary,
            brandSecondary: brandSecondary,
            brandTertiary: brandTertiary,
            accent: dynamic(
                light: Color(red: 0.05, green: 0.55, blue: 0.62),
                dark: brandSecondary
            ),
            facebookBlue: Color(red: 0.23, green: 0.35, blue: 0.60),
            googleBlue: Color(red: 0.26, green: 0.52, blue: 0.96),
            textPrimary: dynamic(
                light: Color(red: 0.10, green: 0.14, blue: 0.20),
                dark: .white
            ),
            textMuted: dynamic(
                light: Color(red: 0.36, green: 0.42, blue: 0.50),
                dark: Color.white.opacity(0.82)
            ),
            textOnLight: Color(red: 0.08, green: 0.12, blue: 0.18),
            backgroundTop: dynamic(
                light: Color(red: 0.84, green: 0.92, blue: 0.99),
                dark: Color(red: 0.05, green: 0.10, blue: 0.20)
            ),
            backgroundMid: dynamic(
                light: Color(red: 0.88, green: 0.90, blue: 0.98),
                dark: Color(red: 0.07, green: 0.20, blue: 0.36)
            ),
            backgroundBottom: dynamic(
                light: Color(red: 0.93, green: 0.91, blue: 0.97),
                dark: Color(red: 0.06, green: 0.13, blue: 0.24)
            ),
            glowAccent: dynamic(
                light: brandPrimary.opacity(0.28),
                dark: brandSecondary.opacity(0.45)
            ),
            blobTeal: dynamic(
                light: brandSecondary.opacity(0.30),
                dark: brandSecondary.opacity(0.40)
            ),
            blobBlue: dynamic(
                light: brandPrimary.opacity(0.26),
                dark: brandPrimary.opacity(0.38)
            ),
            blobDeep: dynamic(
                light: Color(red: 0.55, green: 0.50, blue: 0.92).opacity(0.24),
                dark: brandTertiary.opacity(0.55)
            ),
            fieldGlass: dynamic(
                light: Color.white.opacity(0.85),
                dark: Color.white.opacity(0.10)
            ),
            fieldGlassStroke: dynamic(
                light: Color(red: 0.62, green: 0.68, blue: 0.74),
                dark: Color.white.opacity(0.22)
            ),
            glassPlaceholder: dynamic(
                light: Color(red: 0.55, green: 0.59, blue: 0.65),
                dark: Color.white.opacity(0.55)
            ),
            separator: dynamic(
                light: Color(red: 0.78, green: 0.82, blue: 0.86),
                dark: Color.white.opacity(0.25)
            ),
            socialStroke: dynamic(
                light: Color(red: 0.62, green: 0.68, blue: 0.74),
                dark: Color.white.opacity(0.18)
            ),
            logoBadge: .white
        )
    }()
}

// MARK: - Environment

private struct AuthPaletteKey: EnvironmentKey {
    static let defaultValue: AuthPalette = .default
}

public extension EnvironmentValues {
    /// The palette used by the FeatureAuth screens. Injected automatically by
    /// the public entry views; read it in your own components via
    /// `@Environment(\.authPalette)`.
    var authPalette: AuthPalette {
        get { self[AuthPaletteKey.self] }
        set { self[AuthPaletteKey.self] = newValue }
    }
}
