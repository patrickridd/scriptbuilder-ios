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
import Firebase

protocol InAppPurchaseDelegate: class {
    func didCompleteTransaction(for productIdentifier: String?,
                                with error: Error?,
                                displayLoadingImage: Bool)
    func startingTransaction()
}

class SettingsTableViewController: UITableViewController {

    var loadingNotification = MBProgressHUD()
    var screenplays: [Screenplay] = []
    
    var user: Firebase.User? {
        return Auth.auth().currentUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        self.view.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.separatorColor = Theme.tableViewBackgroundColor
        tableView.tableHeaderView = UIView(frame: CGRect(origin: .zero, size: CGSize(width: 0.0, height: CGFloat.leastNormalMagnitude)))
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        view.backgroundColor = Theme.tableViewBackgroundColor
        tableView.backgroundColor = Theme.tableViewBackgroundColor
        tableView.separatorColor = Theme.tableViewBackgroundColor
        tableView.reloadData()
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.label,
                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                         weight: UIFont.Weight.light)]
        navigationController?.navigationBar.tintColor = Theme.scriptBuilderUIColor
        navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        navigationController?.navigationBar.titleTextAttributes = attributes
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .systemBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        self.title = "Settings".localized
    }
    
    // MARK: UI Methods
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view,
                                        animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool, displayImage: Bool = true, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            if !displayImage {
                self.loadingNotification.hide(animated: true)
                completion?()
                return
            }
            
            self.loadingNotification.mode = .customView
            if success {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success".localized
                self.loadingNotification.hide(animated: true,
                                              afterDelay: 1)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed".localized
                self.loadingNotification.hide(animated: true,
                                              afterDelay: 1)
                completion?()
            }
        }
    }
        
    func presentDeleteAccountConfirmation(completion: @escaping (_ deleted: Bool,_ canceled: Bool) -> ()) -> UIAlertController {
        let alert = UIAlertController(title: "Delete Account".localized,
                                      message: "Are you sure you want to delete your account?".localized,
                                      preferredStyle: .alert)
        let deleteAction = UIAlertAction(title: "Delete".localized,
                                         style: .destructive) { (_) in
            self.showActivityIndicator()
            FirebaseController.shared.deleteAccount(completion: { [weak self] (deleted) in
                self?.hideActivityIndicator(success: true,
                                            completion: nil)
                completion(deleted,false)
            })
        }
        let cancelAction = UIAlertAction(title: "Cancel".localized,
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
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let personalInfoCell = tableView.dequeueReusableCell(withIdentifier: "personalCell",
                                                                 for: indexPath) as? PersonalInfoTableViewCell
            personalInfoCell?.updateCell(with: user, and: screenplays)
            personalInfoCell?.backgroundColor = Theme.secondarySystemBackground
            return personalInfoCell ?? UITableViewCell()
        case 1:
           let interfaceStyleTableViewCell = tableView.dequeueReusableCell(withIdentifier:"InterfaceStyleTableViewCell",
                                                                        for: indexPath) as? InterfaceStyleTableViewCell
            interfaceStyleTableViewCell?.backgroundColor = Theme.secondarySystemBackground
            return interfaceStyleTableViewCell ?? UITableViewCell()
        case 2:
            let changePasswordCell = tableView.dequeueReusableCell(withIdentifier: "changePasswordCell",
                                                                   for: indexPath) as? ChangePasswordTableViewCell
           
            changePasswordCell?.changeButton.addTarget(self,
                                                      action: #selector(changePasswordButtonTapped),
                                                      for: .touchUpInside)
            changePasswordCell?.backgroundColor = Theme.secondarySystemBackground
            return changePasswordCell ?? UITableViewCell()
        case 3:
            let shareAppCell = tableView.dequeueReusableCell(withIdentifier: "shareAppCell",
                                                             for: indexPath) as? ShareTableViewCell
            shareAppCell?.backgroundColor = Theme.secondarySystemBackground
            return shareAppCell ?? UITableViewCell()
        case 4:
            let deleteCell = tableView.dequeueReusableCell(withIdentifier: "deleteAccountCell",
                                                           for: indexPath) as? DeleteAccountTableViewCell
            deleteCell?.backgroundColor = Theme.secondarySystemBackground
            return deleteCell ?? UITableViewCell()
        case 5:
            let legalCell = tableView.dequeueReusableCell(withIdentifier: "legalCell",
                                                            for: indexPath) as? LegalTableViewCellCell
            legalCell?.backgroundColor = Theme.tableViewBackgroundColor
            return legalCell ?? UITableViewCell()
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
        
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 15
        case 5:
            return 5
        default:
            return 45
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 130
        case 1:
            return 60
        case 5:
            // LegalTableViewCellCell
            return 80
        default:
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = Theme.tableViewBackgroundColor
        return footer
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        
        sectionHeader.sectionLabel.font = UIFont.systemFont(ofSize: 14,
                                                            weight: .light)
        sectionHeader.moreButton.isHidden = true
        sectionHeader.contentView.backgroundColor = Theme.tableViewBackgroundColor
        sectionHeader.sectionLabel.trailingAnchor.constraint(equalTo: sectionHeader.trailingAnchor,
                                                             constant: -10).isActive = true
        switch section {
        case 0:
            sectionHeader.sectionLabel.text = ""
        case 1:
            sectionHeader.sectionLabel.text = "Interface Style".localized
        case 2:
            sectionHeader.sectionLabel.text = "Change Password - if signed up via email & password".localized
        case 3:
            sectionHeader.sectionLabel.text = "Share with family & friends".localized
        case 4:
            sectionHeader.sectionLabel.text = "This will remove all information in database".localized
        case 5:
            sectionHeader.sectionLabel.text = ""
        default:
            break
        }
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 3:
            // MARK: - Share App
            DispatchQueue.main.async {
                if let link = URL(string: "https://itunes.apple.com/us/app/scriptbuilder/id1358448790?ls=1&mt=8") {
                    let message = "Build your Screenplay outline".localized
                    let objectsToShare = [message,link] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare,
                                                              applicationActivities: nil)
                    if UIDevice.current.userInterfaceIdiom == .pad {
                        activityVC.popoverPresentationController?.sourceView = self.view
                        activityVC.popoverPresentationController?.sourceRect = CGRect(
                            x: (self.view.bounds.width)/2,
                            y: (self.view.bounds.height)/2,
                            width: self.view.bounds.width,
                            height: 50
                        )
                    }
                    self.present(activityVC, animated: true) {
                                    self.tableView.deselectRow(at: indexPath,
                                                               animated: true)
                     }
                }
            }
        case 4:
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
                }, animated: true,
                   completion: nil)
            }
        }), animated: true,
            completion: nil)
        default:
            break
        }
    }
}


extension SettingsTableViewController: InAppPurchaseDelegate {

    func didCompleteTransaction(for productIdentifier: String?,
                                with error: Error?,
                                displayLoadingImage: Bool = true) {
        tableView.reloadData()
        if let error = error {
            hideActivityIndicator(success: false,
                                  displayImage: displayLoadingImage) {
                self.present(error: error)
            }
        } else {
            hideActivityIndicator(success: true,
                                  displayImage: displayLoadingImage)
        }
    }
    
    func startingTransaction() {
        self.showActivityIndicator()
    }
    
}
