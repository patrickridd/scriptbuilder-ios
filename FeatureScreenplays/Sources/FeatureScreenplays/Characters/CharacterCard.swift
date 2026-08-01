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
            VStack(alignment: .leading, spacing: 3) {
                Text(character.name.isEmpty ? "Unnamed" : character.name)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
                    .lineLimit(1)
                Text(preview)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted)
        }
        .padding(14)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(cardBorder)
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
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
