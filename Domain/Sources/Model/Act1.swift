//
//  Act1.swift
//  Domain
//
//  Act I content: the setup beats plus the act's scenes.
//
//  Pure value type. `scenes` is the single source of truth (kept sorted by
//  `sceneNumber` via the `scenes` accessor's setter). Persistence is a DTO in
//  the Firebase data layer.
//

import Foundation

public struct Act1: Equatable, Sendable, Codable {

    private var _scenes: [Scene] = []

    /// Scenes for this act, always sorted by `sceneNumber`.
    public var scenes: [Scene] {
        get { _scenes }
        set { _scenes = newValue.sorted { $0.sceneNumber < $1.sceneNumber } }
    }

    public var oldWorldDescription: String
    public var incitingIncident: String
    public var callToAdventure: String
    public var meetingMentor: String
    public var theme: String
    public var refusal: String
    public var reasonToAdventure: String
    public var enemyAtTheGates: String
    /// Writer-authored beats placed among the template beats above.
    public var customBeats: [CustomBeat]

    enum CodingKeys: String, CodingKey {
        case _scenes, oldWorldDescription, incitingIncident, callToAdventure,
             meetingMentor, theme, refusal, reasonToAdventure, enemyAtTheGates,
             customBeats
    }

    public init(
        scenes: [Scene] = [],
        oldWorldDescription: String = "",
        incitingIncident: String = "",
        callToAdventure: String = "",
        meetingMentor: String = "",
        theme: String = "",
        refusal: String = "",
        reasonToAdventure: String = "",
        enemyAtTheGates: String = "",
        customBeats: [CustomBeat] = []
    ) {
        self.customBeats = customBeats
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

    /// Hand-written so data saved before custom beats existed still decodes
    /// (synthesized decoding would demand the `customBeats` key).
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        oldWorldDescription = try container.decodeIfPresent(String.self, forKey: .oldWorldDescription) ?? ""
        incitingIncident = try container.decodeIfPresent(String.self, forKey: .incitingIncident) ?? ""
        callToAdventure = try container.decodeIfPresent(String.self, forKey: .callToAdventure) ?? ""
        meetingMentor = try container.decodeIfPresent(String.self, forKey: .meetingMentor) ?? ""
        theme = try container.decodeIfPresent(String.self, forKey: .theme) ?? ""
        refusal = try container.decodeIfPresent(String.self, forKey: .refusal) ?? ""
        reasonToAdventure = try container.decodeIfPresent(String.self, forKey: .reasonToAdventure) ?? ""
        enemyAtTheGates = try container.decodeIfPresent(String.self, forKey: .enemyAtTheGates) ?? ""
        customBeats = try container.decodeIfPresent([CustomBeat].self, forKey: .customBeats) ?? []
        scenes = try container.decodeIfPresent([Scene].self, forKey: ._scenes) ?? []
    }
}
