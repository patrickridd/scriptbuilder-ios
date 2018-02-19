//
//  Role.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

enum Role: Int {
    case protagonist
    case antagonist
    case mentor
    case lover
    case friend
    case jester
    case enemy
    case ally
    case mysterious
    
    var title: String {
        switch self {
        case .protagonist:
            return "Protagonist"
        case .antagonist:
            return "Antagonist"
        case .mentor:
            return "Mentor"
        case .lover:
            return "Lover"
        case .friend:
            return "Friend"
        case .jester:
            return "Jester"
        case .enemy:
            return "Enemy"
        case .ally:
            return "Ally"
        case .mysterious:
            return "Mysterious"
        }
    }
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Role(rawValue: max) { max += 1 }
        return max
    }()
}

