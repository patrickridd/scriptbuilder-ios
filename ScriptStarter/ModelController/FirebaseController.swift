//
//  FirebaseController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import Firebase

class FirebaseController {
    
    static let shared = FirebaseController()

    func signIn(with email: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            completion(error, user)
        }
    }
    
    func createAccount(firstName: String, lastName: String, withEmail: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        
        Auth.auth().createUser(withEmail: withEmail, password: password) { (user, error) in
            guard let createUser = user else {
                completion(error, user)
                return
            }
            
            let changeRequest = createUser.createProfileChangeRequest()
            changeRequest.displayName = "\(firstName) \(lastName)"
            changeRequest.commitChanges { error in
                if let error = error {
                    completion(error, createUser)
                } else {
                    // Profile updated.
                    completion(error, createUser)
                }
            }
        }
    }
    
}
