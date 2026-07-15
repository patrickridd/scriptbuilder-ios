//
//  Screenplay+LegacySceneAccessors.swift
//  Domain
//
//  Bridges the old `Set<Scene>`-style mutation API used by legacy UIKit view
//  controllers to the current `[Scene]` arrays stored on each Act.
//
//  Call sites use:
//      self.screenplay?.act1ScenesSet.insert(scene)
//      self.screenplay?.act1ScenesSet.remove(scene)
//
//  Swift value-type semantics make this work:
//   1. The getter returns a `SceneMutationProxy` wrapping a copy of the scenes.
//   2. `insert` / `remove` mutate that copy.
//   3. Swift calls the setter with the mutated proxy, which writes the updated
//      array back into the act.
//

import Foundation

// MARK: - Scene mutation proxy

/// A lightweight value type that provides Set-style `insert` / `remove`
/// on top of a `[Scene]` snapshot.  The owner's setter commits changes back.
public struct SceneMutationProxy {

    /// Current (possibly mutated) snapshot of the scenes.
    public private(set) var scenes: [Scene]

    public init(scenes: [Scene]) {
        self.scenes = scenes
    }

    /// Inserts `scene`, replacing any existing scene with the same `uuid`.
    public mutating func insert(_ scene: Scene) {
        if let idx = scenes.firstIndex(where: { $0.uuid == scene.uuid }) {
            scenes[idx] = scene
        } else {
            scenes.append(scene)
        }
    }

    /// Removes the scene matching `scene.uuid`, if present.
    public mutating func remove(_ scene: Scene) {
        scenes.removeAll { $0.uuid == scene.uuid }
    }
}

// MARK: - Screenplay + legacy act scene accessors

public extension Screenplay {

    /// Set-style proxy for Act 1 scenes.
    /// Reading returns a proxy snapshot; writing commits the proxy's scenes back.
    var act1ScenesSet: SceneMutationProxy {
        get { SceneMutationProxy(scenes: act1.scenes) }
        set { act1.scenes = newValue.scenes }
    }

    /// Set-style proxy for Act 2 scenes.
    var act2ScenesSet: SceneMutationProxy {
        get { SceneMutationProxy(scenes: act2.scenes) }
        set { act2.scenes = newValue.scenes }
    }

    /// Set-style proxy for Act 3 scenes.
    var act3ScenesSet: SceneMutationProxy {
        get { SceneMutationProxy(scenes: act3.scenes) }
        set { act3.scenes = newValue.scenes }
    }
}
