//
//  Act1.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Act1 {
    
    // Keys
    let oldWorldDescriptionKey = "oldWorldDescription"
    let incitingIncidentKey = "incitingIncident"
    let callToAdventureKey = "callToAdventure"
    let themeKey = "theme"
    let refusalKey = "refusal"
    let reasonToAdventureKey = "reasonToAdventure"
    let enemyAtTheGatesKey = "enemyAtTheGates"
    let scenesKey = "scenes"
    
    var scenes: [Scene] = []
    var oldWorldDescription: String = "" // 1
    var incitingIncident: String = "" // 2
    var callToAdventure: String = "" // 3
    var theme: String = "" // 4
    var refusal: String = "" // 5
    var reasonToAdventure: String = "" // 6
    var enemyAtTheGates: String = "" // 7
    
    init() {}
    
    init?(actOneDict: [String:Any]) {
        guard let oldWorldDescription = actOneDict[oldWorldDescriptionKey] as? String,
        let incitingIncident = actOneDict[incitingIncidentKey] as? String,
        let callToAdventure = actOneDict[callToAdventureKey] as? String,
        let theme = actOneDict[themeKey] as? String,
        let refusal = actOneDict[refusalKey] as? String,
        let reasonToAdventure = actOneDict[reasonToAdventureKey] as? String,
        let enemyAtTheGates = actOneDict[enemyAtTheGatesKey] as? String else {
            return nil
        }
        
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
            self.scenes.append(scene)
        }
        
        self.scenes.sort { (scene1, scene2) -> Bool in
            return scene1.sceneNumber < scene2.sceneNumber
        }
    }
    
    var firActOneDictionary: [String:Any] {
        return [self.oldWorldDescriptionKey:self.oldWorldDescription,       self.incitingIncidentKey:self.incitingIncident,
            self.callToAdventureKey:callToAdventure,
            self.themeKey:theme,
            self.refusalKey:refusal,
            self.reasonToAdventureKey:reasonToAdventure,
            self.enemyAtTheGatesKey:enemyAtTheGates]
    }
}
