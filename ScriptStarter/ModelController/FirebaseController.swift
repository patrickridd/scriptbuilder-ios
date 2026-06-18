//
//  FirebaseController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//
//  MARK: - TEMP: legacy bridge, remove after editor migration
//
//  This class used to talk to RTDB directly. It is now a thin *adapter* that
//  forwards every call to the new `ScreenplayRepository` (the single source of
//  truth), resolved once off the AppDelegate composition root. Legacy call
//  sites keep their old synchronous + completion-handler signatures and compile
//  unchanged; internally each method bridges to the repo's `async throws` API.
//
//  Rules while this seam exists:
//  - Forward only. Never write to RTDB here in parallel with the repo.
//  - Read the repo instance off the AppDelegate; never construct a fresh one.
//  - Keep adapter bodies dead-simple and forward errors faithfully.
//

import Domain
import Foundation
import Firebase
import FirebaseAuth
import FirebaseDatabase
import UIKit

let usersKey: String = "users"
let screenplaysKey: String = "screenplays"
let actOneKey: String = "actOne"
let actTwoKey: String = "actTwo"
let actThreeKey: String = "actThree"
let scenesKey: String = "scenes"
let charactersKey: String = "characters"
let act1ScenesKey = "actOneScenes"
let act2ScenesKey = "actTwoScenes"
let act3ScenesKey = "actThreeScenes"

class FirebaseController {

    static let shared = FirebaseController()

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveCurrentScreenplay),
            name: .ScreenplayUpdated,
            object: nil
        )
    }

    // MARK: - Composition-root accessors

    /// The single, app-wide repository instance built in the AppDelegate.
    /// Force-resolved because the legacy code assumes a configured app.
    private var repository: ScreenplayRepository? {
        (UIApplication.shared.delegate as? AppDelegate)?.firebaseRepository
    }

    var currentScreenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }

    var user: FirebaseAuth.User? {
        return Auth.auth().currentUser
    }

    // MARK: - Connectivity (unchanged — not a persistence concern)

    func areWeOffline(completion: @escaping (_ offline: Bool) -> Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            completion(!(snapshot.value as? Bool ?? false))
        })
    }

    // MARK: - Screenplay

    @objc func saveCurrentScreenplay() {
        if let screenplay = currentScreenplay {
            save(screenplay: screenplay)
        }
    }

    func save(screenplay: Screenplay, completion: ((_ success: Bool) -> Void)? = nil) {
        forward(completionBool: completion) { repo in
            try await repo.save(screenplay)
        }
    }

    /// Outline-only save. Forwards the whole screenplay so the repo's merge
    /// keeps nested acts/characters intact (its `save` is a deep update).
    func saveScreenplayOutline() {
        guard let currentScreenplay else { return }
        forward { repo in try await repo.save(currentScreenplay) }
    }

    func saveCharacters(in screenplay: Screenplay,
                        completion: ((_ error: Error?) -> Void)? = nil) {
        // Value semantics: build a normalized copy, mutating local vars.
        let normalized: [Character] = screenplay.characters.map { character in
            guard character.name.isEmpty else { return character }
            var copy = character
            copy.name = "Unnamed"
            return copy
        }
        forward(completionError: completion) { repo in
            for character in normalized {
                try await repo.save(character: character, in: screenplay.uuid)
            }
        }
    }

    func save(character: Character?) {
        guard let character, let id = currentScreenplay?.uuid else { return }
        forward { repo in try await repo.save(character: character, in: id) }
    }

    /// Save every scene for one act key. Maps the legacy string key to `Act`.
    func save(scenes: [Scene],
              for actKey: String,
              in screenplay: Screenplay,
              completion: ((_ error: Error?) -> Void)? = nil) {
        guard let act = Self.act(forKey: actKey) else {
            completion?(nil)
            return
        }
        forward(completionError: completion) { repo in
            for scene in scenes {
                try await repo.save(scene: scene, in: act, of: screenplay.uuid)
            }
        }
    }

    func delete(screenplay: Screenplay, completion: @escaping () -> Void) {
        let id = screenplay.uuid
        Task {
            try? await self.repository?.delete(id: id)
            await MainActor.run {
                ScreenplayController.shared.resetCurrentScreenplay()
                completion()
            }
        }
    }

    func delete(character: Character, withScreenplay: Screenplay) {
        let id = withScreenplay.uuid
        forward { repo in try await repo.delete(characterID: character.uuid, from: id) }
    }

    func delete(scene: Scene, inAct: Domain.Act) {
        guard let id = currentScreenplay?.uuid else { return }
        forward { repo in try await repo.delete(sceneID: scene.uuid, from: inAct, of: id) }
    }

    func save(scene: Scene?, inAct: Domain.Act?) {
        guard let scene, let inAct, let id = currentScreenplay?.uuid else { return }
        forward { repo in try await repo.save(scene: scene, in: inAct, of: id) }
    }

    func getScreenplays(completion: @escaping ([Screenplay]) -> Void) {
        Task {
            let result: [Screenplay] = (try? await self.repository?.fetchScreenplays() ?? []) ?? []
            await MainActor.run { completion(result) }
        }
    }

    // MARK: - Account (auth-layer, not screenplay persistence)

    func deleteAccount(completion: @escaping (_ deleted: Bool) -> Void) {
        guard let user = user else {
            completion(false)
            return
        }
        let userRef = Database.database().reference().child(usersKey).child(user.uid)
        user.delete { error in
            if error != nil { completion(false) }
            userRef.removeValue { error, _ in
                completion(error == nil)
            }
        }
    }

    func changePassword(to newPassword: String, completion: @escaping (_ success: Bool) -> Void) {
        guard let user = self.user else {
            completion(false)
            return
        }
        user.updatePassword(to: newPassword) { error in
            completion(error == nil)
        }
    }

    // MARK: - Bridging helpers

    /// Maps a legacy act-scenes RTDB key to the domain `Act` enum.
    private static func act(forKey key: String) -> Domain.Act? {
        switch key {
        case act1ScenesKey: return .one
        case act2ScenesKey: return .two
        case act3ScenesKey: return .three
        default: return nil
        }
    }

    /// Fire-and-forget forward to the repo, swallowing errors (legacy callers
    /// that passed no completion never inspected errors).
    private func forward(_ body: @escaping (ScreenplayRepository) async throws -> Void) {
        guard let repo = repository else { return }
        Task { try? await body(repo) }
    }

    /// Forward and report success/failure to a legacy `Bool` completion.
    private func forward(completionBool: ((Bool) -> Void)?,
                         _ body: @escaping (ScreenplayRepository) async throws -> Void) {
        guard let repo = repository else {
            completionBool?(false)
            return
        }
        Task {
            do {
                try await body(repo)
                await MainActor.run { completionBool?(true) }
            } catch {
                await MainActor.run { completionBool?(false) }
            }
        }
    }

    /// Forward and report any thrown error to a legacy `Error?` completion.
    private func forward(completionError: ((Error?) -> Void)?,
                         _ body: @escaping (ScreenplayRepository) async throws -> Void) {
        guard let repo = repository else {
            completionError?(nil)
            return
        }
        Task {
            do {
                try await body(repo)
                await MainActor.run { completionError?(nil) }
            } catch {
                await MainActor.run { completionError?(error) }
            }
        }
    }
}
