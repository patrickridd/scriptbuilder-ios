//
//  Act3.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Act3: Equatable {
    
    // Keys
    let theUltimateAnswerKey = "theUltimateAnswer"
    let rewardsKey = "rewards"
    let untangleStoryKey = "untangleStory"
    let brandNewWorldKey = "brandNewWorld"
    let scenesKey = "scenes"

    var sceneSet: Set<Scene> = [] {
        didSet {
            self.scenes = []
            self.scenes.append(contentsOf: sceneSet)
            self.scenes.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    var scenes: [Scene] = []
    
    var theUltimateAnswer: String = ""
    var rewards: String = ""
    var untangleStory: String = ""
    var brandNewWorld: String = ""
    
    static func == (lhs: Act3, rhs: Act3) -> Bool {
        return lhs.scenes == rhs.scenes &&
               lhs.theUltimateAnswer == rhs.theUltimateAnswer &&
               lhs.rewards == rhs.rewards &&
               lhs.untangleStory == rhs.untangleStory &&
               lhs.brandNewWorld == rhs.brandNewWorld
    }
    
    init() {}
    
    init?(actThreeDict: [String:Any]) {
        guard let theUltimateAnswer = actThreeDict[theUltimateAnswerKey] as? String,
        let rewards = actThreeDict[rewardsKey] as? String,
        let untangleStory = actThreeDict[untangleStoryKey] as? String else {
                return nil
        }
        self.brandNewWorld = actThreeDict[brandNewWorldKey] as? String ?? ""
        self.theUltimateAnswer = theUltimateAnswer
        self.rewards = rewards
        self.untangleStory = untangleStory
        
        guard let sceneDictionaryArray = actThreeDict[self.scenesKey] as? [String:Any] else {
            return
        }

        for sceneKeyPair in sceneDictionaryArray {
            guard let sceneDictionary = sceneKeyPair.value as? [String:Any],
                let scene = Scene(uuid: sceneKeyPair.key, sceneDictionary:sceneDictionary) else {
                    continue
            }
            self.sceneSet.insert(scene)
        }
        self.scenes.append(contentsOf: sceneSet)
        self.scenes.sort(by: { $0.sceneNumber < $1.sceneNumber })
    }
    
    init(act3: Act3) {
        self.brandNewWorld = act3.brandNewWorld
        self.theUltimateAnswer = act3.theUltimateAnswer
        self.rewards = act3.rewards
        self.untangleStory = act3.untangleStory
        
        var scenes: [Scene] = []
        
        for scene in act3.scenes {
            let sceneCopy = Scene(scene: scene)
            scenes.append(sceneCopy)
        }
        self.scenes = scenes
    }
    
    var firActThreeDictionary: [String:Any] {
        return [self.theUltimateAnswerKey:self.theUltimateAnswer,
                self.rewardsKey:self.rewards,
                self.untangleStoryKey:self.untangleStory,
                self.brandNewWorldKey:self.brandNewWorld]
    }
}
