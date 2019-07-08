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
    
    var user: Firebase.User? {
        return Auth.auth().currentUser
    }
    
    func signIn(with email: String, password: String, completion: @escaping (_ error: Error?, _ user: Firebase.User?) -> Void) {
        Auth.auth().signIn(withEmail: email,
                               password: password) { (result, error) in
            completion(error, result?.user)
        }
    }
    
    func createAccount(firstName: String, lastName: String, withEmail: String, password: String, completion: @escaping (_ error: Error?, _ user: Firebase.User?) -> Void) {
        
        Auth.auth().createUser(withEmail: withEmail,
                               password: password) { (result, error) in
            guard let createUser = result?.user else {
                completion(error, result?.user)
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
    
    func save(screenplay: Screenplay, completion: @escaping (_ success:Bool) -> Void) {
        guard let user = user else {
            completion(false)
            return
        }
        
        if screenplay.title == "" { screenplay.title = "Untitled" }
        let screenplayRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid)
        screenplayRef.setValue(screenplay.firDictionary) { (error, reference) in
            if let _ = error {
                completion(false)
                return
            }
            completion(true)
        }
        
        // Update characters
        let characterRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid).child("characters")
        for character in screenplay.characters {
            if character.name == "" {
                character.name = "Unnamed"
            }
            characterRef.updateChildValues([character.uuid:character.characterDictionary]) { (error, reference) in
                if let _ = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
        
        // Update Act One Scenes
        let actOneScenesRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid).child("actOne").child("scenes")
        for scene in screenplay.act1.scenes {
            actOneScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let _ = error {
                    completion(false)
                } else {
                    completion(true)
                }
        }
        
            // Update Act Two Scenes
            let actTwoScenesRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid).child("actTwo").child("scenes")
            
            for scene in screenplay.act2.scenes {
                actTwoScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
            
            // Update Act Three Scenes
            let actThreeScenesRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid).child("actThree").child("scenes")
            for scene in screenplay.act3.scenes {
                actThreeScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
    }
    
    func delete(screenplay: Screenplay, completion: @escaping () -> Void) {
        guard let user = user else {
            completion()
            return
        }
        let screenplayRef = self.ref.child("users").child(user.uid).child("screenplays").child(screenplay.uuid)
        
        screenplayRef.removeValue { (_, _) in
            ScreenplayController.shared.resetCurrentScreenplay()
            completion()
        }
    }
    
    func delete(character: Character, withScreenplay: Screenplay) {
        guard let user = user else { return }
        // Update characters
        let characterRef = self.ref.child("users").child(user.uid).child("screenplays").child(withScreenplay.uuid).child("characters").child(character.uuid)
        
        characterRef.removeValue()
    }
    
    func delete(scene: Scene, withScreenplay: Screenplay, inAct: Act) {
        guard let user = user else { return }
        
       let sceneRef = self.ref.child("users").child(user.uid).child("screenplays").child(withScreenplay.uuid).child(inAct.firebaseTitle).child("scenes").child(scene.uuid)
        
        sceneRef.removeValue()
    }
    
    func getScreenplays(completion: @escaping ([Screenplay])->Void) {
        guard let user = user else {
            completion([])
            return
        }
        self.ref.child("users").child(user.uid).child("screenplays").observe(.value) { (snapshot) in
            guard let screenplayDictionaryArray = snapshot.value as? [String:Any] else {
                completion([])
                return
            }
            
            var screenplays: [Screenplay] = []
            for screenplayKeyValuePair in screenplayDictionaryArray {
                let uuid = screenplayKeyValuePair.key
                guard let screenplayDictionary = screenplayKeyValuePair.value as? [String:Any],
                let screenplay = Screenplay(uuid: uuid, screenplayDictionary: screenplayDictionary)
                    else { continue }
                
                screenplays.append(screenplay)
            }
            completion(screenplays)
        }
    }
    
    func deleteAccount(completion: @escaping (_ deleted: Bool) -> Void) {
        guard let user = user else {
            completion(false)
            return
        }
        let userRef = self.ref.child("users").child(user.uid)

        user.delete(completion: { (error) in
            if let _ = error { completion( false) }
            userRef.removeValue { (error, _) in
                if let _ = error {
                    completion(false)
                } else {
                    completion(true)
                }
            }
        })
        
    }
    
    func changePassword(to newPassword: String, completion: @escaping (_ success: Bool) -> ()) {
        guard let user = self.user else {
            completion(false)
            return
        }
        
        user.updatePassword(to: newPassword) { (error
            ) in
            if let _ = error {
                completion(false)
            } else {
                completion(true)
            }
        }
    }
}
