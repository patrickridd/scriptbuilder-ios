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
        let alert = UIAlertController(title: "Uh oh".localized,
                                      message: message,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
    
    static func passwordResetSuccess(email: String) -> UIAlertController {
        let alert = UIAlertController(title: "It worked!".localized,
                                      message: "Check %@ inbox for a link to create your new password.".localized(with: email),
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
    
    static func deleteAccountConfirmation(completion: @escaping (_ deleted: Bool,_ canceled: Bool) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Account".localized,
                                      message: "Are you sure you want to delete your account?".localized,
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete".localized, style: .destructive) { (_) in
            FirebaseController.shared.deleteAccount(completion: { (deleted) in
                completion(deleted,false)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized,
                                         style: .cancel) { (_) in
            completion(false,
                       true)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    static func accountDeleted(completion: @escaping () -> Void) -> UIAlertController {
        let alert = UIAlertController(title: "It worked!".localized,
                                      message: "Your account has been deleted".localized,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default) { (_) in
            completion()
        }
        alert.addAction(okAction)
        
        return alert
    }
    
    static func accountNotDeleted() -> UIAlertController {
        let alert = UIAlertController(title: "Didn't work!".localized,
                                      message: "Unable to delete account, please check your network settings and try again.".localized,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        
        return alert
    }
}
