import Testing
import Foundation
import Domain
@testable import FirebaseData

/// Behavior of the map ↔ array/set collection mappers in `ScreenplayDTO+Domain`.
///
/// RTDB stores child collections as keyed maps where the child KEY is the
/// authoritative id. Legacy rows may omit the `uuid` body field (it decodes to
/// an empty string), so the mappers backfill the uuid from the key. The map
/// builders also use a merging initializer so a duplicate key can never trap.
///
/// These enums are `private`, so we exercise them through the public
/// `ScreenplayDTO` decode → `toDomain()` path — exactly how they run live.
@Suite("Mapping backfill & dedup")
struct MappingBackfillTests {

    private func decodeScreenplay(_ json: String) throws -> Screenplay {
        try JSONDecoder()
            .decode(ScreenplayDTO.self, from: Data(json.utf8))
            .toDomain()
    }

    @Test("Scene with empty uuid body is backfilled from its RTDB key")
    func sceneUuidBackfilledFromKey() throws {
        // actOne.scenes keyed by "scene-key-1"; the scene body omits `uuid`.
        let json = #"""
        {
          "title": "T",
          "actOne": {
            "scenes": {
              "scene-key-1": { "title": "Cold open", "sceneNumber": 1 }
            }
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act1.scenes.count == 1)
        #expect(screenplay.act1.scenes.first?.uuid == "scene-key-1")
        #expect(screenplay.act1.scenes.first?.title == "Cold open")
    }

    @Test("Scene keeps its explicit uuid when the body provides one")
    func sceneKeepsExplicitUuid() throws {
        let json = #"""
        {
          "title": "T",
          "actOne": {
            "scenes": {
              "map-key": { "uuid": "real-uuid", "title": "S", "sceneNumber": 2 }
            }
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.act1.scenes.first?.uuid == "real-uuid")
    }

    @Test("Character with empty uuid body is backfilled from its RTDB key")
    func characterUuidBackfilledFromKey() throws {
        let json = #"""
        {
          "title": "T",
          "characters": {
            "char-key-1": { "name": "Mara" }
          }
        }
        """#
        let screenplay = try decodeScreenplay(json)
        #expect(screenplay.characters.count == 1)
        #expect(screenplay.characters.first?.uuid == "char-key-1")
        #expect(screenplay.characters.first?.name == "Mara")
    }

    @Test("Save maps duplicate scene uuids without trapping, keeping last")
    func duplicateSceneUuidMergesLast() {
        // Two scenes sharing a uuid must NOT trap on the map build; the merge
        // closure keeps the last one.
        let a = Scene(uuid: "dup", title: "First", sceneNumber: 1)
        let b = Scene(uuid: "dup", title: "Second", sceneNumber: 2)
        let sp = Screenplay(title: "T", act1: Act1(scenes: [a, b]))

        let restored = ScreenplayDTO(domain: sp).toDomain()
        #expect(restored.act1.scenes.count == 1)
        #expect(restored.act1.scenes.first?.title == "Second")
    }

    @Test("Absent collections decode to empty, not nil-crash")
    func absentCollectionsAreEmpty() throws {
        let screenplay = try decodeScreenplay(#"{ "title": "T" }"#)
        #expect(screenplay.characters.isEmpty)
        #expect(screenplay.act1.scenes.isEmpty)
        #expect(screenplay.act2.scenes.isEmpty)
        #expect(screenplay.act3.scenes.isEmpty)
    }
}
