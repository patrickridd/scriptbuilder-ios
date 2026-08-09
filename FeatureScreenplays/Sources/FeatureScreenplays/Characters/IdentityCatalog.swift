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

    var id: String { slug }
}

enum IdentityCatalog {

    // MARK: - Roles (grouped by tier)

    static let primaryRoles: [IdentityCatalogEntry] = [
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
            slug: HierarchicalRole.Stock.deuteragonist,
            name: "Deuteragonist",
            definition: "The second most important character — often the closest companion.",
            examples: "Samwise Gamgee · Dr. Watson"
        )
    ]

    static let secondaryRoles: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.tritagonist,
            name: "Tritagonist",
            definition: "The third most important character; completes the core trio.",
            examples: "Han Solo · Hermione Granger"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.tetratagonist,
            name: "Tetratagonist",
            definition: "Fourth in importance; a steady presence in the ensemble.",
            examples: "Ron Weasley · Merry Brandybuck"
        )
    ]

    static let backgroundRoles: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.fringe,
            name: "Fringe",
            definition: "A recurring minor character who colors the world without steering the plot.",
            examples: "Moaning Myrtle · The Log Lady"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.background,
            name: "Background",
            definition: "Faces in the crowd — walk-ons and extras that populate scenes.",
            examples: "Cantina patrons · Hogwarts students"
        )
    ]

    static var allRoles: [IdentityCatalogEntry] {
        primaryRoles + secondaryRoles + backgroundRoles
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
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.sidekick, name: "Sidekick",
            definition: "Rides along — support in action.",
            examples: "Robin · Samwise Gamgee"
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
    static let roleRow = "Role"
    static let archetypeRow = "Archetype"
    static let storyFunctionRow = "Story Function"
    static let noneValue = "None"
    static let characterComplete = "Fully developed — identity and arc"
    static let intentionPrefix = "Wants to:"
    static let namePlaceholderTitle = "Name your character"

    /// Trailing summary for a multi-select row, e.g. "2 selected".
    static func selectedCount(_ count: Int) -> String {
        "\(count) selected"
    }
    static let clearRole = "No Role"
    static let tierPrimary = "Primary"
    static let tierSecondary = "Secondary"
    static let tierBackground = "Background"
    static let customSection = "Custom"
    static let customRolePlaceholder = "Your own role…"
    static let customTraitPlaceholder = "Add your own…"
    static let addCustom = "Add"
    static let archetypeNudge = "Most memorable characters embody 1–3 archetypes."
    static let storyFunctionNudge = "A focused set of 1–3 story functions reads strongest."
}
