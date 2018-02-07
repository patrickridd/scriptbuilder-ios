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
    
    var theUltimateAnswer: String = ""
    var rewards: String = ""
    var untangleStory: String = ""
    
    init?(actThreeDict: [String:Any]) {
        guard let theUltimateAnswer = actThreeDict[theUltimateAnswer] as? String,
        let rewards = actThreeDict[rewardsKey] as? String,
        let untangleStory = actThreeDict[untangleStoryKey] as? String else {
                return nil
        }
        self.theUltimateAnswer = theUltimateAnswer
        self.rewards = rewards
        self.untangleStory = untangleStory
    }
}
