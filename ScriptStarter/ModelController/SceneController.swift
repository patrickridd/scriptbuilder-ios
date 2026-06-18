//
//  SceneController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/16/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Domain
import Foundation

class SceneController {
    
    static let shared = SceneController()
    
    /// Resolve scene-number collisions in the given act by bumping any other
    /// scene that shares `scene`'s number, cascading upward.
    ///
    /// Value semantics: `Scene`/`Screenplay` are structs, so we mutate the
    /// scenes stored on the act in place (by index) through an `inout`
    /// `screenplay` and let the caller persist the result.
    func adjustSceneNumbers(for scene: Scene, in act: OutlineSection, with screenplay: inout Screenplay) {
        switch act {
        case .one:
            bumpCollisions(for: scene, in: act, scenes: &screenplay.act1.scenes)
        case .two:
            bumpCollisions(for: scene, in: act, scenes: &screenplay.act2.scenes)
        case .three:
            bumpCollisions(for: scene, in: act, scenes: &screenplay.act3.scenes)
        case .idea:
            break
        }
    }

    /// Bump the first scene that collides with `scene`'s number, then recurse
    /// on that bumped scene so the shift cascades through the act.
    private func bumpCollisions(for scene: Scene, in act: OutlineSection, scenes: inout [Scene]) {
        guard let index = scenes.firstIndex(where: {
            $0.uuid != scene.uuid && $0.sceneNumber == scene.sceneNumber
        }) else { return }

        scenes[index].sceneNumber = scene.sceneNumber + 1
        let bumped = scenes[index]
        bumpCollisions(for: bumped, in: act, scenes: &scenes)
    }
    
    
}
