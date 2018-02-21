//
//  Character.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class Character {
    
    // Keys
    let nameKey = "name"
    let roleKey = "role"
    let intentionKey = "intention"
    let whyIntentionKey = "whyTheyWantThis"
    let whatToDoKey = "physicalGoal"
    let obstaclesKey = "obstacles"
    let flawsKey = "flaws"
    let howCharacterChangedKey = "howCharacterChanged"
    let notesKey = "notes"
    let howDoesCharacterDoItKey = "howDoesCharacterDoIt"
    let needKey = "need"
    
    // Basic
    var uuid: String
    var name: String
    var role: String?
    
    // Character Arc
    var intention: String = ""
    var whyIntention: String = ""
    var whatToDo: String = ""
    var howDoesCharacterDoIt: String = ""
    var obstacles: String = ""
    var flaws: String = ""
    var intentionFix: String = ""
    var need: String = ""
    var howCharacterChanged: String = ""
    var notes: String = ""
    
    init(name:String) {
        self.name = name
        self.uuid = UUID().uuidString
    }
    
    init?(uuid: String, characterDictionary: [String:Any]) {
        self.uuid = uuid
        self.name = characterDictionary[nameKey] as? String ?? ""
        self.role = characterDictionary[roleKey] as? String ?? ""
        self.intention = characterDictionary[intentionKey] as? String ?? ""
        self.whyIntention = characterDictionary[whyIntentionKey] as? String ?? ""
        self.whatToDo = characterDictionary[whatToDoKey] as? String ?? ""
        self.howDoesCharacterDoIt = characterDictionary[howDoesCharacterDoItKey] as? String ?? ""
        self.obstacles = characterDictionary[obstaclesKey] as? String ?? ""
        self.flaws = characterDictionary[flawsKey] as? String ?? ""
        self.need = characterDictionary[needKey] as? String ?? ""
        self.howCharacterChanged = characterDictionary[howCharacterChangedKey] as? String ?? ""
        self.notes = characterDictionary[notesKey] as? String ?? ""
    }
    
    
    var characterDictionary: [String:Any] {
        return [self.nameKey:name,
                self.roleKey:role ?? "",
                self.intentionKey:intention,
                self.whyIntentionKey:whyIntention,
                self.whatToDoKey:whatToDo,
                self.howDoesCharacterDoItKey:howDoesCharacterDoIt,
                self.obstaclesKey:obstacles,
                self.flawsKey:flaws,
                self.needKey:need,
                self.howCharacterChangedKey:howCharacterChanged,
                self.notesKey:notes]
    }
}
