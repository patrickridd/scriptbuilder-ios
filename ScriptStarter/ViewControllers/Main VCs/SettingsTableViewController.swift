//
//  SettingsTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        self.view.backgroundColor = UIColor.screenLightGray
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = UIColor.screenLightGray
    }
    
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.screenDark, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: UIFont.Weight.light)]
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
        self.title = "Settings"
    }
    
    
    // MARK: - IBActions && Target Methods
    
    @IBAction func downButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func restoreButtonTapped() {
        
    }
    
    @objc func purchaseButtonTapped() {
        
    }
    
    @objc func changePasswordButtonTapped() {
        
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
            guard let inAppPurchaseCell = tableView.dequeueReusableCell(withIdentifier:"inAppPurchaseCell", for: indexPath) as? IAPTableViewCell else {
                return UITableViewCell()
            }
            return inAppPurchaseCell
        case 1:
            guard let changePasswordCell = tableView.dequeueReusableCell(withIdentifier: "changePasswordCell", for: indexPath) as? ChangePasswordTableViewCell else {
                return UITableViewCell()
            }
            return changePasswordCell
        case 2:
            guard let shareAppCell = tableView.dequeueReusableCell(withIdentifier: "shareAppCell", for: indexPath) as? ShareTableViewCell else {
                return UITableViewCell()
            }
            return shareAppCell
        case 3:
                guard let deleteCell = tableView.dequeueReusableCell(withIdentifier: "deleteAccountCell", for: indexPath) as? DeleteAccountTableViewCell else {
                    return UITableViewCell()
            }
                return deleteCell
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
        case 0,1:
            return 90
        default:
            return 80
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footer = UIView()
        footer.backgroundColor = UIColor.screenLightGray
        return footer
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        
        sectionHeader.sectionLabel.font = UIFont.systemFont(ofSize: 14, weight: .light)
        sectionHeader.moreButton.isHidden = true
        sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
        
        switch section {
        case 0:
            sectionHeader.sectionLabel.text = "Remove Adds / Enable Offline Capabilities"
        case 1:
            sectionHeader.sectionLabel.text = "Change Password"
        case 2:
            sectionHeader.sectionLabel.text = "Share with family / friends"
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
                let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                self.present(activityVC, animated: true) {
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
            }
            }

            break
        case 3:
            // MARK: - Delete Account
            self.present(UIAlertControllers.deleteAccountConfirmation(completion: { [weak self] (deleted, canceled) in
                DispatchQueue.main.async {
                    self?.tableView.deselectRow(at: indexPath, animated: true)
                    
                    if canceled {
                        return
                    }
                    if deleted {
                        self?.present(UIAlertControllers.accountDeleted {
                            guard let dismissingViewController = self?.presentingViewController?.presentingViewController else {
                                self?.navigateToLoginViewController()
                                return
                            }
                            dismissingViewController.dismiss(animated: true, completion: nil)
                        }, animated: true, completion: nil)
                        
                    } else {
                        self?.present(UIAlertControllers.accountNotDeleted(), animated: true, completion: nil)
                    }
                }
            }), animated: true, completion: nil)
        default:
            break
        }
    }
    
}
