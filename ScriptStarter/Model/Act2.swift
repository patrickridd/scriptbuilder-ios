//
//  Act2.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Act2 {
    
    // Keys
    let newWorldDescriptionKey = "newWorldDescription"
    let enemiesFriendsKey = "enemiesFriends"
    let obstaclesKey = "obstacles"
    let theDeadlyEncounterKey = "theDeadlyEncounter"
    let celebrateKey = "celebrate"
    let stormGathersKey = "stormGathers"
    let badGuysStrikeBackKey = "badGuysStrikeBack"
    let allIsLostKey = "allIsLost"
    
    var scenes: [Scene] = []
    var newWorldDescription: String = ""
    var enemiesFriends: String = ""
    var obstacles: String = ""
    var theDeadlyEncounter: String = ""
    var celebrate: String = ""
    var stormGathers: String = ""
    var badGuysStrikeBack: String = ""
    var allIsLost: String = ""
    
    init() {}
    
    init?(actTwoDict: [String:Any]) {
        guard let newWorldDescription = actTwoDict[newWorldDescriptionKey] as? String,
        let enemiesFriends = actTwoDict[enemiesFriendsKey] as? String,
        let obstacles = actTwoDict[obstaclesKey] as? String,
        let theDeadlyEncounter = actTwoDict[theDeadlyEncounterKey] as? String,
        let celebrate = actTwoDict[celebrateKey] as? String,
        let stormGathers = actTwoDict[stormGathersKey] as? String,
        let badGuysStrikeBack = actTwoDict[badGuysStrikeBackKey] as? String,
        let allIsLost = actTwoDict[allIsLostKey] as? String else {
            return nil
        }
        
        self.newWorldDescription = newWorldDescription
        self.enemiesFriends = enemiesFriends
        self.obstacles = obstacles
        self.theDeadlyEncounter = theDeadlyEncounter
        self.celebrate = celebrate
        self.stormGathers = stormGathers
        self.badGuysStrikeBack = badGuysStrikeBack
        self.allIsLost = allIsLost
    }
    
    var firActTwoDictionary: [String:Any] {
        return [self.newWorldDescriptionKey:self.newWorldDescription,       self.enemiesFriendsKey:self.enemiesFriends,
                self.obstaclesKey:obstaclesKey,
                self.theDeadlyEncounterKey:theDeadlyEncounter,
                self.celebrateKey:celebrate,
                self.stormGathersKey:stormGathers,
                self.badGuysStrikeBackKey:badGuysStrikeBackKey,
                self.allIsLostKey:allIsLost]
    }
}
