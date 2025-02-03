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
    let dateKey = "dateKey"
    let authorNameKey = "authorNameKey"
    let uuidKey = "uuid"
    let ideaKey = "idea"
    let notesKey = "notes"
    let themeKey = "theme"
    let centralIntentionKey = "centralIntention"
    let mainObstacleKey = "mainObstacle"
    let charactersKey = "characters"
    let act1ScenesKey = "actOneScenes"
    let act2ScenesKey = "actTwoScenes"
    let act3ScenesKey = "actThreeScenes"

    var title: String
    var uuid: String
    var authorName: String?
    var lastUpdated: Date?
    
    var idea: String = ""
    var logLine: String = ""
    var notes: String = ""
    var theme: String = ""
    var centralIntention: String = ""
    var mainObstacle: String = ""
    
    var actOneDescription: String = ""
    var actTwoDescription: String = ""
    var actThreeDescription: String = ""
    var characters: Set<Character> = []
    
    var act1ScenesSet: Set<Scene> =  []
    {
        didSet {
            self.act1ScenesArray = []
            self.act1ScenesArray.append(contentsOf: act1ScenesSet)
            self.act1ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    var act2ScenesSet: Set<Scene> =  [] {
        didSet {
            self.act2ScenesArray = []
            self.act2ScenesArray.append(contentsOf: act2ScenesSet)
            self.act2ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    var act3ScenesSet: Set<Scene> = [] {
        didSet {
            self.act3ScenesArray = []
            self.act3ScenesArray.append(contentsOf: act3ScenesSet)
            self.act3ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }

    var act1ScenesArray: [Scene] = []
    var act2ScenesArray: [Scene] = []
    var act3ScenesArray: [Scene] = []
    
    var act1 = Act1()
    var act2 = Act2()
    var act3 = Act3()
    
    static func == (lhs: Screenplay, rhs: Screenplay) -> Bool {
        return lhs.title == rhs.title &&
               lhs.uuid == rhs.uuid &&
               lhs.idea == rhs.idea &&
               lhs.lastUpdated == rhs.lastUpdated &&
               lhs.logLine == rhs.logLine &&
               lhs.notes == rhs.notes &&
               lhs.theme == rhs.theme &&
               lhs.centralIntention == rhs.centralIntention &&
               lhs.mainObstacle == rhs.mainObstacle &&
               lhs.actOneDescription == rhs.actOneDescription &&
               lhs.actTwoDescription == rhs.actTwoDescription &&
               lhs.actThreeDescription == rhs.actThreeDescription &&
               lhs.characters == rhs.characters &&
               lhs.act1 == rhs.act1 &&
               lhs.act2 == rhs.act2 &&
               lhs.act3 == rhs.act3 &&
               lhs.act1ScenesSet == rhs.act1ScenesSet &&
               lhs.act2ScenesSet == rhs.act2ScenesSet &&
               lhs.act3ScenesSet == rhs.act3ScenesSet
    }

    init(title: String, authorName: String) {
        self.title = title
        self.authorName = authorName
        self.uuid = UUID().uuidString
        self.lastUpdated = Date()
    }
    
    init?(uuid: String, screenplayDictionary: [String:Any]) {
        guard let title = screenplayDictionary[titleKey] as? String else
        { return nil }
        
        self.authorName = screenplayDictionary[authorNameKey] as? String
        self.notes = screenplayDictionary[notesKey] as? String ?? ""
        self.theme =  screenplayDictionary[themeKey] as? String ?? ""
        self.centralIntention = screenplayDictionary[centralIntentionKey] as? String ?? ""
        self.mainObstacle = screenplayDictionary[mainObstacleKey] as? String ?? ""
        self.uuid = uuid
        self.title = title
        if let dateCreatedInterval = screenplayDictionary[dateKey] as? Double {
            self.lastUpdated = Date(timeIntervalSince1970: dateCreatedInterval)
        } else {
            self.lastUpdated = nil
        }
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
        
        if let charactersDictionaryArray = screenplayDictionary[charactersKey] as? [String:Any] {
            
            for characterKeyPair in charactersDictionaryArray {
                guard let characterDictionary = characterKeyPair.value as? [String:Any],
                      let character = Character(uuid: characterKeyPair.key, characterDictionary:characterDictionary) else {
                    continue
                }
                self.characters.insert(character)
            }
        }
        // Copy Scenes from old act1,act2,act3 object scenes into the new Scenes Set and Array
        for scene in act1.scenes {
            act1ScenesSet.insert(scene)
            act1ScenesArray.append(scene)
        }
        for scene in act2.scenes {
            act2ScenesSet.insert(scene)
            act2ScenesArray.append(scene)
        }
        for scene in act3.scenes {
            act3ScenesSet.insert(scene)
            act3ScenesArray.append(scene)
        }
        
        // If we have act1ScenesDictionaryArray in our new Firebase node update our datasource
        if let act1ScenesDictionaryArray = screenplayDictionary[act1ScenesKey] as? [String:Any] {
            for sceneKeyPair in act1ScenesDictionaryArray {
                guard let sceneDictionary = sceneKeyPair.value as? [String:Any],
                      let scene = Scene(uuid: sceneKeyPair.key, sceneDictionary:sceneDictionary) else {
                    continue
                }
                self.act1ScenesSet.insert(scene)
            }
            self.act1ScenesArray.append(contentsOf: act1ScenesSet)
            self.act1ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
        
        if let act2ScenesDictionaryArray = screenplayDictionary[act2ScenesKey] as? [String:Any] {
            for sceneKeyPair in act2ScenesDictionaryArray {
                guard let sceneDictionary = sceneKeyPair.value as? [String:Any],
                      let scene = Scene(uuid: sceneKeyPair.key, sceneDictionary:sceneDictionary) else {
                    continue
                }
                self.act2ScenesSet.insert(scene)
            }
            self.act2ScenesArray.append(contentsOf: act2ScenesSet)
            self.act2ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
        
        if let act3ScenesDictionaryArray = screenplayDictionary[act3ScenesKey] as? [String:Any] {
            for sceneKeyPair in act3ScenesDictionaryArray {
                guard let sceneDictionary = sceneKeyPair.value as? [String:Any],
                      let scene = Scene(uuid: sceneKeyPair.key, sceneDictionary:sceneDictionary) else {
                    continue
                }
                self.act3ScenesSet.insert(scene)
            }
            self.act3ScenesArray.append(contentsOf: act3ScenesSet)
            self.act3ScenesArray.sort(by: { $0.sceneNumber < $1.sceneNumber })
        }
    }
    
    init(unalteredScreenplay: Screenplay) {
        title = unalteredScreenplay.title
        uuid = unalteredScreenplay.uuid
        lastUpdated = unalteredScreenplay.lastUpdated
        authorName = unalteredScreenplay.authorName
        idea = unalteredScreenplay.idea
        logLine = unalteredScreenplay.logLine
        notes = unalteredScreenplay.notes
        theme = unalteredScreenplay.theme
        centralIntention = unalteredScreenplay.centralIntention
        mainObstacle = unalteredScreenplay.mainObstacle
        
        actOneDescription = unalteredScreenplay.actOneDescription
        actTwoDescription = unalteredScreenplay.actTwoDescription
        actThreeDescription = unalteredScreenplay.actThreeDescription
        
        // Create new Character, Acts, and Scene References so that this screenplay is completely separate than the object passed in
        var characterObjects: Set<Character> = []
        for character in unalteredScreenplay.characters {
            let character = Character(character: character)
            characterObjects.insert(character)
        }
        characters = characterObjects
        
        act1 = Act1(act1: unalteredScreenplay.act1)
        act2 = Act2(act2: unalteredScreenplay.act2)
        act3 = Act3(act3: unalteredScreenplay.act3)
        
        act1ScenesSet = unalteredScreenplay.act1ScenesSet
        act2ScenesSet = unalteredScreenplay.act2ScenesSet
        act3ScenesSet = unalteredScreenplay.act3ScenesSet
    }
    
    var firDictionary: [String:Any] {
        return [titleKey:self.title,
                authorNameKey:self.authorName ?? Auth.auth().currentUser?.displayName ?? "Name",
                logLineKey:self.logLine,
                ideaKey:self.idea,
                dateKey: Date().timeIntervalSince1970,
                themeKey:self.theme,
                notesKey:self.notes,
                centralIntentionKey:self.centralIntention,
                mainObstacleKey: self.mainObstacle,
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
    
    var act1ScenesDictionaryArray : [[String:Any]] {
        var scenesDictionaryArray: [[String:Any]] = [[:]]
        for scene in act1ScenesSet {
            scenesDictionaryArray.append(scene.sceneDictionary)
        }
        
        return scenesDictionaryArray
    }
    
    var act2ScenesDictionaryArray : [[String:Any]] {
        var scenesDictionaryArray: [[String:Any]] = [[:]]
        for scene in act2ScenesSet {
            scenesDictionaryArray.append(scene.sceneDictionary)
        }
        
        return scenesDictionaryArray
    }
    
    var act3ScenesDictionaryArray : [[String:Any]] {
        var scenesDictionaryArray: [[String:Any]] = [[:]]
        for scene in act3ScenesSet {
            scenesDictionaryArray.append(scene.sceneDictionary)
        }
        
        return scenesDictionaryArray
    }
    
}
