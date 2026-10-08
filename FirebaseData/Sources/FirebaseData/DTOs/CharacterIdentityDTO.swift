//
//  CharacterIdentityDTO.swift
//  FirebaseData
//
//  Persistence shape for `CharacterIdentity`, nested under the character's
//  "identity" key. Every field is optional on decode — RTDB omits empty
//  values — and `toDomain()` supplies the defaults.
//
//  The legacy top-level "role" string on the character is never rewritten;
//  when no stored identity exists, the mapping layer resolves one from it.
//

import Foundation
import Domain

// MARK: - HierarchicalRole

struct HierarchicalRoleDTO: Codable, Sendable {
    let slug: String
    let customLabel: String?

    init(slug: String, customLabel: String?) {
        self.slug = slug
        self.customLabel = customLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug        = container.lenientString(.slug)
        customLabel = try? container.decodeIfPresent(String.self, forKey: .customLabel)
    }

    enum CodingKeys: String, CodingKey {
        case slug, customLabel
    }

    init(domain role: HierarchicalRole) {
        self.init(slug: role.slug, customLabel: role.customLabel)
    }

    func toDomain() -> HierarchicalRole {
        HierarchicalRole(slug: slug, customLabel: customLabel)
    }
}

// MARK: - IdentityTrait

struct IdentityTraitDTO: Codable, Sendable {
    let slug: String
    let customLabel: String?

    init(slug: String, customLabel: String?) {
        self.slug = slug
        self.customLabel = customLabel
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        slug        = container.lenientString(.slug)
        customLabel = try? container.decodeIfPresent(String.self, forKey: .customLabel)
    }

    enum CodingKeys: String, CodingKey {
        case slug, customLabel
    }

    init(domain trait: IdentityTrait) {
        self.init(slug: trait.slug, customLabel: trait.customLabel)
    }

    func toDomain() -> IdentityTrait {
        IdentityTrait(slug: slug, customLabel: customLabel)
    }
}

// MARK: - BigFiveTraits

struct BigFiveTraitsDTO: Codable, Sendable {
    let openness: Double?
    let conscientiousness: Double?
    let extraversion: Double?
    let agreeableness: Double?
    let neuroticism: Double?

    init(domain traits: BigFiveTraits) {
        openness = traits.openness
        conscientiousness = traits.conscientiousness
        extraversion = traits.extraversion
        agreeableness = traits.agreeableness
        neuroticism = traits.neuroticism
    }

    func toDomain() -> BigFiveTraits {
        BigFiveTraits(
            openness: openness,
            conscientiousness: conscientiousness,
            extraversion: extraversion,
            agreeableness: agreeableness,
            neuroticism: neuroticism
        )
    }
}

// MARK: - CharacterIdentity

struct CharacterIdentityDTO: Codable, Sendable {
    let role: HierarchicalRoleDTO?
    let archetypes: [IdentityTraitDTO]?
    let storyFunctions: [IdentityTraitDTO]?
    let traits: BigFiveTraitsDTO?
    let quirks: [String]?

    init(
        role: HierarchicalRoleDTO?,
        archetypes: [IdentityTraitDTO]?,
        storyFunctions: [IdentityTraitDTO]?,
        traits: BigFiveTraitsDTO?,
        quirks: [String]?
    ) {
        self.role = role
        self.archetypes = archetypes
        self.storyFunctions = storyFunctions
        self.traits = traits
        self.quirks = quirks
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        role           = try? container.decodeIfPresent(HierarchicalRoleDTO.self, forKey: .role)
        archetypes     = try? container.decodeIfPresent([IdentityTraitDTO].self, forKey: .archetypes)
        storyFunctions = try? container.decodeIfPresent([IdentityTraitDTO].self, forKey: .storyFunctions)
        traits         = try? container.decodeIfPresent(BigFiveTraitsDTO.self, forKey: .traits)
        quirks         = try? container.decodeIfPresent([String].self, forKey: .quirks)
    }

    enum CodingKeys: String, CodingKey {
        case role, archetypes, storyFunctions, traits, quirks
    }

    /// Returns `nil` for an empty identity so blank identities never write a
    /// dangling empty map to Firebase.
    init?(domain identity: CharacterIdentity) {
        guard !identity.isEmpty else { return nil }
        let traitsDTO: BigFiveTraitsDTO?
        if let traits = identity.traits, !traits.isEmpty {
            traitsDTO = BigFiveTraitsDTO(domain: traits)
        } else {
            traitsDTO = nil
        }
        self.init(
            role: identity.role.map(HierarchicalRoleDTO.init(domain:)),
            archetypes: identity.archetypes.isEmpty
                ? nil : identity.archetypes.map(IdentityTraitDTO.init(domain:)),
            storyFunctions: identity.storyFunctions.isEmpty
                ? nil : identity.storyFunctions.map(IdentityTraitDTO.init(domain:)),
            traits: traitsDTO,
            quirks: identity.quirks.isEmpty ? nil : identity.quirks
        )
    }

    func toDomain() -> CharacterIdentity {
        CharacterIdentity(
            role: role?.toDomain(),
            archetypes: archetypes?.map { $0.toDomain() } ?? [],
            storyFunctions: storyFunctions?.map { $0.toDomain() } ?? [],
            traits: traits?.toDomain(),
            quirks: quirks ?? []
        )
    }
}
