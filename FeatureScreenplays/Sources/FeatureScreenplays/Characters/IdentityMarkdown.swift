//
//  IdentityMarkdown.swift
//  FeatureScreenplays
//
//  Tiny Markdown helper for the identity teaching copy. Strings in the
//  catalog/intros can emphasize craft terms with **bold**; this renders them
//  inline and optionally tints the emphasized runs in the facet's own hue so
//  a suggestion source reads in the same colour as its chips.
//

import SwiftUI

enum IdentityMarkdown {

    /// Parses inline Markdown, falling back to the raw string if it ever fails.
    /// When `boldColor` is supplied, every **bold** run is tinted with it.
    static func attributed(_ markdown: String, boldColor: Color? = nil) -> AttributedString {
        attributed(markdown, boldColors: boldColor.map { [$0] } ?? [])
    }

    /// Parses inline Markdown and asks `colorForTerm` what colour each **bold**
    /// run should wear, passing the run's plain text. Returning `nil` leaves
    /// that run untinted so it inherits the surrounding foreground style.
    static func attributed(
        _ markdown: String,
        colorForTerm: (String) -> Color?
    ) -> AttributedString {
        guard var parsed = parse(markdown) else { return AttributedString(markdown) }
        for range in boldRanges(in: parsed) {
            let term = String(parsed[range].characters)
            if let color = colorForTerm(term) {
                parsed[range].foregroundColor = color
            }
        }
        return parsed
    }

    /// Parses inline Markdown and tints each **bold** run with the colour at
    /// the matching index of `boldColors` — so "**Antagonist** · **Villain**"
    /// can read amber then teal. Runs beyond the array keep the last colour;
    /// an empty array leaves the text untinted.
    static func attributed(_ markdown: String, boldColors: [Color]) -> AttributedString {
        guard var parsed = parse(markdown) else { return AttributedString(markdown) }
        guard let fallback = boldColors.last else { return parsed }
        for (index, range) in boldRanges(in: parsed).enumerated() {
            parsed[range].foregroundColor = index < boldColors.count ? boldColors[index] : fallback
        }
        return parsed
    }

    private static func parse(_ markdown: String) -> AttributedString? {
        let options = AttributedString.MarkdownParsingOptions(
            interpretedSyntax: .inlineOnlyPreservingWhitespace
        )
        return try? AttributedString(markdown: markdown, options: options)
    }

    private static func boldRanges(
        in text: AttributedString
    ) -> [Range<AttributedString.Index>] {
        text.runs
            .filter { $0.inlinePresentationIntent?.contains(.stronglyEmphasized) == true }
            .map(\.range)
    }
}
