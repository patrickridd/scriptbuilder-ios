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
let act1ScenesKey = "actOneScenes"
let act2ScenesKey = "actTwoScenes"
let act3ScenesKey = "actThreeScenes"

class FirebaseController {

    static let shared = FirebaseController()

    init() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(saveCurrentScreenplay),
            name: .ScreenplayUpdated,
            object: nil
        )
    }

    var currentScreenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }

    var dataBaseReference: DatabaseReference {
        return Database.database().reference()
    }

    var currentScreenplayReference: DatabaseReference? {
        guard let user = user, let currentScreenplay = currentScreenplay else {
            return nil
        }
        return dataBaseReference.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .child(currentScreenplay.uuid)
    }

    var charactersReference: DatabaseReference? {
        currentScreenplayReference?.child(charactersKey)
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

    @objc func saveCurrentScreenplay() {
        if let screenplay = currentScreenplay {
            save(screenplay: screenplay)
        }
    }
    
    func save(screenplay: Screenplay, completion: ((_ success: Bool) -> Void)? = nil) {
        // Save Outline
        currentScreenplayReference?.updateChildValues(screenplay.firDictionary) { (_, _) in }
        // Save Characters
        saveCharacters(in: screenplay)
        // Act 1
        save(scenes: screenplay.act1ScenesArray, for: act1ScenesKey, in: screenplay)
        // Act 2
        save(scenes: screenplay.act2ScenesArray, for: act2ScenesKey, in: screenplay)
        // Act 3
        save(scenes: screenplay.act3ScenesArray, for: act3ScenesKey, in: screenplay)
        completion?(true)
    }
    
    func saveCharacters(in screenplay: Screenplay,
                        completion: ((_ error: Error?) -> Void)? = nil) {
        // Update characters
        for character in screenplay.characters {
            if character.name == "" {
                character.name = "Unnamed"
            }
            charactersReference?.updateChildValues([character.uuid: character.characterDictionary]) { (error,reference) in
                if let _ = error {
                    completion?(error)
                }
            }
        }
    }
    
    // Save Scenes by specifying the scenes and act number
    func save(scenes: [Scene],
              for actKey: String,
              in screenplay: Screenplay,
              completion: ((_ error: Error?) -> Void)? = nil) {
        let scenesRef = currentScreenplayReference?.child(actKey)
        for scene in scenes {
            scenesRef?.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in
                if let error = error {
                    completion?(error)
                }
            }
        }
    }
    
    func delete(screenplay: Screenplay, completion: @escaping () -> Void) {
        currentScreenplayReference?.removeValue { (_, _) in
            ScreenplayController.shared.resetCurrentScreenplay()
            completion()
        }
    }
    
    func delete(character: Character, withScreenplay: Screenplay) {
        // delete character
        let characterRef = charactersReference?.child(character.uuid)
        characterRef?.removeValue()
    }

    func delete(scene: Scene, inAct: Act) {
        var sceneActKey: String = ""
        switch inAct {
        case .one:
            sceneActKey = act1ScenesKey
        case .two:
            sceneActKey = act2ScenesKey
        case .three:
            sceneActKey = act3ScenesKey
        default:
            break
        }

        let scenesRef = currentScreenplayReference?.child(sceneActKey).child(scene.uuid)
        scenesRef?.removeValue()
    }

    func save(scene: Scene?, inAct: Act) {
        guard let scene else { return }
        var sceneActKey: String = ""
        switch inAct {
        case .one:
            sceneActKey = act1ScenesKey
        case .two:
            sceneActKey = act2ScenesKey
        case .three:
            sceneActKey = act3ScenesKey
        default:
            break
        }

        let sceneActRef = currentScreenplayReference?.child(sceneActKey)
        sceneActRef?.updateChildValues([scene.uuid:scene.sceneDictionary]) { (error, reference) in }
    }
    
    func getScreenplays(completion: @escaping ([Screenplay])->Void) {
        guard let user = user else {
            completion([])
            return
        }
        self.dataBaseReference.child(usersKey)
            .child(user.uid)
            .child(screenplaysKey)
            .observeSingleEvent(of: .value) { (snapshot) in
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
        let userRef = self.dataBaseReference.child(usersKey).child(user.uid)
        
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
