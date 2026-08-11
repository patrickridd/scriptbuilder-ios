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
            ArchetypeSlug.hero, ArchetypeSlug.antiHero, ArchetypeSlug.rebel,
            ArchetypeSlug.innocent, ArchetypeSlug.warrior, ArchetypeSlug.lover,
            ArchetypeSlug.artist
        ],
        HierarchicalRole.Stock.antagonist: [
            ArchetypeSlug.shadow, ArchetypeSlug.shapeshifter, ArchetypeSlug.ruler,
            ArchetypeSlug.warrior, ArchetypeSlug.rebel
        ],
        HierarchicalRole.Stock.deuteragonist: [
            ArchetypeSlug.sidekick, ArchetypeSlug.caregiver, ArchetypeSlug.lover,
            ArchetypeSlug.mentor, ArchetypeSlug.warrior
        ],
        HierarchicalRole.Stock.tritagonist: [
            ArchetypeSlug.jester, ArchetypeSlug.mentor, ArchetypeSlug.warrior,
            ArchetypeSlug.artist, ArchetypeSlug.sidekick
        ],
        HierarchicalRole.Stock.tetratagonist: [
            ArchetypeSlug.jester, ArchetypeSlug.sidekick, ArchetypeSlug.caregiver,
            ArchetypeSlug.artist, ArchetypeSlug.innocent
        ],
        HierarchicalRole.Stock.fringe: [
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
        HierarchicalRole.Stock.deuteragonist: [
            StoryFunctionSlug.confidant, StoryFunctionSlug.foil,
            StoryFunctionSlug.loveInterest, StoryFunctionSlug.voiceOfReason
        ],
        HierarchicalRole.Stock.tritagonist: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.foil,
            StoryFunctionSlug.herald, StoryFunctionSlug.voiceOfReason,
            StoryFunctionSlug.redHerring
        ],
        HierarchicalRole.Stock.tetratagonist: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.catalyst, StoryFunctionSlug.redHerring
        ],
        HierarchicalRole.Stock.fringe: [
            StoryFunctionSlug.comicRelief, StoryFunctionSlug.herald,
            StoryFunctionSlug.harbinger, StoryFunctionSlug.catalyst,
            StoryFunctionSlug.redHerring, StoryFunctionSlug.henchman
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
