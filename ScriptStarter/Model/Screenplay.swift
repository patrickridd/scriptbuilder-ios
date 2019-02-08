//
//  Screenplay.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import Firebase

class Screenplay: Equatable {
  
    // keys
    let logLineKey = "logLineKey"
    let actOneDescriptionKey = "actOneDescription"
    let actTwoDescriptionKey = "actTwoDescription"
    let actThreeDescriptionKey = "actThreeDescription"
    let actOneKey = "actOne"
    let actTwoKey = "actTwo"
    let actThreeKey = "actThree"
    let titleKey = "title"
    let uuidKey = "uuid"
    let ideaKey = "idea"
    let notesKey = "notes"
    let themeKey = "theme"
    let centralIntentionKey = "centralIntention"
    let mainObstacleKey = "mainObstacle"
    let charactersKey = "characters"
    
    
    var title: String
    var uuid: String
    
    var idea: String = ""
    var logLine: String = ""
    var notes: String = ""
    var theme: String = ""
    var centralIntention: String = ""
    var mainObstacle: String = ""
    
    var actOneDescription: String = ""
    var actTwoDescription: String = ""
    var actThreeDescription: String = ""
    var characters: [Character] = []
    var act1 = Act1()
    var act2 = Act2()
    var act3 = Act3()
    
    static func == (lhs: Screenplay, rhs: Screenplay) -> Bool {
        return lhs.title == rhs.title &&
               lhs.uuid == rhs.uuid &&
               lhs.idea == rhs.idea &&
               lhs.logLine == rhs.logLine &&
               lhs.notes == rhs.notes &&
               lhs.theme == rhs.theme &&
               lhs.centralIntention == rhs.centralIntention &&
               lhs.mainObstacle == rhs.mainObstacle &&
               lhs.actOneDescription == rhs.actOneDescription &&
               lhs.characters == rhs.characters &&
               lhs.act1 == rhs.act1 &&
               lhs.act2 == rhs.act2 &&
               lhs.act3 == rhs.act3
    }

    init(title: String) {
        self.title = title
        self.uuid = UUID().uuidString
    }
    
    init?(uuid: String, screenplayDictionary: [String:Any]) {
        guard let title = screenplayDictionary[titleKey] as? String else
        { return nil }
        
        self.notes = screenplayDictionary[notesKey] as? String ?? ""
        self.theme =  screenplayDictionary[themeKey] as? String ?? ""
        self.centralIntention = screenplayDictionary[centralIntentionKey] as? String ?? ""
        self.mainObstacle = screenplayDictionary[mainObstacleKey] as? String ?? ""
        self.uuid = uuid
        self.title = title
        self.logLine = screenplayDictionary[logLineKey] as? String ?? ""
        self.idea = screenplayDictionary[ideaKey] as? String ?? ""
        self.actOneDescription = screenplayDictionary[actOneDescriptionKey] as? String ?? ""
        self.actTwoDescription = screenplayDictionary[actTwoDescriptionKey] as? String ?? ""
        self.actThreeDescription = screenplayDictionary[actThreeDescriptionKey] as? String ?? ""
       
        let actOneDict = screenplayDictionary[actOneKey] as? [String:Any] ?? [:]
        let actTwoDict = screenplayDictionary[actTwoKey] as? [String:Any] ?? [:]
        let actThreeDict = screenplayDictionary[actThreeKey] as? [String:Any] ?? [:]
        self.act1 = Act1(actOneDict: actOneDict) ?? Act1()
        self.act2 = Act2(actTwoDict: actTwoDict) ?? Act2()
        self.act3 = Act3(actThreeDict: actThreeDict) ?? Act3()
        
        guard let charactersDictionaryArray = screenplayDictionary[charactersKey] as? [String:Any] else {
            return
        }
        for characterKeyPair in charactersDictionaryArray {
            guard let characterDictionary = characterKeyPair.value as? [String:Any],
             let character = Character(uuid: characterKeyPair.key, characterDictionary:characterDictionary) else {
                continue
            }
            self.characters.append(character)
        }
    }
    
    init(screenplay: Screenplay) {
        title = screenplay.title
        uuid = screenplay.uuid
        
        idea = screenplay.idea
        logLine = screenplay.logLine
        notes = screenplay.notes
        theme = screenplay.theme
        centralIntention = screenplay.centralIntention
        mainObstacle = screenplay.mainObstacle
        
        actOneDescription = screenplay.actOneDescription
        actTwoDescription = screenplay.actTwoDescription
        actThreeDescription = screenplay.actThreeDescription
        
        // Create new Character, Acts, and Scene References so that this screenplay is completely separate than the object passed in
        var characterObjects: [Character] = []
        for character in screenplay.characters {
            let character = Character(character: character)
            characterObjects.append(character)
        }
        characters = characterObjects
        
        act1 = Act1(act1: screenplay.act1)
        act2 = Act2(act2: screenplay.act2)
        act3 = Act3(act3: screenplay.act3)
    }
    
    var firDictionary: [String:Any] {
        return [titleKey: self.title,
                logLineKey:self.logLine,
                ideaKey:self.idea,
                themeKey:self.theme,
                notesKey:self.notes,
                centralIntentionKey:self.centralIntention,
                mainObstacleKey: self.mainObstacleKey,
                actOneDescriptionKey: self.actOneDescription,
                actTwoDescriptionKey: self.actTwoDescription,
                actThreeDescriptionKey: self.actThreeDescription,
                actOneKey:self.act1.firActOneDictionary,
                actTwoKey:self.act2.firActTwoDictionary,
                actThreeKey:self.act3.firActThreeDictionary]
    }
    
    var characterDictionaryArray: [[String:Any]] {
        var characterDictionaryArray: [[String:Any]] = [[:]]
        for character in characters {
            characterDictionaryArray.append(character.characterDictionary)
        }
        
        return characterDictionaryArray
    }
}
