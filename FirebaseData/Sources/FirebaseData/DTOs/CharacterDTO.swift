//
//  CharacterDTO.swift
//  FirebaseData
//
//  Persistence shape for a `Character`.
//
//  Keys verified against the live `Character` model. Two field names diverge
//  from their Swift property names and are preserved verbatim:
//      whyIntention -> "whyTheyWantThis"
//      whatToDo     -> "physicalGoal"
//

import Foundation

struct CharacterDTO: Codable, Sendable {

    let uuid: String
    let name: String
    let role: String?
    let identity: CharacterIdentityDTO?
    let intention: String
    let whyIntention: String
    let whatToDo: String
    let howDoesCharacterDoIt: String
    let obstacles: String
    let flaws: String
    let intentionFix: String
    let need: String
    let howCharacterChanged: String
    let notes: String
    let arcNotApplicable: Bool

    enum CodingKeys: String, CodingKey {
        case uuid                 = "uuid"
        case name                 = "name"
        case role                 = "role"
        case identity             = "identity"
        case intention            = "intention"
        case whyIntention         = "whyTheyWantThis"      // diverges from property name
        case whatToDo             = "physicalGoal"         // diverges from property name
        case howDoesCharacterDoIt = "howDoesCharacterDoIt"
        case obstacles            = "obstacles"
        case flaws                = "flaws"
        case intentionFix         = "intentionFix"
        case need                 = "need"
        case howCharacterChanged  = "howCharacterChanged"
        case notes                = "notes"
        case arcNotApplicable     = "arcNotApplicable"
    }

    init(
        uuid: String, name: String, role: String?,
        identity: CharacterIdentityDTO?, intention: String,
        whyIntention: String, whatToDo: String, howDoesCharacterDoIt: String,
        obstacles: String, flaws: String, intentionFix: String, need: String,
        howCharacterChanged: String, notes: String,
        arcNotApplicable: Bool = false
    ) {
        self.uuid = uuid
        self.name = name
        self.role = role
        self.identity = identity
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid                 = container.lenientString(.uuid)
        name                 = container.lenientString(.name)
        role                 = try? container.decodeIfPresent(String.self, forKey: .role)
        identity             = try? container.decodeIfPresent(CharacterIdentityDTO.self, forKey: .identity)
        intention            = container.lenientString(.intention)
        whyIntention         = container.lenientString(.whyIntention)
        whatToDo             = container.lenientString(.whatToDo)
        howDoesCharacterDoIt = container.lenientString(.howDoesCharacterDoIt)
        obstacles            = container.lenientString(.obstacles)
        flaws                = container.lenientString(.flaws)
        intentionFix         = container.lenientString(.intentionFix)
        need                 = container.lenientString(.need)
        howCharacterChanged  = container.lenientString(.howCharacterChanged)
        notes                = container.lenientString(.notes)
        // Legacy payloads may store this as a bool, a 0/1 number or a string.
        if let flag = try? container.decodeIfPresent(Bool.self, forKey: .arcNotApplicable) {
            arcNotApplicable = flag
        } else if let number = try? container.decodeIfPresent(Int.self, forKey: .arcNotApplicable) {
            arcNotApplicable = number != 0
        } else {
            arcNotApplicable = container.lenientString(.arcNotApplicable).lowercased() == "true"
        }
    }
}
