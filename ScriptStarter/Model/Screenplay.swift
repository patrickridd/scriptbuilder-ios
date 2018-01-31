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
    var actOneKey = "actOne"
    var actTwoKey = "actTwo"
    var actThreeKey = "actThree"
    var titleKey = "title"
    var uuidKey = "uuid"
    
    var title: String
    var uuid: String
    var logLine: String?
    var actOne: String?
    var actTwo: String?
    var actThree: String?
    
    
    init(title: String) {
        self.title = title
        self.uuid = UUID().uuidString
    }
    
    init?(uuid: String, screenplayDictionary: [String:Any]) {
        guard let title = screenplayDictionary[titleKey] as? String,
        let actOne = screenplayDictionary[actOneKey] as? String,
        let actTwo = screenplayDictionary[actTwoKey] as? String,
        let actThree = screenplayDictionary[actThreeKey] as? String,
        let logLine = screenplayDictionary[logLineKey] as? String else
        { return nil }
        
        self.uuid = uuid
        self.uuid = uuid
        self.title = title
        self.logLine = logLine
        self.actOne = actOne
        self.actTwo = actTwo
        self.actThree = actThree
    }
    
    var firDictionary: [String:Any] {
        return [titleKey: title, logLineKey:logLine ?? "", actOneKey: actOne ?? "", actTwoKey: actTwo ?? "", actThreeKey: actThree ?? ""]
    }
    
}
