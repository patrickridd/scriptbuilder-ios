//
//  Act1.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public class Act1: Equatable {
    
    // Keys
    public let oldWorldDescriptionKey = "oldWorldDescription"
    public let incitingIncidentKey = "incitingIncident"
    public let callToAdventureKey = "callToAdventure"
    public let meetingMentorKey = "meetingMentor"
    public let themeKey = "theme"
    public let refusalKey = "refusal"
    public let reasonToAdventureKey = "reasonToAdventure"
    public let enemyAtTheGatesKey = "enemyAtTheGates"
    public let scenesKey = "scenes"
    
    public var sceneSet: Set<Scene> = [] {
        didSet {
            self.scenes = []
            self.scenes.append(contentsOf: sceneSet)
            self.scenes.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    public var scenes: [Scene] = []
    
    public var oldWorldDescription: String = "" // 1
    public var incitingIncident: String = "" // 2
    public var callToAdventure: String = "" // 3
    public var meetingMentor: String = "" // 4
    public var theme: String = "" // 5
    public var refusal: String = "" // 6
    public var reasonToAdventure: String = "" // 7
    public var enemyAtTheGates: String = "" // 8
    
    static public func == (lhs: Act1, rhs: Act1) -> Bool {
        return lhs.scenes == rhs.scenes &&
               lhs.oldWorldDescription == rhs.oldWorldDescription &&
               lhs.incitingIncident == rhs.incitingIncident &&
               lhs.callToAdventure == rhs.callToAdventure &&
               lhs.meetingMentor == rhs.meetingMentor &&
               lhs.theme == rhs.theme &&
               lhs.refusal == rhs.refusal &&
               lhs.reasonToAdventure == rhs.reasonToAdventure &&
               lhs.enemyAtTheGates == rhs.enemyAtTheGates
    }
    
    public init() {
        self.sceneSet = []
    }
    
    public init?(actOneDict: [String:Any]) {
        guard let oldWorldDescription = actOneDict[oldWorldDescriptionKey] as? String,
        let incitingIncident = actOneDict[incitingIncidentKey] as? String,
        let callToAdventure = actOneDict[callToAdventureKey] as? String,
        let theme = actOneDict[themeKey] as? String,
        let refusal = actOneDict[refusalKey] as? String,
        let reasonToAdventure = actOneDict[reasonToAdventureKey] as? String,
        let enemyAtTheGates = actOneDict[enemyAtTheGatesKey] as? String else {
            return nil
        }
        
        let meetingMentor = actOneDict[meetingMentorKey] as? String ?? ""
        
        self.meetingMentor = meetingMentor
        self.oldWorldDescription = oldWorldDescription
        self.incitingIncident = incitingIncident
        self.callToAdventure = callToAdventure
        self.theme = theme
        self.refusal = refusal
        self.reasonToAdventure = reasonToAdventure
        self.enemyAtTheGates = enemyAtTheGates
        
        guard let sceneDictionaryArray = actOneDict[self.scenesKey] as? [String:Any] else {
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
    
    public init(act1: Act1) {
        self.meetingMentor = act1.meetingMentor
        self.oldWorldDescription = act1.oldWorldDescription
        self.incitingIncident = act1.incitingIncident
        self.callToAdventure = act1.callToAdventure
        self.theme = act1.theme
        self.refusal = act1.refusal
        self.reasonToAdventure = act1.reasonToAdventure
        self.enemyAtTheGates = act1.enemyAtTheGates
        
        var scenes: [Scene] = []
        for scene in act1.scenes {
            let sceneCopy = Scene(scene: scene)
            scenes.append(sceneCopy)
        }
        self.scenes = scenes
    }
    
    public var firActOneDictionary: [String:Any] {
        return [self.oldWorldDescriptionKey:self.oldWorldDescription,
                self.incitingIncidentKey:self.incitingIncident,
                self.callToAdventureKey:callToAdventure,
                self.meetingMentorKey:meetingMentor,
                self.themeKey:theme,
                self.refusalKey:refusal,
                self.reasonToAdventureKey:reasonToAdventure,
                self.enemyAtTheGatesKey:enemyAtTheGates]
    }
}
