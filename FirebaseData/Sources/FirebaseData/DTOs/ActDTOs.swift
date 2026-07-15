//
//  ActDTOs.swift
//  FirebaseData
//
//  Persistence shapes for Act I / II / III content.
//
//  Keys verified against the live Act1/Act2/Act3 models — every narrative-beat
//  field name matches its Swift property name. Within an act node, its scenes
//  map lives under the act's own `scenesKey` ("scenes"). The screenplay-level
//  `actOneScenes` / `actTwoScenes` / `actThreeScenes` keys are separate sibling
//  nodes used only by granular per-act scene writes (see RTDBPaths.actScenes).
//

import Foundation

// MARK: - Act I

struct Act1DTO: Codable, Sendable {
    let oldWorldDescription: String
    let incitingIncident: String
    let callToAdventure: String
    let meetingMentor: String
    let theme: String
    let refusal: String
    let reasonToAdventure: String
    let enemyAtTheGates: String
    let scenes: [String: SceneDTO]?

    enum CodingKeys: String, CodingKey {
        case oldWorldDescription = "oldWorldDescription"
        case incitingIncident    = "incitingIncident"
        case callToAdventure     = "callToAdventure"
        case meetingMentor       = "meetingMentor"
        case theme               = "theme"
        case refusal             = "refusal"
        case reasonToAdventure   = "reasonToAdventure"
        case enemyAtTheGates     = "enemyAtTheGates"
        case scenes              = "scenes"
    }

    init(
        oldWorldDescription: String, incitingIncident: String,
        callToAdventure: String, meetingMentor: String, theme: String,
        refusal: String, reasonToAdventure: String, enemyAtTheGates: String,
        scenes: [String: SceneDTO]?
    ) {
        self.oldWorldDescription = oldWorldDescription
        self.incitingIncident = incitingIncident
        self.callToAdventure = callToAdventure
        self.meetingMentor = meetingMentor
        self.theme = theme
        self.refusal = refusal
        self.reasonToAdventure = reasonToAdventure
        self.enemyAtTheGates = enemyAtTheGates
        self.scenes = scenes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        oldWorldDescription = container.lenientString(.oldWorldDescription)
        incitingIncident    = container.lenientString(.incitingIncident)
        callToAdventure     = container.lenientString(.callToAdventure)
        meetingMentor       = container.lenientString(.meetingMentor)
        theme               = container.lenientString(.theme)
        refusal             = container.lenientString(.refusal)
        reasonToAdventure   = container.lenientString(.reasonToAdventure)
        enemyAtTheGates     = container.lenientString(.enemyAtTheGates)
        scenes              = try? container.decodeIfPresent([String: SceneDTO].self, forKey: .scenes)
    }
}

// MARK: - Act II

struct Act2DTO: Codable, Sendable {
    let newWorldDescription: String
    let enemiesFriends: String
    let obstacles: String
    let sharpeningTheSword: String
    let burnTheBoats: String
    let theDeadlyEncounter: String
    let celebrate: String
    let stormGathers: String
    let badGuysStrikeBack: String
    let allIsLost: String
    let scenes: [String: SceneDTO]?

    enum CodingKeys: String, CodingKey {
        case newWorldDescription = "newWorldDescription"
        case enemiesFriends      = "enemiesFriends"
        case obstacles           = "obstacles"
        case sharpeningTheSword  = "sharpeningTheSword"
        case burnTheBoats        = "burnTheBoats"
        case theDeadlyEncounter  = "theDeadlyEncounter"
        case celebrate           = "celebrate"
        case stormGathers        = "stormGathers"
        case badGuysStrikeBack   = "badGuysStrikeBack"
        case allIsLost           = "allIsLost"
        case scenes              = "scenes"
    }

    init(
        newWorldDescription: String, enemiesFriends: String, obstacles: String,
        sharpeningTheSword: String, burnTheBoats: String, theDeadlyEncounter: String,
        celebrate: String, stormGathers: String, badGuysStrikeBack: String,
        allIsLost: String, scenes: [String: SceneDTO]?
    ) {
        self.newWorldDescription = newWorldDescription
        self.enemiesFriends = enemiesFriends
        self.obstacles = obstacles
        self.sharpeningTheSword = sharpeningTheSword
        self.burnTheBoats = burnTheBoats
        self.theDeadlyEncounter = theDeadlyEncounter
        self.celebrate = celebrate
        self.stormGathers = stormGathers
        self.badGuysStrikeBack = badGuysStrikeBack
        self.allIsLost = allIsLost
        self.scenes = scenes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newWorldDescription = container.lenientString(.newWorldDescription)
        enemiesFriends      = container.lenientString(.enemiesFriends)
        obstacles           = container.lenientString(.obstacles)
        sharpeningTheSword  = container.lenientString(.sharpeningTheSword)
        burnTheBoats        = container.lenientString(.burnTheBoats)
        theDeadlyEncounter  = container.lenientString(.theDeadlyEncounter)
        celebrate           = container.lenientString(.celebrate)
        stormGathers        = container.lenientString(.stormGathers)
        badGuysStrikeBack   = container.lenientString(.badGuysStrikeBack)
        allIsLost           = container.lenientString(.allIsLost)
        scenes              = try? container.decodeIfPresent([String: SceneDTO].self, forKey: .scenes)
    }
}

// MARK: - Act III

struct Act3DTO: Codable, Sendable {
    let theUltimateAnswer: String
    let timeIsRunningOut: String
    let climax: String
    let rewards: String
    let untangleStory: String
    let brandNewWorld: String
    let scenes: [String: SceneDTO]?

    enum CodingKeys: String, CodingKey {
        case theUltimateAnswer = "theUltimateAnswer"
        case timeIsRunningOut  = "timeIsRunningOut"
        case climax            = "climax"
        case rewards           = "rewards"
        case untangleStory     = "untangleStory"
        case brandNewWorld     = "brandNewWorld"
        case scenes            = "scenes"
    }

    init(
        theUltimateAnswer: String, timeIsRunningOut: String, climax: String,
        rewards: String, untangleStory: String, brandNewWorld: String,
        scenes: [String: SceneDTO]?
    ) {
        self.theUltimateAnswer = theUltimateAnswer
        self.timeIsRunningOut = timeIsRunningOut
        self.climax = climax
        self.rewards = rewards
        self.untangleStory = untangleStory
        self.brandNewWorld = brandNewWorld
        self.scenes = scenes
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        theUltimateAnswer = container.lenientString(.theUltimateAnswer)
        timeIsRunningOut  = container.lenientString(.timeIsRunningOut)
        climax            = container.lenientString(.climax)
        rewards           = container.lenientString(.rewards)
        untangleStory     = container.lenientString(.untangleStory)
        brandNewWorld     = container.lenientString(.brandNewWorld)
        scenes            = try? container.decodeIfPresent([String: SceneDTO].self, forKey: .scenes)
    }
}
