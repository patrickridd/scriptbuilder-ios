//
//  Screenplay.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import Firebase

class Screenplay {
    
    // keys
    let logLineKey = "logLineKey"
    let actOneDescriptionKey = "actOneDescription"
    let actTwoDescriptionKey = "actTwoDescription"
    let actThreeDescriptionKey = "actThreeDescription"
    let actOneKey = "actOne"
    let actTwoKey = "actTwo"
    let actThreeKey = "actThree"
    let titleKey = "title"
    let uuidKey = "uuid"
    let ideaKey = "idea"
    let notesKey = "notes"
    let themeKey = "theme"
    
    var title: String
    var uuid: String
    
    var idea: String = ""
    var logLine: String = ""
    var notes: String = ""
    var theme: String = ""

    var actOneDescription: String = ""
    var actTwoDescription: String = ""
    var actThreeDescription: String = ""
    var characters: [Character] = []
    var act1 = Act1()
    var act2 = Act2()
    var act3 = Act3()
    
    init(title: String) {
        self.title = title
        self.uuid = UUID().uuidString
    }
    
    init?(uuid: String, screenplayDictionary: [String:Any]) {
        guard let title = screenplayDictionary[titleKey] as? String,
        let actOneDescription = screenplayDictionary[actOneDescriptionKey] as? String,
        let actTwoDescription = screenplayDictionary[actTwoDescriptionKey] as? String,
        let actThreeDescription = screenplayDictionary[actThreeDescriptionKey] as? String,
        let actOneDict = screenplayDictionary[actOneKey] as? [String:Any],
        let actTwoDict = screenplayDictionary[actTwoKey] as? [String:Any],
        let actThreeDict = screenplayDictionary[actThreeKey] as? [String:Any],
        let act1 = Act1(actOneDict: actOneDict),
        let act2 = Act2(actTwoDict: actTwoDict),
        let act3 = Act3(actThreeDict: actThreeDict),
        let idea = screenplayDictionary[ideaKey] as? String else
        { return nil }
        
        self.notes = screenplayDictionary[notesKey] as? String ?? ""
        self.theme =  screenplayDictionary[themeKey] as? String ?? ""
        self.uuid = uuid
        self.uuid = uuid
        self.title = title
        self.logLine = screenplayDictionary[logLineKey] as? String ?? ""
        self.idea = idea
        self.actOneDescription = actOneDescription
        self.actTwoDescription = actTwoDescription
        self.actThreeDescription = actThreeDescription
        self.act1 = act1
        self.act2 = act2
        self.act3 = act3
    }
    
    var firDictionary: [String:Any] {
        return [titleKey: self.title,
                logLineKey:self.logLine,
                actOneDescriptionKey: self.actOneDescription,
                actTwoDescriptionKey: self.actTwoDescription,
                actThreeDescriptionKey: self.actThreeDescription,
                actOneKey:self.act1.firActOneDictionary,
                actTwoKey:self.act2.firActTwoDictionary,
                actThreeKey:self.act3.firActThreeDictionary]
    }
    
}
