import Testing
import Foundation
import Domain
@testable import FirebaseData

/// Persistence coverage for the two newer Act III beats — `timeIsRunningOut`
/// and `climax`. These verify the full round-trip (domain → DTO → RTDB JSON →
/// domain) plus backward-compatibility with legacy records saved before the
/// fields existed.
///
/// We exercise the public `ScreenplayDTO` decode → `toDomain()` path and the
/// `ScreenplayDTO(domain:)` save path — exactly how they run live.
@Suite("Act 3 beat persistence")
struct Act3BeatPersistenceTests {

    private func decodeScreenplay(_ json: String) throws -> Screenplay {
        try JSONDecoder()
            .decode(ScreenplayDTO.self, from: Data(json.utf8))
            .toDomain()
    }

    // MARK: - Round-trip

    @Test("New Act 3 beats survive a save → load round-trip")
    func newBeatsRoundTrip() {
        let act3 = Act3(
            theUltimateAnswer: "The answer",
            timeIsRunningOut: "The clock ticks",
            climax: "Final showdown",
            rewards: "The prize",
            untangleStory: "Loose ends tied",
            brandNewWorld: "A changed world"
        )
        let sp = Screenplay(title: "T", act3: act3)

        let restored = ScreenplayDTO(domain: sp).toDomain()

        #expect(restored.act3.timeIsRunningOut == "The clock ticks")
        #expect(restored.act3.climax == "Final showdown")
        // Existing beats remain intact alongside the new ones.
        #expect(restored.act3.theUltimateAnswer == "The answer")
        #expect(restored.act3.brandNewWorld == "A changed world")
    }

    // MARK: - Decode from RTDB JSON

    @Test("New Act 3 beats decode from an RTDB record that includes them")
    func newBeatsDecodeFromJSON() throws {
        let json = #"""
        {
          "title": "T",
          "actThree": {
            "theUltimateAnswer": "A",
            "timeIsRunningOut": "Deadline looms",
            "climax": "The clash",
            "rewards": "R",
            "untangleStory": "U",
            "brandNewWorld": "W"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act3.timeIsRunningOut == "Deadline looms")
        #expect(screenplay.act3.climax == "The clash")
    }

    // MARK: - Backward compatibility

    @Test("Legacy Act 3 record without the new keys decodes to empty strings")
    func legacyRecordDecodesToEmpty() throws {
        // An older record: `actThree` present but missing timeIsRunningOut/climax.
        let json = #"""
        {
          "title": "T",
          "actThree": {
            "theUltimateAnswer": "A",
            "rewards": "R",
            "untangleStory": "U",
            "brandNewWorld": "W"
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act3.timeIsRunningOut == "")
        #expect(screenplay.act3.climax == "")
        // Legacy fields still decode correctly.
        #expect(screenplay.act3.theUltimateAnswer == "A")
        #expect(screenplay.act3.brandNewWorld == "W")
    }

    @Test("Empty new beats round-trip back to empty strings")
    func emptyBeatsRoundTrip() {
        let sp = Screenplay(title: "T", act3: Act3())
        let restored = ScreenplayDTO(domain: sp).toDomain()
        #expect(restored.act3.timeIsRunningOut == "")
        #expect(restored.act3.climax == "")
    }
}
