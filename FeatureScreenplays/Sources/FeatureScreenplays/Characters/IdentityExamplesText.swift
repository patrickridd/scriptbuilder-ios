//
//  IdentityExamplesText.swift
//  FeatureScreenplays
//
//  Splits a catalog examples string — "Iago (Othello) · Tyler Durden (Fight
//  Club)" — into coloured runs. The character name takes the card's facet hue
//  (medium weight), the source title stays muted and upright: one colour
//  family, one weight step, no italics.
//

import SwiftUI

enum IdentityExamplesText {
    /// Separator used between examples in `IdentityCatalog`.
    private static let separator = " · "

    /// - Parameters:
    ///   - nameColor: colour for the character name (the part before "(").
    ///   - sourceColor: colour for the parenthesised film/TV title.
    static func attributed(
        _ examples: String,
        nameColor: Color,
        sourceColor: Color
    ) -> AttributedString {
        let entries = examples.components(separatedBy: separator)
        var result = AttributedString()
        for (index, entry) in entries.enumerated() {
            if index > 0 {
                var gap = AttributedString(separator)
                gap.foregroundColor = sourceColor
                gap.font = .caption
                result.append(gap)
            }
            result.append(styled(entry, nameColor: nameColor, sourceColor: sourceColor))
        }
        return result
    }

    private static func styled(
        _ entry: String,
        nameColor: Color,
        sourceColor: Color
    ) -> AttributedString {
        let trimmed = entry.trimmingCharacters(in: .whitespaces)
        guard let open = trimmed.firstIndex(of: "("), trimmed.hasSuffix(")") else {
            return run(trimmed, color: nameColor, weight: .medium)
        }
        let name = String(trimmed[trimmed.startIndex..<open])
            .trimmingCharacters(in: .whitespaces)
        let source = String(trimmed[open...])
        guard !name.isEmpty else { return run(trimmed, color: nameColor, weight: .medium) }

        // Non-breaking space keeps a short title glued to its character name,
        // so a wrap can only ever happen at a " · " separator.
        var combined = run(name, color: nameColor, weight: .medium)
        combined.append(run("\u{00A0}" + source, color: sourceColor, weight: .regular))
        return combined
    }

    private static func run(_ text: String, color: Color, weight: Font.Weight) -> AttributedString {
        var piece = AttributedString(text)
        piece.foregroundColor = color
        piece.font = .caption.weight(weight)
        return piece
    }
}
