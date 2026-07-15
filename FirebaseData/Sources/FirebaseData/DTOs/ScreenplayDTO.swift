//
//  ScreenplayDTO.swift
//  FirebaseData
//
//  Persistence shape for a `Screenplay` as stored in Realtime Database.
//
//  This DTO is the ONLY place the literal RTDB field names live. The clean
//  `Domain.Screenplay` value type never learns about persistence keys; mapping
//  happens in `ScreenplayDTO+Domain.swift`.
//
//  CodingKeys are recovered verbatim from the pre-refactor `Screenplay.swift`
//  key constants. Several keys intentionally contain the literal substring
//  "Key" (e.g. "logLineKey", "dateKey", "authorNameKey") — these match the
//  exact strings already written to live RTDB and MUST NOT be "cleaned up",
//  or existing data will fail to decode.
//

import Foundation

struct ScreenplayDTO: Codable, Sendable {

    let uuid: String
    let title: String
    let authorName: String?
    let lastUpdated: Date?

    let idea: String
    let logLine: String
    let notes: String
    let theme: String
    let centralIntention: String
    let mainObstacle: String

    let actOneDescription: String
    let actTwoDescription: String
    let actThreeDescription: String

    // Nested act content. Scenes are stored as children of these act keys.
    let act1: Act1DTO?
    let act2: Act2DTO?
    let act3: Act3DTO?

    // Characters keyed by their uuid in RTDB; decoded as a map.
    let characters: [String: CharacterDTO]?

    enum CodingKeys: String, CodingKey {
        case uuid                = "uuid"
        case title               = "title"
        case authorName          = "authorNameKey"
        case lastUpdated         = "dateKey"
        case idea                = "idea"
        case logLine             = "logLineKey"
        case notes               = "notes"
        case theme               = "theme"
        case centralIntention    = "centralIntention"
        case mainObstacle        = "mainObstacle"
        case actOneDescription   = "actOneDescription"
        case actTwoDescription   = "actTwoDescription"
        case actThreeDescription = "actThreeDescription"
        case act1                = "actOne"
        case act2                = "actTwo"
        case act3                = "actThree"
        case characters          = "characters"
    }

    init(
        uuid: String, title: String, authorName: String?, lastUpdated: Date?,
        idea: String, logLine: String, notes: String, theme: String,
        centralIntention: String, mainObstacle: String,
        actOneDescription: String, actTwoDescription: String,
        actThreeDescription: String, act1: Act1DTO?, act2: Act2DTO?,
        act3: Act3DTO?, characters: [String: CharacterDTO]?
    ) {
        self.uuid = uuid
        self.title = title
        self.authorName = authorName
        self.lastUpdated = lastUpdated
        self.idea = idea
        self.logLine = logLine
        self.notes = notes
        self.theme = theme
        self.centralIntention = centralIntention
        self.mainObstacle = mainObstacle
        self.actOneDescription = actOneDescription
        self.actTwoDescription = actTwoDescription
        self.actThreeDescription = actThreeDescription
        self.act1 = act1
        self.act2 = act2
        self.act3 = act3
        self.characters = characters
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid                = container.lenientString(.uuid)
        title               = container.lenientString(.title)
        authorName          = try? container.decodeIfPresent(String.self, forKey: .authorName)
        lastUpdated         = try? container.decodeIfPresent(Date.self, forKey: .lastUpdated)
        idea                = container.lenientString(.idea)
        logLine             = container.lenientString(.logLine)
        notes               = container.lenientString(.notes)
        theme               = container.lenientString(.theme)
        centralIntention    = container.lenientString(.centralIntention)
        mainObstacle        = container.lenientString(.mainObstacle)
        actOneDescription   = container.lenientString(.actOneDescription)
        actTwoDescription   = container.lenientString(.actTwoDescription)
        actThreeDescription = container.lenientString(.actThreeDescription)
        act1                = try? container.decodeIfPresent(Act1DTO.self, forKey: .act1)
        act2                = try? container.decodeIfPresent(Act2DTO.self, forKey: .act2)
        act3                = try? container.decodeIfPresent(Act3DTO.self, forKey: .act3)
        characters          = try? container.decodeIfPresent([String: CharacterDTO].self, forKey: .characters)
    }
}
