//
//  SettingsTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD
import StoreKit
import GoogleMobileAds

protocol InAppPurchaseDelegate: class {
    func didCompleteTransaction(for productIdentifier: String,
                                with error: Error?,
                                displayLoadingImage: Bool)
    func startingTransaction()
}

class SettingsTableViewController: UITableViewController {
    
    var interstitial: GADInterstitial?
    var loadingNotification = MBProgressHUD()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        self.view.backgroundColor = UIColor.screenLightGray
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = UIColor.screenLightGray
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If interstitial is not ready load one
        if !interstitialIsReady(interstitial: interstitial) {
            interstitial = createAndLoadInterstitial()
        }
        
        // Display ad if we have one loaded and we have interstitial ads enabled
        display(interstitial: interstitial)
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.screenDark,
                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                         weight: UIFont.Weight.light)]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
        self.title = "Settings"
    }
    
    // MARK: UI Methods
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view,
                                        animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading"
        }
    }
    
    func hideActivityIndicator(success: Bool, displayImage: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            
            if !displayImage {
                self.loadingNotification.hide(animated: true)
                completion?()
                return
            }
            
            self.loadingNotification.mode = .customView
            if success {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success"
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed"
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                completion?()
            }
        }
    }
        
    func presentDeleteAccountConfirmation(completion: @escaping (_ deleted: Bool,_ canceled: Bool) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Account",
                                      message: "Are you sure you want to delete your account?",
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete",
                                         style: .destructive) { (_) in
            self.showActivityIndicator()
            FirebaseController.shared.deleteAccount(completion: { [weak self] (deleted) in
                self?.hideActivityIndicator(success: true,
                                            completion: nil)
                completion(deleted,false)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel) { (_) in
            completion(false, true)
        }
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    
    
    // MARK: - IBActions && Target Methods
    
    @IBAction func downButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func changePasswordButtonTapped() {
        self.view.endEditing(true)
        let indexPath = IndexPath(row: 0, section: 1)
        guard let changePasswordCell = self.tableView.cellForRow(at: indexPath) as? ChangePasswordTableViewCell, let newPassword = changePasswordCell.newPasswordTextField.text else { return }
        showActivityIndicator()
        FirebaseController.shared.changePassword(to: newPassword) { [weak self] (success) in
            DispatchQueue.main.async {
                self?.hideActivityIndicator(success: success, completion: {
                    if success {
                        
                    } else {

                    }
                })
            }
        }
    }
    
    
    // MARK: - UITableView DataSource and Delegate Methods
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
           let inAppPurchaseCell = tableView.dequeueReusableCell(withIdentifier:"inAppPurchaseCell",
                                                                        for: indexPath) as? IAPTableViewCell
           inAppPurchaseCell?.purchaseButtonHandler = { [weak self] product in
                InAppPurchases.store.delegate = self
                InAppPurchases.store.buyProduct(product)
           }
           
           inAppPurchaseCell?.restoreButtonHandler = { [weak self] product in
                InAppPurchases.store.delegate = self
                InAppPurchases.store.restorePurchases()
           }
           
            inAppPurchaseCell?.setPurchasedUI()
            return inAppPurchaseCell ?? UITableViewCell()
        case 1:
            let changePasswordCell = tableView.dequeueReusableCell(withIdentifier: "changePasswordCell",
                                                                   for: indexPath) as? ChangePasswordTableViewCell
           
            changePasswordCell?.changeButton.addTarget(self,
                                                      action: #selector(changePasswordButtonTapped),
                                                      for: .touchUpInside)
            return changePasswordCell ?? UITableViewCell()
        case 2:
            let shareAppCell = tableView.dequeueReusableCell(withIdentifier: "shareAppCell",
                                                             for: indexPath) as? ShareTableViewCell
            return shareAppCell ?? UITableViewCell()
        case 3:
            let deleteCell = tableView.dequeueReusableCell(withIdentifier: "deleteAccountCell",
                                                           for: indexPath) as? DeleteAccountTableViewCell
            return deleteCell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 90
        default:
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.screenLightGray
        return footer
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        
        sectionHeader.sectionLabel.font = UIFont.systemFont(ofSize: 14,
                                                            weight: .light)
        sectionHeader.moreButton.isHidden = true
        sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
        
        switch section {
        case 0:
            sectionHeader.sectionLabel.text = "Remove Banner & Interstitial Ads"
        case 1:
            sectionHeader.sectionLabel.text = "Change Password - if signed up via email & password"
        case 2:
            sectionHeader.sectionLabel.text = "Share with family & friends"
        case 3:
            sectionHeader.sectionLabel.text = "This will remove all information in database"
        default:
            break
        }
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 2:
            // MARK: - Share App
            DispatchQueue.main.async {
                if let link = NSURL(string: "https://itunes.apple.com/us/app/payraise/id1281621920?ls=1&mt=8") {
                    let message = "Check out Script Builder"
                    let objectsToShare = [message,link] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
                    self.present(activityVC, animated: true) {
                                    self.tableView.deselectRow(at: indexPath,
                                                               animated: true)
                     }
                }
            }

            break
        case 3:
            // MARK: - Delete Account
        self.present(self.presentDeleteAccountConfirmation(completion: { [weak self] (deleted, canceled) in
                
            DispatchQueue.main.async {
                self?.tableView.deselectRow(at: indexPath,
                                            animated: true)
                if canceled {
                    return
                }
                
                self?.present(UIAlertControllers.accountDeleted {
                    guard let dismissingViewController = self?.presentingViewController?.presentingViewController else {
                        self?.navigateToLoginViewController()
                        return
                    }
                    dismissingViewController.dismiss(animated: true,
                                                     completion: nil)
                }, animated: true, completion: nil)
            }
        }), animated: true, completion: nil)
        default:
            break
        }
    }
    
}


extension SettingsTableViewController: InAppPurchaseDelegate {

    func didCompleteTransaction(for productIdentifier: String,
                                with error: Error?,
                                displayLoadingImage: Bool = true) {
        tableView.reloadData()
        if let error = error {
            hideActivityIndicator(success: false, displayImage: displayLoadingImage) {
                self.present(error: error)
            }
        } else {
            hideActivityIndicator(success: true, displayImage: displayLoadingImage)
        }
    }
    
    func startingTransaction() {
        self.showActivityIndicator()
    }
    
}
