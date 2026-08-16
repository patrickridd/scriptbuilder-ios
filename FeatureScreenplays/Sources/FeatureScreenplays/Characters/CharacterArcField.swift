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

    /// The arc fields that count toward a character's completion. `notes` is a
    /// free-form scratchpad, so it is deliberately excluded — a fully developed
    /// character can genuinely reach 100%.
    static var scoreable: [CharacterArcField] {
        allCases.filter { $0 != .notes }
    }

    /// How many scoreable fields the writer has filled in. A character marked
    /// as having no arc counts as fully done — the decision *is* the work.
    static func filledCount(for character: Character) -> Int {
        guard !character.arcNotApplicable else { return scoreable.count }
        return scoreable.reduce(into: 0) { total, field in
            let text = field.value(in: character).trimmingCharacters(in: .whitespacesAndNewlines)
            if !text.isEmpty { total += 1 }
        }
    }

    /// The first scoreable field the writer has not filled in yet — drives the
    /// "Next up: …" nudge in the detail editor.
    static func firstUnfilled(for character: Character) -> CharacterArcField? {
        guard !character.arcNotApplicable else { return nil }
        return scoreable.first {
            $0.value(in: character).trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        }
    }

    /// Completion of a character's arc, from 0 to 1.
    static func completion(for character: Character) -> Double {
        let total = scoreable.count
        guard total > 0 else { return 0 }
        return Double(filledCount(for: character)) / Double(total)
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

/// The identity of a cast-list section. Stock roles group by their enum case;
/// free-form ("Custom") roles group by the exact label the writer typed, so the
/// header reads e.g. "FORTUNE TELLER" instead of a generic "CUSTOM".
struct RoleKey: Hashable, Identifiable {
    let role: CharacterRole
    /// The writer's free-form label. Always empty unless `role == .custom`.
    let customName: String

    init(role: CharacterRole, customName: String = "") {
        self.role = role
        self.customName = role == .custom ? customName : ""
    }

    var id: String { role == .custom ? "custom:\(customName)" : role.rawValue }

    /// Header text: the writer's own wording for custom roles, otherwise the
    /// localized stock role name.
    var displayName: String { customName.isEmpty ? role.displayName : customName }

    var systemImage: String { role.systemImage }

    static let protagonist = RoleKey(role: .protagonist)
    static let antagonist = RoleKey(role: .antagonist)
    static let mentor = RoleKey(role: .mentor)
    static let lover = RoleKey(role: .lover)
    static let friend = RoleKey(role: .friend)
    static let jester = RoleKey(role: .jester)
    static let enemy = RoleKey(role: .enemy)
    static let ally = RoleKey(role: .ally)
    static let mysterious = RoleKey(role: .mysterious)
    /// The unlabeled bucket: characters with no role set yet, or literally "Custom".
    static let custom = RoleKey(role: .custom)

    /// The section a stored role string belongs to.
    static func bucket(for stored: String?) -> RoleKey {
        let trimmed = stored?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        guard !trimmed.isEmpty else { return .custom }
        if let known = CharacterRole(rawValue: trimmed) { return RoleKey(role: known) }
        return RoleKey(role: .custom, customName: trimmed)
    }
}
