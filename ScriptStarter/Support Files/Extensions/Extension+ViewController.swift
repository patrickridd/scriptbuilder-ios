//
//  Extension+ViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD
import SwiftUI

extension UIViewController: @retroactive UIScrollViewDelegate {}
extension UIViewController: @retroactive UITextFieldDelegate, @retroactive UITextViewDelegate {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }

    func setSaveTimer() {
        _ = Timer.scheduledTimer(
            withTimeInterval: 2.0,
            repeats: false, block: { _ in
                NotificationCenter.default.post(name: Notification.Name.ScreenplayUpdated, object: nil)
            })
    }

    @objc func saveCurrentScreenplay() {
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay)
        }
    }
    
    func saveScreenplay(completion: @escaping () -> Void) {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving".localized
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay, completion: { (success) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success".localized
                        loadingNotification.hide(animated: true,
                                                 afterDelay: 1)
                        completion()
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed".localized
                    loadingNotification.hide(animated: true,
                                             afterDelay: 1)
                    completion()
                })
            })
        }
    }
    
    func reloadScreenplaysWithAnimation(completion: @escaping ()-> Void) {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view,
                                                          animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "Reloading Screenplay".localized
        
        FirebaseController.shared.getScreenplays { (screenplays) in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {
                
                guard
                    let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays)
                else {
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed".localized
                    loadingNotification.hide(animated: true,
                                             afterDelay: 1)
                    self.navigateToScreenplayCollectionView()
                    completion()
                    return
                }
                
                loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                loadingNotification.label.text = "success".localized
                loadingNotification.hide(animated: true,
                                         afterDelay: 1)
                ScreenplayController.shared.set(currentScreenplay: screenplay)
                print("Screenplay reloaded ⬇︎")
                completion()
            })
        }
    }
    
    @objc func reloadScreenplays() {
        FirebaseController.shared.getScreenplays { (screenplays) in
            if let screenplay = ScreenplayController.shared.getCachedScreenplay(screenplays: screenplays) {
                DispatchQueue.main.async {
                    ScreenplayController.shared.set(currentScreenplay: screenplay)
                }
            }
        }
    }
    
    func getDescriptionCellHeight(with text: String) -> CGFloat {
        let aproximateWidthOfCell = self.view.frame.width // Minus 50 for the leading and trailing margins
        let descriptionSize = CGSize(width: aproximateWidthOfCell,
                                     height: 1000)
        let font = UIFont.systemFont(ofSize: 17,
                                     weight: UIFont.Weight.regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        
        let attributes = [NSAttributedString.Key.font:font,
                          NSAttributedString.Key.paragraphStyle:paragraphStyle]
        let estimatedDescriptionHeight = NSString(string: text).boundingRect(with: descriptionSize,
                                                                             options: .usesLineFragmentOrigin,
                                                                             attributes: attributes,
                                                                             context: nil).height
        if estimatedDescriptionHeight < getDefaultHeightOfCell() {
            return getDefaultHeightOfCell()
        } else {
            return estimatedDescriptionHeight
        }
    }
    
    func getDefaultHeightOfCell() -> CGFloat {
        if self.view.frame.height >= 670 {
            return self.view.frame.height * (1/7)
        } else {
            return self.view.frame.height * (1/7.5)
        }
    }
    
    // UITextField Toolbar
    func addToolBar(textField: UITextField) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.scriptBuilderUIColor
        let doneButton = UIBarButtonItem(title: "Done".localized,
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        toolBar.setItems([spaceButton, doneButton],
                         animated: false)
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    // UITextField UITextView
    func addToolBar(textView: UITextView) {
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = Theme.scriptBuilderUIColor
        
        let doneButton = UIBarButtonItem(title: "Done".localized,
                                         style: .done,
                                         target: self,
                                         action: #selector(donePressed))
        doneButton.tintColor = Theme.descriptionTextColor
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                          target: nil,
                                          action: nil)
        toolBar.setItems([spaceButton, doneButton],
                         animated: false)
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
        self.navigationController?.view.endEditing(true)
        switch self {
        case is EnlargedDescriptionViewController:
            dismiss(animated: true,
                    completion: nil)
        default:
            break
        }
    }
    
    @objc func cancelPressed() {
        self.view.endEditing(true) // or do something
    }
    
    // MARK: Navigation
    
    func navigateToLoginViewController() {
        // Present the main view
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
            if let loginViewController = mainStoryboard.instantiateViewController(withIdentifier: "loginVC") as? LoginViewController {
                UIApplication.shared.mainWindow?.rootViewController = loginViewController
                self.dismiss(animated: false,
                             completion: nil)
            }
        }
    }

    func navigateToScreenplayCollectionView() {
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else {
                return
            }
            UIApplication.shared.mainWindow?.rootViewController = mainNavigationController
            self.dismiss(animated: true,
                         completion: nil)
        }
    }

    // MARK: UIAlertControllers
    func present(error: Error) {
        let alert = UIAlertController(title: "Error".localized,
                                      message: error.localizedDescription,
                                      preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK".localized,
                                     style: .default,
                                     handler: nil)
        alert.addAction(okAction)
        self.present(alert,
                     animated: true,
                     completion: nil)
    }

    // Presents InAppPurchase screen to select Subscriptions or Lifetime purchase
    func presentIAPSubscriptionView() {
        let iapSubscriptionViewController = UIHostingController(rootView: IAPSubscriptionView(presentingViewController: self))
        if UIDevice.current.userInterfaceIdiom != .phone {
            iapSubscriptionViewController.modalPresentationStyle = .fullScreen
        }
        present(iapSubscriptionViewController, animated: true)
    }
}
