//
//  CharacterIdentityPersistenceTests.swift
//  FirebaseDataTests
//
//  DTO round-trip and non-destructive legacy migration for CharacterIdentity.
//

import XCTest
import Domain
@testable import FirebaseData

final class CharacterIdentityPersistenceTests: XCTestCase {

    // MARK: - Round trip

    func testIdentityRoundTripsThroughDTO() throws {
        var hero = Character(name: "Furiosa", role: nil)
        hero.identity = CharacterIdentity(
            role: HierarchicalRole(slug: HierarchicalRole.Stock.protagonist),
            archetypes: [.stock(ArchetypeSlug.warrior), .custom("Road Warrior")],
            storyFunctions: [.stock(StoryFunctionSlug.catalyst)],
            traits: BigFiveTraits(openness: 0.4, neuroticism: 0.7),
            quirks: ["Counts bullets aloud"]
        )

        let data = try JSONEncoder().encode(CharacterDTO(domain: hero))
        let decoded = try JSONDecoder().decode(CharacterDTO.self, from: data)
        let restored = decoded.toDomain()

        XCTAssertEqual(restored.identity, hero.identity)
    }

    // MARK: - Legacy migration on read

    func testLegacyRoleResolvesWhenNoStoredIdentity() throws {
        // Simulates an old RTDB record: has "role", no "identity" key.
        let json = #"{"uuid":"c1","name":"Obi-Wan","role":"Mentor"}"#
        let dto = try JSONDecoder().decode(CharacterDTO.self, from: Data(json.utf8))
        let character = dto.toDomain()

        // Legacy field preserved verbatim; identity resolved from it.
        XCTAssertEqual(character.role, "Mentor")
        XCTAssertEqual(character.identity.archetypes, [.stock(ArchetypeSlug.mentor)])
        XCTAssertNil(character.identity.role)
    }

    func testStoredIdentityWinsOverLegacyRole() throws {
        let json = """
        {"uuid":"c2","name":"Han","role":"Ally",
         "identity":{"role":{"slug":"deuteragonist"},
                     "archetypes":[{"slug":"anti-hero"}]}}
        """
        let dto = try JSONDecoder().decode(CharacterDTO.self, from: Data(json.utf8))
        let character = dto.toDomain()

        XCTAssertEqual(character.identity.role?.slug, "deuteragonist")
        XCTAssertEqual(character.identity.archetypes, [.stock(ArchetypeSlug.antiHero)])
        // Legacy "Ally" was NOT re-resolved because a stored identity exists.
        XCTAssertTrue(character.identity.storyFunctions.isEmpty)
    }

    func testEmptyIdentityIsNotWrittenToFirebase() throws {
        let blank = Character(name: "Extra #3")
        let dto = CharacterDTO(domain: blank)
        XCTAssertNil(dto.identity)

        let data = try JSONEncoder().encode(dto)
        let map = try XCTUnwrap(
            JSONSerialization.jsonObject(with: data) as? [String: Any]
        )
        XCTAssertNil(map["identity"])
    }
}
