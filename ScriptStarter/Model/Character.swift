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
    var intention: String?
    var whyIntention: String?
    var physicalGoal: String?
    var obstacles: String?
    var flaws: String?
    var howIsCharacterChanged: String?
    var notes: String?
    
    init(name:String) {
        self.name = name
    }
    
}
