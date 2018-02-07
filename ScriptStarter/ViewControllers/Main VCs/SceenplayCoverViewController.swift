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
import MBProgressHUD

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

        if let name = Auth.auth().currentUser?.displayName {
            self.nameLabel.text = name
        }

        if let screenplay = screenplay {
            // Set title of existing screenplay
            self.titleTextField.text = screenplay.title
        } else {
            // Create new screenplay
            let newScreenplay = Screenplay(title: "")
            ScreenplayController.shared.set(currentScreenplay: newScreenplay)
            self.titleTextField.becomeFirstResponder()
        }
        
        // Setup Tap Gesture to dismiss keyboard
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
       
        // Create Interstitial Ad
       // interstitial = createAndLoadInterstitial()
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
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.annularDeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving"
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay, completion: { (success) in
                DispatchQueue.main.async {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success"
                        loadingNotification.hide(animated: true, afterDelay: 1)
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed"
                    loadingNotification.hide(animated: true, afterDelay: 1)
                }
            })
        }
    }
    
    // MARK: Tap Gesture Recognizer
    
    @objc func dismissKeyboard() {
        titleTextField.resignFirstResponder()
    }

    // MARK: GADInterstitialDelegate Methods
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-1297096402264538/6489865275")
        
        guard let interstitial = interstitial else {
            return nil
        }
        
        let request = GADRequest()
        // TODO: Remove the following line before you upload the app
        request.testDevices = [kGADSimulatorID]
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
