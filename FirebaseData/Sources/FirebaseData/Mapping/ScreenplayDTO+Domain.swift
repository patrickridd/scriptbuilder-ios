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
    init(domain scene: Scene) {
        self.init(
            uuid: scene.uuid,
            header: scene.header,
            title: scene.title,
            sceneNumber: scene.sceneNumber,
            sceneDescription: scene.sceneDescription,
            dialogue: scene.dialogue,
            action: scene.action,
            characters: scene.characters,
            howPushesStory: scene.howPushesStory,
            notes: scene.notes
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
    init(domain character: Character) {
        self.init(
            uuid: character.uuid,
            name: character.name,
            role: character.role,
            identity: CharacterIdentityDTO(domain: character.identity),
            intention: character.intention,
            whyIntention: character.whyIntention,
            whatToDo: character.whatToDo,
            howDoesCharacterDoIt: character.howDoesCharacterDoIt,
            obstacles: character.obstacles,
            flaws: character.flaws,
            intentionFix: character.intentionFix,
            need: character.need,
            howCharacterChanged: character.howCharacterChanged,
            notes: character.notes,
            arcNotApplicable: character.arcNotApplicable,
            arcQuestions: Self.questionMap(character.arcQuestions),
            arcOrder: character.savedArcOrder.map(ArcQuestionRef.joined),
            disabledArcQuestions: Self.disabledMap(character.disabledArcQuestions)
        )
    }

    private static func questionMap(_ questions: [ArcQuestion]) -> [String: ArcQuestionDTO]? {
        guard !questions.isEmpty else { return nil }
        return Dictionary(
            questions.map { ($0.id, ArcQuestionDTO(domain: $0)) },
            uniquingKeysWith: { _, latest in latest }
        )
    }

    private static func disabledMap(_ disabled: Set<ArcTemplateQuestion>) -> [String: Bool]? {
        guard !disabled.isEmpty else { return nil }
        return Dictionary(uniqueKeysWithValues: disabled.map { ($0.rawValue, true) })
    }

    private var domainArcQuestions: [ArcQuestion] {
        (arcQuestions ?? [:])
            .map { key, question in question.toDomain(key: key) }
            .sorted { $0.id < $1.id }
    }

    private var domainDisabledArcQuestions: Set<ArcTemplateQuestion> {
        let keys = (disabledArcQuestions ?? [:]).filter(\.value).keys
        return Set(keys.compactMap(ArcTemplateQuestion.init(rawValue:)))
    }

    func toDomain() -> Character {
        // Non-destructive migration: when no stored identity exists, resolve
        // one from the legacy flat `role` string. The `role` key itself is
        // preserved verbatim; the structured identity is only written back
        // the next time the character is saved.
        let resolvedIdentity = identity?.toDomain()
            ?? CharacterIdentity(resolvingLegacyRole: role)
        return Character(
            uuid: uuid,
            name: name,
            role: role,
            identity: resolvedIdentity,
            intention: intention,
            whyIntention: whyIntention,
            whatToDo: whatToDo,
            howDoesCharacterDoIt: howDoesCharacterDoIt,
            obstacles: obstacles,
            flaws: flaws,
            intentionFix: intentionFix,
            need: need,
            howCharacterChanged: howCharacterChanged,
            notes: notes,
            arcNotApplicable: arcNotApplicable,
            arcQuestions: domainArcQuestions,
            savedArcOrder: arcOrder.map(ArcQuestionRef.split),
            disabledArcQuestions: domainDisabledArcQuestions
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
            scenes: SceneMapping.toMap(domain.scenes),
            customBeats: CustomBeatMapping.toMap(domain.customBeats)
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
            enemyAtTheGates: enemyAtTheGates,
            customBeats: CustomBeatMapping.toArray(customBeats)
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
            scenes: SceneMapping.toMap(domain.scenes),
            customBeats: CustomBeatMapping.toMap(domain.customBeats)
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
            allIsLost: allIsLost,
            customBeats: CustomBeatMapping.toArray(customBeats)
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
            scenes: SceneMapping.toMap(domain.scenes),
            customBeats: CustomBeatMapping.toMap(domain.customBeats)
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
            brandNewWorld: brandNewWorld,
            customBeats: CustomBeatMapping.toArray(customBeats)
        )
    }
}

// MARK: - Screenplay

extension ScreenplayDTO {
    init(domain screenplay: Screenplay) {
        self.init(
            uuid: screenplay.uuid,
            title: screenplay.title,
            authorName: screenplay.authorName,
            lastUpdated: screenplay.lastUpdated,
            idea: screenplay.idea,
            logLine: screenplay.logLine,
            notes: screenplay.notes,
            theme: screenplay.theme,
            centralIntention: screenplay.centralIntention,
            mainObstacle: screenplay.mainObstacle,
            actOneDescription: screenplay.actOneDescription,
            actTwoDescription: screenplay.actTwoDescription,
            actThreeDescription: screenplay.actThreeDescription,
            act1: Act1DTO(domain: screenplay.act1),
            act2: Act2DTO(domain: screenplay.act2),
            act3: Act3DTO(domain: screenplay.act3),
            characters: CharacterMapping.toMap(screenplay.characters),
            disabledBeats: screenplay.disabledBeats.isEmpty
                ? nil
                : Dictionary(uniqueKeysWithValues: screenplay.disabledBeats.map { ($0.rawValue, true) }),
            structureTemplate: screenplay.structureTemplateID,
            beatLayout: screenplay.savedBeatLayout.map(BeatLayoutMapping.toMap)
        )
    }

    func toDomain() -> Screenplay {
        var act1Domain = act1?.toDomain() ?? Act1()
        var act2Domain = act2?.toDomain() ?? Act2()
        var act3Domain = act3?.toDomain() ?? Act3()
        act1Domain.scenes = SceneMapping.merging(stray: strayActOneScenes, into: act1Domain.scenes)
        act2Domain.scenes = SceneMapping.merging(stray: strayActTwoScenes, into: act2Domain.scenes)
        act3Domain.scenes = SceneMapping.merging(stray: strayActThreeScenes, into: act3Domain.scenes)
        return Screenplay(
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
            act1: act1Domain,
            act2: act2Domain,
            act3: act3Domain,
            disabledBeats: Set((disabledBeats ?? [:])
                .filter(\.value)
                .compactMap { ActBeatField(rawValue: $0.key) }),
            structureTemplateID: structureTemplate,
            savedBeatLayout: beatLayout.map(BeatLayoutMapping.toDomain)
        )
    }
}

// MARK: - Beat layout

/// Each section's order is one string of references joined by "/". RTDB keys
/// can never contain "/", so a custom beat id can't break the encoding, and an
/// empty section is stored as "" instead of vanishing like an empty array.
enum BeatLayoutMapping {
    // `Swift.Character`: Domain's own `Character` (a cast member) shadows it.
    static let separator: Swift.Character = "/"

    static func toMap(_ layout: BeatLayout) -> [String: String] {
        layout.sections.mapValues { references in
            references.map(\.storageKey).joined(separator: String(separator))
        }
    }

    static func toDomain(_ map: [String: String]) -> BeatLayout {
        BeatLayout(sections: map.mapValues { encoded in
            encoded.split(separator: separator)
                .compactMap { BeatReference(storageKey: String($0)) }
        })
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

    /// Folds scenes rescued from the stray sibling node into an act's scenes.
    /// A stray copy only exists because a newer build saved it there, so it
    /// replaces a same-id scene from the nested node; otherwise it's added.
    static func merging(stray: [String: SceneDTO]?, into scenes: [Scene]) -> [Scene] {
        let rescued = toArray(stray)
        guard !rescued.isEmpty else { return scenes }
        mappingLog.notice("Recovered \(rescued.count, privacy: .public) scene(s) from stray act node")
        let rescuedIDs = Set(rescued.map(\.uuid))
        return scenes.filter { !rescuedIDs.contains($0.uuid) } + rescued
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
