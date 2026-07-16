import Foundation
import Domain

/// A test double whose character `save` / `delete` always throw, so view-model
/// tests can assert that `errorMessage` is surfaced on failure. Every other
/// repository method is an inert no-op.
///
/// Like `ScreenplayRepositorySpy`, this is a lock-guarded `final class` (not an
/// `actor`) so it can satisfy the protocol's synchronous requirements without
/// actor isolation, while staying `Sendable`.
///
/// The error it throws is configurable so tests can assert the exact message
/// that reaches `errorMessage`.
struct RepositorySpyError: LocalizedError {
    let message: String
    var errorDescription: String? { message }
}

final class FailingScreenplayRepositorySpy: ScreenplayRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var _saveAttempts = 0
    private var _deleteAttempts = 0
    private var _saveSceneAttempts = 0
    private var _deleteSceneAttempts = 0

    /// The error thrown by both `save(character:in:)` and `delete(characterID:from:)`.
    let error: RepositorySpyError

    init(message: String = "Simulated write failure") {
        self.error = RepositorySpyError(message: message)
    }

    /// How many times a character save was attempted before throwing.
    var saveCharacterCallCount: Int {
        lock.withLock { _saveAttempts }
    }

    /// How many times a character delete was attempted before throwing.
    var deleteCharacterCallCount: Int {
        lock.withLock { _deleteAttempts }
    }

    /// How many times a scene save was attempted before throwing.
    var saveSceneCallCount: Int {
        lock.withLock { _saveSceneAttempts }
    }

    /// How many times a scene delete was attempted before throwing.
    var deleteSceneCallCount: Int {
        lock.withLock { _deleteSceneAttempts }
    }

    func save(character: Character, in screenplayID: String) async throws {
        lock.withLock { _saveAttempts += 1 }
        throw error
    }

    func delete(characterID: String, from screenplayID: String) async throws {
        lock.withLock { _deleteAttempts += 1 }
        throw error
    }

    // MARK: - Unused surface (no-ops)
    func fetchScreenplays() async throws -> [Screenplay] { [] }
    func screenplay(id: String) async throws -> Screenplay? { nil }
    func save(_ screenplay: Screenplay) async throws {}
    func delete(id: String) async throws {}
    func screenplaysStream() -> AsyncStream<[Screenplay]> {
        AsyncStream { $0.finish() }
    }
    func save(scene: Scene, in act: Act, of screenplayID: String) async throws {
        lock.withLock { _saveSceneAttempts += 1 }
        throw error
    }
    func delete(sceneID: String, from act: Act, of screenplayID: String) async throws {
        lock.withLock { _deleteSceneAttempts += 1 }
        throw error
    }
    func updateOutline(_ fields: [OutlineField: String], of screenplayID: String) async throws {
        throw error
    }
    func updateActBeats(_ beats: [ActBeatField: String], in act: Act, of screenplayID: String) async throws {
        throw error
    }
}
