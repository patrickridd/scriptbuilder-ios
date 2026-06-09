import SwiftUI

/// Central design tokens for the FeatureAuth experience.
/// High-contrast colors and generous sizing keep the screens accessible
/// for people who are hard of seeing.
enum AuthTheme {

    // MARK: - Brand Colors

    static let brandBlue = Color(red: 0.16, green: 0.50, blue: 0.92)
    static let brandTeal = Color(red: 0.16, green: 0.78, blue: 0.84)
    static let brandDeep = Color(red: 0.09, green: 0.27, blue: 0.45)

    static let facebookBlue = Color(red: 0.23, green: 0.35, blue: 0.60)
    static let googleBlue = Color(red: 0.26, green: 0.52, blue: 0.96)

    // MARK: - Text

    static let textPrimary = Color.white
    static let textOnLight = Color(red: 0.08, green: 0.12, blue: 0.18)
    static let textMuted = Color.white.opacity(0.82)

    // MARK: - Field

    static let fieldBackground = Color.white
    static let fieldText = Color(red: 0.08, green: 0.12, blue: 0.18)
    static let fieldPlaceholder = Color(red: 0.40, green: 0.44, blue: 0.50)

    // MARK: - Gradient

    static let backgroundTop = Color(red: 0.05, green: 0.10, blue: 0.20)
    static let backgroundMid = Color(red: 0.07, green: 0.20, blue: 0.36)
    static let backgroundBottom = Color(red: 0.06, green: 0.13, blue: 0.24)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [backgroundTop, backgroundMid, backgroundBottom],
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
    static var accentGlow: RadialGradient {
        RadialGradient(
            colors: [brandTeal.opacity(0.45), .clear],
            center: .topTrailing,
            startRadius: 0,
            endRadius: 380
        )
    }

    // MARK: - Glassy field surface

    static let fieldGlass = Color.white.opacity(0.10)
    static let fieldGlassStroke = Color.white.opacity(0.22)
    static let glassPlaceholder = Color.white.opacity(0.55)

    // MARK: - Metrics

    static let controlHeight: CGFloat = 54
    static let cornerRadius: CGFloat = 14
    static let horizontalPadding: CGFloat = 26
    static let controlSpacing: CGFloat = 12
}
