//
//  Scene.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

class Scene {
    
    var header: String = ""
    var sceneNumber: String = "1"
    
    var title: String = ""
    var sceneDescription: String = ""
    var dialogue: String = ""
    var action: String = ""
    var characters: String = ""
    var howPushesStory: String = ""
    var notes: String = ""
    
    static var sceneTitles: [String] {
        return ["Scene Description",
                "Dialogue",
                "Action",
                "Characters",
                "Story Progression",
                "Notes"]
    }
    
    static var sceneSubtitles: [String] {
        return ["Overall idea of what happens and feeling the scene bring",
            "What snappy dialogue and/or information is said?",
            "What are your characters doing?",
            "Which characters are in the scene?",
            "How does the scene move the story forward?",
            "Details you don't want to forget"]
    }
}
