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

class SceenplayCoverViewController: UIViewController, UITextFieldDelegate {

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

    override func viewWillAppear(_ animated: Bool) {
        if let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.backgroundColor = UIColor.white
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
    
    
    //    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//       // CGPoint velocity = [gestureRecognizer velocityInView:yourView];
//        let velocity = sender.velocity(in: view)
//        if velocity.x > 0 || velocity.x < 0 {
//            return
//        }
////        if(velocity.x > 0)
////        {
////            NSLog(@"gesture went right");
////        }
////        else
////        {
////            NSLog(@"gesture went left");
////        }
//
//        switch sender.state {
//        case .began:
//            hero_dismissViewController()
//        case .changed:
//            let translation = sender.translation(in: nil)
//            let progress = translation.y / 2 / view.bounds.height
//            Hero.shared.update(progress)
//        default:
//            Hero.shared.finish()
//        }
//    }
    
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        
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
