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

    public init(
        uuid: String = UUID().uuidString,
        name: String,
        role: String? = nil,
        intention: String = "",
        whyIntention: String = "",
        whatToDo: String = "",
        howDoesCharacterDoIt: String = "",
        obstacles: String = "",
        flaws: String = "",
        intentionFix: String = "",
        need: String = "",
        howCharacterChanged: String = "",
        notes: String = ""
    ) {
        self.uuid = uuid
        self.name = name
        self.role = role
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
    }

    // Identity-based equality/hashing keeps Set semantics stable across edits,
    // matching the original reference-type behaviour (keyed on uuid).
    public static func == (lhs: Character, rhs: Character) -> Bool {
        lhs.uuid == rhs.uuid
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}
