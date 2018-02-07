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
    var logLineKey = "logLineKey"
    var actOneDescriptionKey = "actOneDescription"
    var actTwoDescriptionKey = "actTwoDescription"
    var actThreeDescriptionKey = "actThreeDescription"
    var actOneKey = "actOne"
    var actTwoKey = "actTwo"
    var actThreeKey = "actThree"
    var titleKey = "title"
    var uuidKey = "uuid"
    
    var title: String
    var uuid: String
    var logLine: String?
    var actOneDescription: String?
    var actTwoDescription: String?
    var actThreeDescription: String?
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
        let logLine = screenplayDictionary[logLineKey] as? String else
        { return nil }
        
        self.uuid = uuid
        self.uuid = uuid
        self.title = title
        self.logLine = logLine
        self.actOneDescription = actOneDescription
        self.actTwoDescription = actTwoDescription
        self.actThreeDescription = actThreeDescription
        self.act1 = act1
        self.act2 = act2
        self.act3 = act3
    }
    
    var firDictionary: [String:Any] {
        return [titleKey: title,
                logLineKey:logLine ?? "",
                actOneDescriptionKey: actOneDescription ?? "",
                actTwoDescriptionKey: actTwoDescription ?? "",
                actThreeDescriptionKey: actThreeDescription ?? "",
                actOneKey:self.act1.firActOneDictionary,
                actTwoKey:self.act2.firActTwoDictionary,
                actThreeKey:self.act3.firActThreeDictionary]
    }
    
}
