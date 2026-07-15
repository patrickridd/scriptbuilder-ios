//
//  FirebaseScreenplayRepository.swift
//  FirebaseData
//
//  Concrete `Domain.ScreenplayRepository` backed by Firebase Realtime Database.
//
//  The repository never imports an auth package: the composition root supplies a
//  `uidProvider` closure that returns the signed-in user's id (or nil). This
//  keeps FirebaseData decoupled from FirebaseAuthData while still scoping every
//  read/write to the current user, exactly as the protocol intends.
//
//  DTOs own the literal RTDB keys; `RTDBPaths` owns the node layout. This type
//  only orchestrates I/O and DTO ↔ Domain mapping.
//

import Foundation
import Domain
@preconcurrency import FirebaseDatabase
import os

private let repositoryLog = Logger(subsystem: "FeatureAuth-Dev.FirebaseData", category: "Repository")

public final class FirebaseScreenplayRepository: ScreenplayRepository, @unchecked Sendable {

    private let databaseProvider: () -> DatabaseReference
    private lazy var database: DatabaseReference = databaseProvider()
    private let uidProvider: @Sendable () -> String?
    private let logger: AppLogger

    /// - Parameters:
    ///   - database: Root RTDB reference. Defaults to `Database.database().reference()`.
    ///     Resolved lazily on first use so that constructing the repository does
    ///     not force `FirebaseApp.configure()` — unit tests can inject a logger
    ///     without a configured Firebase app.
    ///   - uidProvider: Returns the current signed-in user's id, or nil.
    ///   - logger: Logging seam from `Domain`. Defaults to a `SystemLogger`
    ///     scoped to this package's category, so the composition root can pass
    ///     the app-wide logger to unify output, or a mock in tests.
    public init(
        database: DatabaseReference? = nil,
        uidProvider: @escaping @Sendable () -> String?,
        logger: AppLogger = SystemLogger(subsystem: "FeatureAuth-Dev.FirebaseData", category: "Repository")
    ) {
        self.databaseProvider = { database ?? Database.database().reference() }
        self.uidProvider = uidProvider
        self.logger = logger
    }

    // MARK: - Helpers

    private func requireUID() throws -> String {
        guard let uid = uidProvider(), !uid.isEmpty else {
            throw RepositoryError.notAuthenticated
        }
        return uid
    }

    private func ref(_ path: String) -> DatabaseReference {
        database.child(path)
    }

    /// Validates an identifier before it is used as an RTDB child key.
    ///
    /// RTDB keys must be non-empty and may not contain `/ . # $ [ ]`. Passing
    /// such a key to `updateChildValues` throws an uncatchable Obj-C
    /// `NSException` that tears down the app. This converts that into a
    /// catchable Swift error so autosave can skip the bad write instead of
    /// crashing.
    private func safeKey(_ id: String) throws -> String {
        let illegal = CharacterSet(charactersIn: "/.#$[]")
        guard !id.isEmpty, id.rangeOfCharacter(from: illegal) == nil else {
            repositoryLog.error("Rejected invalid RTDB key: \(id, privacy: .private)")
            throw RepositoryError.invalidIdentifier
        }
        return id
    }

    private func removeObserver(_ handle: DatabaseHandle, at path: String) {
        ref(path).removeObserver(withHandle: handle)
    }

    // MARK: - ScreenplayRepository

    public func fetchScreenplays() async throws -> [Screenplay] {
        let uid = try requireUID()
        let snapshot = try await ref(RTDBPaths.screenplays(uid: uid)).getData()
        guard snapshot.exists() else { return [] }
        return try decodeCollection(snapshot)
    }

    public func screenplay(id: String) async throws -> Screenplay? {
        let uid = try requireUID()
        let snapshot = try await ref(RTDBPaths.screenplay(uid: uid, id: id)).getData()
        guard snapshot.exists(), let value = snapshot.value else { return nil }
        let dto = try decode(ScreenplayDTO.self, from: value)
        return dto.toDomain()
    }

    public func save(_ screenplay: Screenplay) async throws {
        let uid = try requireUID()
        let id = try safeKey(screenplay.uuid)
        let dto = ScreenplayDTO(domain: screenplay)
        let payload = try encode(dto)
        try await ref(RTDBPaths.screenplay(uid: uid, id: id)).setValue(payload)
    }

    public func delete(id: String) async throws {
        let uid = try requireUID()
        try await ref(RTDBPaths.screenplay(uid: uid, id: id)).removeValue()
    }

    public func screenplaysStream() -> AsyncStream<[Screenplay]> {
        AsyncStream { continuation in
            guard let uid = uidProvider(), !uid.isEmpty else {
                continuation.yield([])
                continuation.finish()
                return
            }
            let node = ref(RTDBPaths.screenplays(uid: uid))
            let handle = node.observe(.value) { [weak self] snapshot in
                guard let self else { return }
                let screenplays = (try? self.decodeCollection(snapshot)) ?? []
                continuation.yield(screenplays)
            }
            continuation.onTermination = { [weak self] _ in
                self?.removeObserver(handle, at: RTDBPaths.screenplays(uid: uid))
            }
        }
    }

    // MARK: - Granular writes (autosave)
    //
    // All of these use `updateChildValues` (a non-destructive MERGE) at a
    // scoped child path. This is the deliberate safeguard against the historical
    // bug where `setValue` on a parent node with a partial payload wiped sibling
    // keys. Here we only ever merge a single keyed item (or a few outline
    // fields) and never replace a parent.

    public func save(character: Character, in screenplayID: String) async throws {
        let uid = try requireUID()
        let key = try safeKey(character.uuid)
        let dto = CharacterDTO(domain: character)
        let value = try encode(dto)
        // Merge: only this character's key is written; siblings untouched.
        try await ref(RTDBPaths.characters(uid: uid, id: screenplayID))
            .updateChildValues([key: value])
        try await touchLastUpdated(uid: uid, screenplayID: screenplayID)
    }

    public func delete(characterID: String, from screenplayID: String) async throws {
        let uid = try requireUID()
        let key = try safeKey(characterID)
        // Merge with NSNull removes just this child key; siblings untouched.
        try await ref(RTDBPaths.characters(uid: uid, id: screenplayID))
            .updateChildValues([key: NSNull()])
        try await touchLastUpdated(uid: uid, screenplayID: screenplayID)
    }

    public func save(scene: Scene, in act: Act, of screenplayID: String) async throws {
        let uid = try requireUID()
        let key = try safeKey(scene.uuid)
        let dto = SceneDTO(domain: scene)
        let value = try encode(dto)
        try await ref(RTDBPaths.actScenes(uid: uid, id: screenplayID, act: act))
            .updateChildValues([key: value])
        try await touchLastUpdated(uid: uid, screenplayID: screenplayID)
    }

    public func delete(sceneID: String, from act: Act, of screenplayID: String) async throws {
        let uid = try requireUID()
        let key = try safeKey(sceneID)
        try await ref(RTDBPaths.actScenes(uid: uid, id: screenplayID, act: act))
            .updateChildValues([key: NSNull()])
        try await touchLastUpdated(uid: uid, screenplayID: screenplayID)
    }

    public func updateOutline(_ fields: [OutlineField: String],
                              of screenplayID: String) async throws {
        let uid = try requireUID()
        guard !fields.isEmpty else { return }
        // Map each domain OutlineField to its literal RTDB key, so the UI never
        // sees the diverging persistence keys (logLineKey, authorNameKey, …).
        var payload: [String: Any] = [:]
        for (field, value) in fields {
            payload[field.rtdbKey] = value
        }
        payload[OutlineField.lastUpdatedRTDBKey] = Date().timeIntervalSince1970
        // Merge at the screenplay node: only the supplied outline keys + the
        // timestamp are written. Nested acts/characters are NOT in the payload,
        // and updateChildValues leaves them fully intact.
        try await ref(RTDBPaths.screenplay(uid: uid, id: screenplayID))
            .updateChildValues(payload)
    }

    public func updateActBeats(_ beats: [ActBeatField: String],
                               in act: Act,
                               of screenplayID: String) async throws {
        let uid = try requireUID()
        let scoped = beats.filter { $0.key.act == act }
        guard !scoped.isEmpty else { return }
        // Merge only the supplied beat keys at the act node — the act's nested
        // `scenes` child and every sibling beat are left fully intact.
        var payload: [String: Any] = [:]
        for (beat, value) in scoped {
            payload[beat.rtdbKey] = value
        }
        try await ref(RTDBPaths.actNode(uid: uid, id: screenplayID, act: act))
            .updateChildValues(payload)
        try await touchLastUpdated(uid: uid, screenplayID: screenplayID)
    }

    /// Refreshes only the `lastUpdated` timestamp via a scoped merge.
    private func touchLastUpdated(uid: String, screenplayID: String) async throws {
        try await ref(RTDBPaths.screenplay(uid: uid, id: screenplayID))
            .updateChildValues([OutlineField.lastUpdatedRTDBKey: Date().timeIntervalSince1970])
    }

    // MARK: - Decoding

    /// Decodes a `screenplays` collection snapshot (uuid → screenplay map).
    private func decodeCollection(_ snapshot: DataSnapshot) throws -> [Screenplay] {
        guard snapshot.exists(), let value = snapshot.value, !(value is NSNull) else {
            return []
        }
        do {
            let map = try decode([String: ScreenplayDTO].self, from: value)
            // The RTDB child key IS the screenplay's id. Legacy ScriptStarter
            // data often omits a `uuid` body field, so decoded DTOs come back
            // with an empty uuid. If we trusted that, every keyless screenplay
            // would collapse to the same SwiftUI identity and only one tile
            // would render. Backfill the id from the authoritative child key.
            return map.map { key, dto in
                var screenplay = dto.toDomain()
                if screenplay.uuid.isEmpty {
                    screenplay.uuid = key
                }
                return screenplay
            }
        } catch {
            logger.error("[FirebaseData] decodeCollection failed: \(error)")
            throw error
        }
    }

    private func encode<T: Encodable>(_ value: T) throws -> Any {
        let data = try JSONEncoder.rtdb.encode(value)
        return try JSONSerialization.jsonObject(with: data, options: [.fragmentsAllowed])
    }

    private func decode<T: Decodable>(_ type: T.Type, from value: Any) throws -> T {
        let data = try JSONSerialization.data(withJSONObject: value, options: [.fragmentsAllowed])
        return try JSONDecoder.rtdb.decode(type, from: data)
    }
}

// MARK: - Coders

private extension JSONEncoder {
    static var rtdb: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .secondsSince1970
        return encoder
    }
}

private extension JSONDecoder {
    static var rtdb: JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .secondsSince1970
        return decoder
    }
}
