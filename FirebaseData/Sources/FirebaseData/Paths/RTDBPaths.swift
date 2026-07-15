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

    /// The scenes child node for a given act under a screenplay.
    static func actScenes(uid: String, id: String, act: Act) -> String {
        "\(screenplay(uid: uid, id: id))/\(act.scenesNodeKey)"
    }

    /// The act content node (holds narrative beats + nested scenes) under a
    /// screenplay. Keys match the `ScreenplayDTO` coding keys: actOne/Two/Three.
    static func actNode(uid: String, id: String, act: Act) -> String {
        let key: String
        switch act {
        case .one:   key = "actOne"
        case .two:   key = "actTwo"
        case .three: key = "actThree"
        }
        return "\(screenplay(uid: uid, id: id))/\(key)"
    }

    /// The characters child node under a screenplay.
    static func characters(uid: String, id: String) -> String {
        "\(screenplay(uid: uid, id: id))/characters"
    }
}
