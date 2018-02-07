//
//  Character.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class Character {
    
    var name: String
    var role: String?
    
    // Character Arc
    var intention: String = ""
    var whyIntention: String = ""
    var physicalGoal: String = ""
    var obstacles: String = ""
    var flaws: String = ""
    var howIsCharacterChanged: String = ""
    var notes: String = ""
    
    init(name:String) {
        self.name = name
    }
    
    init?(characterDictionary: [String:Any]) {
        guard let name = characterDictionary["name"] as? String,
            let role = characterDictionary["role"] as? String,
            let intention = characterDictionary["intention"] as? String,
            let whyIntention = characterDictionary["whyTheyWantThis"] as? String,
            let physicalGoal = characterDictionary["physicalGoal"] as? String,
            let obstacles = characterDictionary["obstacles"] as? String,
            let flaws = characterDictionary["flaws"] as? String,
            let howIsCharacterChanged = characterDictionary["howCharacterChanged"] as? String,
            let notes = characterDictionary["notes"] as? String else {
                return nil
        }
        
        self.name = name
        self.role = role
        self.intention = intention
        self.whyIntention = whyIntention
        self.physicalGoal = physicalGoal
        self.obstacles = obstacles
        self.flaws = flaws
        self.howIsCharacterChanged = howIsCharacterChanged
        self.notes = notes
        
    }
    
}
