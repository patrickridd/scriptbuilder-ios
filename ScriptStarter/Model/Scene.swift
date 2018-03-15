//
//  Scene.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Scene {
    
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
    
    init(title: String, sceneNumber: Int) {
        self.title = title
        self.sceneNumber = sceneNumber
        self.uuid = UUID().uuidString
    }
    
    static var sceneTitles: [String] {
        return ["Scene Description",
                "Dialogue",
                "Action",
                "Characters",
                "Story Progression",
                "Notes"]
    }
    
    static var sceneSubtitles: [String] {
        return ["Overall idea of what happens and feeling the scene bring",
            "What snappy dialogue and/or information is said?",
            "What are your characters doing?",
            "What are the characters feeling and what do they want?",
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
