//
//  Scene.swift
//  Domain
//
//  A single scene within an act.
//
//  Pure value type: identity is the `uuid`, equality/hashing are synthesized.
//  Persistence (RTDB key names, dictionary round-tripping) lives in the
//  Firebase data layer as a DTO — never here.
//

import Foundation

public struct Scene: Identifiable, Hashable, Sendable, Codable {

    public var id: String { uuid }

    public var uuid: String
    public var header: String
    public var title: String
    public var sceneNumber: Int

    public var sceneDescription: String
    public var dialogue: String
    public var action: String
    public var characters: String
    public var howPushesStory: String
    public var notes: String

    public init(
        uuid: String = UUID().uuidString,
        title: String,
        sceneNumber: Int,
        header: String = "",
        sceneDescription: String = "",
        dialogue: String = "",
        action: String = "",
        characters: String = "",
        howPushesStory: String = "",
        notes: String = ""
    ) {
        self.uuid = uuid
        self.title = title
        self.sceneNumber = sceneNumber
        self.header = header
        self.sceneDescription = sceneDescription
        self.dialogue = dialogue
        self.action = action
        self.characters = characters
        self.howPushesStory = howPushesStory
        self.notes = notes
    }
}
