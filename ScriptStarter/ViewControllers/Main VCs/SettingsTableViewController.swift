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
    
    
    // MARK: - IBActions
    
    @IBAction func downButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
            return UITableViewCell()
        case 3:
            return UITableViewCell()
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0,1:
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
}
