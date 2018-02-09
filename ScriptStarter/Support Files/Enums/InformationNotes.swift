//
//  InformationNotes.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/9/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

enum InformationNote {
    
    case logline
    case actBeats
    
    var description: String {
        switch self {
        case .logline:
            return "A logline is a one to two sentence description of your script. Think about how you pitch movies you want to see to your friends/family. There are plenty of resources to help you build a perfect logline."
        case .actBeats:
            return "These act beats are common plot points found in screenplays and stories. A lot of these beats are based upon, The Hero With a Thousand Faces (Campbell, 1949)."
        }
    }
    
    var contentHeight: Int {
        switch self {
        case .logline:
            return 200
        case .actBeats:
            return 175
        }
    }
}
