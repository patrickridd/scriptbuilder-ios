//
//  ScreenplayCoverViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/25/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import MBProgressHUD
import Firebase

class ScreenplayCoverViewController: UIViewController {

    
    @IBOutlet weak var saveButton: SaveButton!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var nameLabel: UILabel!
    
    var interstitial: AmazonAdInterstitial?
    var amazonAdService: AmazonAdServiceLogic?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        amazonAdService = AmazonAdService()
        saveButton.view = self
        titleTextField.delegate = self

        if let name = Auth.auth().currentUser?.displayName {
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
        let tapGesture = UITapGestureRecognizer(target: self,
                                                action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If interstitial is not ready load one
        if !interstitialIsReady(interstitial: interstitial) {
            interstitial = amazonAdService?.loadInterstitial(for: self)
        }
        
        // Display ad if we have one loaded and we have interstitial ads enabled
        display(interstitial: interstitial)
    }
    
    // MARK: IBActions
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        // We want to remind the user to save if the screenplay has changed
        if ScreenplayController.shared.screenplayChanged {
            remindUserToSave()
        
        // Else just dismiss the view
        } else {
            dismissView()
        }
    }
    
    @IBAction func arrowButtonTapped(_ sender: Any) {
        let swipeNotificationName = Notification.Name(swipeLeftNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        self.present(deleteScreenplayAlert(), animated: true) 
    }
    
    @IBAction func shareButtonTapped(_ sender: UIButton) {
        ScreenplayController.shared.generateAndSharePdfForCurrentScreenplay { [weak self] (error, data) in
            guard let data = data else { return }

            let vc = UIActivityViewController(activityItems: [data], applicationActivities: [])

            if UIDevice.current.userInterfaceIdiom == .pad {
                vc.popoverPresentationController?.sourceView = self?.view
                vc.popoverPresentationController?.sourceRect = CGRect(x: (self?.view.bounds.width ?? 1)/2,
                                                                      y: (self?.view.bounds.height ?? 1)/2,
                                                                      width: self?.view.bounds.width ?? 50,
                                                                      height: 50)
            }
            
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Tap Gesture Recognizer
    
    @objc func dismissKeyboard() {
        titleTextField.resignFirstResponder()
    }
    
    
    // MARK: Helper Methods
    
    func deleteScreenplayAlert() -> UIAlertController {
        let screenplayTitle = ScreenplayController.shared.currentScreenplay?.title ?? "this screenplay".localized
        
        let alert = UIAlertController(title: "Delete Screenplay".localized,
                                      message: "Are you sure you want to delete %@?".localized(with: screenplayTitle),
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel".localized,
                                         style: .cancel,
                                         handler: nil)
        let deleteAction = UIAlertAction(title: "Delete".localized,
                                         style: .destructive) { (_) in
            if let screenplay = self.screenplay {
                // Delete currentScreenplay
                FirebaseController.shared.delete(screenplay: screenplay,
                                                 completion: {
                    self.dismiss(animated: true,
                                 completion: nil)
                })
            }
            self.dismiss(animated: true,
                         completion: nil)
        }
        alert.addAction(cancelAction)
        alert.addAction(deleteAction)
        return alert
    }
    
    func remindUserToSave() {
        let saveReminderAlert = UIAlertController(title: "Save".localized,
                                                  message: "Would you like to save your work?".localized,
                                                  preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save".localized,
                                       style: .default) { [weak self] (_) in
            self?.saveButton.save()
            self?.dismissView()
        }
        let nopeAction = UIAlertAction(title: "Discard".localized,
                                       style: .destructive) { [weak self] (_) in
            ScreenplayController.shared.discardChangesInCurrentScreenplay()
            self?.dismissView()
        }
        
        
        saveReminderAlert.addAction(saveAction)
        saveReminderAlert.addAction(nopeAction)
        self.present(saveReminderAlert,
                     animated: true,
                     completion: nil)
    }
    
    func dismissView() {
        ScreenplayController.shared.resetCurrentScreenplay()
        if let _ = self.presentingViewController {
            self.dismiss(animated: true, completion: nil)
            return
        }
        self.navigateToScreenplayCollectionView()
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
            screenplay?.title = "Untitled".localized
            return
        }
        screenplay?.title = title
    }
}
