//
//  CharacterTableViewSection.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/20/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

struct CharacterTableViewSection: Hashable {
    
    var roleTitle: String
    var characters: [Character] = []
    
    var hashValue: Int {
        return self.roleTitle.hashValue
    }
    
    static func ==(lhs: CharacterTableViewSection, rhs: CharacterTableViewSection) -> Bool {
        return lhs.roleTitle == rhs.roleTitle
    }
}
