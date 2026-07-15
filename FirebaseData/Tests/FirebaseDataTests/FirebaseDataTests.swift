import Testing
import Foundation
import Domain
@testable import FirebaseData

/// An `AppLogger` test double that records every call, so tests can assert on
/// the level and message a unit under test emitted without touching the real
/// Unified Logging System.
final class CapturingLogger: AppLogger, @unchecked Sendable {
    struct Entry: Sendable { let level: LogLevel; let message: String }

    private let lock = NSLock()
    private var _entries: [Entry] = []

    var entries: [Entry] {
        lock.lock(); defer { lock.unlock() }
        return _entries
    }

    func log(_ level: LogLevel, _ message: String) {
        lock.lock(); defer { lock.unlock() }
        _entries.append(Entry(level: level, message: message))
    }
}

@Suite("FirebaseData")
struct FirebaseDataTests {

    /// The repository accepts an injected `AppLogger` from the composition root,
    /// so packages can unify their output through the app-wide logging seam.
    @Test("Repository accepts an injected logger")
    func repositoryAcceptsInjectedLogger() {
        let logger = CapturingLogger()
        _ = FirebaseScreenplayRepository(uidProvider: { nil }, logger: logger)
        #expect(logger.entries.isEmpty)
    }

    /// The capturing logger routes convenience methods to the right levels.
    @Test("Capturing logger routes levels")
    func capturingLoggerRoutesLevels() {
        let logger = CapturingLogger()
        logger.error("oops")
        #expect(logger.entries.count == 1)
        #expect(logger.entries.first?.message == "oops")
        #expect(logger.entries.first?.level == .error)
    }

    /// A Screenplay → DTO → Screenplay round-trip preserves outline fields.
    @Test("Screenplay round-trip preserves outline")
    func screenplayRoundTripPreservesOutline() throws {
        let original = Screenplay(
            uuid: "sp-1",
            title: "The Heist",
            authorName: "Pat",
            idea: "A crew pulls one last job",
            logLine: "Thieves vs. fate",
            theme: "Loyalty",
            centralIntention: "Steal the diamond",
            mainObstacle: "The vault"
        )

        let dto = ScreenplayDTO(domain: original)
        let restored = dto.toDomain()

        #expect(restored.uuid == original.uuid)
        #expect(restored.title == original.title)
        #expect(restored.authorName == original.authorName)
        #expect(restored.logLine == original.logLine)
        #expect(restored.theme == original.theme)
        #expect(restored.centralIntention == original.centralIntention)
        #expect(restored.mainObstacle == original.mainObstacle)
    }

    /// Characters survive the Set ↔ keyed-map conversion.
    @Test("Characters round-trip")
    func charactersRoundTrip() throws {
        let hero = Character(uuid: "c-1", name: "Mara", role: "Protagonist")
        let original = Screenplay(title: "X", characters: [hero])

        let restored = ScreenplayDTO(domain: original).toDomain()

        #expect(restored.characters.count == 1)
        #expect(restored.characters.first?.uuid == "c-1")
        #expect(restored.characters.first?.name == "Mara")
    }

    /// The RTDB authorName key intentionally preserves the legacy "Key" suffix.
    @Test("Legacy key strings preserved")
    func legacyKeyStringsPreserved() throws {
        let data = try JSONEncoder().encode(ScreenplayDTO(domain: Screenplay(title: "T", authorName: "A")))
        let json = String(decoding: data, as: UTF8.self)
        #expect(json.contains("authorNameKey"))
        #expect(json.contains("logLineKey"))
        #expect(json.contains("dateKey"))
    }

    /// The two Character keys that diverge from their property names encode
    /// with the live RTDB strings ("whyTheyWantThis", "physicalGoal").
    @Test("Character divergent keys preserved")
    func characterDivergentKeysPreserved() throws {
        let hero = Character(
            uuid: "c-1",
            name: "Mara",
            whyIntention: "to be free",
            whatToDo: "open the vault"
        )
        let data = try JSONEncoder().encode(CharacterDTO(domain: hero))
        let json = String(decoding: data, as: UTF8.self)
        #expect(json.contains("whyTheyWantThis"))
        #expect(json.contains("physicalGoal"))
        #expect(!json.contains("whyIntention"))
        #expect(!json.contains("whatToDo"))
    }
}
