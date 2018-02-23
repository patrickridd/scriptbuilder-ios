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
    
    var currentScreenplay: Screenplay?
    
    func set(currentScreenplay: Screenplay) {
        self.currentScreenplay = currentScreenplay
    }
    
    func resetCurrentScreenplay() {
        self.currentScreenplay = nil
    }
    
    func saveCurrentScreenplay() {
        guard let screenplay = currentScreenplay else { return }
       // FirebaseController.shared.save(screenplay: screenplay)
    }
    
    func add(character: Character) {
        if let screenplay = self.currentScreenplay {
            screenplay.characters.append(character)
        }
    }
    
}
