//
//  Act3.swift
//  Domain
//
//  Act III content: the resolution beats plus the act's scenes.
//
//  Pure value type. `scenes` is the single source of truth (kept sorted by
//  `sceneNumber`). Persistence is a DTO in the Firebase data layer.
//

import Foundation

public struct Act3: Equatable, Sendable, Codable {

    private var _scenes: [Scene] = []

    /// Scenes for this act, always sorted by `sceneNumber`.
    public var scenes: [Scene] {
        get { _scenes }
        set { _scenes = newValue.sorted { $0.sceneNumber < $1.sceneNumber } }
    }

    public var theUltimateAnswer: String
    public var timeIsRunningOut: String
    public var climax: String
    public var rewards: String
    public var untangleStory: String
    public var brandNewWorld: String

    public init(
        scenes: [Scene] = [],
        theUltimateAnswer: String = "",
        timeIsRunningOut: String = "",
        climax: String = "",
        rewards: String = "",
        untangleStory: String = "",
        brandNewWorld: String = ""
    ) {
        self.theUltimateAnswer = theUltimateAnswer
        self.timeIsRunningOut = timeIsRunningOut
        self.climax = climax
        self.rewards = rewards
        self.untangleStory = untangleStory
        self.brandNewWorld = brandNewWorld
        self.scenes = scenes
    }
}
