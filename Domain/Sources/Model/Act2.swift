//
//  Act2.swift
//  Domain
//
//  Act II content: the confrontation beats plus the act's scenes.
//
//  Pure value type. `scenes` is the single source of truth (kept sorted by
//  `sceneNumber`). Persistence is a DTO in the Firebase data layer.
//

import Foundation

public struct Act2: Equatable, Sendable, Codable {

    private var _scenes: [Scene] = []

    /// Scenes for this act, always sorted by `sceneNumber`.
    public var scenes: [Scene] {
        get { _scenes }
        set { _scenes = newValue.sorted { $0.sceneNumber < $1.sceneNumber } }
    }

    public var newWorldDescription: String
    public var enemiesFriends: String
    public var obstacles: String
    public var sharpeningTheSword: String
    public var burnTheBoats: String
    public var theDeadlyEncounter: String
    public var celebrate: String
    public var stormGathers: String
    public var badGuysStrikeBack: String
    public var allIsLost: String
    /// Writer-authored beats placed among the template beats above.
    public var customBeats: [CustomBeat]

    enum CodingKeys: String, CodingKey {
        case _scenes, newWorldDescription, enemiesFriends, obstacles,
             sharpeningTheSword, burnTheBoats, theDeadlyEncounter, celebrate,
             stormGathers, badGuysStrikeBack, allIsLost, customBeats
    }

    public init(
        scenes: [Scene] = [],
        newWorldDescription: String = "",
        enemiesFriends: String = "",
        obstacles: String = "",
        sharpeningTheSword: String = "",
        burnTheBoats: String = "",
        theDeadlyEncounter: String = "",
        celebrate: String = "",
        stormGathers: String = "",
        badGuysStrikeBack: String = "",
        allIsLost: String = "",
        customBeats: [CustomBeat] = []
    ) {
        self.customBeats = customBeats
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

    /// Hand-written so data saved before custom beats existed still decodes.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        newWorldDescription = try container.decodeIfPresent(String.self, forKey: .newWorldDescription) ?? ""
        enemiesFriends = try container.decodeIfPresent(String.self, forKey: .enemiesFriends) ?? ""
        obstacles = try container.decodeIfPresent(String.self, forKey: .obstacles) ?? ""
        sharpeningTheSword = try container.decodeIfPresent(String.self, forKey: .sharpeningTheSword) ?? ""
        burnTheBoats = try container.decodeIfPresent(String.self, forKey: .burnTheBoats) ?? ""
        theDeadlyEncounter = try container.decodeIfPresent(String.self, forKey: .theDeadlyEncounter) ?? ""
        celebrate = try container.decodeIfPresent(String.self, forKey: .celebrate) ?? ""
        stormGathers = try container.decodeIfPresent(String.self, forKey: .stormGathers) ?? ""
        badGuysStrikeBack = try container.decodeIfPresent(String.self, forKey: .badGuysStrikeBack) ?? ""
        allIsLost = try container.decodeIfPresent(String.self, forKey: .allIsLost) ?? ""
        customBeats = try container.decodeIfPresent([CustomBeat].self, forKey: .customBeats) ?? []
        scenes = try container.decodeIfPresent([Scene].self, forKey: ._scenes) ?? []
    }
}
