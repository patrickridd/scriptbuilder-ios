//
//  CharacterIdentityTests.swift
//  DomainTests
//
//  Legacy role resolution and backward-compatible Character decoding.
//

import XCTest
@testable import Domain

final class CharacterIdentityTests: XCTestCase {

    // MARK: - Legacy role resolution

    func testProtagonistResolvesToPrimaryTierRole() {
        let identity = CharacterIdentity(resolvingLegacyRole: "Protagonist")
        XCTAssertEqual(identity.role?.slug, HierarchicalRole.Stock.protagonist)
        XCTAssertEqual(identity.role?.tier, .primary)
        XCTAssertTrue(identity.archetypes.isEmpty)
        XCTAssertTrue(identity.storyFunctions.isEmpty)
    }

    func testAntagonistResolvesToPrimaryTierRole() {
        let identity = CharacterIdentity(resolvingLegacyRole: "Antagonist")
        XCTAssertEqual(identity.role?.slug, HierarchicalRole.Stock.antagonist)
        XCTAssertEqual(identity.role?.tier, .primary)
    }

    func testArchetypeWordsResolveToStockArchetypes() {
        XCTAssertEqual(
            CharacterIdentity(resolvingLegacyRole: "Mentor").archetypes,
            [.stock(ArchetypeSlug.mentor)]
        )
        XCTAssertEqual(
            CharacterIdentity(resolvingLegacyRole: "Lover").archetypes,
            [.stock(ArchetypeSlug.lover)]
        )
        XCTAssertEqual(
            CharacterIdentity(resolvingLegacyRole: "Jester").archetypes,
            [.stock(ArchetypeSlug.jester)]
        )
    }

    func testMysteriousIsPreservedAsCustomArchetype() {
        let identity = CharacterIdentity(resolvingLegacyRole: "Mysterious")
        XCTAssertEqual(identity.archetypes, [.custom("Mysterious")])
        XCTAssertNil(identity.role)
    }

    func testRelationshipWordsResolveToCustomStoryFunctions() {
        for word in ["Ally", "Friend", "Enemy"] {
            let identity = CharacterIdentity(resolvingLegacyRole: word)
            XCTAssertEqual(identity.storyFunctions, [.custom(word)])
            XCTAssertNil(identity.role)
            XCTAssertTrue(identity.archetypes.isEmpty)
        }
    }

    func testFreeTextIsPreservedAsCustomRole() {
        let identity = CharacterIdentity(resolvingLegacyRole: "Chaos Gremlin")
        XCTAssertEqual(identity.role, .custom("Chaos Gremlin"))
        XCTAssertEqual(identity.role?.customLabel, "Chaos Gremlin")
        XCTAssertNil(identity.role?.tier)
    }

    func testNilAndEmptyResolveToEmptyIdentity() {
        XCTAssertTrue(CharacterIdentity(resolvingLegacyRole: nil).isEmpty)
        XCTAssertTrue(CharacterIdentity(resolvingLegacyRole: "  ").isEmpty)
    }

    // MARK: - Tier mapping

    func testStockRoleTiers() {
        XCTAssertEqual(HierarchicalRole(slug: "deuteragonist").tier, .primary)
        XCTAssertEqual(HierarchicalRole(slug: "tritagonist").tier, .secondary)
        XCTAssertEqual(HierarchicalRole(slug: "tetratagonist").tier, .secondary)
        XCTAssertEqual(HierarchicalRole(slug: "fringe").tier, .secondary)
        XCTAssertNil(HierarchicalRole(slug: "background").tier)
    }

    // MARK: - Backward-compatible Character decoding

    func testCharacterWithoutIdentityKeyDecodesAndResolvesLegacyRole() throws {
        let json = #"{"uuid":"abc","name":"Miles","role":"Jester"}"#
        let character = try JSONDecoder().decode(Character.self, from: Data(json.utf8))
        XCTAssertEqual(character.role, "Jester")
        XCTAssertEqual(character.identity.archetypes, [.stock(ArchetypeSlug.jester)])
    }

    func testCharacterIdentityRoundTripsThroughCodable() throws {
        var character = Character(name: "Ripley")
        character.identity = CharacterIdentity(
            role: HierarchicalRole(slug: HierarchicalRole.Stock.protagonist),
            archetypes: [.stock(ArchetypeSlug.warrior), .custom("Survivor")],
            storyFunctions: [.stock(StoryFunctionSlug.audienceSurrogate)],
            traits: BigFiveTraits(conscientiousness: 0.9),
            quirks: ["Keeps a cat"]
        )
        let data = try JSONEncoder().encode(character)
        let decoded = try JSONDecoder().decode(Character.self, from: data)
        XCTAssertEqual(decoded.identity, character.identity)
    }
}
