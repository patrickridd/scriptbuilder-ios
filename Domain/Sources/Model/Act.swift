//
//  Act.swift
//  Domain
//
//  An abstract reference to one of a screenplay's three acts.
//
//  The concrete act *content* lives in `Act1`/`Act2`/`Act3`, each with its own
//  shape and Firebase key set. This enum exists so callers (and future granular
//  repository methods like `save(scene:in:)`) can address an act abstractly —
//  `.one` / `.two` / `.three` — without coupling to a concrete act class.
//

import Foundation

public enum Act: Int, CaseIterable, Sendable, Identifiable {
    case one = 1
    case two = 2
    case three = 3

    public var id: Int { rawValue }

    /// Human-facing label, e.g. "Act I".
    public var title: String {
        L10n.dynamic("act.\(rawValue).title")
    }

    /// The **legacy stray** RTDB sibling node (`actOneScenes`, …) an earlier
    /// build wrote scenes to by mistake. Scenes are read from and written to
    /// `actOne/scenes/{id}` (`RTDBPaths.relativeSceneKeyPath`); this key is only
    /// used to rescue and clean up stranded copies. Never write new scenes here.
    public var scenesNodeKey: String {
        switch self {
        case .one:   return "actOneScenes"
        case .two:   return "actTwoScenes"
        case .three: return "actThreeScenes"
        }
    }
}
