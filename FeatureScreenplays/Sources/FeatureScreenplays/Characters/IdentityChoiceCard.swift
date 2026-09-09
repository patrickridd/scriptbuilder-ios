//
//  IdentityChoiceCard.swift
//  FeatureScreenplays
//
//  One selectable choice in an identity picker: name, one-line definition,
//  film examples, selection indicator, and an optional delete action for
//  custom (writer-created) entries.
//

import SwiftUI
import DesignSystem

struct IdentityChoiceCard: View {
    @Environment(\.appPalette) private var palette

    let name: String
    let definition: String?
    let examples: String?
    /// Optional scholarly term shown as a quiet caption under the name.
    var classicalName: String?
    /// The noun this choice is filed under, shown as a small tag beneath an
    /// action headline (story functions lead with the verb phrase instead).
    var term: String?
    let isSelected: Bool
    let onTap: () -> Void
    var onDelete: (() -> Void)?
    /// Facet hue for the selected state. Falls back to the app accent.
    var tint: Color?
    /// SF Symbol marking which facet this choice belongs to, so an archetype
    /// card never reads like a story-function card at a glance.
    var glyph: String?

    private var accent: Color { tint ?? palette.accent }

    /// Name-only cards (custom entries) read best centred; multi-line cards
    /// keep their indicator pinned to the first line of text.
    private var isCompact: Bool {
        (definition?.isEmpty ?? true) && (examples?.isEmpty ?? true)
            && (classicalName?.isEmpty ?? true) && (term?.isEmpty ?? true)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: isCompact ? .center : .top, spacing: 12) {
                glyphBadge
                textStack
                Spacer(minLength: 0)
                deleteButton
                selectionIndicator
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(border)
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isSelected ? accent : palette.textMuted.opacity(0.5))
            .frame(height: isCompact ? nil : titleLineHeight)
    }

    /// Facet glyph in its own leading column, vertically centred on the title
    /// line so it reads as a marker for the headline, not for the paragraph.
    @ViewBuilder
    private var glyphBadge: some View {
        if let glyph, !glyph.isEmpty {
            Image(systemName: glyph)
                .font(.footnote.weight(.semibold))
                .foregroundStyle(accent.opacity(isSelected ? 1 : 0.75))
                .frame(width: 18, height: isCompact ? nil : titleLineHeight)
                .accessibilityHidden(true)
        }
    }

    /// Height of the title's line box, used to centre the leading glyph and
    /// the trailing checkmark against the headline.
    private var titleLineHeight: CGFloat { 22 }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 6) {
            nameLine
            if let term, !term.isEmpty {
                Text(term)
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(0.6)
                    .foregroundStyle(accent.opacity(isSelected ? 1 : 0.85))
                    .accessibilityLabel(IdentityUIStrings.knownAs(term))
            }
            if let classicalName, !classicalName.isEmpty {
                Text(classicalName)
                    .font(.caption2)
                    .italic()
                    .foregroundStyle(palette.textMuted)
                    .accessibilityLabel(IdentityUIStrings.classicalTerm(classicalName))
            }
            if let definition, !definition.isEmpty {
                Text(definition)
                    .font(.footnote)
                    .foregroundStyle(palette.textSecondary)
                    .multilineTextAlignment(.leading)
            }
            if let examples, !examples.isEmpty {
                HStack {
                    Text("Examples:")
                        .font(.caption)
                    Text(examples)
                        .font(.caption)
                        .italic()
                        .foregroundStyle(palette.accent)
                        .multilineTextAlignment(.leading)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    /// The headline itself. The facet glyph sits in its own column to the
    /// left so long names wrap flush instead of tucking under the symbol.
    private var nameLine: some View {
        Text(name)
            .font(.body.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
            .multilineTextAlignment(.leading)
            .frame(minHeight: isCompact ? nil : titleLineHeight, alignment: .leading)
    }

    @ViewBuilder
    private var deleteButton: some View {
        if let onDelete {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Action.delete)
        }
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? accent.opacity(0.7) : palette.cardStroke, lineWidth: isSelected ? 1.5 : 1)
    }
}

/// Full selection display for multi-select rows: every chosen trait as a chip,
/// wrapping onto as many lines as it needs beneath the row it belongs to.
/// Each chip is a navigation link straight to that trait inside the picker.
struct TraitChipsWrap<Destination: View>: View {
    @Environment(\.appPalette) private var palette

    let names: [String]
    /// Chip hue; defaults to the app accent when not supplied.
    var tint: Color?
    /// Facet glyph carried on every chip, matching the picker cards.
    var glyph: String?
    @ViewBuilder var destination: (Int) -> Destination

    private var hue: Color { tint ?? palette.accent }

    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(Array(names.enumerated()), id: \.offset) { index, name in
                NavigationLink {
                    destination(index)
                } label: {
                    chip(name)
                }
                .buttonStyle(PressableScaleStyle())
                .accessibilityLabel(name)
                .accessibilityHint(IdentityUIStrings.chipHint)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func chip(_ name: String) -> some View {
        HStack(spacing: 4) {
            if let glyph, !glyph.isEmpty {
                Image(systemName: glyph)
                    .font(.caption2.weight(.semibold))
                    .accessibilityHidden(true)
            }
            Text(name)
                .font(.caption.weight(.medium))
                .lineLimit(1)
        }
        .foregroundStyle(hue)
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(hue.opacity(0.14), in: Capsule())
        .overlay(Capsule().stroke(hue.opacity(0.25), lineWidth: 1))
    }
}

/// Inline summary for multi-select rows: the first two selections as small
/// chips plus a "+N" overflow marker.
struct TraitChipsPreview: View {
    @Environment(\.appPalette) private var palette

    let names: [String]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(names.prefix(2)), id: \.self) { name in
                chip(name)
            }
            if names.count > 2 {
                Text("+\(names.count - 2)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
            }
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(palette.accent.opacity(0.12), in: Capsule())
    }
}

#if DEBUG
/// Gallery of every shape the card can take, one per facet plus the two
/// special cases (a classical term, and a compact custom entry with delete).
/// Tapping toggles selection so the accent border, tinted glyph and checkmark
/// can be checked live in both colour schemes.
private struct IdentityChoiceCardGallery: View {
    @State private var selected: Set<String> = ["protagonist", "instigator"]

    private var roleHue: Color { IdentityHue.hue(for: .role) }
    private var archetypeHue: Color { IdentityHue.hue(for: .archetype) }
    private var functionHue: Color { IdentityHue.hue(for: .storyFunction) }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 12) {
                    roleCard
                    archetypeCard
                    storyFunctionCard
                    customCard
                }
                .padding(16)
            }
        }
    }

    private var roleCard: some View {
        card(
            id: "protagonist",
            name: "Protagonist",
            definition: "The character whose choices drive the story forward.",
            examples: "Clarice Starling · Michael Corleone",
            facet: .role,
            tint: roleHue
        )
    }

    private var archetypeCard: some View {
        card(
            id: "mentor",
            name: "Mentor",
            definition: "Guides the lead, then steps aside so they can face it alone.",
            examples: "Obi-Wan Kenobi · Mickey Goldmill",
            facet: .archetype,
            tint: archetypeHue,
            classicalName: "Senex"
        )
    }

    /// Story functions lead with the verb phrase and file the noun underneath.
    private var storyFunctionCard: some View {
        card(
            id: "instigator",
            name: "Stirs up trouble",
            definition: "Pushes the story off balance and keeps the pressure on.",
            examples: "Amy Dunne · Loki",
            facet: .storyFunction,
            tint: functionHue,
            term: "Instigator"
        )
    }

    /// Writer-typed entry: name only, so it centres and offers a delete.
    private var customCard: some View {
        IdentityChoiceCard(
            name: "Reluctant Fixer",
            definition: nil,
            examples: nil,
            isSelected: selected.contains("custom"),
            onTap: { toggle("custom") },
            onDelete: {},
            tint: functionHue,
            glyph: IdentityHue.glyph(for: .storyFunction)
        )
    }

    private func card(
        id: String,
        name: String,
        definition: String,
        examples: String,
        facet: IdentityHue.Facet,
        tint: Color,
        classicalName: String? = nil,
        term: String? = nil
    ) -> some View {
        IdentityChoiceCard(
            name: name,
            definition: definition,
            examples: examples,
            classicalName: classicalName,
            term: term,
            isSelected: selected.contains(id),
            onTap: { toggle(id) },
            tint: tint,
            glyph: IdentityHue.glyph(for: facet)
        )
    }

    private func toggle(_ id: String) {
        if selected.contains(id) {
            selected.remove(id)
        } else {
            selected.insert(id)
        }
    }
}

#Preview("Identity Choice Cards — Light") {
    IdentityChoiceCardGallery()
}

#Preview("Identity Choice Cards — Dark") {
    IdentityChoiceCardGallery()
        .preferredColorScheme(.dark)
}
#endif
