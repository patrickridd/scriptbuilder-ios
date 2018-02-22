//
//  Act.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

enum Act {
    case idea
    case one
    case two
    case three
    
    var title: String {
        switch self {
        case .idea:
            return "Idea"
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
        case .idea:
            sectionTitles = ["Log line",
                             "Intention",
                             "Obstacle",
                            "Themes",
                            "Notes"]
        case .one:
            sectionTitles = ["Old World",
                             "Inciting Incident",
                             "Call to Adventure",
                             "Themes Introduced",
                             "I don't want to go",
                             "I must go",
                             "Enemy at the gates"]
        case .two:
            sectionTitles = ["Strange New World",
                             "Enemies/Friends",
                             "Obstacles",
                             "Deadly encounter",
                             "Celebrate",
                             "Storm gathers",
                             "Bad Guys Strike back",
                             "Ultimate fears realized"]
        case .three:
            sectionTitles = ["The ultimate answer",
                             "Reward",
                             "Untangle"]
            
        }
        return sectionTitles
    }
    
    var sectionSubTitles: [String] {
        switch self {
        case .idea:
            return ["One to two sentence description of your movie.",
                    "Central goal your hero(s) are trying to accomplish",
                    "Main obstacle preventing your hero(s) from getting what they want",
                    "Any beliefs or premises you want to test in your story",
                    "Details you don't want to forget"]
        case .one:
            return ["What is life like before the story begins?",
            "What event, person, or thing creates disharmony in the old world?",
            "What must your hero or world do to bring harmony?",
            "Are there premises, beliefs, or ideas that can be tested in the adventure?",
            "Does your hero(s) have doubts about the adventure ahead?",
            "What convinces your hero(s) to go on their adventure?",
            "Are there any obstacles or enemies in getting the adventure started?"]
        case .two:
            return ["What makes the life and world the adventure is in different or more dangerous than the old world?",
                "Are there any friends or enemies that your hero(s) meet?",
                "What tests and obstacles does your hero(s) find along their adventure?",
                "What is your hero(s)'s most deadly obstacle?",
                "How do your hero(s) celebrate in victory?",
                "How do the bad guys regather strength?",
                "How do the villains defeat your hero(s) temporarily?",
                "What major fears and hopes are dashed by your hero(s)?"]
        case .three:
            return ["What is your hero(s) ultimate answer(s) in making things right?",
                    " What type of reward does your hero(s) gain through the journey (wisdom, money, love)?",
                    "Are there any unanswered questions that need to be untangled?"]
        }
    }
    
    var placeholders: [String] {
        switch self {
        case .idea:
            return []
        case .one:
            return ["The setup",
                    "e.g. Bruce Wayne's parents have died and Gotham City is riddled with crime...",
                    "e.g. Princess Leia is captured by Darth Vader...",
                "e.g. Indian Jones is asked by the government to find the Arc of the Covenant before the Nazis do",
                "e.g. Better to be with friends and family even if they annoy you sometimes...",
                "e.g. Luke Skywalker refuses the call to help save Princess Leia, because he needs to help his aunt and uncle with the farm",
                "e.g. After Luke Skywalker's aunt and uncle are killed by stormtroopers he's realizes he must go help save princess Leia",
                "e.g. Obi Wan and Luke get past the storm troopers on Tatooine. \"These aren't the droids you're looking for\""]
        case .two:
            return ["The conflict",
                    "e.g. In the Last Samurai, the hero's new world is of the Samurai who capture him.",
                    "e.g. In the Lion King, Simba makes friends with Timon and Pumba",
                    "e.g. "]
        case .three:
            return ["The resolution"]
        }
    }
}
