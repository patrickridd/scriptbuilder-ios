import Foundation
import Domain

/// A test double that records every character written through
/// `save(character:in:)` so view-model tests can assert autosave / `flush()`
/// behaviour. Every other repository method is an inert no-op — the character
/// editor only ever calls character saves.
///
/// Implemented as a lock-guarded `final class` rather than an `actor`: the
/// protocol has synchronous requirements (e.g. `screenplaysStream()`), and
/// satisfying those on an actor would make them actor-isolated, which the
/// compiler flags as crossing into isolated code. A lock keeps it `Sendable`
/// while leaving the synchronous members non-isolated.
///
/// Shared across suites — keep it feature-agnostic.
final class ScreenplayRepositorySpy: ScreenplayRepository, @unchecked Sendable {
    private let lock = NSLock()
    private var _savedCharacters: [Character] = []
    private var _deletedCharacterIDs: [String] = []
    private var _savedScenes: [(scene: Scene, act: Act)] = []
    private var _deletedScenes: [(sceneID: String, act: Act)] = []
    private var _updatedOutlines: [[OutlineField: String]] = []
    private var _updatedActBeats: [(beats: [ActBeatField: String], act: Act)] = []

    /// Every character passed to `save(character:in:)`, in call order.
    var savedCharacters: [Character] {
        lock.withLock { _savedCharacters }
    }

    /// How many times `save(character:in:)` has been invoked.
    var saveCharacterCallCount: Int {
        lock.withLock { _savedCharacters.count }
    }

    /// Every character id passed to `delete(characterID:from:)`, in call order.
    var deletedCharacterIDs: [String] {
        lock.withLock { _deletedCharacterIDs }
    }

    /// Every scene passed to `save(scene:in:of:)`, paired with its act, in call order.
    var savedScenes: [(scene: Scene, act: Act)] {
        lock.withLock { _savedScenes }
    }

    /// How many times `save(scene:in:of:)` has been invoked.
    var saveSceneCallCount: Int {
        lock.withLock { _savedScenes.count }
    }

    /// Every scene id passed to `delete(sceneID:from:of:)`, paired with the act
    /// it was removed from, in call order.
    var deletedScenes: [(sceneID: String, act: Act)] {
        lock.withLock { _deletedScenes }
    }

    /// How many times `delete(sceneID:from:of:)` has been invoked.
    var deleteSceneCallCount: Int {
        lock.withLock { _deletedScenes.count }
    }

    /// Every outline field dictionary passed to `updateOutline(_:of:)`, in call order.
    var updatedOutlines: [[OutlineField: String]] {
        lock.withLock { _updatedOutlines }
    }

    /// How many times `updateOutline(_:of:)` has been invoked.
    var updateOutlineCallCount: Int {
        lock.withLock { _updatedOutlines.count }
    }

    /// Every beat dictionary passed to `updateActBeats(_:in:of:)`, paired with
    /// the act it targeted, in call order.
    var updatedActBeats: [(beats: [ActBeatField: String], act: Act)] {
        lock.withLock { _updatedActBeats }
    }

    /// How many times `updateActBeats(_:in:of:)` has been invoked.
    var updateActBeatsCallCount: Int {
        lock.withLock { _updatedActBeats.count }
    }

    func save(character: Character, in screenplayID: String) async throws {
        lock.withLock { _savedCharacters.append(character) }
    }

    func delete(characterID: String, from screenplayID: String) async throws {
        lock.withLock { _deletedCharacterIDs.append(characterID) }
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
        lock.withLock { _savedScenes.append((scene, act)) }
    }
    func delete(sceneID: String, from act: Act, of screenplayID: String) async throws {
        lock.withLock { _deletedScenes.append((sceneID, act)) }
    }
    func updateOutline(_ fields: [OutlineField: String], of screenplayID: String) async throws {
        lock.withLock { _updatedOutlines.append(fields) }
    }
    func updateActBeats(_ beats: [ActBeatField: String], in act: Act, of screenplayID: String) async throws {
        lock.withLock { _updatedActBeats.append((beats, act)) }
    }
}
