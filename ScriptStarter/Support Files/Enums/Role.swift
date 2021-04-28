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
            return "Protagonist".localized
        case .antagonist:
            return "Antagonist".localized
        case .mentor:
            return "Mentor".localized
        case .lover:
            return "Lover".localized
        case .friend:
            return "Friend".localized
        case .jester:
            return "Jester".localized
        case .enemy:
            return "Enemy".localized
        case .ally:
            return "Ally".localized
        case .mysterious:
            return "Mysterious".localized
        }
    }
    
    static let count: Int = {
        var max: Int = 0
        while let _ = Role(rawValue: max) { max += 1 }
        return max
    }()
}

