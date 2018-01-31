//
//  Screenplay.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Screenplay {
    
    // keys
    var logLineKey = "logLineKey"
    var actOneKey = "actOne"
    var actTwoKey = "actTwo"
    var actThreeKey = "actThree"
    var titleKey = "title"
    
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
    
    var firDictionary: [String:Any] {
        return [titleKey: title, logLineKey:logLine ?? "", actOneKey: actOne ?? "", actTwoKey: actTwo ?? "", actThreeKey: actThree ?? ""]
    }
    
}
