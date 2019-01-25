//
//  Act2.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Act2: Equatable {
    
    // Keys
    let newWorldDescriptionKey = "newWorldDescription"
    let enemiesFriendsKey = "enemiesFriends"
    let obstaclesKey = "obstacles"
    let theDeadlyEncounterKey = "theDeadlyEncounter"
    let celebrateKey = "celebrate"
    let stormGathersKey = "stormGathers"
    let badGuysStrikeBackKey = "badGuysStrikeBack"
    let allIsLostKey = "allIsLost"
    let burnTheBoatsKey = "burnTheBoats"
    let sharpeningTheSwordKey = "sharpeningTheSword"
    let scenesKey = "scenes"
    
    var sceneSet: Set<Scene> = [] {
        didSet {
            self.scenes = []
            self.scenes.append(contentsOf: sceneSet)
            self.scenes.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    var scenes: [Scene] = []
    
    var newWorldDescription: String = ""
    var enemiesFriends: String = ""
    var obstacles: String = ""
    var sharpeningTheSword: String = ""
    var burnTheBoats: String = ""
    var theDeadlyEncounter: String = ""
    var celebrate: String = ""
    var stormGathers: String = ""
    var badGuysStrikeBack: String = ""
    var allIsLost: String = ""
    
    static func == (lhs: Act2, rhs: Act2) -> Bool {
        return lhs.scenes == rhs.scenes &&
               lhs.newWorldDescription == rhs.newWorldDescription &&
               lhs.enemiesFriends == rhs.enemiesFriends &&
               lhs.obstacles == rhs.obstacles &&
               lhs.sharpeningTheSword == rhs.sharpeningTheSword &&
               lhs.burnTheBoats == rhs.burnTheBoats &&
               lhs.theDeadlyEncounter == rhs.theDeadlyEncounter &&
               lhs.celebrate == rhs.celebrate &&
               lhs.stormGathers == rhs.stormGathers &&
               lhs.badGuysStrikeBack == rhs.badGuysStrikeBack &&
               lhs.allIsLost == rhs.allIsLost
    }
    
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
        
        if let burnTheBoats = actTwoDict[burnTheBoatsKey] as? String {
            self.burnTheBoats = burnTheBoats
        }
        self.sharpeningTheSword = actTwoDict[sharpeningTheSwordKey] as? String ?? ""
        
        self.newWorldDescription = newWorldDescription
        self.enemiesFriends = enemiesFriends
        self.obstacles = obstacles
        self.theDeadlyEncounter = theDeadlyEncounter
        self.celebrate = celebrate
        self.stormGathers = stormGathers
        self.badGuysStrikeBack = badGuysStrikeBack
        self.allIsLost = allIsLost
        
        guard let sceneDictionaryArray = actTwoDict[self.scenesKey] as? [String:Any] else {
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
    
    var firActTwoDictionary: [String:Any] {
        return [self.newWorldDescriptionKey:self.newWorldDescription,       self.enemiesFriendsKey:self.enemiesFriends,
                self.obstaclesKey:obstaclesKey,
                self.theDeadlyEncounterKey:theDeadlyEncounter,
                self.sharpeningTheSwordKey:self.sharpeningTheSword,
                self.burnTheBoatsKey:self.burnTheBoats,
                self.celebrateKey:celebrate,
                self.stormGathersKey:stormGathers,
                self.badGuysStrikeBackKey:badGuysStrikeBackKey,
                self.allIsLostKey:allIsLost]
    }
}
