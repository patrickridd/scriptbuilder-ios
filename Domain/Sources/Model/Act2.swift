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
        allIsLost: String = ""
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
}
