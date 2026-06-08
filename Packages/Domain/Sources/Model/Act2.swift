//
//  Act2.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public class Act2: Equatable {
    
    // Keys
    public let newWorldDescriptionKey = "newWorldDescription"
    public let enemiesFriendsKey = "enemiesFriends"
    public let obstaclesKey = "obstacles"
    public let theDeadlyEncounterKey = "theDeadlyEncounter"
    public let celebrateKey = "celebrate"
    public let stormGathersKey = "stormGathers"
    public let badGuysStrikeBackKey = "badGuysStrikeBack"
    public let allIsLostKey = "allIsLost"
    public let burnTheBoatsKey = "burnTheBoats"
    public let sharpeningTheSwordKey = "sharpeningTheSword"
    public let scenesKey = "scenes"
    
    public var sceneSet: Set<Scene> = [] {
        didSet {
            self.scenes = []
            self.scenes.append(contentsOf: sceneSet)
            self.scenes.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    public var scenes: [Scene] = []
    
    public var newWorldDescription: String = ""
    public var enemiesFriends: String = ""
    public var obstacles: String = ""
    public var sharpeningTheSword: String = ""
    public var burnTheBoats: String = ""
    public var theDeadlyEncounter: String = ""
    public var celebrate: String = ""
    public var stormGathers: String = ""
    public var badGuysStrikeBack: String = ""
    public var allIsLost: String = ""
    
    static public func == (lhs: Act2, rhs: Act2) -> Bool {
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
    
    public init() {}
    
    public init?(actTwoDict: [String:Any]) {
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
    
    public init(act2: Act2) {
        self.burnTheBoats = act2.burnTheBoats
        self.sharpeningTheSword = act2.sharpeningTheSword
        self.newWorldDescription = act2.newWorldDescription
        self.enemiesFriends = act2.enemiesFriends
        self.obstacles = act2.obstacles
        self.theDeadlyEncounter = act2.theDeadlyEncounter
        self.celebrate = act2.celebrate
        self.stormGathers = act2.stormGathers
        self.badGuysStrikeBack = act2.badGuysStrikeBack
        self.allIsLost = act2.allIsLost
        
        var scenes: [Scene] = []
        for scene in act2.scenes {
            let sceneCopy = Scene(scene: scene)
            scenes.append(sceneCopy)
        }
        self.scenes = scenes
    }
    
    public var firActTwoDictionary: [String:Any] {
        return [self.newWorldDescriptionKey:self.newWorldDescription,
                self.enemiesFriendsKey:self.enemiesFriends,
                self.obstaclesKey:obstacles,
                self.theDeadlyEncounterKey:theDeadlyEncounter,
                self.sharpeningTheSwordKey:self.sharpeningTheSword,
                self.burnTheBoatsKey:self.burnTheBoats,
                self.celebrateKey:celebrate,
                self.stormGathersKey:stormGathers,
                self.badGuysStrikeBackKey:badGuysStrikeBack,
                self.allIsLostKey:allIsLost]
    }
}
