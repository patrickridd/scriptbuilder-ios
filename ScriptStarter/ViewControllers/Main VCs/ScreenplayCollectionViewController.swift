//
//  ScreenplayCollectionViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ScreenplayCollectionViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var screenplayView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var screenplays = [Screenplay]()
   
    var user: User? {
        return Auth.auth().currentUser
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        if let name = Auth.auth().currentUser?.displayName {
             self.nameLabel.text = name
        }
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        self.title = "Screenplays"
        
        // Enlarge new screenplay if none exist
        if screenplays.count == 0 {
            enlargeNewScreenplay()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func logoutButtonTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
        } catch let error {
            print(error)
        }
        
        FBSDKLoginManager().logOut()
        self.dismiss(animated: true, completion: nil)
    }
    
    func enlargeNewScreenplay() {
        self.screenplayView.alpha = 1.0
        self.screenplayView.layer.borderColor = UIColor.screenLightBlue.cgColor
        self.screenplayView.layer.borderWidth = 2.0
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
           // self.titleTextField.becomeFirstResponder()
        }
    }
    
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        
        return true
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        self.navigationController?.navigationBar.topItem?.title = ""
        self.navigationController?.navigationBar.tintColor = UIColor.screenLightBlue
        self.navigationController?.navigationBar.backgroundColor = UIColor.screenDark
    }


}
