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
    var unalteredScreenplay: Screenplay?
    
    var screenplayChanged: Bool {
        return self.currentScreenplay != unalteredScreenplay
    }
    
    func set(currentScreenplay: Screenplay) {
        self.currentScreenplay = currentScreenplay
        
        self.unalteredScreenplay = Screenplay(screenplay: currentScreenplay)
        // Save ID so that when user opens app we can open the screenplay they last were working on
          userDefaults.setValue(currentScreenplay.uuid, forKey: self.screenplayKey)
    }
    
    func resetCurrentScreenplay() {
        self.currentScreenplay = nil
        self.unalteredScreenplay = nil
        self.userDefaults.setValue(nil, forKey: self.screenplayKey)
    }
    
    func sort(screenplays: [Screenplay]) -> [Screenplay] {
        return screenplays.sorted { (screenplay1, screenplay2) -> Bool in
            return screenplay1.title < screenplay2.title
        }
    }
    
    func discardChangesInCurrentScreenplay() {
        self.currentScreenplay = unalteredScreenplay
    }
    
    func add(character: Character) {
        if let screenplay = self.currentScreenplay {
            screenplay.characters.insert(character)
        }
    }
    
    func getScreenPlayId() -> String? {
        return userDefaults.value(forKey: screenplayKey) as? String
    }
    
    func getCachedScreenplay(screenplays: [Screenplay]) -> Screenplay? {
        // Find previously opened screenplay and present it
        guard let screenplayId = self.getScreenPlayId(),
            let screenplay = screenplays.filter({screenplayId == $0.uuid}).first else {
                return nil
        }
        
        return screenplay
    }
}
