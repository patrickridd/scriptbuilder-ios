//
//  ScreenplayDTO+Domain.swift
//  FirebaseData
//
//  Bidirectional mapping between the RTDB persistence shape (`ScreenplayDTO`)
//  and the pure `Domain.Screenplay` value type.
//
//  RTDB stores child collections as keyed maps (uuid → value); the domain uses
//  ordered arrays / sets. These mappers bridge the two representations.
//

import Foundation
import Domain
import os

// Unified-logging channel for the mapping layer. User data (scene titles,
// character names) is interpolated as `.private` so it is redacted in release
// and device logs while remaining visible during local debugging.
private let mappingLog = Logger(subsystem: "FeatureAuth-Dev.FirebaseData", category: "Mapping")

// MARK: - OutlineField → RTDB key

// Maps the domain-level `OutlineField` (autosave) to the exact literal RTDB
// key. Kept here next to `ScreenplayDTO.CodingKeys` so the diverging keys
// (logLineKey, authorNameKey, dateKey) live in ONE place and can never drift
// apart. If a key changes here it must change in CodingKeys too — they describe
// the same RTDB nodes.
extension OutlineField {
    var rtdbKey: String {
        switch self {
        case .title:               return "title"
        case .authorName:          return "authorNameKey"
        case .idea:                return "idea"
        case .logLine:             return "logLineKey"
        case .notes:               return "notes"
        case .theme:               return "theme"
        case .centralIntention:    return "centralIntention"
        case .mainObstacle:        return "mainObstacle"
        case .actOneDescription:   return "actOneDescription"
        case .actTwoDescription:   return "actTwoDescription"
        case .actThreeDescription: return "actThreeDescription"
        }
    }

    /// The RTDB key for the screenplay's last-updated timestamp.
    static var lastUpdatedRTDBKey: String { "dateKey" }
}

// MARK: - Scene

extension SceneDTO {
    init(domain s: Scene) {
        self.init(
            uuid: s.uuid,
            header: s.header,
            title: s.title,
            sceneNumber: s.sceneNumber,
            sceneDescription: s.sceneDescription,
            dialogue: s.dialogue,
            action: s.action,
            characters: s.characters,
            howPushesStory: s.howPushesStory,
            notes: s.notes
        )
    }

    func toDomain() -> Scene {
        Scene(
            uuid: uuid,
            title: title,
            sceneNumber: sceneNumber,
            header: header,
            sceneDescription: sceneDescription,
            dialogue: dialogue,
            action: action,
            characters: characters,
            howPushesStory: howPushesStory,
            notes: notes
        )
    }
}

// MARK: - Character

extension CharacterDTO {
    init(domain c: Character) {
        self.init(
            uuid: c.uuid,
            name: c.name,
            role: c.role,
            intention: c.intention,
            whyIntention: c.whyIntention,
            whatToDo: c.whatToDo,
            howDoesCharacterDoIt: c.howDoesCharacterDoIt,
            obstacles: c.obstacles,
            flaws: c.flaws,
            intentionFix: c.intentionFix,
            need: c.need,
            howCharacterChanged: c.howCharacterChanged,
            notes: c.notes
        )
    }

    func toDomain() -> Character {
        Character(
            uuid: uuid,
            name: name,
            role: role,
            intention: intention,
            whyIntention: whyIntention,
            whatToDo: whatToDo,
            howDoesCharacterDoIt: howDoesCharacterDoIt,
            obstacles: obstacles,
            flaws: flaws,
            intentionFix: intentionFix,
            need: need,
            howCharacterChanged: howCharacterChanged,
            notes: notes
        )
    }
}

// MARK: - Acts

extension Act1DTO {
    init(domain: Act1) {
        self.init(
            oldWorldDescription: domain.oldWorldDescription,
            incitingIncident: domain.incitingIncident,
            callToAdventure: domain.callToAdventure,
            meetingMentor: domain.meetingMentor,
            theme: domain.theme,
            refusal: domain.refusal,
            reasonToAdventure: domain.reasonToAdventure,
            enemyAtTheGates: domain.enemyAtTheGates,
            scenes: SceneMapping.toMap(domain.scenes)
        )
    }

    func toDomain() -> Act1 {
        Act1(
            scenes: SceneMapping.toArray(scenes),
            oldWorldDescription: oldWorldDescription,
            incitingIncident: incitingIncident,
            callToAdventure: callToAdventure,
            meetingMentor: meetingMentor,
            theme: theme,
            refusal: refusal,
            reasonToAdventure: reasonToAdventure,
            enemyAtTheGates: enemyAtTheGates
        )
    }
}

extension Act2DTO {
    init(domain: Act2) {
        self.init(
            newWorldDescription: domain.newWorldDescription,
            enemiesFriends: domain.enemiesFriends,
            obstacles: domain.obstacles,
            sharpeningTheSword: domain.sharpeningTheSword,
            burnTheBoats: domain.burnTheBoats,
            theDeadlyEncounter: domain.theDeadlyEncounter,
            celebrate: domain.celebrate,
            stormGathers: domain.stormGathers,
            badGuysStrikeBack: domain.badGuysStrikeBack,
            allIsLost: domain.allIsLost,
            scenes: SceneMapping.toMap(domain.scenes)
        )
    }

    func toDomain() -> Act2 {
        Act2(
            scenes: SceneMapping.toArray(scenes),
            newWorldDescription: newWorldDescription,
            enemiesFriends: enemiesFriends,
            obstacles: obstacles,
            sharpeningTheSword: sharpeningTheSword,
            burnTheBoats: burnTheBoats,
            theDeadlyEncounter: theDeadlyEncounter,
            celebrate: celebrate,
            stormGathers: stormGathers,
            badGuysStrikeBack: badGuysStrikeBack,
            allIsLost: allIsLost
        )
    }
}

extension Act3DTO {
    init(domain: Act3) {
        self.init(
            theUltimateAnswer: domain.theUltimateAnswer,
            timeIsRunningOut: domain.timeIsRunningOut,
            climax: domain.climax,
            rewards: domain.rewards,
            untangleStory: domain.untangleStory,
            brandNewWorld: domain.brandNewWorld,
            scenes: SceneMapping.toMap(domain.scenes)
        )
    }

    func toDomain() -> Act3 {
        Act3(
            scenes: SceneMapping.toArray(scenes),
            theUltimateAnswer: theUltimateAnswer,
            timeIsRunningOut: timeIsRunningOut,
            climax: climax,
            rewards: rewards,
            untangleStory: untangleStory,
            brandNewWorld: brandNewWorld
        )
    }
}

// MARK: - Screenplay

extension ScreenplayDTO {
    init(domain s: Screenplay) {
        self.init(
            uuid: s.uuid,
            title: s.title,
            authorName: s.authorName,
            lastUpdated: s.lastUpdated,
            idea: s.idea,
            logLine: s.logLine,
            notes: s.notes,
            theme: s.theme,
            centralIntention: s.centralIntention,
            mainObstacle: s.mainObstacle,
            actOneDescription: s.actOneDescription,
            actTwoDescription: s.actTwoDescription,
            actThreeDescription: s.actThreeDescription,
            act1: Act1DTO(domain: s.act1),
            act2: Act2DTO(domain: s.act2),
            act3: Act3DTO(domain: s.act3),
            characters: CharacterMapping.toMap(s.characters)
        )
    }

    func toDomain() -> Screenplay {
        Screenplay(
            uuid: uuid,
            title: title,
            authorName: authorName,
            lastUpdated: lastUpdated,
            idea: idea,
            logLine: logLine,
            notes: notes,
            theme: theme,
            centralIntention: centralIntention,
            mainObstacle: mainObstacle,
            actOneDescription: actOneDescription,
            actTwoDescription: actTwoDescription,
            actThreeDescription: actThreeDescription,
            characters: CharacterMapping.toSet(characters),
            act1: act1?.toDomain() ?? Act1(),
            act2: act2?.toDomain() ?? Act2(),
            act3: act3?.toDomain() ?? Act3()
        )
    }
}

// MARK: - Collection mapping helpers

private enum SceneMapping {
    /// Builds the uuid → DTO map for persistence. Uses a merging initializer
    /// (NOT `uniqueKeysWithValues`, which traps at runtime on a duplicate or
    /// empty key) so a malformed scene can never crash the full-screenplay save.
    static func toMap(_ scenes: [Scene]) -> [String: SceneDTO] {
        Dictionary(
            scenes.map { ($0.uuid, SceneDTO(domain: $0)) },
            uniquingKeysWith: { first, last in
                mappingLog.error("Duplicate scene uuid on save: \(last.uuid, privacy: .public) — keeping last, dropping earlier (title: \(first.title, privacy: .private))")
                return last
            }
        )
    }

    /// Decodes the map back to domain scenes. The RTDB child key IS the scene's
    /// id; legacy data may omit the `uuid` body field, decoding to an empty
    /// string. Backfill it from the authoritative child key so scenes never
    /// reach the autosave path with an empty uuid.
    static func toArray(_ map: [String: SceneDTO]?) -> [Scene] {
        (map ?? [:]).map { key, dto in
            var scene = dto.toDomain()
            if scene.uuid.isEmpty {
                mappingLog.notice("Backfilled empty scene uuid from key \(key, privacy: .public) (title: \(scene.title, privacy: .private))")
                scene.uuid = key
            }
            return scene
        }
    }
}

private enum CharacterMapping {
    /// See `SceneMapping.toMap` — merging initializer guards against trap.
    static func toMap(_ characters: Set<Character>) -> [String: CharacterDTO] {
        Dictionary(
            characters.map { ($0.uuid, CharacterDTO(domain: $0)) },
            uniquingKeysWith: { first, last in
                mappingLog.error("Duplicate character uuid on save: \(last.uuid, privacy: .public) — keeping last, dropping earlier (name: \(first.name, privacy: .private))")
                return last
            }
        )
    }

    /// Backfills an empty uuid from the authoritative child key, mirroring the
    /// screenplay-collection decode, so characters never reach autosave blank.
    static func toSet(_ map: [String: CharacterDTO]?) -> Set<Character> {
        Set((map ?? [:]).map { key, dto in
            var character = dto.toDomain()
            if character.uuid.isEmpty {
                mappingLog.notice("Backfilled empty character uuid from key \(key, privacy: .public) (name: \(character.name, privacy: .private))")
                character.uuid = key
            }
            return character
        })
    }
}
