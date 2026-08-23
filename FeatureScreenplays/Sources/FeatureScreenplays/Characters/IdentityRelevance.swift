//
//  IdentityRelevance.swift
//  FeatureScreenplays
//
//  Maps a character's role onto the archetypes and story functions that
//  conventionally suit it. This *suggests*, it never restricts: every choice
//  stays reachable under "All …", and anything already selected is pinned into
//  the suggested group so changing a role can never hide saved work.
//

import Foundation
import Domain

/// A catalog split into role-relevant choices and everything else.
struct IdentityRelevanceGroups {
    let suggested: [IdentityCatalogEntry]
    let others: [IdentityCatalogEntry]

    /// True when there is a meaningful suggestion set to lead with.
    var isFiltering: Bool { !suggested.isEmpty && !others.isEmpty }
}

enum IdentityRelevance {

    // MARK: - Registry

    private static let archetypesByRole: [String: [String]] = [
        HierarchicalRole.Stock.protagonist: [
            ArchetypeSlug.hero, ArchetypeSlug.antiHero, ArchetypeSlug.tragicHero,
            ArchetypeSlug.villainProtagonist,
            ArchetypeSlug.rebel,
            ArchetypeSlug.innocent, ArchetypeSlug.warrior, ArchetypeSlug.lover,
            ArchetypeSlug.artist, ArchetypeSlug.jester, ArchetypeSlug.caregiver
        ],
        HierarchicalRole.Stock.antagonist: [
            ArchetypeSlug.villain, ArchetypeSlug.antiVillain, ArchetypeSlug.shadow,
            ArchetypeSlug.inanimateAntagonist,
            ArchetypeSlug.shapeshifter, ArchetypeSlug.ruler,
            ArchetypeSlug.warrior, ArchetypeSlug.rebel
        ],
        HierarchicalRole.Stock.secondLead: [
            ArchetypeSlug.sidekick, ArchetypeSlug.caregiver, ArchetypeSlug.lover,
            ArchetypeSlug.mentor, ArchetypeSlug.warrior
        ],
        HierarchicalRole.Stock.thirdLead: [
            ArchetypeSlug.jester, ArchetypeSlug.mentor, ArchetypeSlug.warrior,
            ArchetypeSlug.artist, ArchetypeSlug.sidekick
        ],
        HierarchicalRole.Stock.fourthLead: [
            ArchetypeSlug.jester, ArchetypeSlug.sidekick, ArchetypeSlug.caregiver,
            ArchetypeSlug.artist, ArchetypeSlug.innocent
        ],
        HierarchicalRole.Stock.recurring: [
            ArchetypeSlug.jester, ArchetypeSlug.innocent, ArchetypeSlug.caregiver,
            ArchetypeSlug.artist
        ]
    ]

    private static let storyFunctionsByRole: [String: [String]] = [
        HierarchicalRole.Stock.protagonist: [
            StoryFunctionSlug.activeProtagonist,
            StoryFunctionSlug.catalystLead,
            StoryFunctionSlug.investigator,
            StoryFunctionSlug.audienceSurrogate,
            StoryFunctionSlug.thematicAnchor,
            StoryFunctionSlug.passiveProtagonist
        ],
        HierarchicalRole.Stock.antagonist: [
            StoryFunctionSlug.tempter, StoryFunctionSlug.saboteur,
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.harbinger,
            StoryFunctionSlug.mirror, StoryFunctionSlug.instigator,
            StoryFunctionSlug.falseAntagonist, StoryFunctionSlug.heroAntagonist,
            StoryFunctionSlug.hiddenAntagonist
        ],
        HierarchicalRole.Stock.secondLead: [
            StoryFunctionSlug.confidant, StoryFunctionSlug.foil,
            StoryFunctionSlug.loveInterest, StoryFunctionSlug.voiceOfReason,
            StoryFunctionSlug.falseAntagonist, StoryFunctionSlug.heroAntagonist,
            StoryFunctionSlug.hiddenAntagonist
        ],
        HierarchicalRole.Stock.thirdLead: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.foil,
            StoryFunctionSlug.herald, StoryFunctionSlug.voiceOfReason,
            StoryFunctionSlug.falseAntagonist
        ],
        HierarchicalRole.Stock.fourthLead: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.catalyst, StoryFunctionSlug.falseAntagonist
        ],
        HierarchicalRole.Stock.recurring: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.harbinger, StoryFunctionSlug.catalyst,
            StoryFunctionSlug.falseAntagonist, StoryFunctionSlug.henchman
        ]
    ]

    /// Story functions an archetype tends to perform. Archetype is *who a
    /// character is*; story function is *the job they do for the plot* — a
    /// Mentor often speaks as the Voice of Reason, but a Voice of Reason
    /// (Hermione) need not be anyone's Mentor. These merge with the role's own
    /// suggestions rather than replacing them.
    private static let storyFunctionsByArchetype: [String: [String]] = [
        ArchetypeSlug.hero: [
            StoryFunctionSlug.activeProtagonist,
            StoryFunctionSlug.audienceSurrogate, StoryFunctionSlug.thematicAnchor
        ],
        ArchetypeSlug.antiHero: [
            StoryFunctionSlug.foil, StoryFunctionSlug.mirror, StoryFunctionSlug.instigator
        ],
        ArchetypeSlug.villainProtagonist: [
            StoryFunctionSlug.instigator, StoryFunctionSlug.saboteur,
            StoryFunctionSlug.thematicAnchor
        ],
        ArchetypeSlug.tragicHero: [
            StoryFunctionSlug.thematicAnchor, StoryFunctionSlug.mirror,
            StoryFunctionSlug.catalyst, StoryFunctionSlug.passiveProtagonist
        ],
        ArchetypeSlug.mentor: [
            StoryFunctionSlug.voiceOfReason, StoryFunctionSlug.herald,
            StoryFunctionSlug.thresholdGuardian
        ],
        ArchetypeSlug.jester: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.foil,
            StoryFunctionSlug.instigator
        ],
        ArchetypeSlug.sidekick: [
            StoryFunctionSlug.confidant, StoryFunctionSlug.comicRelief
        ],
        ArchetypeSlug.caregiver: [
            StoryFunctionSlug.confidant, StoryFunctionSlug.voiceOfReason
        ],
        ArchetypeSlug.lover: [
            StoryFunctionSlug.loveInterest, StoryFunctionSlug.confidant
        ],
        ArchetypeSlug.shadow: [
            StoryFunctionSlug.tempter, StoryFunctionSlug.saboteur,
            StoryFunctionSlug.mirror, StoryFunctionSlug.hiddenAntagonist
        ],
        ArchetypeSlug.villain: [
            StoryFunctionSlug.saboteur, StoryFunctionSlug.tempter,
            StoryFunctionSlug.harbinger, StoryFunctionSlug.hiddenAntagonist
        ],
        ArchetypeSlug.antiVillain: [
            StoryFunctionSlug.mirror, StoryFunctionSlug.foil
        ],
        ArchetypeSlug.inanimateAntagonist: [
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.catalyst,
            StoryFunctionSlug.harbinger
        ],
        ArchetypeSlug.shapeshifter: [
            StoryFunctionSlug.falseAntagonist, StoryFunctionSlug.hiddenAntagonist,
            StoryFunctionSlug.saboteur
        ],
        ArchetypeSlug.rebel: [
            StoryFunctionSlug.instigator, StoryFunctionSlug.catalyst
        ],
        ArchetypeSlug.warrior: [
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.henchman,
            StoryFunctionSlug.heroAntagonist
        ],
        ArchetypeSlug.ruler: [
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.harbinger,
            StoryFunctionSlug.heroAntagonist
        ],
        ArchetypeSlug.innocent: [
            StoryFunctionSlug.audienceSurrogate, StoryFunctionSlug.catalyst,
            StoryFunctionSlug.passiveProtagonist
        ],
        ArchetypeSlug.artist: [
            StoryFunctionSlug.thematicAnchor, StoryFunctionSlug.mirror,
            StoryFunctionSlug.passiveProtagonist
        ]
    ]

    /// Archetypes that only make sense for one role — the hero family reads as
    /// nonsense on a Recurring player, and the antagonist family on a Second
    /// Lead. These are hidden from the archetype picker (even under "All …")
    /// unless the matching role is selected, or the writer already saved one.
    private static let requiredRoleByArchetype: [String: String] = [
        ArchetypeSlug.hero: HierarchicalRole.Stock.protagonist,
        ArchetypeSlug.antiHero: HierarchicalRole.Stock.protagonist,
        ArchetypeSlug.tragicHero: HierarchicalRole.Stock.protagonist,
        ArchetypeSlug.villainProtagonist: HierarchicalRole.Stock.protagonist,
        ArchetypeSlug.villain: HierarchicalRole.Stock.antagonist,
        ArchetypeSlug.antiVillain: HierarchicalRole.Stock.antagonist,
        ArchetypeSlug.inanimateAntagonist: HierarchicalRole.Stock.antagonist
    ]

    /// The archetype catalog trimmed to what the current role can wear.
    /// Anything already selected stays visible so changing a role never hides
    /// saved work.
    static func archetypeCatalog(
        for role: HierarchicalRole?,
        selection: [IdentityTrait] = []
    ) -> [IdentityCatalogEntry] {
        let selected = Set(selection.filter { !$0.isCustom }.map(\.slug))
        return IdentityCatalog.archetypes.filter { entry in
            guard let required = requiredRoleByArchetype[entry.slug] else { return true }
            if selected.contains(entry.slug) { return true }
            guard let role, !role.isCustom else { return false }
            return role.slug == required
        }
    }

    /// Jobs that only make sense for the person the story is *about*: they
    /// describe how the lead carries the plot, so a supporting player or the
    /// opposition can never wear them.
    private static let leadOnlyStoryFunctions: Set<String> = [
        StoryFunctionSlug.activeProtagonist,
        StoryFunctionSlug.passiveProtagonist,
        StoryFunctionSlug.catalystLead
    ]

    /// Story functions that contradict a role outright. A Protagonist can be
    /// plenty of unpleasant things, but they cannot be the story's opposition
    /// machinery — those jobs only read as jobs when someone else does them.
    /// Hidden from the picker (even under "All …") unless already saved.
    private static let blockedStoryFunctionsByRole: [String: Set<String>] = [
        HierarchicalRole.Stock.protagonist: [
            StoryFunctionSlug.falseAntagonist,
            StoryFunctionSlug.heroAntagonist,
            StoryFunctionSlug.hiddenAntagonist,
            StoryFunctionSlug.saboteur,
            StoryFunctionSlug.tempter,
            StoryFunctionSlug.henchman,
            StoryFunctionSlug.instigator
        ],
        HierarchicalRole.Stock.antagonist: [
            StoryFunctionSlug.activeProtagonist,
            StoryFunctionSlug.audienceSurrogate,
            StoryFunctionSlug.passiveProtagonist,
            StoryFunctionSlug.thematicAnchor,
            StoryFunctionSlug.catalystLead
        ],
        HierarchicalRole.Stock.secondLead: leadOnlyStoryFunctions,
        HierarchicalRole.Stock.thirdLead: leadOnlyStoryFunctions,
        HierarchicalRole.Stock.fourthLead: leadOnlyStoryFunctions,
        HierarchicalRole.Stock.recurring: leadOnlyStoryFunctions
    ]

    /// Story function slugs the role cannot wear, minus anything already saved.
    private static func blockedStoryFunctions(
        for role: HierarchicalRole?,
        selection: [IdentityTrait]
    ) -> Set<String> {
        guard let role, !role.isCustom,
              let blocked = blockedStoryFunctionsByRole[role.slug] else { return [] }
        return blocked.subtracting(selection.filter { !$0.isCustom }.map(\.slug))
    }

    /// The story-function catalog trimmed to what the current role can do.
    /// Anything already selected stays visible so changing a role never hides
    /// saved work.
    static func storyFunctionCatalog(
        for role: HierarchicalRole?,
        selection: [IdentityTrait] = []
    ) -> [IdentityCatalogEntry] {
        let blocked = blockedStoryFunctions(for: role, selection: selection)
        guard !blocked.isEmpty else { return IdentityCatalog.storyFunctions }
        return IdentityCatalog.storyFunctions.filter { !blocked.contains($0.slug) }
    }

    /// How many story functions the current role is barred from — surfaced in
    /// the picker so a trimmed catalog explains itself.
    static func hiddenStoryFunctionCount(
        for role: HierarchicalRole?,
        selection: [IdentityTrait] = []
    ) -> Int {
        blockedStoryFunctions(for: role, selection: selection).count
    }

    /// Jobs that belong to exactly one role, so a supporting player can be told
    /// *whose* jobs they're missing rather than a vague "restricted".
    private static let ownerRoleByStoryFunction: [String: String] = Dictionary(
        uniqueKeysWithValues: leadOnlyStoryFunctions.map {
            ($0, HierarchicalRole.Stock.protagonist)
        }
    )

    /// The display name of the single role that owns every hidden job, when
    /// there is one. Returns nil for mixed sets (a Protagonist hides several
    /// opposition jobs that no single role owns), so the caller can fall back
    /// to neutral copy.
    static func hiddenStoryFunctionOwnerRoleName(
        for role: HierarchicalRole?,
        selection: [IdentityTrait] = []
    ) -> String? {
        let hidden = blockedStoryFunctions(for: role, selection: selection)
        guard !hidden.isEmpty else { return nil }
        let owners = Set(hidden.map { ownerRoleByStoryFunction[$0] ?? "" })
        guard owners.count == 1, let ownerSlug = owners.first, !ownerSlug.isEmpty else {
            return nil
        }
        return IdentityCatalog.roleEntry(for: ownerSlug)?.name ?? ownerSlug.capitalized
    }

    /// An archetype family currently out of reach because it belongs to one
    /// role only — surfaced in the picker so a shorter list explains itself
    /// instead of quietly shrinking.
    struct RoleExclusiveFamily: Identifiable, Equatable {
        let roleSlug: String
        let roleName: String
        let count: Int
        var id: String { roleSlug }
    }

    /// The role-exclusive archetype families the current role cannot wear.
    static func hiddenRoleExclusiveFamilies(
        for role: HierarchicalRole?,
        selection: [IdentityTrait] = []
    ) -> [RoleExclusiveFamily] {
        let visible = Set(archetypeCatalog(for: role, selection: selection).map(\.slug))
        var counts: [String: Int] = [:]
        for (slug, requiredRole) in requiredRoleByArchetype where !visible.contains(slug) {
            counts[requiredRole, default: 0] += 1
        }
        return counts.keys.sorted().map { roleSlug in
            RoleExclusiveFamily(
                roleSlug: roleSlug,
                roleName: IdentityCatalog.roleEntry(for: roleSlug)?.name ?? roleSlug.capitalized,
                count: counts[roleSlug] ?? 0
            )
        }
    }

    // MARK: - Lookups

    /// Archetype slugs that suit the role, in suggestion order.
    /// Empty for custom roles or no role — meaning "show everything".
    static func suggestedArchetypeSlugs(for role: HierarchicalRole?) -> [String] {
        guard let role, !role.isCustom else { return [] }
        return archetypesByRole[role.slug] ?? []
    }

    /// Story function slugs that suit the role, in suggestion order.
    static func suggestedStoryFunctionSlugs(for role: HierarchicalRole?) -> [String] {
        guard let role, !role.isCustom else { return [] }
        return storyFunctionsByRole[role.slug] ?? []
    }

    /// Union of the role's story functions and those of every chosen archetype,
    /// role-led and de-duplicated. Custom roles and custom archetypes are
    /// skipped, and an archetype on its own is enough to produce suggestions.
    static func suggestedStoryFunctionSlugs(
        for role: HierarchicalRole?,
        archetypes: [IdentityTrait]
    ) -> [String] {
        var ordered = suggestedStoryFunctionSlugs(for: role)
        var seen = Set(ordered)
        for trait in archetypes where !trait.isCustom {
            for slug in storyFunctionsByArchetype[trait.slug] ?? [] where !seen.contains(slug) {
                ordered.append(slug)
                seen.insert(slug)
            }
        }
        // Archetype hints merge with role hints, so a Protagonist/Warrior could
        // otherwise be handed Hero Antagonist through the back door.
        guard let role, !role.isCustom,
              let blocked = blockedStoryFunctionsByRole[role.slug] else { return ordered }
        return ordered.filter { !blocked.contains($0) }
    }

    /// One identity choice a suggestion set was derived from, tagged with the
    /// facet it came from so the picker can colour it like its chips.
    struct SuggestionSource: Equatable {
        let name: String
        let facet: IdentityHue.Facet
    }

    /// Sources a suggestion set was derived from, so the picker can say *why*
    /// it is suggesting — e.g. Antagonist (role) · Villain (archetype).
    static func storyFunctionSuggestionSources(
        role: HierarchicalRole?,
        roleName: String?,
        archetypes: [IdentityTrait]
    ) -> [SuggestionSource] {
        var sources: [SuggestionSource] = []
        if let role, !role.isCustom, storyFunctionsByRole[role.slug] != nil, let roleName {
            sources.append(SuggestionSource(name: roleName, facet: .role))
        }
        for trait in archetypes where !trait.isCustom && storyFunctionsByArchetype[trait.slug] != nil {
            let name = IdentityCatalog.displayName(for: trait, in: IdentityCatalog.archetypes)
            sources.append(SuggestionSource(name: name, facet: .archetype))
        }
        return sources
    }

    // MARK: - Splitting

    /// Splits a catalog into the suggested set (plus anything already selected,
    /// so a saved choice never disappears) and the remainder.
    static func groups(
        catalog: [IdentityCatalogEntry],
        suggestedSlugs: [String],
        pinning selection: [IdentityTrait]
    ) -> IdentityRelevanceGroups {
        guard !suggestedSlugs.isEmpty else {
            return IdentityRelevanceGroups(suggested: [], others: catalog)
        }
        let selected = Set(selection.filter { !$0.isCustom }.map(\.slug))
        var keep = Set(suggestedSlugs)
        keep.formUnion(selected)

        let ordered = suggestedSlugs.compactMap { slug in
            catalog.first { $0.slug == slug }
        }
        let pinnedExtras = catalog.filter { selected.contains($0.slug) && !suggestedSlugs.contains($0.slug) }
        let others = catalog.filter { !keep.contains($0.slug) }
        return IdentityRelevanceGroups(suggested: ordered + pinnedExtras, others: others)
    }
}
