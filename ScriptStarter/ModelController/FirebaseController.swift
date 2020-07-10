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
        let screenplayRef = self.ref.child(usersKey)
                           .child(user.uid)
                           .child(screenplaysKey)
                           .child(screenplay.uuid)
        screenplayRef.setValue(screenplay.firDictionary) { [weak self] (error, reference) in
            if let _ = error {
                completion(false)
                return
            }
            
            self?.saveCharacters(in: screenplay, with: user) { (error) in
                if let _ = error {
                    completion(false)
                    return
                }
                
                self?.saveScenes(in: screenplay, with: user) { (error) in
                    if let _ = error {
                        completion(false)
                    } else {
                        completion(true)
                    }
                }
            }
        }
        self.areWeOffline { (offline) in
            if offline {
                // We want to perform an optimistic update if offline so return true
                completion(true)
            }
        }
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
    
    
    func saveScenes(in screenplay: Screenplay, with user: User, completion: @escaping (_ error: Error?)-> Void) {
        saveScenesInActOne(in: screenplay, with: user) { [weak self] (error) in
            if let _ = error {
                completion(error)
                return
            }
            
            self?.saveScenesInActTwo(in: screenplay, with: user) { (error) in
                if let _ = error {
                    completion(error)
                    return
                }
                
                self?.saveScenesInActThree(in: screenplay, with: user) { (error) in
                    completion(error)
                }
            }
        }
    }
    
    // ACT 1 SCENES
    func saveScenesInActOne(in screenplay: Screenplay,
                            with user: User,
                            completion: @escaping (_ error: Error?) -> Void) {
        let actOneScenesDispatchGroup: DispatchGroup = DispatchGroup()
        var actOneScenesDispatchEnterCount: Int = 0
        // Act 1 Reference
        let actOneScenesRef = self.ref.child(usersKey)
                             .child(user.uid)
                             .child(screenplaysKey)
                             .child(screenplay.uuid)
                             .child(actOneKey)
                             .child(scenesKey)
        for scene in screenplay.act1.scenes {
            actOneScenesDispatchGroup.enter()
            actOneScenesDispatchEnterCount += 1
            
            actOneScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let _ = error {
                    completion(error)
                }
                
                if actOneScenesDispatchEnterCount > 0 {
                    actOneScenesDispatchGroup.leave()
                    actOneScenesDispatchEnterCount -= 1
                }
            }
        }
        
        actOneScenesDispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    // ACT 2 SCENES
    func saveScenesInActTwo(in screenplay: Screenplay,
                            with user: User,
                            completion: @escaping (_ error: Error?) -> Void) {
        let actTwoScenesDispatchGroup: DispatchGroup = DispatchGroup()
        var actTwoScenesDispatchEnterCount: Int = 0
        
        // Act 2 Reference
        let actTwoScenesRef = self.ref.child(usersKey)
                             .child(user.uid)
                             .child(screenplaysKey)
                             .child(screenplay.uuid)
                             .child(actTwoKey)
                             .child(scenesKey)

        for scene in screenplay.act2.scenes {
            actTwoScenesDispatchGroup.enter()
            actTwoScenesDispatchEnterCount += 1
            
            actTwoScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let _ = error {
                    completion(error)
                }
                if actTwoScenesDispatchEnterCount > 0 {
                    actTwoScenesDispatchGroup.leave()
                    actTwoScenesDispatchEnterCount -= 1
                }
            }
        }
        actTwoScenesDispatchGroup.notify(queue: .main) {
            completion(nil)
        }
    }
    
    // ACT 3 SCENES
    func saveScenesInActThree(in screenplay: Screenplay,
                              with user: User,
                              completion: @escaping (_ error: Error?) -> Void) {
        
        let actThreeScenesDispatchGroup: DispatchGroup = DispatchGroup()
        var actThreeScenesDispatchEnterCount: Int = 0
        
        // Act 3 Reference
        let actThreeScenesRef = self.ref.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .child(screenplay.uuid)
            .child(actThreeKey)
            .child(scenesKey)
        
        for scene in screenplay.act3.scenes {
            actThreeScenesDispatchGroup.enter()
            actThreeScenesDispatchEnterCount += 1
            actThreeScenesRef.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let _ = error {
                    completion(error)
                    return
                }
                
                if actThreeScenesDispatchEnterCount > 0 {
                    actThreeScenesDispatchGroup.leave()
                    actThreeScenesDispatchEnterCount -= 1
                }
            }
        }
        
        actThreeScenesDispatchGroup.notify(queue: .main) {
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
