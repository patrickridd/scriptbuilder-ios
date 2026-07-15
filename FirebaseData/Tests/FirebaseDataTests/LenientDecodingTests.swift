import Testing
import Foundation
@testable import FirebaseData

/// The whole point of `LenientDecoding` is that Realtime Database omits empty
/// strings, zeros, and nils entirely — so a DTO with non-optional fields must
/// treat "absent" and "null" as an empty default rather than throwing. These
/// tests decode partial / null JSON directly and assert the fallbacks hold.
@Suite("Lenient decoding")
struct LenientDecodingTests {

    /// Decode a `SceneDTO` from JSON, returning the decoded value.
    private func decodeScene(_ json: String) throws -> SceneDTO {
        try JSONDecoder().decode(SceneDTO.self, from: Data(json.utf8))
    }

    @Test("Missing string keys fall back to empty string")
    func missingStringsBecomeEmpty() throws {
        // Only `title` present — every other RTDB key omitted, as RTDB does
        // for empty values.
        let dto = try decodeScene(#"{ "title": "Opening" }"#)
        #expect(dto.title == "Opening")
        #expect(dto.header.isEmpty)
        #expect(dto.sceneDescription.isEmpty)
        #expect(dto.dialogue.isEmpty)
        #expect(dto.action.isEmpty)
        #expect(dto.characters.isEmpty)
        #expect(dto.howPushesStory.isEmpty)
        #expect(dto.notes.isEmpty)
        #expect(dto.uuid.isEmpty)
    }

    @Test("Explicit null string falls back to empty string")
    func nullStringBecomesEmpty() throws {
        let dto = try decodeScene(#"{ "title": "T", "dialogue": null }"#)
        #expect(dto.dialogue.isEmpty)
    }

    @Test("Missing int key falls back to zero")
    func missingIntBecomesZero() throws {
        let dto = try decodeScene(#"{ "title": "T" }"#)
        #expect(dto.sceneNumber == 0)
    }

    @Test("Explicit null int falls back to zero")
    func nullIntBecomesZero() throws {
        let dto = try decodeScene(#"{ "title": "T", "sceneNumber": null }"#)
        #expect(dto.sceneNumber == 0)
    }

    @Test("Present values are preserved verbatim")
    func presentValuesPreserved() throws {
        let dto = try decodeScene(#"{ "title": "T", "sceneNumber": 7, "dialogue": "Hi" }"#)
        #expect(dto.sceneNumber == 7)
        #expect(dto.dialogue == "Hi")
    }

    @Test("Optional role decodes to nil when absent")
    func optionalRoleAbsentIsNil() throws {
        // CharacterDTO.role is a true optional (decodeIfPresent), distinct from
        // the lenient empty-string fields.
        let dto = try JSONDecoder().decode(
            CharacterDTO.self,
            from: Data(#"{ "name": "Mara" }"#.utf8)
        )
        #expect(dto.name == "Mara")
        #expect(dto.role == nil)
        #expect(dto.intention.isEmpty)
    }
}
