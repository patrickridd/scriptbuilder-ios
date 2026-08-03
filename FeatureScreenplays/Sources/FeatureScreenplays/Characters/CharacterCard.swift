import SwiftUI
import Domain
import DesignSystem

/// A single cast-list card: role glyph, name, role, and an intention preview.
struct CharacterCard: View {
    @Environment(\.appPalette) private var palette
    let character: Character
    var isHighlighted: Bool = false

    private var role: CharacterRole { CharacterRole.bucket(for: character.role) }

    private var preview: String {
        let intention = character.intention.trimmingCharacters(in: .whitespacesAndNewlines)
        return intention.isEmpty ? "No intention set yet" : intention
    }

    var body: some View {
        HStack(spacing: 14) {
            roleGlyph
            VStack(alignment: .leading, spacing: 10) {
                nameRow
                Text(preview)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
            chevron
        }
        .padding(14)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(cardBorder)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }

    private var filledCount: Int { CharacterArcField.filledCount(for: character) }
    private var totalCount: Int { CharacterArcField.scoreable.count }
    private var isComplete: Bool { totalCount > 0 && filledCount == totalCount }

    private var nameRow: some View {
        HStack(spacing: 12) {
            Text(character.name.isEmpty ? "Unnamed" : character.name)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
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
                .font(.caption.weight(.semibold))
                .monospacedDigit()
                .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
                .padding(.horizontal, 8)
                .padding(.vertical, 3)
                .background(palette.accent.opacity(isComplete ? 0.14 : 0.06), in: Capsule())
                .accessibilityLabel(arcAccessibilityLabel)
        }
    }

    private var arcAccessibilityLabel: String {
        "Arc \(filledCount) of \(totalCount) complete"
    }

    private var roleGlyph: some View {
        Image(systemName: role.systemImage)
            .font(.title3.weight(.semibold))
            .foregroundStyle(.white)
            .frame(width: 46, height: 46)
            .background(palette.heroGradient, in: RoundedRectangle(cornerRadius: 13, style: .continuous))
    }

    private var cardBorder: some View {
        RoundedRectangle(cornerRadius: 16, style: .continuous)
            .stroke(
                isHighlighted ? palette.accent.opacity(0.9) : palette.cardStroke,
                lineWidth: isHighlighted ? 1.5 : 1
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
