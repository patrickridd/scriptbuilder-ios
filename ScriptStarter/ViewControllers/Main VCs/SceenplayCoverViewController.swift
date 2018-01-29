//
//  SceenplayCoverViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/25/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import Hero

class SceenplayCoverViewController: UIViewController, UITextFieldDelegate, HeroViewControllerDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.heroID = "screenplay"
        titleTextField.delegate = self
        
        if let name = Auth.auth().currentUser?.displayName {
            self.nameLabel.text = name
        }
    }

    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        hero_dismissViewController()
    }
    
    @IBAction func arrowButtonTapped(_ sender: Any) {
        let swipeNotificationName = Notification.Name(swipeLeftNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    

    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    
    // MARK: HeroViewControllerDelegate Methods
    
    func heroDidEndTransition() {
        
    }

}
