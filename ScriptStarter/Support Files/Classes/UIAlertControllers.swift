//
//  UIAlertControllers.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/24/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class UIAlertControllers {
    
    static func emailAuthenticationError(message: String) -> UIAlertController {
        let alert = UIAlertController(title: "Uh oh", message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
    
    static func deleteScreenplayAlert() -> UIAlertController {
        let screenplayTitle = ScreenplayController.shared.currentScreenplay?.title ?? "this screenplay"
        
        let alert = UIAlertController(title: "Delete Screenplay", message: "Are you sure you want to delete \(screenplayTitle)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            if let screenplay = ScreenplayController.shared.currentScreenplay {
                // Delete currentScreenplay

            } else {
                // Just Dismiss ViewController
            }
            
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        return alert
    }
    
}
