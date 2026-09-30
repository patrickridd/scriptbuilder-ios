//
//  RTDBPaths.swift
//  FirebaseData
//
//  Single source of truth for Realtime Database node paths.
//
//  Confirmed against the original `FirebaseController.currentScreenplayReference`:
//      users/{uid}/screenplays/{screenplayUuid}
//  (usersKey = "users", screenplaysKey = "screenplays").
//

import Foundation
import Domain

enum RTDBPaths {

    /// Collection of a user's screenplays.
    static func screenplays(uid: String) -> String {
        "users/\(uid)/screenplays"
    }

    /// A single screenplay node, keyed by its `uuid`.
    static func screenplay(uid: String, id: String) -> String {
        "\(screenplays(uid: uid))/\(id)"
    }

    /// The act content node key (holds narrative beats + nested scenes).
    /// Matches the `ScreenplayDTO` coding keys: actOne/Two/Three.
    static func actNodeKey(_ act: Act) -> String {
        switch act {
        case .one:   return "actOne"
        case .two:   return "actTwo"
        case .three: return "actThree"
        }
    }

    /// Scene map path **relative to the screenplay node** — the one location
    /// scenes are read from (`ActNDTO.scenes`). Writes must target this.
    static func relativeSceneKeyPath(act: Act, sceneKey: String) -> String {
        "\(actNodeKey(act))/scenes/\(sceneKey)"
    }

    /// Relative path of a scene in the **stray** sibling node
    /// (`actOneScenes/…`). An earlier build wrote scenes here by mistake while
    /// reading from `actOne/scenes`, so edits never came back. Kept only so
    /// those scenes can be read back and cleaned up on the next save.
    static func relativeStraySceneKeyPath(act: Act, sceneKey: String) -> String {
        "\(act.scenesNodeKey)/\(sceneKey)"
    }

    /// The act content node (holds narrative beats + nested scenes) under a
    /// screenplay.
    static func actNode(uid: String, id: String, act: Act) -> String {
        "\(screenplay(uid: uid, id: id))/\(actNodeKey(act))"
    }

    /// The custom-beats map (id → beat) inside an act node.
    static func actCustomBeats(uid: String, id: String, act: Act) -> String {
        "\(actNode(uid: uid, id: id, act: act))/customBeats"
    }

    /// The disabled-template-beats flag map (beat key → true) on a screenplay.
    static func disabledBeats(uid: String, id: String) -> String {
        "\(screenplay(uid: uid, id: id))/disabledBeats"
    }

    /// The characters child node under a screenplay.
    static func characters(uid: String, id: String) -> String {
        "\(screenplay(uid: uid, id: id))/characters"
    }
}
