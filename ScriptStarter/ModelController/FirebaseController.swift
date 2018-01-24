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
    
    func createAccount(with email: String, password: String, completion: @escaping (_ error: Error?, _ user: User?) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { (user, error) in
            completion(error, user)
        }
        
    }
    
}
