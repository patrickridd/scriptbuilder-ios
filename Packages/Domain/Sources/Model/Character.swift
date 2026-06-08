//
//  Character.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

public class Character: Equatable, Hashable {
    
    // Keys
    public let nameKey = "name"
    public let roleKey = "role"
    public let intentionKey = "intention"
    public let whyIntentionKey = "whyTheyWantThis"
    public let whatToDoKey = "physicalGoal"
    public let obstaclesKey = "obstacles"
    public let flawsKey = "flaws"
    public let intentionFixKey = "intentionFix"
    public let howCharacterChangedKey = "howCharacterChanged"
    public let notesKey = "notes"
    public let howDoesCharacterDoItKey = "howDoesCharacterDoIt"
    public let needKey = "need"
    
    // Basic
    public let uuid: String
    public var name: String
    public var role: String?
    
    // Character Arc
    public var intention: String = ""
    public var whyIntention: String = ""
    public var whatToDo: String = ""
    public var howDoesCharacterDoIt: String = ""
    public var obstacles: String = ""
    public var flaws: String = ""
    public var intentionFix: String = ""
    public var need: String = ""
    public var howCharacterChanged: String = ""
    public var notes: String = ""
    
    static public func == (lhs: Character, rhs: Character) -> Bool {
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
    
    public func hash(into hasher: inout Hasher) {
        self.uuid.hash(into: &hasher)
    }
    
    public init(name:String) {
        self.name = name
        self.uuid = UUID().uuidString
    }
    
    public init?(uuid: String, characterDictionary: [String:Any]) {
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
    
    public init(character:Character) {
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
    
    
    public var characterDictionary: [String:Any] {
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
