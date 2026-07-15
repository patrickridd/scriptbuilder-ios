import Testing
import Foundation
import Domain
@testable import FirebaseData

/// `OutlineField.rtdbKey` maps each autosave field to the exact literal RTDB
/// node key. Three keys intentionally diverge from their case name and carry
/// the legacy "Key" suffix (`authorNameKey`, `logLineKey`) — if any of these
/// drift, autosave writes silently land on the wrong node and existing data
/// stops updating. These tests pin the contract.
@Suite("OutlineField RTDB keys")
struct OutlineFieldKeyTests {

    @Test("Diverging keys keep their legacy literal strings")
    func divergingKeysPreserved() {
        #expect(OutlineField.authorName.rtdbKey == "authorNameKey")
        #expect(OutlineField.logLine.rtdbKey == "logLineKey")
    }

    @Test("Straightforward keys match their case name")
    func straightforwardKeysMatchName() {
        #expect(OutlineField.title.rtdbKey == "title")
        #expect(OutlineField.idea.rtdbKey == "idea")
        #expect(OutlineField.notes.rtdbKey == "notes")
        #expect(OutlineField.theme.rtdbKey == "theme")
        #expect(OutlineField.centralIntention.rtdbKey == "centralIntention")
        #expect(OutlineField.mainObstacle.rtdbKey == "mainObstacle")
        #expect(OutlineField.actOneDescription.rtdbKey == "actOneDescription")
        #expect(OutlineField.actTwoDescription.rtdbKey == "actTwoDescription")
        #expect(OutlineField.actThreeDescription.rtdbKey == "actThreeDescription")
    }

    @Test("Every field maps to a non-empty, unique key")
    func allKeysNonEmptyAndUnique() {
        let keys = OutlineField.allCases.map(\.rtdbKey)
        #expect(keys.allSatisfy { !$0.isEmpty })
        #expect(Set(keys).count == keys.count)
    }

    @Test("Last-updated timestamp uses the legacy dateKey")
    func lastUpdatedKeyPreserved() {
        #expect(OutlineField.lastUpdatedRTDBKey == "dateKey")
    }
}
