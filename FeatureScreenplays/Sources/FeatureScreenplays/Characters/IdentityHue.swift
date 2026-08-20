//
//  IdentityHue.swift
//  FeatureScreenplays
//
//  Colour coding for the three identity facets. Role, Archetype and Story
//  Function each own a hue so a chip's meaning reads before its text does:
//  amber for role (hierarchy / billing), teal-blue for archetype (character
//  pattern), violet for story function (what they do to the plot).
//
//  Every hue is a dynamic colour — brightened for dark mode, deepened for
//  light mode — so labels clear contrast on translucent card surfaces.
//

import SwiftUI

enum IdentityHue {

    /// The three identity facets, in the order the writer fills them in.
    enum Facet {
        case role
        case archetype
        case storyFunction
    }

    /// Warm amber/gold — role is the billing/hierarchy facet, so a "status"
    /// colour reads right next to the cooler pattern facets.
    static let role = dynamic(
        light: rgb(0.63, 0.40, 0.03),
        dark: rgb(0.98, 0.78, 0.36)
    )

    /// Teal-leaning blue, deliberately off the app accent so archetype chips
    /// aren't confused with generic interactive chrome.
    static let archetype = dynamic(
        light: rgb(0.02, 0.44, 0.50),
        dark: rgb(0.42, 0.83, 0.88)
    )

    /// Violet — the original story-function hue, unchanged.
    static let storyFunction = dynamic(
        light: rgb(0.42, 0.26, 0.76),
        dark: rgb(0.76, 0.65, 1.00)
    )

    /// One lookup so no screen hardcodes a facet colour again.
    static func hue(for facet: Facet) -> Color {
        switch facet {
        case .role: return role
        case .archetype: return archetype
        case .storyFunction: return storyFunction
        }
    }

    /// Maps an emphasized craft term from the teaching copy to its facet, so
    /// "Hierarchical Role", "Archetype" and "Story Function" wear their own
    /// colour wherever they're name-dropped in prose. Returns `nil` for terms
    /// that aren't facet names — the caller keeps its own fallback colour.
    static func facet(forTerm term: String) -> Facet? {
        let key = term
            .lowercased()
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if namedArchetypes.contains(key) { return .archetype }
        if namedFunctions.contains(key) { return .storyFunction }
        if key.contains("archetype") { return .archetype }
        if key.contains("function") { return .storyFunction }
        if key.contains("role") { return .role }
        return nil
    }

    /// Archetypes cited by name inside the intro paragraphs.
    private static let namedArchetypes: Set<String> = [
        "mentor", "rebel", "caregiver", "shadow", "shapeshifter", "trickster"
    ]

    /// Story functions cited by name inside the intro paragraphs.
    private static let namedFunctions: Set<String> = [
        "exposition device", "confidant", "foil", "threshold guardian"
    ]

    private static func dynamic(light: UIColor, dark: UIColor) -> Color {
        Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? dark : light })
    }

    private static func rgb(_ red: CGFloat, _ green: CGFloat, _ blue: CGFloat) -> UIColor {
        UIColor(red: red, green: green, blue: blue, alpha: 1)
    }
}
