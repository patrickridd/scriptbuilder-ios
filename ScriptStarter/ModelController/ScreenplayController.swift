//
//  ScreenplayController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/31/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase

class ScreenplayController {
    
    static let shared = ScreenplayController()
   
    let screenplayKey = "screenplay"
   
    let userDefaults = UserDefaults()
    
    var currentScreenplay: Screenplay?
    
    func set(currentScreenplay: Screenplay) {
        self.currentScreenplay = currentScreenplay
        // Save ID so that when user opens app we can open the screenplay they last were working on
          userDefaults.setValue(currentScreenplay.uuid, forKey: self.screenplayKey)
    }
    
    func resetCurrentScreenplay() {
        self.currentScreenplay = nil
        self.userDefaults.setValue(nil, forKey: self.screenplayKey)
    }
    
    func add(character: Character) {
        if let screenplay = self.currentScreenplay {
            screenplay.characters.append(character)
        }
    }
    
    func getScreenPlayId() -> String? {
        return userDefaults.value(forKey: screenplayKey) as? String
    }
}
