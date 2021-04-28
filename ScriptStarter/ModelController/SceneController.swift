//
//  SceneController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/16/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class SceneController {
    
    static let shared = SceneController()
    
    func adjustSceneNumbers(for scene: Scene, in act: Act, with screenplay: Screenplay) {

        switch act {
        case .one:
            for otherScene in screenplay.act1ScenesArray {
                if scene.uuid == otherScene.uuid { continue }
                if otherScene.sceneNumber == scene.sceneNumber {
                    otherScene.sceneNumber = scene.sceneNumber+1
                    adjustSceneNumbers(for: otherScene, in: .one, with: screenplay)
                }
            }
        case .two:
            for otherScene in screenplay.act2ScenesArray {
                if scene.uuid == otherScene.uuid { continue }
                if otherScene.sceneNumber == scene.sceneNumber {
                    otherScene.sceneNumber = scene.sceneNumber+1
                    adjustSceneNumbers(for: otherScene, in: .two, with: screenplay)
                }
            }
        case .three:
            for otherScene in screenplay.act3ScenesArray {
                if scene.uuid == otherScene.uuid { continue }
                if otherScene.sceneNumber == scene.sceneNumber {
                    otherScene.sceneNumber = scene.sceneNumber+1
                    adjustSceneNumbers(for: otherScene, in: .three, with: screenplay)
                }
            }
        default:
            break
        }
    }
    
    
}
