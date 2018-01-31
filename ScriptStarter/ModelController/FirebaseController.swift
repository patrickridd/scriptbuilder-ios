//
//  FirebaseController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase

class FirebaseController {
    
    
    static let shared = FirebaseController()
    
    var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    var user: User? {
        return Auth.auth().currentUser
    }
    
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
    
    func saveScreenPlay(screenplay: Screenplay) {
        guard let user = user else { return }
        let screenplayRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.title)
        screenplayRef.setValue(screenplay.firDictionary)
    }
    
}
