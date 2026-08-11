//
//  CharacterIdentity.swift
//  Domain
//
//  Who a character *is*, separate from how they change (the Arc).
//
//  Three complementary facets:
//    - HierarchicalRole  — how important are they?  (single-select, tiered)
//    - Archetypes        — what pattern do they embody?  (multi-select + custom)
//    - StoryFunctions    — what job do they do for the plot?  (multi-select + custom)
//
//  Values are stored as stable slugs (not hard enums) so stock catalogs can
//  grow without schema migrations. A `customLabel` preserves user-created and
//  legacy free-text values verbatim.
//

import Foundation

// MARK: - Role tier

/// Narrative importance tier for a `HierarchicalRole`.
public enum RoleTier: String, CaseIterable, Sendable, Codable {
    case primary
    case secondary
}

// MARK: - Hierarchical role

/// Single-select narrative-importance role ("Protagonist", "Tritagonist"…).
public struct HierarchicalRole: Equatable, Hashable, Sendable, Codable {

    /// A stock slug (see `Stock`) or `HierarchicalRole.customSlug`.
    public var slug: String

    /// Free-text label, set when the writer created a custom role or when a
    /// legacy free-text role was preserved during migration.
    public var customLabel: String?

    public init(slug: String, customLabel: String? = nil) {
        self.slug = slug
        self.customLabel = customLabel
    }

    // MARK: Stock slugs

    public enum Stock {
        public static let protagonist  = "protagonist"
        public static let antagonist   = "antagonist"
        public static let deuteragonist = "deuteragonist"
        public static let tritagonist  = "tritagonist"
        public static let tetartagonist = "tetartagonist"
        public static let fringe       = "fringe"

        /// All stock slugs in canonical (tier, importance) order.
        public static let all: [String] = [
            protagonist, antagonist, deuteragonist,
            tritagonist, tetartagonist,
            fringe
        ]
    }

    public static let customSlug = "custom"

    public static func custom(_ label: String) -> HierarchicalRole {
        HierarchicalRole(slug: customSlug, customLabel: label)
    }

    public var isCustom: Bool { slug == Self.customSlug }

    /// Tier of a stock role; `nil` for custom roles.
    public var tier: RoleTier? {
        switch slug {
        case Stock.protagonist, Stock.antagonist, Stock.deuteragonist:
            return .primary
        case Stock.tritagonist, Stock.tetartagonist, Stock.fringe:
            return .secondary
        default:
            return nil
        }
    }
}

// MARK: - Identity trait (shared shape for Archetype & StoryFunction)

/// One selected archetype or story function — either a stock slug or a
/// user-created custom value.
public struct IdentityTrait: Equatable, Hashable, Sendable, Codable {

    /// A stock catalog slug, or `IdentityTrait.customSlug` for custom values.
    public var slug: String

    /// The writer's own text, set only when `slug == customSlug`.
    public var customLabel: String?

    public init(slug: String, customLabel: String? = nil) {
        self.slug = slug
        self.customLabel = customLabel
    }

    public static let customSlug = "custom"

    public static func stock(_ slug: String) -> IdentityTrait {
        IdentityTrait(slug: slug)
    }

    public static func custom(_ label: String) -> IdentityTrait {
        IdentityTrait(slug: customSlug, customLabel: label)
    }

    public var isCustom: Bool { slug == Self.customSlug }
}

// MARK: - Stock slug catalogs

/// Stable slugs for the stock Archetype catalog. Display names, definitions,
/// and film examples live in the UI layer's catalog.
public enum ArchetypeSlug {
    public static let jester       = "jester"
    public static let mentor       = "mentor"
    public static let antiHero     = "anti-hero"
    public static let shapeshifter = "shapeshifter"
    public static let lover        = "lover"
    public static let rebel        = "rebel"
    public static let caregiver    = "caregiver"
    public static let warrior      = "warrior"
    public static let ruler        = "ruler"
    public static let hero         = "hero"
    public static let innocent     = "innocent"
    public static let shadow       = "shadow"
    public static let sidekick     = "sidekick"
    public static let artist       = "artist"

    public static let all: [String] = [
        jester, mentor, antiHero, shapeshifter, lover, rebel, caregiver,
        warrior, ruler, hero, innocent, shadow, sidekick, artist
    ]
}

/// Stable slugs for the stock StoryFunction catalog.
public enum StoryFunctionSlug {
    public static let catalyst          = "catalyst"
    public static let foil              = "foil"
    public static let confidant         = "confidant"
    public static let thresholdGuardian = "threshold-guardian"
    public static let herald            = "herald"
    public static let comicRelief       = "comic-relief"
    public static let loveInterest      = "love-interest"
    public static let voiceOfReason     = "voice-of-reason"
    public static let redHerring        = "red-herring"
    public static let audienceSurrogate = "audience-surrogate"
    public static let harbinger         = "harbinger"
    public static let mirror            = "mirror"
    public static let saboteur          = "saboteur"
    public static let tempter           = "tempter"
    public static let thematicAnchor    = "thematic-anchor"
    public static let instigator        = "instigator"
    public static let henchman          = "henchman"

    public static let all: [String] = [
        catalyst, foil, confidant, thresholdGuardian, herald, comicRelief,
        loveInterest, voiceOfReason, redHerring, audienceSurrogate, harbinger,
        mirror, saboteur, tempter, thematicAnchor, instigator, henchman
    ]
}

// MARK: - Big Five personality traits

/// Optional 0…1 sliders; `nil` means "not set".
public struct BigFiveTraits: Equatable, Hashable, Sendable, Codable {

    public var openness: Double?
    public var conscientiousness: Double?
    public var extraversion: Double?
    public var agreeableness: Double?
    public var neuroticism: Double?

    public init(
        openness: Double? = nil,
        conscientiousness: Double? = nil,
        extraversion: Double? = nil,
        agreeableness: Double? = nil,
        neuroticism: Double? = nil
    ) {
        self.openness = openness
        self.conscientiousness = conscientiousness
        self.extraversion = extraversion
        self.agreeableness = agreeableness
        self.neuroticism = neuroticism
    }

    public var isEmpty: Bool {
        openness == nil && conscientiousness == nil && extraversion == nil
            && agreeableness == nil && neuroticism == nil
    }
}

// MARK: - Character identity

/// The unified Identity hub value: role, archetypes, story functions,
/// personality traits, and quirks. A completely blank identity is valid.
public struct CharacterIdentity: Equatable, Hashable, Sendable, Codable {

    public var role: HierarchicalRole?
    public var archetypes: [IdentityTrait]
    public var storyFunctions: [IdentityTrait]
    public var traits: BigFiveTraits?
    public var quirks: [String]

    public init(
        role: HierarchicalRole? = nil,
        archetypes: [IdentityTrait] = [],
        storyFunctions: [IdentityTrait] = [],
        traits: BigFiveTraits? = nil,
        quirks: [String] = []
    ) {
        self.role = role
        self.archetypes = archetypes
        self.storyFunctions = storyFunctions
        self.traits = traits
        self.quirks = quirks
    }

    public static let empty = CharacterIdentity()

    public var isEmpty: Bool {
        role == nil && archetypes.isEmpty && storyFunctions.isEmpty
            && (traits?.isEmpty ?? true) && quirks.isEmpty
    }
}

// MARK: - Legacy role migration (non-destructive)

public extension CharacterIdentity {

    /// Resolves a legacy flat `Character.role` string into a structured
    /// identity. Used on read when no stored identity exists; the original
    /// `role` field is never modified.
    ///
    /// Mapping:
    ///   Protagonist / Antagonist          -> HierarchicalRole (primary tier)
    ///   Mentor / Lover / Jester           -> stock Archetype
    ///   Mysterious                        -> custom Archetype (preserved verbatim)
    ///   Ally / Friend / Enemy             -> custom StoryFunction (preserved verbatim)
    ///   Anything else (free text)         -> custom HierarchicalRole label
    init(resolvingLegacyRole legacyRole: String?) {
        let trimmed = legacyRole?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else {
            self = .empty
            return
        }

        switch trimmed.lowercased() {
        case "protagonist":
            self.init(role: HierarchicalRole(slug: HierarchicalRole.Stock.protagonist))
        case "antagonist":
            self.init(role: HierarchicalRole(slug: HierarchicalRole.Stock.antagonist))
        case "mentor":
            self.init(archetypes: [.stock(ArchetypeSlug.mentor)])
        case "lover":
            self.init(archetypes: [.stock(ArchetypeSlug.lover)])
        case "jester":
            self.init(archetypes: [.stock(ArchetypeSlug.jester)])
        case "mysterious":
            self.init(archetypes: [.custom(trimmed)])
        case "ally", "friend", "enemy":
            self.init(storyFunctions: [.custom(trimmed)])
        default:
            self.init(role: .custom(trimmed))
        }
    }
}
