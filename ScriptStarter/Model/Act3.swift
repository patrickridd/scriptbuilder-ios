//
//  Act3.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Act3 {
    
    // Keys
    let theUltimateAnswerKey = "theUltimateAnswer"
    let rewardsKey = "rewards"
    let untangleStoryKey = "untangleStory"
    let brandNewWorldKey = "brandNewWorld"
    
    var scenes: [Scene] = []
    var theUltimateAnswer: String = ""
    var rewards: String = ""
    var untangleStory: String = ""
    var brandNewWorld: String = ""
    
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
    }
    
    var firActThreeDictionary: [String:Any] {
        return [self.theUltimateAnswerKey:self.theUltimateAnswer,
                self.rewardsKey:self.rewards,
                self.untangleStoryKey:self.untangleStory,
            self.brandNewWorldKey:self.brandNewWorld]
    }
}
