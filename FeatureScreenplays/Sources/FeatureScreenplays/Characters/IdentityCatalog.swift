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
            examples: "Luke Skywalker (Star Wars) · Mulan"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.mentor, name: "Mentor",
            definition: "Guides the hero's growth with wisdom and gifts.",
            examples: "Obi-Wan Kenobi (Star Wars) · Mr. Miyagi (The Karate Kid)"
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
            examples: "Tony Soprano (The Sopranos) · Deadpool"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.tragicHero, name: "Tragic Hero",
            definition: "A noble, generally good character whose fatal flaw or "
                + "misjudgment leads to their downfall and death.",
            examples: "Anakin Skywalker (Star Wars) · Harvey Dent (The Dark Knight) · "
                + "Michael Corleone (The Godfather)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.villain, name: "Villain",
            definition: "Commits evil intentionally to oppose the hero and serve "
                + "malicious goals.",
            examples: "Lord Voldemort (Harry Potter) · The Joker (The Dark Knight) · "
                + "Sauron (The Lord of the Rings)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.antiVillain, name: "Anti-Villain",
            definition: "Opposes the hero, yet acts on noble intentions or a "
                + "sympathetic past.",
            examples: "Killmonger (Black Panther) · Magneto (X-Men) · "
                + "Thanos (Avengers: Infinity War)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.inanimateAntagonist, name: "Inanimate Antagonist",
            definition: "A non-sentient force — nature, disease, machine — that the "
                + "hero must survive.",
            examples: "Mars (The Martian) · The Overlook Hotel (The Shining) · "
                + "The iceberg (Titanic)"
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
            examples: "Ferris Bueller (Ferris Bueller's Day Off) · "
                + "Jack Sparrow (Pirates of the Caribbean) · Genie (Aladdin)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.lover, name: "Lover",
            definition: "Led by the heart; seeks intimacy and connection.",
            examples: "Rose DeWitt (Titanic) · Noah Calhoun (The Notebook)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.rebel, name: "Rebel",
            definition: "Breaks the rules to upend the status quo.",
            examples: "Katniss Everdeen (The Hunger Games) · Magneto (X-Men)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.caregiver, name: "Caregiver",
            definition: "Protects and nurtures others, often at personal cost.",
            examples: "Marlin (Finding Nemo) · "
                + "Samwise Gamgee (The Lord of the Rings) · Mary Poppins"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.warrior, name: "Warrior",
            definition: "Lives by courage, discipline, and the fight.",
            examples: "Maximus (Gladiator) · General Zod (Man of Steel)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.ruler, name: "Ruler",
            definition: "Craves control and order; leads — or dominates.",
            examples: "Michael Corleone (The Godfather) · "
                + "Miranda Priestly (The Devil Wears Prada)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.innocent, name: "Innocent",
            definition: "Sees the world with optimism and trust.",
            examples: "Forrest Gump · Buddy the Elf (Elf)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.sidekick, name: "Sidekick",
            definition: "The loyal companion who steadies and supports.",
            examples: "Ron Weasley (Harry Potter) · Chewbacca (Star Wars)"
        ),
        IdentityCatalogEntry(
            slug: ArchetypeSlug.artist, name: "Artist",
            definition: "Creates meaning and sees the world differently.",
            examples: "Amélie · Jack Dawson (Titanic)"
        )
    ]

    // MARK: - Story functions

    static let storyFunctions: [IdentityCatalogEntry] = [
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.catalyst, name: "Catalyst",
            definition: "Sparks someone else's story into motion, "
                + "then steps out of the way.",
            examples: "R2-D2 (Star Wars) · The White Rabbit (Alice in Wonderland)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.foil, name: "Foil",
            definition: "Contrasts the hero to reveal their qualities.",
            examples: "Draco Malfoy (Harry Potter) · Buzz Lightyear (Toy Story)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.confidant, name: "Confidant",
            definition: "The trusted ear where inner thoughts surface.",
            examples: "Dr. Watson (Sherlock Holmes) · Horatio (Hamlet)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.thresholdGuardian, name: "Threshold Guardian",
            definition: "Tests the hero at the gate of new territory.",
            examples: "The Sphinx (Oedipus Rex) · "
                + "Emerald City gatekeeper (The Wizard of Oz)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.herald, name: "Herald",
            definition: "Hands the lead an invitation to act — the door into "
                + "the story only opens because they showed up.",
            examples: "Hagrid (Harry Potter) · Effie Trinket (The Hunger Games)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.comicRelief, name: "Comic Relief",
            definition: "Breaks tension with humor.",
            examples: "C-3PO (Star Wars) · Olaf (Frozen)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.loveInterest, name: "Love Interest",
            definition: "The romantic stake that raises the pressure.",
            examples: "Mary Jane Watson (Spider-Man) · "
                + "Peeta Mellark (The Hunger Games)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.voiceOfReason, name: "Voice of Reason",
            definition: "Grounds the group with logic and caution.",
            examples: "Spock (Star Trek) · Hermione Granger (Harry Potter)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.falseAntagonist,
            name: "False Antagonist (Red Herring)",
            definition: "Framed as the threat and drawing the suspicion, later "
                + "revealed as an ally or an innocent — the real opposition "
                + "belongs to someone else.",
            examples: "Severus Snape (Harry Potter) · The Iron Giant · "
                + "Boo Radley (To Kill a Mockingbird)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.heroAntagonist, name: "Hero Antagonist",
            definition: "Doing the right thing — and it puts them squarely "
                + "against our lead.",
            examples: "Inspector Javert (Les Misérables) · "
                + "Hank Schrader (Breaking Bad) · "
                + "Chief Inspector Campbell (Peaky Blinders)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.hiddenAntagonist,
            name: "Hidden Antagonist (Secret Threat)",
            definition: "Hides their identity or motives — trusted by the cast "
                + "until the twist lands.",
            examples: "Palpatine (Star Wars) · Lotso (Toy Story 3) · "
                + "Peter Pettigrew (Harry Potter)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.passiveProtagonist,
            name: "Passive Protagonist",
            definition: "Carries the story by reacting to events rather than "
                + "driving them — the plot happens to them.",
            examples: "Nick Carraway (The Great Gatsby) · "
                + "The Dude (The Big Lebowski) · Bilbo Baggins (The Hobbit)"
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
            examples: "Nick Carraway (The Great Gatsby) · Bilbo Baggins (The Hobbit)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.harbinger, name: "Harbinger",
            definition: "Warns what's coming whether anyone acts or not — they "
                + "hand the story dread, not an invitation.",
            examples: "The Three Witches (Macbeth) · Cassandra (Troy)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.mirror, name: "Mirror",
            definition: "Reflects the hero's choices taken down another path.",
            examples: "Gollum (The Lord of the Rings) · Kylo Ren (Star Wars)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.saboteur, name: "Saboteur",
            definition: "Undermines the plan from within.",
            examples: "Cypher (The Matrix) · Edmund Pevensie (The Chronicles of Narnia)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.tempter, name: "Tempter",
            definition: "Offers the easy, corrupting path.",
            examples: "Palpatine (Star Wars) · "
                + "The White Witch (The Chronicles of Narnia)"
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
            examples: "Paddington · Superman · Atticus Finch (To Kill a Mockingbird)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.instigator, name: "Instigator",
            definition: "Stirs conflict and forces decisions.",
            examples: "Iago (Othello) · Tyler Durden (Fight Club)"
        ),
        IdentityCatalogEntry(
            slug: StoryFunctionSlug.henchman, name: "Henchman",
            definition: "Executes the antagonist's will.",
            examples: "Oddjob (Goldfinger) · Crabbe & Goyle (Harry Potter)"
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
