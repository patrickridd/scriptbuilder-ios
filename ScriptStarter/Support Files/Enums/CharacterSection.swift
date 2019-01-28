//
//  CharacterSection.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/9/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

enum CharacterSection {
    
    case intention
    case why
    case what
    case how
    case obstacles
    case flawsFears
    case fix
    case need
    case characterChanged
    case notes
    
    static var sectionSubtitles: [String] {
        return ["Intention - What does your character want?",
                "Why does your character want this?",
                "What does your character need to do to get what they want?",
                "How does your character get what they want?",
                "What obstacles are in your characters's way?",
                "What flaws or fears does your character have?",
                "Does acheiving their intention solve their problem?",
                "Is there something the character \"needs\" to do but is avoiding that would fix their problem?",
                "How is the character changed through the story?",
                "Any other pertinent details about the character?"]
    }
    
    static var sectionTitles: [String] {
            return ["Intention",
                    "Why",
                    "What",
                    "How",
                    "Obstacles",
                    "Flaws",
                    "Problem Solved?",
                    "Need",
                    "Changed",
                    "Notes"]
    }
}
