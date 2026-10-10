import SwiftUI
import Domain
import DesignSystem

/// A single identity chip shown on a cast-list card.
private struct IdentityTag: Identifiable {
    let text: String
    let facet: IdentityHue.Facet
    var id: String { "\(facet)-" + text }
}

extension Character {

    /// A string that changes whenever anything a cast-list card *renders*
    /// changes: name, role bucket, intention preview, every identity chip
    /// (role / archetypes / story functions, custom labels included) and the
    /// progress ring's filled count. Passed to `CharacterCard.revision` so the
    /// card re-renders in place instead of waiting for a structural refresh.
    var cardRevision: String {
        var parts: [String] = [uuid, name, role ?? "", intention]
        if let identityRole = identity.role {
            parts.append("R:" + identityRole.slug + "/" + (identityRole.customLabel ?? ""))
        }
        parts += identity.archetypes.map { "A:" + $0.slug + "/" + ($0.customLabel ?? "") }
        parts += identity.storyFunctions.map { "F:" + $0.slug + "/" + ($0.customLabel ?? "") }
        let filled = CharacterIdentityField.filledCount(for: self) + CharacterArcField.filledCount(for: self)
        parts.append("P:\(filled)/\(arcTotalCount)")
        parts.append(arcNotApplicable ? "N:1" : "N:0")
        return parts.joined(separator: "~")
    }
}

/// A single cast-list card: role glyph, name, role, and an intention preview.
struct CharacterCard: View {
    @Environment(\.appPalette) private var palette
    let character: Character
    /// Fingerprint of everything this card draws (see `Character.cardRevision`).
    ///
    /// `Character` is `Equatable` on `uuid` **only**, so SwiftUI's structural
    /// comparison considers two cards for the same character identical even
    /// after its role / archetypes / story functions changed — and skips
    /// re-evaluating `body`, which is why freshly picked traits used to appear
    /// only after a round trip through the detail screen forced a rebuild.
    /// Holding the fingerprint here makes the view value itself change.
    var revision: String = ""
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
            VStack(alignment: .leading, spacing: 14) {
                topCardSection
                identityChips
                    .padding(.leading, 16)
            }
            chevron
        }
        .padding(14)
        .background(cardShape.fill(palette.cardSurface))
        .overlay(cardBorder)
        .compositingGroup()
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
    
    var topCardSection: some View {
        HStack(alignment: .center, spacing: 14) {
            roleGlyph
            VStack(alignment: .leading, spacing: 6) {
                nameRow
                previewLine
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
        }
    }

    /// Mirrors the detail screen's ring: identity facets + scoreable arc fields.
    private var filledCount: Int {
        CharacterIdentityField.filledCount(for: character) + CharacterArcField.filledCount(for: character)
    }

    private var totalCount: Int {
        CharacterIdentityField.allCases.count + CharacterArcField.totalCount(for: character)
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

    /// Role first, then archetypes, then story functions — the same order the
    /// writer fills them in. Capped so a card never grows tall.
    private var identityTags: [IdentityTag] {
        let roleTag = character.identity.role.map {
            IdentityTag(text: IdentityCatalog.displayName(for: $0), facet: .role)
        }
        let archetypes = character.identity.archetypes.map {
            IdentityTag(
                text: IdentityCatalog.displayName(for: $0, in: IdentityCatalog.archetypes),
                facet: .archetype
            )
        }
        let functions = character.identity.storyFunctions.map {
            IdentityTag(
                text: IdentityCatalog.displayName(for: $0, in: IdentityCatalog.storyFunctions),
                facet: .storyFunction
            )
        }
        return [roleTag].compactMap { $0 } + archetypes + functions
    }

    private static let maxVisibleTags = 5

    @ViewBuilder
    private var identityChips: some View {
        let tags = identityTags
        if !tags.isEmpty {
            let visible = Array(tags.prefix(Self.maxVisibleTags))
            let overflow = tags.count - visible.count
            FlowLayout(spacing: 6, lineSpacing: 6) {
                ForEach(visible) { tag in
                    chip(tag.text, facet: tag.facet)
                }
                if overflow > 0 {
                    overflowChip(overflow)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .accessibilityElement(children: .combine)
        }
    }

    private func chip(_ text: String, facet: IdentityHue.Facet) -> some View {
        let hue = IdentityHue.hue(for: facet)
        return HStack(spacing: 4) {
            Image(systemName: IdentityHue.glyph(for: facet))
                .font(.system(size: 9, weight: .semibold))
                .accessibilityHidden(true)
            Text(text)
                .font(.caption2.weight(.medium))
                .lineLimit(1)
        }
            .foregroundStyle(hue)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(hue.opacity(0.14), in: Capsule())
            .overlay(Capsule().stroke(hue.opacity(0.22), lineWidth: 1))
    }

    private func overflowChip(_ count: Int) -> some View {
        Text("+\(count)")
            .font(.caption2.weight(.semibold))
            .foregroundStyle(palette.textMuted)
            .padding(.horizontal, 7)
            .padding(.vertical, 4)
            .background(palette.textMuted.opacity(0.10), in: Capsule())
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
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(palette.accent.opacity(isComplete ? 0.14 : 0.06), in: Capsule())
                .accessibilityLabel(arcAccessibilityLabel)
                .accessibilityElement(children: .ignore)
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
/// Sample cast tuned to exercise every chip state: accent archetypes, violet
/// story functions, a mixed card, a custom (writer-typed) trait, the "+N"
/// overflow marker, and a card with no identity at all.
enum CharacterCardSamples {

    static let mixed = Character(
        name: "Nora Vance",
        role: "Protagonist",
        identity: CharacterIdentity(
            role: HierarchicalRole(slug: HierarchicalRole.Stock.protagonist),
            archetypes: [.stock(ArchetypeSlug.hero), .stock(ArchetypeSlug.rebel)],
            storyFunctions: [.stock(StoryFunctionSlug.catalyst)]
        ),
        intention: "Win back the observatory before the grant deadline."
    )

    static let functionsOnly = Character(
        name: "Professor Aoki",
        role: "Mentor",
        identity: CharacterIdentity(
            storyFunctions: [
                .stock(StoryFunctionSlug.voiceOfReason),
                .stock(StoryFunctionSlug.confidant)
            ]
        ),
        intention: "Teach Nora that proof matters more than pride."
    )

    static let overflowing = Character(
        name: "Desmond Kade",
        role: "Antagonist",
        identity: CharacterIdentity(
            archetypes: [.stock(ArchetypeSlug.shadow), .stock(ArchetypeSlug.ruler)],
            storyFunctions: [
                .stock(StoryFunctionSlug.saboteur),
                .stock(StoryFunctionSlug.tempter),
                .stock(StoryFunctionSlug.foil)
            ]
        ),
        intention: "Bury the discovery to protect his legacy."
    )

    static let custom = Character(
        name: "Sam Ortiz",
        role: "Friend",
        identity: CharacterIdentity(
            archetypes: [.custom("Night Owl")],
            storyFunctions: [.custom("Getaway Driver")]
        ),
        intention: "Keep the crew laughing when the funding falls through."
    )

    static let blank = Character(name: "", role: nil)
}

private struct CharacterCardPreview: View {
    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 12) {
                    CharacterCard(character: CharacterCardSamples.mixed)
                    CharacterCard(character: CharacterCardSamples.functionsOnly)
                    CharacterCard(character: CharacterCardSamples.overflowing, isHighlighted: true)
                    CharacterCard(character: CharacterCardSamples.custom)
                    CharacterCard(character: CharacterCardSamples.blank)
                }
                .padding(16)
            }
        }
    }
}

#Preview("Character Card — Light") { CharacterCardPreview() }
#Preview("Character Card — Dark") { CharacterCardPreview().preferredColorScheme(.dark) }

#Preview("Chips — Dynamic Type XXL") {
    CharacterCardPreview()
        .environment(\.sizeCategory, .accessibilityExtraLarge)
}
#endif
