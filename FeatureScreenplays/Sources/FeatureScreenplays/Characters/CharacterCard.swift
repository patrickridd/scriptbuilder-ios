import SwiftUI
import Domain
import DesignSystem

/// A single cast-list card: role glyph, name, role, and an intention preview.
struct CharacterCard: View {
    @Environment(\.appPalette) private var palette
    let character: Character
    var isHighlighted: Bool = false

    private var role: CharacterRole { CharacterRole.bucket(for: character.role) }

    private var trimmedIntention: String {
        character.intention.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var preview: String {
        trimmedIntention.isEmpty ? "No intention set yet" : trimmedIntention
    }

    /// "Wants to: …" once an intention exists; the empty-state line stays plain.
    private var previewLine: Text {
        guard !trimmedIntention.isEmpty else { return Text(preview) }
        return Text(IdentityUIStrings.intentionPrefix)
            .fontWeight(.medium)
            .foregroundColor(palette.textPrimary)
            + Text(" " + trimmedIntention)
    }

    var body: some View {
        HStack(spacing: 14) {
            roleGlyph
            VStack(alignment: .leading, spacing: 10) {
                nameRow
                previewLine
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
            chevron
        }
        .padding(14)        .background(cardShape.fill(palette.cardSurface))
        .overlay(cardBorder)
        .compositingGroup()
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }

    /// Mirrors the detail screen's ring: identity facets + scoreable arc fields.
    private var filledCount: Int {
        CharacterIdentityField.filledCount(for: character) + CharacterArcField.filledCount(for: character)
    }

    private var totalCount: Int {
        CharacterIdentityField.allCases.count + CharacterArcField.scoreable.count
    }

    private var isComplete: Bool { totalCount > 0 && filledCount == totalCount }

    private var fraction: Double {
        totalCount > 0 ? Double(filledCount) / Double(totalCount) : 0
    }

    private var trimmedName: String {
        character.name.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var hasName: Bool { !trimmedName.isEmpty }

    private var nameRow: some View {
        HStack(spacing: 12) {
            Text(hasName ? trimmedName : IdentityUIStrings.namePlaceholderTitle)
                .font(hasName ? .headline : .subheadline.weight(.medium))
                .foregroundStyle(hasName ? palette.textPrimary : palette.textMuted)
                .lineLimit(1)
            Spacer(minLength: 4)
            progressBadge
        }
        .accessibilityElement(children: .combine)
    }

    private var chevron: some View {
        Image(systemName: "chevron.right")
            .font(.footnote.weight(.semibold))
            .foregroundStyle(palette.textMuted.opacity(0.6))
    }

    @ViewBuilder
    private var progressBadge: some View {
        if totalCount > 0 {
            Text("\(filledCount)/\(totalCount)")
                .font(.caption2.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(arcAccessibilityLabel)
        }
    }

    private var arcAccessibilityLabel: String {
        "\(filledCount) of \(totalCount) fields complete"
    }

    private var roleGlyph: some View {
        Image(systemName: role.systemImage)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background(palette.heroGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var cardShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
    }

    /// Drawn with `strokeBorder` so the full line sits *inside* the card bounds.
    /// A plain `stroke` straddles the edge, and the outer half was being clipped
    /// by the enclosing list row — which made the highlight border look like it
    /// stopped short of wrapping the card.
    private var cardBorder: some View {
        cardShape
            .strokeBorder(
                isHighlighted ? palette.accent.opacity(0.9) : palette.cardStroke,
                lineWidth: isHighlighted ? 2 : 1
            )
    }
}

#if DEBUG
private struct CharacterCardPreview: View {
    var body: some View {
        ZStack {
            AppBackground()
            VStack(spacing: 12) {
                CharacterCard(
                    character: Character(
                        name: "Nora Vance",
                        role: "Protagonist",
                        intention: "Win back the observatory before the grant deadline."
                    )
                )
                CharacterCard(
                    character: Character(
                        name: "Desmond Kade",
                        role: "Antagonist",
                        intention: "Bury the discovery to protect his legacy."
                    ),
                    isHighlighted: true
                )
                CharacterCard(character: Character(name: "", role: nil))
            }
            .padding(16)
        }
    }
}

#Preview("Character Card — Light") { CharacterCardPreview() }
#Preview("Character Card — Dark") { CharacterCardPreview().preferredColorScheme(.dark) }
#endif
