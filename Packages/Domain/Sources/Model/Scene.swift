//
//  Scene.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public class Scene: Hashable, Equatable {
    
    public let uuidKey = "uuid"
    public let headerKey = "header"
    public let titleKey = "title"
    public let sceneNumberKey = "sceneNumber"
    public let sceneDescriptionKey = "sceneDescription"
    public let dialogueKey = "dialogue"
    public let actionKey = "action"
    public let charactersKey = "characters"
    public let howPushesStoryKey = "howPushesStory"
    public let notesKey = "notes"
    
    public var uuid: String
    public var header: String = ""
    public var title: String
    public var sceneNumber: Int
    
    public var sceneDescription: String = ""
    public var dialogue: String = ""
    public var action: String = ""
    public var characters: String = ""
    public var howPushesStory: String = ""
    public var notes: String = ""
    
    public func hash(into hasher: inout Hasher) {
        self.uuid.hash(into: &hasher)
    }
    
    public static func ==(lhs: Scene, rhs: Scene) -> Bool {
        return lhs.uuid == rhs.uuid
    }
    
    public init(title: String, sceneNumber: Int) {
        self.title = title
        self.sceneNumber = sceneNumber
        self.uuid = UUID().uuidString
    }
    
    public init?(uuid: String, sceneDictionary: [String:Any]) {
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
    
    public init(scene: Scene) {
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
    
    static public var sceneTitles: [String] {
        return ["Scene Description".localized,
                "Characters".localized,
                "Dialogue".localized,
                "Action".localized,
                "Story Progression".localized,
                "Notes".localized]
    }
    
    static public  var sceneSubtitles: [String] {
        return ["Overall idea of what happens and the feeling the scene brings".localized,
                "What do the characters want and what are they feeling?".localized,
                "What snappy dialogue and/or information is said?".localized,
                "What are your characters doing?".localized,
                "How does the scene move the story forward?".localized,
                "Details you don't want to forget".localized]
    }
    
    public var sceneDictionary: [String:Any] {
        [self.headerKey:self.header,
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
