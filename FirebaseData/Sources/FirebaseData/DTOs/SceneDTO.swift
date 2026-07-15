//
//  SceneDTO.swift
//  FirebaseData
//
//  Persistence shape for a `Scene`. All keys verified against the live
//  `Scene` model — every field name matches its Swift property name.
//

import Foundation

struct SceneDTO: Codable, Sendable {

    let uuid: String
    let header: String
    let title: String
    let sceneNumber: Int
    let sceneDescription: String
    let dialogue: String
    let action: String
    let characters: String
    let howPushesStory: String
    let notes: String

    enum CodingKeys: String, CodingKey {
        case uuid             = "uuid"
        case header           = "header"
        case title            = "title"
        case sceneNumber      = "sceneNumber"
        case sceneDescription = "sceneDescription"
        case dialogue         = "dialogue"
        case action           = "action"
        case characters       = "characters"
        case howPushesStory   = "howPushesStory"
        case notes            = "notes"
    }

    init(
        uuid: String, header: String, title: String, sceneNumber: Int,
        sceneDescription: String, dialogue: String, action: String,
        characters: String, howPushesStory: String, notes: String
    ) {
        self.uuid = uuid
        self.header = header
        self.title = title
        self.sceneNumber = sceneNumber
        self.sceneDescription = sceneDescription
        self.dialogue = dialogue
        self.action = action
        self.characters = characters
        self.howPushesStory = howPushesStory
        self.notes = notes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid             = container.lenientString(.uuid)
        header           = container.lenientString(.header)
        title            = container.lenientString(.title)
        sceneNumber      = container.lenientInt(.sceneNumber)
        sceneDescription = container.lenientString(.sceneDescription)
        dialogue         = container.lenientString(.dialogue)
        action           = container.lenientString(.action)
        characters       = container.lenientString(.characters)
        howPushesStory   = container.lenientString(.howPushesStory)
        notes            = container.lenientString(.notes)
    }
}
