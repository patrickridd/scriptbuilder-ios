//
//  Screenplay.swift
//  Domain
//
//  The top-level screenplay aggregate: outline, characters, and three acts.
//
//  Pure value type. Swift's value semantics give every consumer its own copy,
//  so it's automatically `Sendable` — no `@unchecked`, no hand-written copy
//  constructors. Scenes live solely on each act (`act1.scenes`, etc.); the
//  per-act accessors here are read-through conveniences.
//
//  Persistence (RTDB key names, dictionary round-tripping) belongs to a DTO in
//  the Firebase data layer, never in the domain model.
//

import Foundation

public struct Screenplay: Identifiable, Equatable, Sendable, Codable {

    /// Stable identity for SwiftUI `List`/`ForEach`. Backed by `uuid`.
    public var id: String { uuid }

    public var uuid: String
    public var title: String
    public var authorName: String?
    public var lastUpdated: Date?

    public var idea: String
    public var logLine: String
    public var notes: String
    public var theme: String
    public var centralIntention: String
    public var mainObstacle: String

    public var actOneDescription: String
    public var actTwoDescription: String
    public var actThreeDescription: String

    public var characters: Set<Character>

    public var act1: Act1
    public var act2: Act2
    public var act3: Act3

    public init(
        uuid: String = UUID().uuidString,
        title: String,
        authorName: String? = nil,
        lastUpdated: Date? = Date(),
        idea: String = "",
        logLine: String = "",
        notes: String = "",
        theme: String = "",
        centralIntention: String = "",
        mainObstacle: String = "",
        actOneDescription: String = "",
        actTwoDescription: String = "",
        actThreeDescription: String = "",
        characters: Set<Character> = [],
        act1: Act1 = Act1(),
        act2: Act2 = Act2(),
        act3: Act3 = Act3()
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
        self.characters = characters
        self.act1 = act1
        self.act2 = act2
        self.act3 = act3
    }

    // MARK: - Scene conveniences

    /// All scenes across the three acts, in act then scene-number order.
    public var allScenes: [Scene] {
        act1.scenes + act2.scenes + act3.scenes
    }

    /// Scenes for a given act, addressed abstractly via the `Act` enum.
    public func scenes(in act: Act) -> [Scene] {
        switch act {
        case .one:   return act1.scenes
        case .two:   return act2.scenes
        case .three: return act3.scenes
        }
    }
}
