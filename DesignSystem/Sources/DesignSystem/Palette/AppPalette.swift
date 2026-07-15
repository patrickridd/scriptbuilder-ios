import SwiftUI

/// A complete, injectable set of design tokens shared across every feature in
/// the app. `DesignSystem` ships a polished `AppPalette.default` (the signature
/// blue → teal look), but clients can pass their own palette to re-skin any
/// feature without touching its source.
///
/// All colors are plain `Color` values, so you can supply asset-catalog colors
/// (which adapt to light/dark automatically) or build dynamic colors yourself
/// with `AppPalette.dynamic(light:dark:)`.
public struct AppPalette: Sendable {

    // MARK: - Brand
    public var brandPrimary: Color
    public var brandSecondary: Color
    public var brandTertiary: Color
    public var accent: Color

    /// The legacy ScriptBuilder brand color (ported from the old
    /// `scriptBuilderColor` asset). Adapts to light/dark automatically.
    public var scriptBuilder: Color

    // MARK: - Text
    public var textPrimary: Color
    public var textMuted: Color
    public var textOnLight: Color

    // MARK: - Background gradient stops
    public var backgroundTop: Color
    public var backgroundMid: Color
    public var backgroundBottom: Color
    public var glowAccent: Color

    // MARK: - Ambient blobs
    public var blobTeal: Color
    public var blobBlue: Color
    public var blobDeep: Color

    // MARK: - Surfaces
    public var cardSurface: Color
    public var cardStroke: Color
    public var separator: Color

    // MARK: - Cover art seeds (used to derive deterministic gradient covers)
    public var coverSeeds: [CoverSeed]

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
        scriptBuilder: Color,
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
        cardSurface: Color,
        cardStroke: Color,
        separator: Color,
        coverSeeds: [CoverSeed],
        controlHeight: CGFloat = 54,
        cornerRadius: CGFloat = 14,
        horizontalPadding: CGFloat = 26,
        controlSpacing: CGFloat = 12
    ) {
        self.brandPrimary = brandPrimary
        self.brandSecondary = brandSecondary
        self.brandTertiary = brandTertiary
        self.accent = accent
        self.scriptBuilder = scriptBuilder
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
        self.cardSurface = cardSurface
        self.cardStroke = cardStroke
        self.separator = separator
        self.coverSeeds = coverSeeds
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

    public var heroGradient: LinearGradient {
        LinearGradient(
            colors: [brandPrimary, brandSecondary, brandTertiary],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
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

    /// A deterministic gradient cover for a given title — same title always
    /// maps to the same on-brand pair, so the grid feels stable run to run.
    public func coverGradient(for title: String) -> CoverSeed {
        guard !coverSeeds.isEmpty else {
            return CoverSeed(startHex: 0x2980EB, endHex: 0x29C7D6)
        }
        let hash = title.unicodeScalars.reduce(UInt64(5381)) { acc, scalar in
            acc &* 33 &+ UInt64(scalar.value)
        }
        return coverSeeds[Int(hash % UInt64(coverSeeds.count))]
    }

    // MARK: - Helpers

    /// Builds a color that resolves differently in light vs dark mode.
    public static func dynamic(light: Color, dark: Color) -> Color {
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? UIColor(dark) : UIColor(light)
        })
    }

    /// Returns a copy of this palette with the given tokens overridden.
    public func with(
        brandPrimary: Color? = nil,
        brandSecondary: Color? = nil,
        brandTertiary: Color? = nil,
        accent: Color? = nil,
        cornerRadius: CGFloat? = nil
    ) -> AppPalette {
        var copy = self
        if let brandPrimary { copy.brandPrimary = brandPrimary }
        if let brandSecondary { copy.brandSecondary = brandSecondary }
        if let brandTertiary { copy.brandTertiary = brandTertiary }
        if let accent { copy.accent = accent }
        if let cornerRadius { copy.cornerRadius = cornerRadius }
        return copy
    }
}

// MARK: - CoverSeed

/// A pair of fixed RGB hex stops used to render a screenplay cover gradient.
/// Stored as hex (rather than `Color`) so it stays `Equatable` for testing and
/// stable regardless of trait collection.
public struct CoverSeed: Sendable, Equatable {
    public var startHex: UInt32
    public var endHex: UInt32

    public init(startHex: UInt32, endHex: UInt32) {
        self.startHex = startHex
        self.endHex = endHex
    }

    public var startColor: Color { Color(hex: startHex) }
    public var endColor: Color { Color(hex: endHex) }

    public var gradient: LinearGradient {
        LinearGradient(
            colors: [startColor, endColor],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Color hex helper

extension Color {
    init(hex: UInt32) {
        let red = Double((hex >> 16) & 0xFF) / 255.0
        let green = Double((hex >> 8) & 0xFF) / 255.0
        let blue = Double(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }
}
