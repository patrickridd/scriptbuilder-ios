//
//  Act.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/6/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Domain
import Foundation

/// A section of the screenplay outline UI. Unlike `Domain.Act`, this includes
/// the `.idea` case (which isn't an act) and carries the UILabel copy
/// (`title`, `sectionsTitles`, `sectionSubTitles`, `placeholders`) used by the
/// outline/act-detail screens. Map to the domain model via `domainAct`.
enum OutlineSection: Int {
    case idea = 4
    case one = 0
    case two = 1
    case three = 2

    /// The corresponding `Domain.Act`, or `nil` for `.idea` (not an act).
    var domainAct: Domain.Act? {
        switch self {
        case .one:   return .one
        case .two:   return .two
        case .three: return .three
        case .idea:  return nil
        }
    }

    var title: String {
        switch self {
        case .idea:
            return "Idea".localized
        case .one:
            return "Act 1".localized
        case .two:
            return "Act 2".localized
        case .three:
            return "Act 3".localized
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
            sectionTitles = ["Log line".localized,
                             "Intention".localized,
                             "Obstacle".localized,
                             "Themes".localized,
                             "Notes".localized]
        case .one:
            sectionTitles = ["Old World".localized,
                             "Inciting Incident".localized,
                             "Call To Action".localized,
                             "Meet Your Mentor".localized,
                             "Themes Introduced".localized,
                             "Analysis Paralysis".localized,
                             "I Must Go".localized,
                             "We Won't Let You Go".localized]
        case .two:
            sectionTitles = ["Strange New World".localized,
                             "Friends / Foes / Frenemies".localized,
                             "Test Resolve".localized,
                             "Sharpening the Sword".localized,
                             "Burn The Boats".localized,
                             "Supreme Sacrifice".localized,
                             "Celebrate Good Times".localized,
                             "Empire Strikes Back".localized,
                             "Darkest Before the Dawn".localized]
        case .three:
            sectionTitles = ["The Ultimate Answer".localized,
                             "Reap Rewards".localized,
                             "Questions That Need Answering".localized,
                             "Brand New World".localized]
        }
        return sectionTitles
    }
    
    var sectionSubTitles: [String] {
        switch self {
        case .idea:
            return ["One to two sentence description of your movie".localized,
                    "Central goal your hero(s) are trying to accomplish".localized,
                    "Main obstacle preventing your hero(s) from getting what they want".localized,
                    "Any beliefs or premises you want to test in your story".localized,
                    "Details you don't want to forget".localized]
        case .one:
            return ["What is life like before the story begins?".localized,
            "What event, person, or thing creates disharmony in the old world?".localized,
            "What must the hero or group do to bring harmony?".localized,
            "Does your hero(s) meet a mentor to help them through their journey".localized,
            "Are there premises, beliefs, or ideas that can be tested in the adventure?".localized,
            "Does your hero(s) have doubts about the adventure ahead?".localized,
            "What convinces your hero(s) to make the decision to go on the adventure?".localized,
            "Are there any obstacles/enemies/friends trying to prevent the adventure from being started?".localized]
        case .two:
            return [
              // Strange New World
                "Your hero(s) started the adventure, is the new world different, dangerous, and/or difficult?".localized,
                // Friends/Foes/Frenemies
                "Are there any friends, enemies, and/or mysterious characters that your hero(s) meet?".localized,
                // Test Resolve
                "What obstacles/opponents test your hero's resolve to attain their goal?".localized,
                // Sharpening the sword
                "What skills/knowledge does your hero(s) acquire?".localized,
                // Burn the Boats
                "Are there events that prevent your hero(s) from turning back?".localized,
                // Supreme Sacrifice
                "Does your hero(s) risk their life for the cause?".localized,
                // Celebrate Good Times
                "What temporary wins and successes does your hero(s) experience?".localized,
                // Empire Strikes Back
                "How do the antagonists defeat your hero(s) temporarily?".localized,
                // Darkest Before the Dawn
                "All is lost moment. What major fears are realized and what hopes are dashed?".localized]
        case .three:
            return ["What is your hero(s) ultimate answer(s) in making things right?".localized,
                    "What type of reward does your hero(s) gain through the journey (wisdom, wealth, love)?".localized,
                    "Are there any unanswered questions that need to be untangled?".localized,
                    "Because of the adventure, how is the world and the characters in it different from the start of the story?".localized]
        }
    }
    
    var placeholders: [String] {
        switch self {
        case .idea:
            return []
        case .one:
            return ["The setup".localized,
                    "e.g. Bruce Wayne's parents have died and Gotham City is riddled with crime...",
                    "e.g. Princess Leia is captured by Darth Vader...",
                    "e.g. Indian Jones is asked by the government to find the Arc of the Covenant before the Nazis do",
                    "e.g. Better to be with friends and family even if they annoy you sometimes...",
                    "e.g. Luke Skywalker refuses the call to help save Princess Leia, because he needs to help his aunt and uncle with the farm",
                    "e.g. After Luke Skywalker's aunt and uncle are killed by stormtroopers he's realizes he must go help save princess Leia",
                    "e.g. Obi Wan and Luke get past the storm troopers on Tatooine. \"These aren't the droids you're looking for\""]
        case .two:
            return ["The conflict".localized,
                    "e.g. In the Last Samurai, the hero's new world is of the Samurai who capture him.",
                    "e.g. In the Lion King, Simba makes friends with Timon and Pumba",
                    "e.g. "]
        case .three:
            return ["The resolution".localized]
        }
    }
}
