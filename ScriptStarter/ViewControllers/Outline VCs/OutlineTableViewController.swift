//
//  OutlineTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class OutlineTableViewController: UITableViewController {
    
    var screenplay: Screenplay?
   
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        self.tabBarController?.tabBar.barTintColor = UIColor.screenDark
        self.tabBarController?.tabBar.tintColor = UIColor.screenLightBlue
        self.tableView.backgroundColor = .screenLightBlue
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
       // self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
       // self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.barStyle = .black

    }
    
    // MARK: UITableView DataSource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // SECTIONS:
        // 1. Basic Idea (Log line)
        // 2. Act 1
        // 3. Act 2
        // 4. Act 3
        
        return 4
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else {
            return UITableViewCell() }
        
        switch indexPath.section {
        case 0: // Log line
            descriptionCell.descriptionTextView.placeholder = "About a robot lizard who..."
       
        case 1: // Act 1
            descriptionCell.descriptionTextView.placeholder = "Setup"
        
        case 2: // Act 2
            descriptionCell.descriptionTextView.placeholder = "Confrontation"
       
        case 3: // Act 3
            descriptionCell.descriptionTextView.placeholder = "Resolution"
        
        default:
            break
        }
    
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "  Basic Idea (Log Line)"
        case 1:
            return "  Act 1"
        case 2:
            return "  Act 2"
        case 3:
            return "  Act 3"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.screenDark
            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            headerTitle.textLabel?.font = font
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 100
        default:
            switch indexPath.row {
            case 0:
                return 100
            default:
                return 40
            }
        }
    }
   
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    

}
