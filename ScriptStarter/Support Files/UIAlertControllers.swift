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
    
    
    
}
