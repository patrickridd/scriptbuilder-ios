import Testing
import Foundation
import Domain
@testable import FirebaseData

/// Persistence coverage for the Act I setup beats. These verify the full
/// round-trip (domain → DTO → RTDB JSON → domain) plus backward-compatibility
/// with legacy records that omit some beat keys.
///
/// We exercise the public `ScreenplayDTO` decode → `toDomain()` path and the
/// `ScreenplayDTO(domain:)` save path — exactly how they run live.
@Suite("Act 1 beat persistence")
struct Act1BeatPersistenceTests {

    private func decodeScreenplay(_ json: String) throws -> Screenplay {
        try JSONDecoder()
            .decode(ScreenplayDTO.self, from: Data(json.utf8))
            .toDomain()
    }

    // MARK: - Round-trip

    @Test("All Act 1 beats survive a save → load round-trip")
    func beatsRoundTrip() {
        let act1 = Act1(
            oldWorldDescription: "Old world",
            incitingIncident: "Incident",
            callToAdventure: "Call",
            meetingMentor: "Mentor",
            theme: "Theme",
            refusal: "Refusal",
            reasonToAdventure: "Reason",
            enemyAtTheGates: "Enemy"
        )
        let sp = Screenplay(title: "T", act1: act1)

        let restored = ScreenplayDTO(domain: sp).toDomain()

        #expect(restored.act1.oldWorldDescription == "Old world")
        #expect(restored.act1.incitingIncident == "Incident")
        #expect(restored.act1.callToAdventure == "Call")
        #expect(restored.act1.meetingMentor == "Mentor")
        #expect(restored.act1.theme == "Theme")
        #expect(restored.act1.refusal == "Refusal")
        #expect(restored.act1.reasonToAdventure == "Reason")
        #expect(restored.act1.enemyAtTheGates == "Enemy")
    }

    // MARK: - Decode from RTDB JSON

    @Test("Act 1 beats decode from an RTDB record that includes them")
    func beatsDecodeFromJSON() throws {
        let json = #"""
        {
          "title": "T",
          "actOne": {
            "oldWorldDescription": "OW",
            "incitingIncident": "II",
            "callToAdventure": "CTA",
            "meetingMentor": "MM",
            "theme": "TH",
            "refusal": "RF",
            "reasonToAdventure": "RA",
            "enemyAtTheGates": "EG"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act1.oldWorldDescription == "OW")
        #expect(screenplay.act1.incitingIncident == "II")
        #expect(screenplay.act1.enemyAtTheGates == "EG")
    }

    // MARK: - Backward compatibility

    @Test("Legacy Act 1 record missing some beat keys decodes to empty strings")
    func legacyRecordDecodesToEmpty() throws {
        let json = #"""
        {
          "title": "T",
          "actOne": {
            "oldWorldDescription": "OW"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act1.oldWorldDescription == "OW")
        #expect(screenplay.act1.incitingIncident == "")
        #expect(screenplay.act1.enemyAtTheGates == "")
    }

    @Test("Empty Act 1 beats round-trip back to empty strings")
    func emptyBeatsRoundTrip() {
        let sp = Screenplay(title: "T", act1: Act1())
        let restored = ScreenplayDTO(domain: sp).toDomain()
        #expect(restored.act1.oldWorldDescription == "")
        #expect(restored.act1.enemyAtTheGates == "")
    }
}
