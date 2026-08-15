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
            ArchetypeSlug.rebel,
            ArchetypeSlug.innocent, ArchetypeSlug.warrior, ArchetypeSlug.lover,
            ArchetypeSlug.artist
        ],
        HierarchicalRole.Stock.antagonist: [
            ArchetypeSlug.shadow, ArchetypeSlug.shapeshifter, ArchetypeSlug.ruler,
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
            StoryFunctionSlug.audienceSurrogate, StoryFunctionSlug.instigator,
            StoryFunctionSlug.thematicAnchor, StoryFunctionSlug.catalyst
        ],
        HierarchicalRole.Stock.antagonist: [
            StoryFunctionSlug.tempter, StoryFunctionSlug.saboteur,
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.harbinger,
            StoryFunctionSlug.mirror, StoryFunctionSlug.instigator
        ],
        HierarchicalRole.Stock.secondLead: [
            StoryFunctionSlug.confidant, StoryFunctionSlug.foil,
            StoryFunctionSlug.loveInterest, StoryFunctionSlug.voiceOfReason
        ],
        HierarchicalRole.Stock.thirdLead: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.foil,
            StoryFunctionSlug.herald, StoryFunctionSlug.voiceOfReason,
            StoryFunctionSlug.redHerring
        ],
        HierarchicalRole.Stock.fourthLead: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.catalyst, StoryFunctionSlug.redHerring
        ],
        HierarchicalRole.Stock.recurring: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.harbinger, StoryFunctionSlug.catalyst,
            StoryFunctionSlug.redHerring, StoryFunctionSlug.henchman
        ]
    ]

    /// Story functions an archetype tends to perform. Archetype is *who a
    /// character is*; story function is *the job they do for the plot* — a
    /// Mentor often speaks as the Voice of Reason, but a Voice of Reason
    /// (Hermione) need not be anyone's Mentor. These merge with the role's own
    /// suggestions rather than replacing them.
    private static let storyFunctionsByArchetype: [String: [String]] = [
        ArchetypeSlug.hero: [
            StoryFunctionSlug.audienceSurrogate, StoryFunctionSlug.instigator,
            StoryFunctionSlug.catalyst
        ],
        ArchetypeSlug.antiHero: [
            StoryFunctionSlug.foil, StoryFunctionSlug.mirror, StoryFunctionSlug.instigator
        ],
        ArchetypeSlug.tragicHero: [
            StoryFunctionSlug.thematicAnchor, StoryFunctionSlug.mirror,
            StoryFunctionSlug.catalyst
        ],
        ArchetypeSlug.mentor: [
            StoryFunctionSlug.voiceOfReason, StoryFunctionSlug.herald,
            StoryFunctionSlug.thresholdGuardian
        ],
        ArchetypeSlug.jester: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.redHerring
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
            StoryFunctionSlug.tempter, StoryFunctionSlug.saboteur, StoryFunctionSlug.mirror
        ],
        ArchetypeSlug.shapeshifter: [
            StoryFunctionSlug.redHerring, StoryFunctionSlug.saboteur
        ],
        ArchetypeSlug.rebel: [
            StoryFunctionSlug.instigator, StoryFunctionSlug.catalyst
        ],
        ArchetypeSlug.warrior: [
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.henchman
        ],
        ArchetypeSlug.ruler: [
            StoryFunctionSlug.thresholdGuardian, StoryFunctionSlug.harbinger
        ],
        ArchetypeSlug.innocent: [
            StoryFunctionSlug.audienceSurrogate, StoryFunctionSlug.catalyst
        ],
        ArchetypeSlug.artist: [
            StoryFunctionSlug.thematicAnchor, StoryFunctionSlug.mirror
        ]
    ]

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
        return ordered
    }

    /// Names of the identity choices a suggestion set was derived from, so the
    /// picker can say *why* it is suggesting — e.g. ["Deuteragonist", "Mentor"].
    static func storyFunctionSuggestionSources(
        role: HierarchicalRole?,
        roleName: String?,
        archetypes: [IdentityTrait]
    ) -> [String] {
        var names: [String] = []
        if let role, !role.isCustom, storyFunctionsByRole[role.slug] != nil, let roleName {
            names.append(roleName)
        }
        for trait in archetypes where !trait.isCustom && storyFunctionsByArchetype[trait.slug] != nil {
            names.append(IdentityCatalog.displayName(for: trait, in: IdentityCatalog.archetypes))
        }
        return names
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
