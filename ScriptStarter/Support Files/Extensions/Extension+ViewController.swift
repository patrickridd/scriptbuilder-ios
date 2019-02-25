//
//  Extension+ViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/8/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD
import GoogleMobileAds

extension UIViewController: UITextFieldDelegate, UITextViewDelegate {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    var shouldDisplayInterstitials: Bool {
        let shouldDisplayInterstitial = UserDefaults.standard.bool(forKey: Constants.shouldDisplayInterstitial)
        
        // Should display interstitial if user defaults is stored as true and if they havent purchased the IAP
        return (shouldDisplayInterstitial && InAppPurchases.shouldDisplayAds)
    }
    
    func saveScreenplay() {
        let loadingNotification = MBProgressHUD.showAdded(to: self.view,
                                                          animated: true)
        loadingNotification.mode = MBProgressHUDMode.indeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving".localized
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay, completion: { (success) in
                DispatchQueue.main.async {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success".localized
                        loadingNotification.hide(animated: true,
                                                 afterDelay: 1)
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed".localized
                    loadingNotification.hide(animated: true,
                                             afterDelay: 1)
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
        toolBar.tintColor = UIColor.screenLightBlue
        let doneButton = UIBarButtonItem(image: #imageLiteral(resourceName: "downArrowButtonAsset 1"),
                                         landscapeImagePhone: nil,
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
        toolBar.barStyle = .black
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.screenLightBlue
        
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
        
        textView.delegate = self
        textView.inputAccessoryView = toolBar
    }
    
    @objc func donePressed() {
        self.view.endEditing(true)
        self.navigationController?.view.endEditing(true)
        switch self {
        case is EnlargedDescriptionTableViewController:
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
                UIApplication.shared.keyWindow?.rootViewController = loginViewController
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
            UIApplication.shared.keyWindow?.rootViewController = mainNavigationController
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
}

extension UIViewController: GADInterstitialDelegate {
    
    // Helper methods
    
    func createAndLoadInterstitial() -> GADInterstitial? {
       
        let interstitial = GADInterstitial(adUnitID: GoogleAds.interstitialAdUnitId)
        interstitial.delegate = self
        
        let request = GADRequest()
        
        #if DEBUG
        request.testDevices = [kGADSimulatorID]
        #endif
        
        interstitial.load(request)
        
        return interstitial
    }
    
    func display(interstitial: GADInterstitial?) {
        if shouldDisplayInterstitials, InAppPurchases.shouldDisplayAds {
            if let interstitial = interstitial {
                if interstitial.isReady {
                    DispatchQueue.main.async {
                        interstitial.present(fromRootViewController: self)
                    }
                }
            }
        }
    }
    
    // Delegate Methods
    
    private func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("Did receive interstitial")
    }
    
    private func interstitialDidFail(toPresentScreen ad: GADInterstitial) {
        print("Fail to receive interstitial")
    }
    
    public func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        setShouldDisplayInterstitial(state: false)
        scheduleInterstitialStateToTrue()
    }
}


// MARK: Interstitial Ad State methods
extension UIViewController {
    
    func setShouldDisplayInterstitial(state: Bool) {
        UserDefaults.standard.set(state,
                                  forKey: Constants.shouldDisplayInterstitial)
    }
    
    func interstitialIsReady(interstitial: GADInterstitial?) -> Bool {
        if let interstitial = interstitial {
            return interstitial.isReady
        } else {
            return false
        }
    }
    
    func rewardBasedAdReady(rewardBasedAd: GADRewardBasedVideoAd?) -> Bool {
        if let rewardBasedAd = rewardBasedAd {
            return rewardBasedAd.isReady
        } else {
            return false
        }
    }
    
    @objc func enableInterstitialDisplay() {
        setShouldDisplayInterstitial(state: true)
    }
    
    func scheduleInterstitialStateToTrue() {
        // Set timer to change enable interstitial ads every 5 minutes
        Timer.scheduledTimer(timeInterval:60*5,
                             target: self,
                             selector: #selector(enableInterstitialDisplay),
                             userInfo: nil,
                             repeats: false)
    }
}


extension UIViewController: GADRewardBasedVideoAdDelegate {
    
    public func rewardBasedVideoAd(_ rewardBasedVideoAd: GADRewardBasedVideoAd,
                            didRewardUserWith reward: GADAdReward) {
        self.rewardUserWithSceneBuilder()
        self.rewardUserWithCharacterBuilder()
    }
    
    // Reward Based Ad - Character Builder helper methods
    
    func scheduleTimerForCharacterBuilderReward() {
        Timer.scheduledTimer(timeInterval: 10*60,
                             target: self,
                             selector: #selector(expireCharacterBuilderReward),
                             userInfo: nil,
                             repeats: false)
    }
    
    @objc func expireCharacterBuilderReward() {
        UserDefaults.standard.set(false,
                                  forKey: Constants.characterBuilderRewardEnabled)
    }
    
    func rewardUserWithCharacterBuilder() {
        UserDefaults.standard.set(true,
                                  forKey: Constants.characterBuilderRewardEnabled)
        scheduleTimerForCharacterBuilderReward()
    }
    
    func characterBuilderRewarded() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.characterBuilderRewardEnabled)
    }
    
    // Reward Based Ad - Scene Builder helper methods
    
    func scheduleTimerForSceneBuilderReward() {
        Timer.scheduledTimer(timeInterval: 10*60,
                             target: self,
                             selector: #selector(expireSceneBuilderReward),
                             userInfo: nil,
                             repeats: false)
    }
    
    @objc func expireSceneBuilderReward() {
        UserDefaults.standard.set(false,
                                  forKey: Constants.sceneBuilderTrialType)
    }
    
    func rewardUserWithSceneBuilder() {
        UserDefaults.standard.set(true,
                                  forKey: Constants.sceneBuilderTrialType)
        scheduleTimerForSceneBuilderReward()
    }
    
    func sceneBuilderRewardEnabled() -> Bool {
        return UserDefaults.standard.bool(forKey: Constants.sceneBuilderTrialType)
    }
}
