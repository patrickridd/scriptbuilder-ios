//
//  Character.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class Character: Equatable, Hashable {
    
    // Keys
    let nameKey = "name"
    let roleKey = "role"
    let intentionKey = "intention"
    let whyIntentionKey = "whyTheyWantThis"
    let whatToDoKey = "physicalGoal"
    let obstaclesKey = "obstacles"
    let flawsKey = "flaws"
    let intentionFixKey = "intentionFix"
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
    
    static func == (lhs: Character, rhs: Character) -> Bool {
        return lhs.uuid == rhs.uuid &&
               lhs.name == rhs.name &&
               lhs.role == rhs.role &&
               lhs.intention == rhs.intention &&
               lhs.whyIntention == rhs.whyIntention &&
               lhs.whatToDo == rhs.whatToDo &&
               lhs.howDoesCharacterDoIt == rhs.howDoesCharacterDoIt &&
               lhs.obstacles == rhs.obstacles &&
               lhs.flaws == rhs.flaws &&
               lhs.intentionFix == rhs.intentionFix &&
               lhs.need == rhs.need &&
               lhs.howCharacterChanged == rhs.howCharacterChanged &&
               lhs.notes == rhs.notes
    }
    
    func hash(into hasher: inout Hasher) {
        self.uuid.hash(into: &hasher)
    }
    
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
        self.intentionFix = characterDictionary[intentionFixKey] as? String ?? ""
        self.need = characterDictionary[needKey] as? String ?? ""
        self.howCharacterChanged = characterDictionary[howCharacterChangedKey] as? String ?? ""
        self.notes = characterDictionary[notesKey] as? String ?? ""
    }
    
    init(character:Character) {
        self.uuid = character.uuid
        self.name = character.name
        self.role = character.role
        self.intention = character.intention
        self.whyIntention = character.whyIntention
        self.whatToDo = character.whatToDo
        self.howDoesCharacterDoIt = character.howDoesCharacterDoIt
        self.obstacles = character.obstacles
        self.flaws = character.flaws
        self.intentionFix = character.intentionFix
        self.need = character.need
        self.howCharacterChanged = character.howCharacterChanged
        self.notes = character.notes
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
                self.intentionFixKey:intentionFix,
                self.needKey:need,
                self.howCharacterChangedKey:howCharacterChanged,
                self.notesKey:notes]
    }
}
