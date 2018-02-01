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
import GoogleMobileAds

class SceenplayCoverViewController: UIViewController, UITextFieldDelegate, GADInterstitialDelegate {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    var interstitial: GADInterstitial?
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self
        
        // Create Interstitial Ad
        interstitial = createAndLoadInterstitial()
        
        if let screenplay = screenplay {
            // Set title of existing screenplay
            self.titleTextField.text = screenplay.title
        } else {
            // Create new screenplay
            let newScreenplay = Screenplay(title: "Untitled")
            ScreenplayController.shared.set(currentScreenplay: newScreenplay)
        }
        
        if let name = Auth.auth().currentUser?.displayName {
            self.nameLabel.text = name
        }
    }

    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        ScreenplayController.shared.resetCurrentScreenplay()
        hero_dismissViewController()
    }
    
    @IBAction func arrowButtonTapped(_ sender: Any) {
        let swipeNotificationName = Notification.Name(swipeLeftNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
        
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        ScreenplayController.shared.saveCurrentScreenplay()
    }
    
    
    // MARK: GADInterstitialDelegate Methods
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Interstitial loaded successfully")
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-8501671653071605/2568258533")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // Remove the following line before you upload the app
        request.testDevices = [ kGADSimulatorID ]
        interstitial.load(request)
        interstitial.delegate = self
        
        return interstitial
    }
    
    // MARK: UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }

    @IBAction func titleTextFieldDidChange(_ sender: Any) {
        guard let title = titleTextField.text, title != "" else { return }
        screenplay?.title = title
    }
}
