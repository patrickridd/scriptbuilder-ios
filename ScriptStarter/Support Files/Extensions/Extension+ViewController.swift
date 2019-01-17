//
//  Extension+ViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD

extension UIViewController: UITextFieldDelegate {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    func saveScreenplay() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
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
    
    
    func getDescriptionCellHeight(with text:String) -> CGFloat {
        let aproximateWidthOfCell = self.view.frame.width // Minus 50 for the leading and trailing margins
        let descriptionSize = CGSize(width: aproximateWidthOfCell,
                                     height: 1000)
        let font = UIFont.systemFont(ofSize: 17,
                                     weight: UIFont.Weight.regular)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 1
        
        let estimatedDescriptionHeight = NSString(string: text).boundingRect(with: descriptionSize,
                                                                             options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font:font, NSAttributedString.Key.paragraphStyle:paragraphStyle],
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
        toolBar.tintColor = UIColor.screenLightBlue// UIColor(red: 76 / 255, green: 217 / 255, blue: 100 / 255, alpha: 1)
//        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(donePressed))
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "downArrowButtonAsset 1"), landscapeImagePhone: nil, style: .done, target: self, action: #selector(donePressed))
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelPressed))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, doneButton], animated: false)
        
        toolBar.isUserInteractionEnabled = true
        toolBar.sizeToFit()
        
        textField.delegate = self
        textField.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
        self.navigationController?.view.endEditing(true)
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
                UIApplication.shared.keyWindow?.rootViewController = loginViewController
                self.dismiss(animated: false, completion: nil)
            }
        }
    }
    
    func navigateToScreenplayCollectionView() {
        DispatchQueue.main.async {
            let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
            
            guard let mainNavigationController = mainStoryboard.instantiateViewController(withIdentifier: "screenplayNavigationController") as? UINavigationController else {
                return
            }
            UIApplication.shared.keyWindow?.rootViewController = mainNavigationController
            self.dismiss(animated: true, completion: nil)
        }
    }
    
}
