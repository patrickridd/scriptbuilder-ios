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


let usersKey: String = "users"
let screenplaysKey: String = "screenplays"
let actOneKey: String = "actOne"
let actTwoKey: String = "actTwo"
let actThreeKey: String = "actThree"
let scenesKey: String = "scenes"
let charactersKey: String = "characters"

class FirebaseController {
    
    static let shared = FirebaseController()
    
    var ref: DatabaseReference {
        return Database.database().reference()
    }
    
    var user: Firebase.User? {
        return Auth.auth().currentUser
    }
    
    func areWeOffline(completion: @escaping (_ offline: Bool) -> Void) {
        let connectedRef = Database.database().reference(withPath: ".info/connected")
        connectedRef.observe(.value, with: { snapshot in
            if snapshot.value as? Bool ?? false {
                // Online
                completion(false)
            } else {
                // Offline
                completion(true)
            }
        })
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
       
        // OUTLINE
        let screenplayRef = self.ref.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .child(screenplay.uuid)
        screenplayRef.updateChildValues(screenplay.firDictionary) { [weak self] (error, reference) in
            if let _ = error {
                completion(false)
                return
            }
            // CHARACTERS
            self?.saveCharacters(in: screenplay, with: user) { (error) in
                if let _ = error {
                    completion(false)
                    return
                }
                // ACT 1 SCENES
                self?.save(scenes: screenplay.act1.scenes,
                           for: actOneKey,
                           in: screenplay,
                           with: user, completion: { (error) in
                            if let _ = error {
                                completion(false)
                                return
                            }
                            // ACT 2 SCENES
                            self?.save(scenes: screenplay.act2.scenes,
                                       for: actTwoKey,
                                       in: screenplay,
                                       with: user, completion: { (error) in
                                if let _ = error {
                                    completion(false)
                                    return
                                }
                                // ACT 3 SCENES
                                self?.save(scenes: screenplay.act3.scenes,
                                           for: actThreeKey,
                                           in: screenplay,
                                           with: user, completion: { (error) in
                                    if let _ = error {
                                        completion(false)
                                    } else {
                                        completion(true)
                                    }
                                })
                            })
                })
            }
        }
        self.areWeOffline { (offline) in
            if offline {
                // We want to perform an optimistic update if offline so return true
                completion(true)
                self.saveScreenplayOffline(screenplay: screenplay, with: user)
            }
        }
    }
    
    // Save References without worrying about network calls
    func saveScreenplayOffline(screenplay: Screenplay, with user: User) {
        
        // Save Outline
        let screenplayRef = self.ref.child(usersKey).child(user.uid).child(screenplaysKey).child(screenplay.uuid)
        screenplayRef.updateChildValues(screenplay.firDictionary) { (_, _) in }
        
        // Save Characters
        self.saveCharacters(in: screenplay, with: user) { (_) in }
        
        // Act 1
        self.save(scenes: screenplay.act1.scenes,
                  for: actOneKey,
                  in: screenplay,
                  with: user, completion: { (_) in })
        // Act 2
        self.save(scenes: screenplay.act2.scenes,
                  for: actTwoKey,
                  in: screenplay,
                  with: user, completion: { (_) in })
        // Act 3
        self.save(scenes: screenplay.act3.scenes,
                  for: actThreeKey,
                  in: screenplay,
                  with: user, completion: { (_) in })
    }
    
    func saveCharacters(in screenplay: Screenplay,
                        with user: User,
                        completion: @escaping (_ error: Error?) -> Void) {
        
        let dispatchGroup: DispatchGroup = DispatchGroup()
        var dispatchEnterCount: Int = 0
        
        // Update characters
        let characterRef = self.ref.child(usersKey)
                          .child(user.uid)
                          .child(screenplaysKey)
                          .child(screenplay.uuid)
                          .child(charactersKey)
        for character in screenplay.characters {
            dispatchGroup.enter()
            dispatchEnterCount += 1
            
            if character.name == "" {
                character.name = "Unnamed"
            }
            characterRef.updateChildValues([character.uuid:character.characterDictionary]) { (error,reference) in
                if let _ = error {
                    completion(error)
                }
                
                if dispatchEnterCount > 0 {
                    dispatchGroup.leave()
                    dispatchEnterCount -= 1
                }
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    // Save Scenes by specifying the scenes and act number
    func save(scenes: [Scene],
              for act: String,
              in screenplay: Screenplay,
              with user: User,
              completion: @escaping (_ error: Error?) -> Void) {
       
        let dispatchGroup: DispatchGroup = DispatchGroup()
        var dispatchEnterCount: Int = 0
        
        let scenesRef = self.ref.child(usersKey)
                             .child(user.uid)
                             .child(screenplaysKey)
                             .child(screenplay.uuid)
                             .child(act)
                             .child(scenesKey)
        for scene in scenes {
            dispatchGroup.enter()
            dispatchEnterCount += 1
            
            scenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let error = error {
                    completion(error)
                }
                if dispatchEnterCount > 0 {
                    dispatchGroup.leave()
                    dispatchEnterCount -= 1
                }
            }
        }
        dispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    func delete(screenplay: Screenplay, completion: @escaping () -> Void) {
        guard let user = user else {
            completion()
            return
        }
        let screenplayRef = self.ref.child(usersKey)
                           .child(user.uid)
                           .child(screenplaysKey)
                           .child(screenplay.uuid)
        
        screenplayRef.removeValue { (_, _) in
            ScreenplayController.shared.resetCurrentScreenplay()
            completion()
        }
    }
    
    func delete(character: Character, withScreenplay: Screenplay) {
        guard let user = user else { return }
        // Update characters
        let characterRef = self.ref.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .child(withScreenplay.uuid)
            .child(charactersKey)
            .child(character.uuid)
        
        characterRef.removeValue()
    }
    
    func delete(scene: Scene, withScreenplay: Screenplay, inAct: Act) {
        guard let user = user else { return }
        
        let sceneRef = self.ref.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .child(withScreenplay.uuid)
            .child(inAct.firebaseTitle)
            .child(scenesKey)
            .child(scene.uuid)
        
        sceneRef.removeValue()
    }
    
    func getScreenplays(completion: @escaping ([Screenplay])->Void) {
        guard let user = user else {
            completion([])
            return
        }
        self.ref.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .observe(.value) { (snapshot) in
            guard let screenplayDictionaryArray = snapshot.value as? [String:Any] else {
                completion([])
                return
            }
            
            var screenplays: [Screenplay] = []
            for screenplayKeyValuePair in screenplayDictionaryArray {
                let uuid = screenplayKeyValuePair.key
                guard
                    let screenplayDictionary = screenplayKeyValuePair.value as? [String:Any],
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
        let userRef = self.ref.child(usersKey).child(user.uid)
        
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
