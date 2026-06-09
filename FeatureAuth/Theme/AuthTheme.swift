import SwiftUI

/// Central design tokens for the FeatureAuth experience.
/// All colors adapt automatically between light and dark mode using
/// dynamic `UIColor` providers, so a single token works everywhere.
/// High-contrast values and generous sizing keep the screens accessible
/// for people who are hard of seeing.
enum AuthTheme {

    // MARK: - Dynamic color helper

    /// Builds a color that resolves differently in light vs dark mode.
    private static func dynamic(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark
                ? UIColor(dark)
                : UIColor(light)
        })
    }

    // MARK: - Brand Colors (stable across modes)

    static let brandBlue = Color(red: 0.16, green: 0.50, blue: 0.92)
    static let brandTeal = Color(red: 0.16, green: 0.78, blue: 0.84)
    static let brandDeep = Color(red: 0.09, green: 0.27, blue: 0.45)

    /// Accent used for field icons / focus — slightly deeper in light mode
    /// so it stays legible on the off-white surface.
    static let accent = dynamic(
        light: Color(red: 0.05, green: 0.55, blue: 0.62),
        dark: brandTeal
    )

    static let facebookBlue = Color(red: 0.23, green: 0.35, blue: 0.60)
    static let googleBlue = Color(red: 0.26, green: 0.52, blue: 0.96)

    // MARK: - Text

    /// Primary text — near-black on light, white on dark.
    static let textPrimary = dynamic(
        light: Color(red: 0.10, green: 0.14, blue: 0.20),
        dark: .white
    )

    /// Muted/secondary text.
    static let textMuted = dynamic(
        light: Color(red: 0.36, green: 0.42, blue: 0.50),
        dark: Color.white.opacity(0.82)
    )

    static let textOnLight = Color(red: 0.08, green: 0.12, blue: 0.18)

    // MARK: - Gradient background

    private static let darkTop = Color(red: 0.05, green: 0.10, blue: 0.20)
    private static let darkMid = Color(red: 0.07, green: 0.20, blue: 0.36)
    private static let darkBottom = Color(red: 0.06, green: 0.13, blue: 0.24)

    // Off-white, premium light background with a faint cool tint.
    private static let lightTop = Color(red: 0.97, green: 0.98, blue: 0.99)
    private static let lightMid = Color(red: 0.95, green: 0.97, blue: 0.98)
    private static let lightBottom = Color(red: 0.93, green: 0.96, blue: 0.97)

    private static let bgTop = dynamic(light: lightTop, dark: darkTop)
    private static let bgMid = dynamic(light: lightMid, dark: darkMid)
    private static let bgBottom = dynamic(light: lightBottom, dark: darkBottom)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [bgTop, bgMid, bgBottom],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    static var primaryButtonGradient: LinearGradient {
        LinearGradient(
            colors: [brandBlue, brandTeal],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    /// Soft glow accents layered behind the content for depth.
    /// Subtle in light mode so it reads as a gentle highlight, not a smudge.
    static var accentGlow: RadialGradient {
        RadialGradient(
            colors: [glowAccent, .clear],
            center: .topTrailing,
            startRadius: 0,
            endRadius: 380
        )
    }

    private static let glowAccent = dynamic(
        light: brandTeal.opacity(0.16),
        dark: brandTeal.opacity(0.45)
    )

    // MARK: - Glassy field surface

    /// Frosted field fill — a soft white card on light, translucent on dark.
    static let fieldGlass = dynamic(
        light: Color.white.opacity(0.85),
        dark: Color.white.opacity(0.10)
    )

    static let fieldGlassStroke = dynamic(
        light: Color(red: 0.80, green: 0.84, blue: 0.88),
        dark: Color.white.opacity(0.22)
    )

    static let glassPlaceholder = dynamic(
        light: Color(red: 0.55, green: 0.59, blue: 0.65),
        dark: Color.white.opacity(0.55)
    )

    /// Hairline separators (dividers, social outlines).
    static let separator = dynamic(
        light: Color(red: 0.78, green: 0.82, blue: 0.86),
        dark: Color.white.opacity(0.25)
    )

    /// Outline used around icon-only / outlined social buttons.
    static let socialStroke = dynamic(
        light: Color(red: 0.82, green: 0.86, blue: 0.90),
        dark: Color.white.opacity(0.18)
    )

    /// Fill behind the brand logo badge.
    static let logoBadge = dynamic(
        light: .white,
        dark: .white
    )

    // MARK: - Metrics

    static let controlHeight: CGFloat = 54
    static let cornerRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 26
    static let controlSpacing: CGFloat = 12
}
