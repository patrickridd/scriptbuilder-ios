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

    enum CodingKeys: String, CodingKey {
        case uuid                 = "uuid"
        case name                 = "name"
        case role                 = "role"
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
    }

    init(
        uuid: String, name: String, role: String?, intention: String,
        whyIntention: String, whatToDo: String, howDoesCharacterDoIt: String,
        obstacles: String, flaws: String, intentionFix: String, need: String,
        howCharacterChanged: String, notes: String
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

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        uuid                 = container.lenientString(.uuid)
        name                 = container.lenientString(.name)
        role                 = try? container.decodeIfPresent(String.self, forKey: .role)
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
    }
}
