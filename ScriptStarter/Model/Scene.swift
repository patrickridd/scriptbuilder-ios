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
    
    init(scene: Scene) {
        self.uuid = scene.uuid
        self.title = scene.title
        self.header = scene.header
        self.sceneNumber = scene.sceneNumber
        self.sceneDescription = scene.sceneDescription
        self.dialogue = scene.dialogue
        self.action = scene.action
        self.characters = scene.characters
        self.howPushesStory = scene.howPushesStory
        self.notes = scene.notes
    }
    
    static var sceneTitles: [String] {
        return ["Scene Description".localized,
                "Characters".localized,
                "Dialogue".localized,
                "Action".localized,
                "Story Progression".localized,
                "Notes".localized]
    }
    
    static var sceneSubtitles: [String] {
        return ["Overall idea of what happens and the feeling the scene brings".localized,
                "What do the characters want and what are they feeling?".localized,
                "What snappy dialogue and/or information is said?".localized,
                "What are your characters doing?".localized,
                "How does the scene move the story forward?".localized,
                "Details you don't want to forget".localized]
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
