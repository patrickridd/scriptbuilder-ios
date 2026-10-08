//
//  IdentityGroupHeader.swift
//  FeatureScreenplays
//
//  Shared section header for the identity pickers (Role, Archetype, Story
//  Function). An uppercase title with an optional one-line explanation set
//  tighter beneath it than the whole block sits from the section above, so the
//  caption reads as belonging to its own header rather than the cards above it.
//

import SwiftUI
import DesignSystem

struct IdentityGroupHeader: View {
    @Environment(\.appPalette) private var palette

    let title: String
    var description: String?
    /// Colour applied to **bold** words in the description — the facet's hue,
    /// so a suggestion source matches the chips it produced.
    var emphasisTint: Color?
    /// Per-run colours for **bold** words, in order — lets one line mix facet
    /// hues (e.g. an amber role beside a teal archetype). Wins over `emphasisTint`.
    var emphasisTints: [Color] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
            if let attributedDescription {
                Text(attributedDescription)
                    .font(.footnote)
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }

    /// Parses Markdown so callers can emphasize words inline (e.g. bolded suggestion sources).
    private var attributedDescription: AttributedString? {
        guard let description, !description.isEmpty else { return nil }
        let colors = emphasisTints.isEmpty ? [emphasisTint].compactMap { $0 } : emphasisTints
        return IdentityMarkdown.attributed(description, boldColors: colors)
    }
}
