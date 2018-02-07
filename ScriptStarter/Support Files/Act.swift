//
//  Act.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

enum Act {
    case one
    case two
    case three
    
    var title: String {
        switch self {
        case .one:
            return "Act 1"
        case .two:
            return "Act 2"
        case .three:
            return "Act 3"
        }
    }
    
    var sectionsTitles: [String] {
        var sectionTitles: [String] = []
        switch self {
        case .one:
            sectionTitles = ["Old World - What is life like before the story begins?",
                             "Inciting incident - What event, person, or thing creates disharmony in the old world?",
                             "Call to Adventure - What must your hero or world do to bring harmony?",
                             "Theme - Are there any premises, beliefs, or ideas that can be tested in the adventure?",
                             "I don't want to go - Does your hero(s) have doubts about the adventure ahead?",
                             "I must go - What convinces your hero(s) to go on their adventure?",
                             "Enemy at the gates - Are there any obstacles or enemies in getting the adventure started?"]
        case .two:
            sectionTitles = ["New World - What makes the life and world the adventure is in different           or more dangerous than the old world?",
                             "Enemies/Friends - Are there any friends or enemies that your hero(s) encounters?",
                             "Obstacles - What tests and obstacles does your hero(s) find along their adventure?",
                             "Deadly encounter - What is your hero(s)'s most deadly obstacle?",
                             "Celebrate - How do your hero(s) celebrate in victory?",
                             "Storm gathers - How do the bad guys regather strength?",
                             "Bad Guys Strike back - How do the villains defeat your hero(s) temporarily?",
                             "All is lost - What fears and hopes are dashed by your hero(s)?"]
        case .three:
            sectionTitles = ["The ultimate answer - What is your hero(s) ultimate answer(s) in making things right?",
                             "Reward - What type of reward does your hero(s) gain through the journey (wisdom, money, love)?",
                             "Untangle - Are there any unanswered questions that need to be untangled?"]
            
        }
        return sectionTitles
    }
}
