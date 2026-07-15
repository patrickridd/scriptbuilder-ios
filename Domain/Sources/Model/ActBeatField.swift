//
//  ActBeatField.swift
//  Domain
//
//  The per-act narrative "beats" the Outline editor lets a writer fill in
//  (Old World, Inciting Incident, …). Each case maps 1:1 to a text property on
//  `Act1`/`Act2`/`Act3` AND to that property's RTDB key (they're identical),
//  and carries the on-screen title + guiding subtitle ported verbatim from the
//  legacy UIKit `ActDetailTableViewController`.
//
//  This mirrors `OutlineField`: a pure-Swift addressing enum so the UI and the
//  granular repository write never touch raw persistence strings. Beats are
//  grouped by act; `beats(for:)` returns the ordered set for a given act.
//

import Foundation

public enum ActBeatField: String, CaseIterable, Sendable, Identifiable {

    // Act I
    case oldWorldDescription
    case incitingIncident
    case callToAdventure
    case meetingMentor
    case theme
    case refusal
    case reasonToAdventure
    case enemyAtTheGates

    // Act II
    case newWorldDescription
    case enemiesFriends
    case obstacles
    case sharpeningTheSword
    case burnTheBoats
    case theDeadlyEncounter
    case celebrate
    case stormGathers
    case badGuysStrikeBack
    case allIsLost

    // Act III
    case theUltimateAnswer
    case timeIsRunningOut
    case climax
    case rewards
    case untangleStory
    case brandNewWorld

    public var id: String { rawValue }

    /// The RTDB child key under the act node — identical to the raw value, since
    /// the DTO coding keys mirror the Swift property names exactly.
    public var rtdbKey: String { rawValue }

    /// The act this beat belongs to.
    public var act: Act {
        switch self {
        case .oldWorldDescription, .incitingIncident, .callToAdventure,
             .meetingMentor, .theme, .refusal, .reasonToAdventure, .enemyAtTheGates:
            return .one
        case .newWorldDescription, .enemiesFriends, .obstacles, .sharpeningTheSword,
             .burnTheBoats, .theDeadlyEncounter, .celebrate, .stormGathers,
             .badGuysStrikeBack, .allIsLost:
            return .two
        case .theUltimateAnswer, .timeIsRunningOut, .climax, .rewards, .untangleStory, .brandNewWorld:
            return .three
        }
    }

    /// The ordered beats for a given act, in narrative sequence.
    public static func beats(for act: Act) -> [ActBeatField] {
        allCases.filter { $0.act == act }
    }

    /// Short section label shown above the field.
    public var title: String {
        L10n.dynamic("beat.\(rawValue).title")
    }

    /// The guiding question shown beneath the title.
    public var subtitle: String {
        L10n.dynamic("beat.\(rawValue).subtitle")
    }

    /// Read this beat's value out of a screenplay's acts.
    public func value(in screenplay: Screenplay) -> String {
        switch self {
        // Act I
        case .oldWorldDescription: return screenplay.act1.oldWorldDescription
        case .incitingIncident:    return screenplay.act1.incitingIncident
        case .callToAdventure:     return screenplay.act1.callToAdventure
        case .meetingMentor:       return screenplay.act1.meetingMentor
        case .theme:               return screenplay.act1.theme
        case .refusal:             return screenplay.act1.refusal
        case .reasonToAdventure:   return screenplay.act1.reasonToAdventure
        case .enemyAtTheGates:     return screenplay.act1.enemyAtTheGates
        // Act II
        case .newWorldDescription: return screenplay.act2.newWorldDescription
        case .enemiesFriends:      return screenplay.act2.enemiesFriends
        case .obstacles:           return screenplay.act2.obstacles
        case .sharpeningTheSword:  return screenplay.act2.sharpeningTheSword
        case .burnTheBoats:        return screenplay.act2.burnTheBoats
        case .theDeadlyEncounter:  return screenplay.act2.theDeadlyEncounter
        case .celebrate:           return screenplay.act2.celebrate
        case .stormGathers:        return screenplay.act2.stormGathers
        case .badGuysStrikeBack:   return screenplay.act2.badGuysStrikeBack
        case .allIsLost:           return screenplay.act2.allIsLost
        // Act III
        case .theUltimateAnswer:   return screenplay.act3.theUltimateAnswer
        case .timeIsRunningOut:    return screenplay.act3.timeIsRunningOut
        case .climax:              return screenplay.act3.climax
        case .rewards:             return screenplay.act3.rewards
        case .untangleStory:       return screenplay.act3.untangleStory
        case .brandNewWorld:       return screenplay.act3.brandNewWorld
        }
    }

    /// Write this beat's value into a screenplay's acts (used by the mock repo).
    public func apply(_ value: String, to screenplay: inout Screenplay) {
        switch self {
        // Act I
        case .oldWorldDescription: screenplay.act1.oldWorldDescription = value
        case .incitingIncident:    screenplay.act1.incitingIncident = value
        case .callToAdventure:     screenplay.act1.callToAdventure = value
        case .meetingMentor:       screenplay.act1.meetingMentor = value
        case .theme:               screenplay.act1.theme = value
        case .refusal:             screenplay.act1.refusal = value
        case .reasonToAdventure:   screenplay.act1.reasonToAdventure = value
        case .enemyAtTheGates:     screenplay.act1.enemyAtTheGates = value
        // Act II
        case .newWorldDescription: screenplay.act2.newWorldDescription = value
        case .enemiesFriends:      screenplay.act2.enemiesFriends = value
        case .obstacles:           screenplay.act2.obstacles = value
        case .sharpeningTheSword:  screenplay.act2.sharpeningTheSword = value
        case .burnTheBoats:        screenplay.act2.burnTheBoats = value
        case .theDeadlyEncounter:  screenplay.act2.theDeadlyEncounter = value
        case .celebrate:           screenplay.act2.celebrate = value
        case .stormGathers:        screenplay.act2.stormGathers = value
        case .badGuysStrikeBack:   screenplay.act2.badGuysStrikeBack = value
        case .allIsLost:           screenplay.act2.allIsLost = value
        // Act III
        case .theUltimateAnswer:   screenplay.act3.theUltimateAnswer = value
        case .timeIsRunningOut:    screenplay.act3.timeIsRunningOut = value
        case .climax:              screenplay.act3.climax = value
        case .rewards:             screenplay.act3.rewards = value
        case .untangleStory:       screenplay.act3.untangleStory = value
        case .brandNewWorld:       screenplay.act3.brandNewWorld = value
        }
    }
}
