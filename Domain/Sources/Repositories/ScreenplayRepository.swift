//
//  ScreenplayRepository.swift
//  Domain
//
//  The contract the Home UI depends on for screenplay persistence.
//
//  Mirrors the `AuthService` pattern: the UI layer (`FeatureHome`) and previews
//  depend ONLY on this protocol — never on Firebase, never on `[String: Any]`,
//  never on a `uid`. The app's composition root injects a concrete
//  implementation (e.g. a `FirebaseScreenplayRepository` in a `FirebaseData`
//  package) that reads the current user's id internally from the auth layer.
//
//  Design notes:
//  - **Pure Swift surface.** No persistence-format types leak across this
//    boundary; round-tripping RTDB dictionaries is an implementation detail.
//  - **Whole-screenplay operations only (v1).** Granular character/scene writes
//    are deferred to the editor phase; when added they'll use the `Act` enum.
//  - **Live streaming built in.** `screenplaysStream()` mirrors
//    `authStateStream()` so Home can react to remote changes in real time.
//

import Foundation

public protocol ScreenplayRepository: Sendable {

    /// One-shot fetch of every screenplay for the current user.
    func fetchScreenplays() async throws -> [Screenplay]

    /// Fetch a single screenplay by its `uuid`, or `nil` if none exists.
    func screenplay(id: String) async throws -> Screenplay?

    /// Create or update a whole screenplay (outline + characters + all scenes).
    ///
    /// Implementations should write the entire object in a single deep,
    /// multi-path update where the backend allows it — one round-trip,
    /// atomic-ish — rather than fanning out into many small writes.
    func save(_ screenplay: Screenplay) async throws

    /// Permanently delete the screenplay with the given `uuid`.
    func delete(id: String) async throws

    /// A live stream of the current user's screenplays. Emits the current value
    /// on subscription and again whenever the remote data changes.
    func screenplaysStream() -> AsyncStream<[Screenplay]>

    // MARK: - Granular writes (autosave)
    //
    // These exist for editor autosave: write ONE item or a handful of changed
    // outline fields, not the whole screenplay. Implementations MUST perform a
    // non-destructive *merge* (e.g. RTDB `updateChildValues`) at a scoped child
    // path — never a destructive replace of a parent node, and never a partial
    // dictionary written to a parent. This is the exact safeguard that prevents
    // the historical "save wiped sibling data" bug.
    //
    // Each call should also refresh the screenplay's `lastUpdated` timestamp so
    // lists re-sort, without rewriting any other field.

    /// Upsert a single character under a screenplay. Other characters, the
    /// outline, and all acts are left untouched.
    func save(character: Character, in screenplayID: String) async throws

    /// Remove a single character from a screenplay. Everything else is untouched.
    func delete(characterID: String, from screenplayID: String) async throws

    /// Upsert a single scene within a specific act. Other scenes in that act,
    /// the other acts, characters, and the outline are left untouched.
    func save(scene: Scene, in act: Act, of screenplayID: String) async throws

    /// Remove a single scene from a specific act. Everything else is untouched.
    func delete(sceneID: String, from act: Act, of screenplayID: String) async throws

    /// Merge a set of changed outline fields into a screenplay (e.g. title,
    /// logline, theme). Only the supplied fields are written; unspecified
    /// fields and all nested acts/characters are left untouched.
    ///
    /// Keys are addressed via `OutlineField` so the UI never touches raw RTDB
    /// strings. Pass only the fields the user actually edited.
    func updateOutline(_ fields: [OutlineField: String], of screenplayID: String) async throws

    /// Merge a set of changed per-act narrative beats (e.g. Old World, Inciting
    /// Incident) into a specific act. Only the supplied beats are written;
    /// unspecified beats, the act's scenes, the other acts, characters, and the
    /// outline are all left untouched.
    ///
    /// Keys are addressed via `ActBeatField` so the UI never touches raw RTDB
    /// strings. Every supplied beat must belong to `act`.
    func updateActBeats(_ beats: [ActBeatField: String], in act: Act, of screenplayID: String) async throws
}

/// Outline-level (non-nested) text fields of a screenplay that the editor can
/// autosave individually. Excludes nested acts/characters, which have their own
/// granular methods.
public enum OutlineField: String, CaseIterable, Sendable {
    case title
    case authorName
    case idea
    case logLine
    case notes
    case theme
    case centralIntention
    case mainObstacle
    case actOneDescription
    case actTwoDescription
    case actThreeDescription
}
