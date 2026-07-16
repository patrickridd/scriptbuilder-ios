import Foundation
import Domain

/// The ten dramatic-arc fields of a `Character`, each paired with the section
/// title, guiding prompt, and SF Symbol used in the detail form. Mirrors the
/// legacy `CharacterSection` enum (titles + subtitles) 1:1, but binds directly
/// to the pure Swift `Character` value type.
enum CharacterArcField: Int, CaseIterable, Identifiable {
    case intention
    case whyIntention
    case whatToDo
    case howDoesCharacterDoIt
    case obstacles
    case flaws
    case intentionFix
    case need
    case howCharacterChanged
    case notes

    var id: Int { rawValue }

    /// Stable, locale-independent key used to build the localization lookup.
    var key: String {
        switch self {
        case .intention: return "intention"
        case .whyIntention: return "why"
        case .whatToDo: return "what"
        case .howDoesCharacterDoIt: return "how"
        case .obstacles: return "obstacles"
        case .flaws: return "flaws"
        case .intentionFix: return "problemSolved"
        case .need: return "need"
        case .howCharacterChanged: return "changed"
        case .notes: return "notes"
        }
    }

    var title: String {
        L10n.Character.title(self)
    }

    var prompt: String {
        L10n.Character.prompt(self)
    }

    var systemImage: String {
        switch self {
        case .intention: return "target"
        case .whyIntention: return "questionmark.circle"
        case .whatToDo: return "checklist"
        case .howDoesCharacterDoIt: return "arrow.triangle.turn.up.right.diamond"
        case .obstacles: return "exclamationmark.triangle"
        case .flaws: return "heart.slash"
        case .intentionFix: return "checkmark.seal"
        case .need: return "sparkles"
        case .howCharacterChanged: return "arrow.2.squarepath"
        case .notes: return "note.text"
        }
    }

    /// Read/write access to the matching field on a `Character`.
    func value(in character: Character) -> String {
        switch self {
        case .intention: return character.intention
        case .whyIntention: return character.whyIntention
        case .whatToDo: return character.whatToDo
        case .howDoesCharacterDoIt: return character.howDoesCharacterDoIt
        case .obstacles: return character.obstacles
        case .flaws: return character.flaws
        case .intentionFix: return character.intentionFix
        case .need: return character.need
        case .howCharacterChanged: return character.howCharacterChanged
        case .notes: return character.notes
        }
    }

    func set(_ newValue: String, on character: inout Character) {
        switch self {
        case .intention: character.intention = newValue
        case .whyIntention: character.whyIntention = newValue
        case .whatToDo: character.whatToDo = newValue
        case .howDoesCharacterDoIt: character.howDoesCharacterDoIt = newValue
        case .obstacles: character.obstacles = newValue
        case .flaws: character.flaws = newValue
        case .intentionFix: character.intentionFix = newValue
        case .need: character.need = newValue
        case .howCharacterChanged: character.howCharacterChanged = newValue
        case .notes: character.notes = newValue
        }
    }
}

/// The stock character roles offered by the legacy role picker, plus a free-form
/// "Custom" fallback. Stored on `Character.role` as a plain string.
enum CharacterRole: String, CaseIterable, Identifiable {
    case protagonist = "Protagonist"
    case antagonist = "Antagonist"
    case mentor = "Mentor"
    case lover = "Lover"
    case friend = "Friend"
    case jester = "Jester"
    case enemy = "Enemy"
    case ally = "Ally"
    case mysterious = "Mysterious"
    case custom = "Custom"

    var id: String { rawValue }

    /// Stable key for localization lookup. Distinct from `rawValue` (which is
    /// the persisted English identifier) so translations never affect storage.
    var key: String {
        switch self {
        case .protagonist: return "protagonist"
        case .antagonist: return "antagonist"
        case .mentor: return "mentor"
        case .lover: return "lover"
        case .friend: return "friend"
        case .jester: return "jester"
        case .enemy: return "enemy"
        case .ally: return "ally"
        case .mysterious: return "mysterious"
        case .custom: return "custom"
        }
    }

    /// Localized name shown in the UI. `rawValue` remains the stored value.
    var displayName: String { L10n.Character.role(self) }

    var systemImage: String {
        switch self {
        case .protagonist: return "star.fill"
        case .antagonist: return "bolt.fill"
        case .mentor: return "graduationcap.fill"
        case .lover: return "heart.fill"
        case .friend: return "person.2.fill"
        case .jester: return "theatermasks.fill"
        case .enemy: return "flame.fill"
        case .ally: return "shield.fill"
        case .mysterious: return "moon.stars.fill"
        case .custom: return "person.crop.circle"
        }
    }

    /// The display bucket for an arbitrary stored role string. Unknown/empty
    /// roles fall into `.custom` so nothing is ever dropped from the list.
    static func bucket(for stored: String?) -> CharacterRole {
        guard let stored, !stored.isEmpty else { return .custom }
        return CharacterRole(rawValue: stored) ?? .custom
    }
}
