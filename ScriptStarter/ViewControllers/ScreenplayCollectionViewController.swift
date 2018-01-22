//
//  ScreenplayCollectionViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ScreenplayCollectionViewController: UIViewController, UITextFieldDelegate {

    var screenplays = [Screenplay]()
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var screenplayView: UIView!
    @IBOutlet weak var authorTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        authorTextField.delegate = self
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        // Enlarge new screenplay if none exist
        if screenplays.count == 0 {
            enlargeNewScreenplay()
        }
    }
    
    func enlargeNewScreenplay() {
        self.screenplayView.alpha = 1.0
        self.screenplayView.layer.borderColor = UIColor.blue.cgColor
        self.screenplayView.layer.borderWidth = 1.0
        let when = DispatchTime.now() + 1 // change 2 to desired number of seconds
        DispatchQueue.main.asyncAfter(deadline: when) {
            // Your code with delay
            self.titleTextField.becomeFirstResponder()
        }
    }
    
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField {
        case titleTextField:
            authorTextField.becomeFirstResponder()
        default:
            titleTextField.resignFirstResponder()
            authorTextField.resignFirstResponder()
        }
        return true
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
