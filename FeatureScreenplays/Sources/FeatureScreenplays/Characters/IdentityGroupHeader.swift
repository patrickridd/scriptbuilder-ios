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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
            if let description, !description.isEmpty {
                Text(description)
                    .font(.footnote)
                    .foregroundStyle(palette.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.top, 8)
        .accessibilityElement(children: .combine)
    }
}
