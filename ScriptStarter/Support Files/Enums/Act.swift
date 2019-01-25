//
//  Act.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

enum Act: Int {
    case idea = 4
    case one = 0
    case two = 1
    case three = 2
    
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
    
    var firebaseTitle: String {
        switch self {
        case .idea:
            return "idea"
        case .one:
            return "actOne"
        case .two:
            return "actTwo"
        case .three:
            return "actThree"
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
                             "Call to Action",
                             "Meet your Mentor",
                             "Themes Introduced",
                             "Analysis Paralysis",
                             "I Must Go",
                             "You Can't Go"]
        case .two:
            sectionTitles = ["Strange New World",
                             "Friends / Foes / Frenemies",
                             "Test Resolve",
                             "Sharpening the Sword",
                             "Burn the Boats",
                             "Supreme Sacrifice",
                             "Celebrate Good Times",
                             "Empire Strikes Back",
                             "Darkest Before the Dawn"]
        case .three:
            sectionTitles = ["The Ultimate Answer",
                             "Trophy",
                             "Questions That Need Answering",
                             "Brand New World"]
            
        }
        return sectionTitles
    }
    
    var sectionSubTitles: [String] {
        switch self {
        case .idea:
            return ["One to two sentence description of your movie",
                    "Central goal your hero(s) are trying to accomplish",
                    "Main obstacle preventing your hero(s) from getting what they want",
                    "Any beliefs or premises you want to test in your story",
                    "Details you don't want to forget"]
        case .one:
            return ["What is life like before the story begins?",
            "What event, person, or thing creates disharmony in the old world?",
            "What must the hero or group do to bring harmony?",
            "Does your hero(s) meet a mentor to help them through their journey",
            "Are there premises, beliefs, or ideas that can be tested in the adventure?",
            "Does your hero(s) have doubts about the adventure ahead?",
            "What convinces your hero(s) to make the decision to go on the adventure?",
            "Are there any obstacles/enemies/friends trying to prevent the adventure from being started?"]
        case .two:
            return [
              // Strange New World
                "Your hero(s) started the adventure, is the new world different, dangerous, and/or difficult?",
                // Friends/Foes/Frenemies
                "Are there any friends, enemies, and/or mysterious characters that your hero(s) meet?",
                // Test Resolve
                "What obstacles/opponents test your hero's resolve to attain their goal?",
                // Sharpening the sword
                "What skills/knowledge does your hero(s) acquire?",
                // Burn the Boats
                "Are there events that prevent your hero(s) from turning back?",
                // Supreme Sacrifice
                "Does your hero(s) risk their life for the cause?",
                // Celebrate Good Times
                "What temporary wins and successes does your hero(s) experience?",
                // Empire Strikes Back
                "How do the antagonists defeat your hero(s) temporarily?",
                // Darkest Before the Dawn
                "All is lost moment. What major fears are realized and what hopes are dashed?"]
        case .three:
            return ["What is your hero(s) ultimate answer(s) in making things right?",
                    "What type of reward does your hero(s) gain through the journey (wisdom, wealth, love)?",
                    "Are there any unanswered questions that need to be untangled?",
                    "Because of the adventure, how is the world and the characters in it different from the start of the story?"]
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
