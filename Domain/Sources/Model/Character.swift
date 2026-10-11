//
//  Character.swift
//  Domain
//
//  A screenplay character and their dramatic arc.
//
//  Pure value type: identity is the `uuid`; equality/hashing are based on it.
//  Persistence is handled by a DTO in the Firebase data layer, not here.
//

import Foundation

public struct Character: Identifiable, Hashable, Sendable, Codable {

    public var id: String { uuid }

    // Basic
    // `var` (not `let`) so the data layer can backfill an empty uuid from the
    // authoritative RTDB child key on decode, exactly as Screenplay/Scene do.
    public var uuid: String
    public var name: String
    public var role: String?

    // Identity — who the character is (role tier, archetypes, story
    // functions, personality, quirks). Defaults to empty; old records that
    // predate this field decode fine.
    public var identity: CharacterIdentity

    // Character Arc
    public var intention: String
    public var whyIntention: String
    public var whatToDo: String
    public var howDoesCharacterDoIt: String
    public var obstacles: String
    public var flaws: String
    public var intentionFix: String
    public var need: String
    public var howCharacterChanged: String
    public var notes: String

    /// Some characters simply have no dramatic arc (the iceberg in *Titanic*
    /// wants nothing). When true, the arc is treated as intentionally complete
    /// and stops counting against the character's progress.
    public var arcNotApplicable: Bool

    /// Writer-authored arc questions (unsorted — read `arcSlots` for display).
    public var arcQuestions: [ArcQuestion]
    /// The writer's own question order; `nil` = standard order. Read
    /// `arcOrder` instead — it repairs stale or partial saved orders.
    public var savedArcOrder: [ArcQuestionRef]?
    /// Stock questions the writer switched off for this character.
    public var disabledArcQuestions: Set<ArcTemplateQuestion>

    public init(
        uuid: String = UUID().uuidString,
        name: String,
        role: String? = nil,
        identity: CharacterIdentity = .empty,
        intention: String = "",
        whyIntention: String = "",
        whatToDo: String = "",
        howDoesCharacterDoIt: String = "",
        obstacles: String = "",
        flaws: String = "",
        intentionFix: String = "",
        need: String = "",
        howCharacterChanged: String = "",
        notes: String = "",
        arcNotApplicable: Bool = false,
        arcQuestions: [ArcQuestion] = [],
        savedArcOrder: [ArcQuestionRef]? = nil,
        disabledArcQuestions: Set<ArcTemplateQuestion> = []
    ) {
        self.arcQuestions = arcQuestions
        self.savedArcOrder = savedArcOrder
        self.disabledArcQuestions = disabledArcQuestions
        self.uuid = uuid
        self.name = name
        self.role = role
        // A character that carries only the legacy flat `role` string (seed
        // data, previews, anything built in memory) still gets a structured
        // identity, so the cast list shows the same chips the detail screen
        // would show. Non-destructive: the legacy string is kept verbatim and
        // the resolved identity is only written back on the next save.
        self.identity = identity.isEmpty ? CharacterIdentity(resolvingLegacyRole: role) : identity
        self.intention = intention
        self.whyIntention = whyIntention
        self.whatToDo = whatToDo
        self.howDoesCharacterDoIt = howDoesCharacterDoIt
        self.obstacles = obstacles
        self.flaws = flaws
        self.intentionFix = intentionFix
        self.need = need
        self.howCharacterChanged = howCharacterChanged
        self.notes = notes
        self.arcNotApplicable = arcNotApplicable
    }

    // Identity-based equality/hashing keeps Set semantics stable across edits,
    // matching the original reference-type behaviour (keyed on uuid).
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }

    // MARK: - Codable (backward-compatible)

    enum CodingKeys: String, CodingKey {
        case uuid, name, role, identity
        case intention, whyIntention, whatToDo, howDoesCharacterDoIt
        case obstacles, flaws, intentionFix, need, howCharacterChanged, notes
        case arcNotApplicable
        case arcQuestions, savedArcOrder, disabledArcQuestions
    }

    /// Custom decode so records that predate `identity` still decode; when the
    /// key is absent, the identity is resolved from the legacy `role` string.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid = try container.decodeIfPresent(String.self, forKey: .uuid) ?? UUID().uuidString
        name = try container.decodeIfPresent(String.self, forKey: .name) ?? ""
        role = try container.decodeIfPresent(String.self, forKey: .role)
        let storedIdentity = try container.decodeIfPresent(CharacterIdentity.self, forKey: .identity)
        if let storedIdentity, !storedIdentity.isEmpty {
            identity = storedIdentity
        } else {
            identity = CharacterIdentity(resolvingLegacyRole: role)
        }
        intention = try container.decodeIfPresent(String.self, forKey: .intention) ?? ""
        whyIntention = try container.decodeIfPresent(String.self, forKey: .whyIntention) ?? ""
        whatToDo = try container.decodeIfPresent(String.self, forKey: .whatToDo) ?? ""
        howDoesCharacterDoIt = try container.decodeIfPresent(String.self, forKey: .howDoesCharacterDoIt) ?? ""
        obstacles = try container.decodeIfPresent(String.self, forKey: .obstacles) ?? ""
        flaws = try container.decodeIfPresent(String.self, forKey: .flaws) ?? ""
        intentionFix = try container.decodeIfPresent(String.self, forKey: .intentionFix) ?? ""
        need = try container.decodeIfPresent(String.self, forKey: .need) ?? ""
        howCharacterChanged = try container.decodeIfPresent(String.self, forKey: .howCharacterChanged) ?? ""
        notes = try container.decodeIfPresent(String.self, forKey: .notes) ?? ""
        arcNotApplicable = try container.decodeIfPresent(Bool.self, forKey: .arcNotApplicable) ?? false
        // Lenient: older records lack these, and a corrupt entry must never
        // cost the writer the rest of the character.
        arcQuestions = (try? container.decodeIfPresent([ArcQuestion].self, forKey: .arcQuestions)) ?? []
        savedArcOrder = try? container.decodeIfPresent([ArcQuestionRef].self, forKey: .savedArcOrder)
        disabledArcQuestions = (try? container.decodeIfPresent(
            Set<ArcTemplateQuestion>.self, forKey: .disabledArcQuestions
        )) ?? []
    }
}
