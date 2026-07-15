import Testing
import Foundation
import Domain
@testable import FirebaseData

/// Persistence coverage for the Act II confrontation beats. These verify the
/// full round-trip (domain → DTO → RTDB JSON → domain) plus backward-compat
/// with legacy records that omit some beat keys.
///
/// We exercise the public `ScreenplayDTO` decode → `toDomain()` path and the
/// `ScreenplayDTO(domain:)` save path — exactly how they run live.
@Suite("Act 2 beat persistence")
struct Act2BeatPersistenceTests {

    private func decodeScreenplay(_ json: String) throws -> Screenplay {
        try JSONDecoder()
            .decode(ScreenplayDTO.self, from: Data(json.utf8))
            .toDomain()
    }

    // MARK: - Round-trip

    @Test("All Act 2 beats survive a save → load round-trip")
    func beatsRoundTrip() {
        let act2 = Act2(
            newWorldDescription: "New world",
            enemiesFriends: "Enemies",
            obstacles: "Obstacles",
            sharpeningTheSword: "Sharpen",
            burnTheBoats: "Burn",
            theDeadlyEncounter: "Encounter",
            celebrate: "Celebrate",
            stormGathers: "Storm",
            badGuysStrikeBack: "Strike",
            allIsLost: "Lost"
        )
        let sp = Screenplay(title: "T", act2: act2)

        let restored = ScreenplayDTO(domain: sp).toDomain()

        #expect(restored.act2.newWorldDescription == "New world")
        #expect(restored.act2.enemiesFriends == "Enemies")
        #expect(restored.act2.obstacles == "Obstacles")
        #expect(restored.act2.sharpeningTheSword == "Sharpen")
        #expect(restored.act2.burnTheBoats == "Burn")
        #expect(restored.act2.theDeadlyEncounter == "Encounter")
        #expect(restored.act2.celebrate == "Celebrate")
        #expect(restored.act2.stormGathers == "Storm")
        #expect(restored.act2.badGuysStrikeBack == "Strike")
        #expect(restored.act2.allIsLost == "Lost")
    }

    // MARK: - Decode from RTDB JSON

    @Test("Act 2 beats decode from an RTDB record that includes them")
    func beatsDecodeFromJSON() throws {
        let json = #"""
        {
          "title": "T",
          "actTwo": {
            "newWorldDescription": "NW",
            "enemiesFriends": "EF",
            "obstacles": "OB",
            "sharpeningTheSword": "SS",
            "burnTheBoats": "BB",
            "theDeadlyEncounter": "DE",
            "celebrate": "CE",
            "stormGathers": "SG",
            "badGuysStrikeBack": "SB",
            "allIsLost": "AL"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act2.newWorldDescription == "NW")
        #expect(screenplay.act2.enemiesFriends == "EF")
        #expect(screenplay.act2.allIsLost == "AL")
    }

    // MARK: - Backward compatibility

    @Test("Legacy Act 2 record missing some beat keys decodes to empty strings")
    func legacyRecordDecodesToEmpty() throws {
        let json = #"""
        {
          "title": "T",
          "actTwo": {
            "newWorldDescription": "NW"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act2.newWorldDescription == "NW")
        #expect(screenplay.act2.enemiesFriends == "")
        #expect(screenplay.act2.allIsLost == "")
    }

    @Test("Empty Act 2 beats round-trip back to empty strings")
    func emptyBeatsRoundTrip() {
        let sp = Screenplay(title: "T", act2: Act2())
        let restored = ScreenplayDTO(domain: sp).toDomain()
        #expect(restored.act2.newWorldDescription == "")
        #expect(restored.act2.allIsLost == "")
    }
}
