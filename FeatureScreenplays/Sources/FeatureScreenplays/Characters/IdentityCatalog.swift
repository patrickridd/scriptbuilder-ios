//
//  IdentityCatalog.swift
//  FeatureScreenplays
//
//  Display content for the Character Identity pickers: names, one-line
//  definitions, and film examples for every stock slug in the Domain layer's
//  HierarchicalRole / Archetype / StoryFunction catalogs. Slugs are the
//  stable storage keys; everything here is presentation only.
//

import Foundation
import Domain

/// One presentable choice in an identity picker.
struct IdentityCatalogEntry: Identifiable, Hashable {
    let slug: String
    let name: String
    let definition: String
    let examples: String
    /// Scholarly term for the same idea (e.g. "Deuteragonist"), shown as a
    /// quiet caption so the plain-English name can lead.
    var classicalName: String?

    var id: String { slug }
}

enum IdentityCatalog {

    // MARK: - Roles (grouped by tier)

    static let mainRoles: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.protagonist,
            name: "Protagonist",
            definition: "The story's central character, whose goal drives the plot.",
            examples: "Luke Skywalker · Erin Brockovich"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.antagonist,
            name: "Antagonist",
            definition: "The main force standing against the protagonist's goal.",
            examples: "Darth Vader · Nurse Ratched"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.secondLead,
            name: "Second Lead",
            definition: "The second most important character — often the closest companion.",
            examples: "Samwise Gamgee · Dr. Watson",
            classicalName: "Deuteragonist"
        )
    ]

    static let supportingRoles: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.thirdLead,
            name: "Third Lead",
            definition: "The third most important character; completes the core trio.",
            examples: "Han Solo · Hermione Granger",
            classicalName: "Tritagonist"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.fourthLead,
            name: "Fourth Lead",
            definition: "Fourth in importance; a steady presence in the ensemble.",
            examples: "Ron Weasley · Merry Brandybuck",
            classicalName: "Tetartagonist"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.recurring,
            name: "Recurring",
            definition: "A recurring minor character who colors the world without steering the plot.",
            examples: "Moaning Myrtle · The Log Lady",
            classicalName: "Fringe"
        )
    ]

    static var allRoles: [IdentityCatalogEntry] {
        mainRoles + supportingRoles
    }

    static func roleEntry(for slug: String) -> IdentityCatalogEntry? {
        allRoles.first { $0.slug == slug }
    }

    // MARK: - Archetypes

    static let archetypes: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: ArchetypeSlug.hero, name: "Hero",
            definition: "Rises to the challenge and sacrifices for others.",
            examples: "Luke Skywalker · Mulan"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.mentor, name: "Mentor",
            definition: "Guides the hero's growth with wisdom and gifts.",
            examples: "Obi-Wan Kenobi · Mr. Miyagi"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.antiHero, name: "Anti-Hero",
            definition: "A flawed lead who does the right thing the wrong way.",
            examples: "Tony Soprano · Deadpool"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.tragicHero, name: "Tragic Hero",
            definition: "A noble, generally good character whose fatal flaw or "
                + "misjudgment leads to their downfall and death.",
            examples: "Anakin Skywalker · Harvey Dent · Michael Corleone"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.villain, name: "Villain",
            definition: "Commits evil intentionally to oppose the hero and serve "
                + "malicious goals.",
            examples: "Lord Voldemort · The Joker · Sauron"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.antiVillain, name: "Anti-Villain",
            definition: "Opposes the hero, yet acts on noble intentions or a "
                + "sympathetic past.",
            examples: "Killmonger · Magneto · Thanos"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.falseAntagonist, name: "False Antagonist",
            definition: "Introduced as a threat, later revealed as an ally or an "
                + "innocent.",
            examples: "Severus Snape · The Iron Giant · Boo Radley"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.hiddenAntagonist, name: "Hidden Antagonist",
            definition: "A mastermind who hides their identity or motives until the "
                + "twist lands.",
            examples: "Palpatine · Lotso · Peter Pettigrew"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.heroAntagonist, name: "Hero Antagonist",
            definition: "Doing the right thing — and it puts them squarely against "
                + "our lead.",
            examples: "Inspector Javert · Hank Schrader · Chief Inspector Campbell"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.innerAntagonist, name: "Inner Antagonist",
            definition: "The flaw, guilt, or self-sabotage inside the hero that is "
                + "the real obstacle.",
            examples: "Walter White's hubris · Holden Caulfield's alienation"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.inanimateAntagonist, name: "Inanimate Antagonist",
            definition: "A non-sentient force — nature, disease, machine — that the "
                + "hero must survive.",
            examples: "Mars (The Martian) · The Overlook Hotel · The iceberg (Titanic)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.shadow, name: "Shadow",
            definition: "The dark mirror of the hero's repressed side.",
            examples: "Darth Vader · Tyler Durden"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.shapeshifter, name: "Shapeshifter",
            definition: "Loyalty and identity keep shifting — keeps everyone guessing.",
            examples: "Catwoman · Severus Snape"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.jester, name: "Jester",
            definition: "Uses humor to disarm — and to speak the truth.",
            examples: "Genie · Donkey"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.lover, name: "Lover",
            definition: "Led by the heart; seeks intimacy and connection.",
            examples: "Rose DeWitt · Noah Calhoun"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.rebel, name: "Rebel",
            definition: "Breaks the rules to upend the status quo.",
            examples: "Katniss Everdeen · V"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.caregiver, name: "Caregiver",
            definition: "Protects and nurtures others, often at personal cost.",
            examples: "Samwise Gamgee · Mary Poppins"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.warrior, name: "Warrior",
            definition: "Lives by courage, discipline, and the fight.",
            examples: "Maximus · Sarah Connor"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.ruler, name: "Ruler",
            definition: "Craves control and order; leads — or dominates.",
            examples: "Michael Corleone · Miranda Priestly"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.innocent, name: "Innocent",
            definition: "Sees the world with optimism and trust.",
            examples: "Forrest Gump · Buddy the Elf"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.sidekick, name: "Sidekick",
            definition: "The loyal companion who steadies and supports.",
            examples: "Ron Weasley · Chewbacca"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.artist, name: "Artist",
            definition: "Creates meaning and sees the world differently.",
            examples: "Amélie · Jack Dawson"
        )
    ]

    // MARK: - Story functions

    static let storyFunctions: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.catalyst, name: "Catalyst",
            definition: "Sparks the story into motion.",
            examples: "R2-D2 · The White Rabbit"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.foil, name: "Foil",
            definition: "Contrasts the hero to reveal their qualities.",
            examples: "Draco Malfoy · Buzz Lightyear"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.confidant, name: "Confidant",
            definition: "The trusted ear where inner thoughts surface.",
            examples: "Dr. Watson · Horatio"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.thresholdGuardian, name: "Threshold Guardian",
            definition: "Tests the hero at the gate of new territory.",
            examples: "The Sphinx · Emerald City gatekeeper"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.herald, name: "Herald",
            definition: "Announces the call to adventure.",
            examples: "Hagrid · Effie Trinket"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.comicRelief, name: "Comic Relief",
            definition: "Breaks tension with humor.",
            examples: "C-3PO · Olaf"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.loveInterest, name: "Love Interest",
            definition: "The romantic stake that raises the pressure.",
            examples: "Mary Jane Watson · Peeta Mellark"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.voiceOfReason, name: "Voice of Reason",
            definition: "Grounds the group with logic and caution.",
            examples: "Spock · Hermione Granger"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.redHerring, name: "Red Herring",
            definition: "Draws suspicion to mislead the audience.",
            examples: "Severus Snape · Bishop Aringarosa"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.audienceSurrogate, name: "Audience Surrogate",
            definition: "Asks what we're all thinking — our way into the world.",
            examples: "Nick Carraway · Bilbo Baggins"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.harbinger, name: "Harbinger",
            definition: "Foreshadows what's coming.",
            examples: "The Three Witches · The Fortune Teller"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.mirror, name: "Mirror",
            definition: "Reflects the hero's choices taken down another path.",
            examples: "Gollum · Kylo Ren"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.saboteur, name: "Saboteur",
            definition: "Undermines the plan from within.",
            examples: "Cypher · Edmund Pevensie"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.tempter, name: "Tempter",
            definition: "Offers the easy, corrupting path.",
            examples: "Palpatine · The White Witch"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.thematicAnchor, name: "Thematic Anchor",
            definition: "Embodies the story's central idea.",
            examples: "Yoda · Atticus Finch"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.instigator, name: "Instigator",
            definition: "Stirs conflict and forces decisions.",
            examples: "Iago · Tyler Durden"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.henchman, name: "Henchman",
            definition: "Executes the antagonist's will.",
            examples: "Oddjob · Crabbe & Goyle"
        )
    ]

    // MARK: - Display helpers

    /// Display text for a selected role: the writer's own label for custom /
    /// legacy roles (shown as-is), otherwise the stock catalog name.
    static func displayName(for role: HierarchicalRole) -> String {
        if let label = role.customLabel, !label.isEmpty { return label }
        return roleEntry(for: role.slug)?.name ?? role.slug.capitalized
    }

    /// Display text for a selected trait against a given catalog.
    static func displayName(for trait: IdentityTrait, in catalog: [IdentityCatalogEntry]) -> String {
        if let label = trait.customLabel, !label.isEmpty { return label }
        return catalog.first { $0.slug == trait.slug }?.name ?? trait.slug.capitalized
    }
}

/// UI copy for the identity pickers. English-only for now; the catalog content
/// above is inherently English so these live alongside it until a dedicated
/// localization pass.
enum IdentityUIStrings {
    static let sectionTitle = "Identity"
    static let arcCardSubtitle = "Where they start, break and land"
    static let roleRow = "Role"
    static let archetypeRow = "Archetype"
    static let storyFunctionRow = "Story Function"
    static let noneValue = "None"
    static let characterComplete = "Fully developed — identity and arc"
    static let intentionPrefix = "Wants to:"
    static let namePlaceholderTitle = "Name your character"
    static let nameFieldLabel = "Character name"
    /// Short prompt used inside the header field, where width is precious.
    static let nameFieldPrompt = "Character name"
    static let nameFieldDone = "Done"
    /// Menu action that drops the caret into the header name field.
    static let changeNameAction = "Change Name"
    static let moreActions = "More actions"
    static let chipHint = "Opens this choice in the picker"

    /// Spoken form of the scholarly caption, e.g. "Also called Deuteragonist".
    static func classicalTerm(_ term: String) -> String {
        "Also called \(term)"
    }

    /// Trailing summary for a multi-select row, e.g. "2 selected".
    static func selectedCount(_ count: Int) -> String {
        "\(count) selected"
    }
    static let clearRole = "No Role"
    static let tierMain = "Main"
    static let tierMainDescription = "Carries the story"
    static let tierSupporting = "Supporting"
    static let tierSupportingDescription = "Shapes it from the edges"
    static let customSection = "Custom"
    static let customSectionDescription = "Anything the list is missing"
    static let savedRoleSection = "Your Saved Role"
    static let savedRoleHint = "Roles now come from the list above. Pick one to replace this."
    static let customTraitPlaceholder = "Add your own…"
    static let addCustom = "Add"
    static let archetypeNudge = "Most memorable characters embody 1–3 archetypes."
    static let storyFunctionNudge = "A focused set of 1–3 story functions reads strongest."

    /// Title above the role-relevant choices. The sources it was drawn from
    /// are named in the description line beneath it.
    static let suggestedSection = "Suggested"

    /// Description naming every source a suggestion set came from, e.g.
    /// "Fits your Second Lead · Mentor". Nil when nothing is driving the order.
    static func suggestedDescription(sources: [String]) -> String? {
        guard !sources.isEmpty else { return nil }
        return "Fits your \(sources.joined(separator: " · "))"
    }

    /// Disclosure label revealing the full catalog, e.g. "All Archetypes".
    static func allChoices(_ title: String) -> String {
        "All \(title)s"
    }

    /// Badge on the disclosure showing how many choices remain hidden, e.g. "+9".
    static func moreCount(_ count: Int) -> String {
        "+\(count)"
    }

    /// Spoken version of the disclosure label, e.g. "All Archetypes, 9 more".
    static func allChoicesAccessibility(_ title: String, count: Int) -> String {
        "\(allChoices(title)), \(count) more"
    }
}
