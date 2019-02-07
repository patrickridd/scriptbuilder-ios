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
        return ["Intention - What does your character want?".localized,
                "Why does your character want this?".localized,
                "What does your character need to do to get what they want?".localized,
                "How does your character get what they want?".localized,
                "What obstacles are in your characters's way?".localized,
                "What flaws or fears does your character have?".localized,
                "Does acheiving their intention solve their problem?".localized,
                "Is there something the character \"needs\" to do but is avoiding that would fix their problem?".localized,
                "How is the character changed through the story?".localized,
                "Any other pertinent details about the character?".localized]
    }
    
    static var sectionTitles: [String] {
            return ["Intention".localized,
                    "Why".localized,
                    "What".localized,
                    "How".localized,
                    "Obstacles".localized,
                    "Flaws".localized,
                    "Problem Solved?".localized,
                    "Need".localized,
                    "Changed".localized,
                    "Notes".localized]
    }
}
