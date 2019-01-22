//
//  ScreenplayCoverViewController.swift
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
import Firebase

class ScreenplayCoverViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    var interstitial: GADInterstitial?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleTextField.delegate = self

        if let name = FIRAuth.auth()?.currentUser?.displayName {
            self.nameLabel.text = name
        }

        if let screenplay = self.screenplay {
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
        if let _ = self.presentingViewController {
            hero.dismissViewController()
            return
        }
        self.navigateToScreenplayCollectionView()
    }
    
    @IBAction func arrowButtonTapped(_ sender: Any) {
        let swipeNotificationName = Notification.Name(swipeLeftNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let loadingNotification = MBProgressHUD.showAdded(to: view,
                                                          animated: true)
        loadingNotification.mode = MBProgressHUDMode.annularDeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving"
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay,
                                           completion: { (success) in
                DispatchQueue.main.async {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success"
                        loadingNotification.hide(animated: true,
                                                 afterDelay: 1)
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed"
                    loadingNotification.hide(animated: true,
                                             afterDelay: 1)
                }
            })
        }
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.present(deleteScreenplayAlert(), animated: true) 
    }
    
    // MARK: Tap Gesture Recognizer
    
    @objc func dismissKeyboard() {
        titleTextField.resignFirstResponder()
    }
    
    
    // MARK: Helper Methods
    
    func deleteScreenplayAlert() -> UIAlertController {
        let screenplayTitle = ScreenplayController.shared.currentScreenplay?.title ?? "this screenplay"
        
        let alert = UIAlertController(title: "Delete Screenplay", message: "Are you sure you want to delete \(screenplayTitle)", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            if let screenplay = self.screenplay {
                // Delete currentScreenplay
                FirebaseController.shared.delete(screenplay: screenplay, completion: {
                    self.dismiss(animated: true, completion: nil)
                })
            }
            self.dismiss(animated: true, completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        return alert
    }

    // MARK: GADInterstitialDelegate Methods
    
    private func createAndLoadInterstitial() -> GADInterstitial? {
        interstitial = GADInterstitial(adUnitID: GoogleAds.interstitialAdUnitId)
        
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
}

extension ScreenplayCoverViewController: GADInterstitialDelegate {
    
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        ad.present(fromRootViewController: self)
    }
    
    func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
}

// Mark UITextField Methods
extension ScreenplayCoverViewController {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func titleTextFieldDidChange(_ sender: Any) {
        guard let title = titleTextField.text, title != "" else {
            screenplay?.title = "Untitled"
            return
        }
        screenplay?.title = title
    }
}
