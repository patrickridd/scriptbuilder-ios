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
            definition: "A central character whose goal drives the plot — a story "
                + "can follow more than one.",
            examples: "Luke Skywalker · Erin Brockovich · Thelma & Louise"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.antagonist,
            name: "Antagonist",
            definition: "A primary force working against a protagonist's goal — "
                + "a story can carry several.",
            examples: "Darth Vader · Nurse Ratched · the Lannisters"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.secondLead,
            name: "Second Lead",
            definition: "Second in importance — often the closest companion. "
                + "An ensemble can hold more than one.",
            examples: "Samwise Gamgee · Dr. Watson · Trinity",
            classicalName: "Deuteragonist"
        )
    ]

    static let supportingRoles: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.thirdLead,
            name: "Third Lead",
            definition: "Third in importance; often completes a core trio — "
                + "several can share this tier.",
            examples: "Han Solo · Hermione Granger · Dr. Ellie Sattler",
            classicalName: "Tritagonist"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.fourthLead,
            name: "Fourth Lead",
            definition: "Fourth in importance; a steady presence in the ensemble — "
                + "add as many as your cast needs.",
            examples: "Ron Weasley · Merry Brandybuck · Ian Malcolm",
            classicalName: "Tetartagonist"
        ),
        IdentityCatalogEntry(
            slug: HierarchicalRole.Stock.recurring,
            name: "Recurring",
            definition: "A minor character who colors the world without steering "
                + "the plot — most stories keep a handful.",
            examples: "Moaning Myrtle · The Log Lady · Norm from Cheers",
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
            slug: ArchetypeSlug.villainProtagonist, name: "Villain Protagonist",
            definition: "A main character who drives the plot forward but we root against "
                + "due to their evil motives or harmful actions.",
            examples: "Patrick Bateman (American Psycho) · Lou Bloom (Nightcrawler) · "
                + "Arthur Fleck (Joker)"
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
            slug: ArchetypeSlug.inanimateAntagonist, name: "Inanimate Antagonist",
            definition: "A non-sentient force — nature, disease, machine — that the "
                + "hero must survive.",
            examples: "Mars (The Martian) · The Overlook Hotel · The iceberg (Titanic)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.shadow, name: "Shadow",
            definition: "The dark psychological mirror to the protagonist, embodying "
                + "the hero's repressed flaws, fears, or potential for corruption.",
            examples: "Darth Vader (Star Wars) · Killmonger (Black Panther)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.shapeshifter, name: "Shapeshifter",
            definition: "Allegiance never settles — ally in one scene, threat in "
                + "the next. Defined by which way they'll turn.",
            examples: "Petyr Baelish (Game of Thrones) · Gollum (The Lord of the Rings)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.jester, name: "Jester",
            definition: "Uses humor to disarm — and to speak the truth.",
            examples: "Ferris Bueller · Jack Sparrow · Genie · Donkey"
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
            examples: "Marlin (Finding Nemo) · Samwise Gamgee · Mary Poppins"
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
            definition: "Sparks someone else's story into motion, "
                + "then steps out of the way.",
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
            definition: "Hands the lead an invitation to act — the door into "
                + "the story only opens because they showed up.",
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
            slug: StoryFunctionSlug.falseAntagonist,
            name: "False Antagonist (Red Herring)",
            definition: "Framed as the threat and drawing the suspicion, later "
                + "revealed as an ally or an innocent — the real opposition "
                + "belongs to someone else.",
            examples: "Severus Snape · The Iron Giant · Boo Radley"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.heroAntagonist, name: "Hero Antagonist",
            definition: "Doing the right thing — and it puts them squarely "
                + "against our lead.",
            examples: "Inspector Javert · Hank Schrader · Chief Inspector Campbell"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.hiddenAntagonist,
            name: "Hidden Antagonist (Secret Threat)",
            definition: "Hides their identity or motives — trusted by the cast "
                + "until the twist lands.",
            examples: "Palpatine · Lotso · Peter Pettigrew"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.passiveProtagonist,
            name: "Passive Protagonist",
            definition: "Carries the story by reacting to events rather than "
                + "driving them — the plot happens to them.",
            examples: "Nick Carraway · The Dude · Bilbo Baggins"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.activeProtagonist,
            name: "Active Protagonist",
            definition: "Proactively makes decisions, pursues an external goal, "
                + "and drives the plot forward through scene-by-scene agency.",
            examples: "John McClane (Die Hard) · Marlin (Finding Nemo)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.investigator,
            name: "The Investigator",
            definition: "Drives the narrative momentum by systematically "
                + "uncovering clues, secrets, and worldbuilding for the audience.",
            examples: "Benoit Blanc (Knives Out) · Rick Deckard (Blade Runner)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.catalystLead,
            name: "Catalyst Lead",
            definition: "Makes the pivotal choice that triggers their own journey.",
            examples: "Katniss Everdeen (The Hunger Games) · "
                + "Sarah Connor (The Terminator)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.audienceSurrogate, name: "Audience Surrogate",
            definition: "Asks what we're all thinking — our way into the world.",
            examples: "Nick Carraway · Bilbo Baggins"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.harbinger, name: "Harbinger",
            definition: "Warns what's coming whether anyone acts or not — they "
                + "hand the story dread, not an invitation.",
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
            slug: StoryFunctionSlug.rival, name: "The Rival",
            definition: "Wants the exact same thing the lead does, and only one "
                + "of them can have it — opposition without malice.",
            examples: "Salieri (Amadeus) · Apollo Creed (Rocky) · "
                + "Gaston (Beauty and the Beast)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.pursuer, name: "The Pursuer",
            definition: "Applies pressure by proximity rather than scheming: "
                + "they keep coming, and stopping isn't something they do.",
            examples: "The Terminator · Anton Chigurh (No Country for Old Men) · "
                + "The shark (Jaws)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.puppeteer, name: "Puppet Master",
            definition: "Runs the opposition through proxies and stays out of "
                + "reach — often unmet until the last act.",
            examples: "Professor Moriarty · Keyser Söze (The Usual Suspects)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.authority, name: "The Authority",
            definition: "Blocks the lead with the rulebook on their side — "
                + "grinding, systemic resistance rather than a single test.",
            examples: "Nurse Ratched (One Flew Over the Cuckoo's Nest) · "
                + "Miranda Priestly (The Devil Wears Prada)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.thematicAnchor, name: "Thematic Anchor",
            definition: "Holds the story's moral centre and never bends. "
                + "They don't change — the world around them does.",
            examples: "Paddington · Superman · Atticus Finch"
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

    // MARK: - Story function actions

    /// Verb-phrase headline for every story function, keyed by slug.
    ///
    /// Archetypes and story functions are both lists of agent nouns ("Mentor",
    /// "Tempter"), so grammar — not colour — is what separates them. In the
    /// picker the job leads as an *action* and the noun drops to a caption,
    /// making that list read as things a character does rather than things a
    /// character is. Only story functions appear here; a nil lookup means the
    /// card keeps its noun headline.
    static let storyFunctionActions: [String: String] = [
        StoryFunctionSlug.catalyst: "Sparks someone else's story",
        StoryFunctionSlug.foil: "Contrasts the lead",
        StoryFunctionSlug.confidant: "Hears what the lead can't say aloud",
        StoryFunctionSlug.thresholdGuardian: "Blocks the way in",
        StoryFunctionSlug.herald: "Delivers the call to adventure",
        StoryFunctionSlug.comicRelief: "Breaks the tension",
        StoryFunctionSlug.loveInterest: "Raises the personal stakes",
        StoryFunctionSlug.voiceOfReason: "Argues for the sensible plan",
        StoryFunctionSlug.falseAntagonist: "Draws the suspicion",
        StoryFunctionSlug.heroAntagonist: "Opposes the lead for good reasons",
        StoryFunctionSlug.hiddenAntagonist: "Hides in plain sight",
        StoryFunctionSlug.passiveProtagonist: "Reacts instead of driving",
        StoryFunctionSlug.activeProtagonist: "Drives the plot scene by scene",
        StoryFunctionSlug.investigator: "Uncovers the truth",
        StoryFunctionSlug.catalystLead: "Makes the choice that starts it all",
        StoryFunctionSlug.audienceSurrogate: "Asks what we're all thinking",
        StoryFunctionSlug.harbinger: "Warns what's coming",
        StoryFunctionSlug.mirror: "Shows the road not taken",
        StoryFunctionSlug.saboteur: "Undermines the plan from within",
        StoryFunctionSlug.tempter: "Offers the easy way out",
        StoryFunctionSlug.rival: "Wants the same thing the lead wants",
        StoryFunctionSlug.pursuer: "Never stops coming",
        StoryFunctionSlug.puppeteer: "Pulls the strings and never shows up",
        StoryFunctionSlug.authority: "Says no from behind a desk",
        StoryFunctionSlug.thematicAnchor: "Holds the moral line",
        StoryFunctionSlug.instigator: "Stirs up trouble",
        StoryFunctionSlug.henchman: "Carries out the orders"
    ]

    /// Verb-phrase headline for a slug, when one exists.
    static func action(for slug: String) -> String? {
        storyFunctionActions[slug]
    }

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
    /// Second grouping on character detail: what the character *does* in the
    /// story (story function) and how they change (arc).
    static let behaviorSectionTitle = "Behavior"
    static let arcCardSubtitle = "Where they start, break and land"
    static let arcNotApplicableTitle = "This character has no arc"
    static let arcNotApplicableSubtitle =
        "Objects, forces and figures who never want anything — mark it and the arc counts as done."
    static let arcNotApplicableComplete = "No Arc needed"
    static let arcNotApplicableNote = "Arc questions are hidden. Notes stay available if you want a line about why."
    /// Character-level settings screen, reached from the overflow menu.
    static let settingsTitle = "Character Settings"
    static let settingsAction = "Character Settings"
    static let settingsArcSection = "Dramatic Arc"
    static let settingsNameSection = "Name"
    static let settingsNameFooter = "How this character appears across the cast list, scenes and exports."
    static let settingsDangerSection = "Danger Zone"
    static let settingsDeleteAction = "Delete Character"
    static let settingsDeleteFooter = "Removes this character and everything written about them. This cannot be undone."
    static let settingsFooter =
        "Nothing you have written is deleted — hidden fields come straight back if you switch this off."
    static let roleRow = "Role"
    static let archetypeRow = "Archetype"
    static let storyFunctionRow = "Story Function"
    static let noneValue = "None"
    /// Empty-state prompts on the identity rows. A question invites a tap far
    /// better than a flat "None", and each one frames what that step decides.
    static let rolePrompt = "Where do they stand?"
    static let archetypePrompt = "Who are they?"
    static let storyFunctionPrompt = "What do they do?"
    static let characterComplete = "Fully developed — identity and arc"
    static let intentionPrefix = "Wants to:"
    static let namePlaceholderTitle = "Name your character"
    static let nameFieldLabel = "Character name"
    /// Short prompt used inside the header field, where width is precious.
    static let nameFieldPrompt = "Character name"
    static let nameFieldDone = "Done"
    /// Confirmation button that dismisses the Character Settings sheet.
    static let settingsSave = "Save"
    /// Menu action that drops the caret into the header name field.
    static let changeNameAction = "Change Name"
    static let moreActions = "More actions"
    static let chipHint = "Opens this choice in the picker"

    /// Spoken form of the noun tag under an action headline, e.g. "Known as
    /// Catalyst".
    static func knownAs(_ term: String) -> String {
        "Known as \(term)"
    }

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
    /// "Commonly paired with **Second Lead** · **Mentor**", with each source bolded via
    /// Markdown. Nil when nothing drives the order.
    static func suggestedDescription(sources: [String]) -> String? {
        guard !sources.isEmpty else { return nil }
        let emphasized = sources.map { "**\($0)**" }.joined(separator: " · ")
        return "Commonly paired with \(emphasized)"
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

    // MARK: - Craft sequence (soft gates)
    //
    // Role → Archetype → Story Function is the order the craft teaches, so the
    // rows are numbered and the later ones read as "not ready yet". Nothing is
    // ever locked: every row stays tappable and no saved choice is discarded.

    /// Spoken form of a row's step number, e.g. "Step 2 of 3".
    static func stepLabel(_ step: Int, of total: Int = 3) -> String {
        "Step \(step) of \(total)"
    }

    /// Sub-line on the Archetype row while no role is chosen.
    static let archetypeGateHint = "Pick a role first for tailored suggestions"
    /// Sub-line on the Story Function row while no archetype is chosen.
    static let storyFunctionGateHint = "Pick an archetype for sharper suggestions"

    /// Banner at the top of the Archetype picker when no role is set.
    static let archetypeGateBanner = "Set a role and we'll suggest the archetypes that fit."
    /// Banner at the top of the Story Function picker when no archetype is set.
    static let storyFunctionGateBanner = "Set an archetype and we'll suggest the jobs it usually does."
    /// Tappable tail of a gate banner — pops back to the Identity rows.
    static let gateBannerAction = "Back to Identity"

    /// Explains an archetype family the current role cannot wear, e.g.
    /// "5 Protagonist-only archetypes. Change the role to see them".
    /// Deliberately mirrors `roleOnlyFunctionNotice` so both picker notices
    /// read as one voice.
    static func roleExclusiveNotice(count: Int, roleName: String) -> String {
        let archetypes = count == 1 ? "archetype" : "archetypes"
        let them = count == 1 ? "it" : "them"
        return "\(count) \(roleName)-only \(archetypes). Change the role to see \(them)"
    }

    /// Explains story functions withheld because they don't fit the current role,
    /// e.g. "6 jobs restricted for Protagonist. Change the role to see them".
    /// Deliberately neutral: the hidden set can be opposition jobs (for a lead)
    /// or lead-driver jobs (for a supporting role), so the copy must fit both.
    static func blockedFunctionNotice(count: Int, roleName: String) -> String {
        let jobs = count == 1 ? "job" : "jobs"
        let them = count == 1 ? "it" : "them"
        return "\(count) \(jobs) restricted for \(roleName). Change the role to see \(them)"
    }

    /// Used when every hidden job belongs to one specific role, e.g.
    /// "3 Protagonist-only jobs. Change the role to see them".
    static func roleOnlyFunctionNotice(count: Int, roleName: String) -> String {
        let jobs = count == 1 ? "job" : "jobs"
        let them = count == 1 ? "it" : "them"
        return "\(count) \(roleName)-only \(jobs). Change the role to see \(them)"
    }
}
