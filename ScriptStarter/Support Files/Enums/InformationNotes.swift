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
            return "A logline is a one to two sentence description of your screenplay. Think about how you pitch movies you want to see to your friends/family.".localized
        case .actBeats:
            return "Answering these questions can help you develop the plot points in your acts and push the story forward. Although not required, they can help you escape writer's block.".localized
        }
    }
    
    var contentHeight: Int {
        switch self {
        case .logline, .actBeats:
            return 160
        }
    }
}
