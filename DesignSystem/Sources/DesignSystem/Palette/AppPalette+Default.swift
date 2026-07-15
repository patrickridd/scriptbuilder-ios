import SwiftUI

// MARK: - Default palette (the app's signature look)

public extension AppPalette {
    /// The signature palette — soft sky-to-periwinkle in light mode, premium
    /// navy-to-teal in dark mode. Mirrors the values FeatureAuth ships so every
    /// feature shares one brand identity.
    static let `default`: AppPalette = {
        let brandPrimary = Color(red: 0.16, green: 0.50, blue: 0.92)
        let brandSecondary = Color(red: 0.16, green: 0.78, blue: 0.84)
        let brandTertiary = Color(red: 0.09, green: 0.27, blue: 0.45)

        return AppPalette(
            brandPrimary: brandPrimary,
            brandSecondary: brandSecondary,
            brandTertiary: brandTertiary,
            accent: dynamic(
                light: brandPrimary,
                dark: brandSecondary
            ),
            scriptBuilder: dynamic(
                light: Color(red: 0.20, green: 0.68, blue: 0.90),
                dark: Color(red: 0.39, green: 0.82, blue: 1.00)
            ),
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
            cardSurface: dynamic(
                light: Color.white.opacity(0.92),
                dark: Color.white.opacity(0.08)
            ),
            cardStroke: dynamic(
                light: Color(red: 0.80, green: 0.84, blue: 0.90),
                dark: Color.white.opacity(0.16)
            ),
            separator: dynamic(
                light: Color(red: 0.78, green: 0.82, blue: 0.86),
                dark: Color.white.opacity(0.25)
            ),
            coverSeeds: [
                CoverSeed(startHex: 0x2980EB, endHex: 0x29C7D6), // blue → teal
                CoverSeed(startHex: 0x8C80EB, endHex: 0x2980EB), // periwinkle → blue
                CoverSeed(startHex: 0x29C7D6, endHex: 0x167A99), // teal → deep
                CoverSeed(startHex: 0x174573, endHex: 0x29C7D6), // navy → teal
                CoverSeed(startHex: 0x5C7BE0, endHex: 0x9B7BE8), // indigo → violet
                CoverSeed(startHex: 0x2980EB, endHex: 0x174573)  // blue → navy
            ]
        )
    }()
}
