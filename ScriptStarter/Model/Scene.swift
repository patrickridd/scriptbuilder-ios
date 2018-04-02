//
//  Scene.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Scene: Hashable, Equatable {
    
    let uuidKey = "uuid"
    let headerKey = "header"
    let titleKey = "title"
    let sceneNumberKey = "sceneNumber"
    let sceneDescriptionKey = "sceneDescription"
    let dialogueKey = "dialogue"
    let actionKey = "action"
    let charactersKey = "characters"
    let howPushesStoryKey = "howPushesStory"
    let notesKey = "notes"
    
    var uuid: String
    var header: String = ""
    var title: String
    var sceneNumber: Int
    
    var sceneDescription: String = ""
    var dialogue: String = ""
    var action: String = ""
    var characters: String = ""
    var howPushesStory: String = ""
    var notes: String = ""
    
    var hashValue: Int {
        return self.uuid.hashValue
    }
    
    static func ==(lhs: Scene, rhs: Scene) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    init(title: String, sceneNumber: Int) {
        self.title = title
        self.sceneNumber = sceneNumber
        self.uuid = UUID().uuidString
    }
    
    init?(uuid: String, sceneDictionary: [String:Any]) {
        self.uuid = uuid
        self.title = sceneDictionary[self.titleKey] as? String ?? ""
         self.header = sceneDictionary[self.headerKey] as? String ?? ""
         self.sceneNumber = sceneDictionary[self.sceneNumberKey] as? Int ?? 0
        self.sceneDescription = sceneDictionary[self.sceneDescriptionKey] as? String ?? ""
        self.dialogue = sceneDictionary[self.dialogueKey] as? String ?? ""
        self.action = sceneDictionary[self.actionKey] as? String ?? ""
        self.characters = sceneDictionary[self.charactersKey] as? String ?? ""
        self.howPushesStory = sceneDictionary[self.howPushesStoryKey] as? String ?? ""
        self.notes = sceneDictionary[self.notesKey] as? String ?? ""
    }
    
    static var sceneTitles: [String] {
        return ["Scene Description",
                "Characters",
                "Dialogue",
                "Action",
                "Story Progression",
                "Notes"]
    }
    
    static var sceneSubtitles: [String] {
        return ["Overall idea of what happens and feeling the scene bring",
            "What do the characters want and what are they feeling?",
            "What snappy dialogue and/or information is said?",
            "What are your characters doing?",
            "How does the scene move the story forward?",
            "Details you don't want to forget"]
    }
    
    var sceneDictionary: [String:Any] {
        return [self.headerKey:self.header,
                self.titleKey:self.title,
                self.sceneNumberKey:self.sceneNumber,
                self.sceneDescriptionKey:self.sceneDescription,
                self.dialogueKey:self.dialogue,
                self.actionKey:self.action,
                self.charactersKey:self.characters,
                self.howPushesStoryKey:self.howPushesStory,
                self.notesKey:self.notes]
    }
}
