//
//  IdentitySectionIntro.swift
//  FeatureScreenplays
//
//  Explanatory header shown at the top of each identity picker (Role,
//  Archetype, Story Function). The character's name owns the nav bar title,
//  so each screen states its own subject here: a big section heading, a
//  large-type core definition, and smaller supporting copy.
//

import SwiftUI
import DesignSystem

/// Static teaching copy for one identity picker screen.
struct IdentitySectionIntro {
    let title: String
    let symbol: String
    /// The one-line "what is this" definition, rendered in larger type.
    let lead: String
    /// Supporting paragraphs, rendered smaller.
    let paragraphs: [String]
    /// Optional closing note, called out beneath the paragraphs.
    let takeaway: String?

    static let role = IdentitySectionIntro(
        title: "Role",
        symbol: "person.3.sequence",
        lead: "Roles define a character's importance, screentime, and narrative weight in your story roster.",
        paragraphs: [
            "Unlike an Archetype (who a character is psychologically) or a Story Function (the mechanical tool they use to help the writer), a Hierarchical Role simply answers the question: \"How high up are they on the team roster?\"",
            "Think of it like the billing on a movie poster. It establishes who gets the main spotlight, who gets the subplots, and who is just populating the background."
        ],
        takeaway: nil
    )

    static let archetype = IdentitySectionIntro(
        title: "Archetype",
        symbol: "theatermasks",
        lead: "An Archetype defines a character's core psychology, universal personality pattern, and symbolic blueprint.",
        paragraphs: [
            "Unlike a Hierarchical Role (where they sit on the team roster) or a Story Function (how they mechanically move the plot), an Archetype answers the question: \"Who is this character at their absolute core?\"",
            "Think of it as a character's psychological DNA. Archetypes tap into ancient, recognizable human patterns (like the Mentor, the Rebel, or the Caregiver). Because these patterns are hardwired into our collective storytelling history, they instantly tell the audience how a character views, processes, and reacts to the world."
        ],
        takeaway: "An archetype doesn't change based on the plot. If you lock a character in an empty room by themselves, their Hierarchical Role vanishes, but their Archetype remains exactly the same."
    )

    static let storyFunction = IdentitySectionIntro(
        title: "Story Function",
        symbol: "gearshape.2",
        lead: "A Character Story Function defines a character's structural purpose and mechanical utility within the script or manuscript layout.",
        paragraphs: [
            "Unlike a Hierarchical Role (how much screen time they get) or an Archetype (what their personality is like), a Character Function answers the question: \"What tool does this character represent for the writer?\"",
            "Think of functions as the gears and levers of your plot. Characters hold functions to help the writer handle behind-the-scenes logistics — like delivering complex world-building details (Exposition Device), externalizing a hero's private thoughts (Confidant), highlighting a specific virtue through contrast (Foil), or forcing the plot past a major roadblock (Threshold Guardian)."
        ],
        takeaway: "Functions are fully flexible. A single character can hold multiple functions at once, or swap functions completely as they move from Act 1 to Act 2."
    )
}

/// Renders an `IdentitySectionIntro` as the header card of a picker screen.
/// Shows the heading plus the one-line definition; the deeper explanation is
/// tucked behind a "Learn more" disclosure so the list stays close to the top.
struct IdentitySectionHeader: View {
    @Environment(\.appPalette) private var palette

    let intro: IdentitySectionIntro

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: intro.symbol)
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(intro.title)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
            }
            Text(intro.lead)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
            learnMoreButton
            if isExpanded {
                expandedContent
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 8)
        .padding(.bottom, 4)
    }

    private var learnMoreButton: some View {
        Button {
            Haptics.selection()
            withAnimation(.easeInOut(duration: 0.22)) { isExpanded.toggle() }
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                    .font(.footnote.weight(.semibold))
                Text(isExpanded ? "Show less" : "Learn more")
                    .font(.subheadline.weight(.medium))
                Image(systemName: "chevron.down")
                    .font(.caption2.weight(.bold))
                    .rotationEffect(.degrees(isExpanded ? 180 : 0))
            }
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 14)
            .padding(.vertical, 9)
            .background(palette.accent.opacity(0.12), in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityLabel(isExpanded ? "Show less about \(intro.title)" : "Learn more about \(intro.title)")
    }

    private var expandedContent: some View {
        VStack(alignment: .leading, spacing: 10) {
            paragraphStack
            if let takeaway = intro.takeaway {
                takeawayBlock(takeaway)
            }
        }
        .transition(.opacity.combined(with: .move(edge: .top)))
    }

    private var paragraphStack: some View {
        VStack(alignment: .leading, spacing: 10) {
            ForEach(Array(intro.paragraphs.enumerated()), id: \.offset) { _, text in
                Text(text)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
    }

    private func takeawayBlock(_ text: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("KEY TAKEAWAY")
                .font(.caption2.weight(.bold))
                .foregroundStyle(palette.accent)
            Text(text)
                .font(.footnote)
                .foregroundStyle(palette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(palette.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}
