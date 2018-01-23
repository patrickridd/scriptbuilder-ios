//
//  OutlineViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class OutlineViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    // MARK: UITableView DataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        // SECTIONS:
        // 1. Basic Idea (Log line)
        // 2. Act 1
        // 3. Act 2
        // 4. Act 3
        
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // Log line TextView
        default:
            return 2 //
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
        
        let moreCell = UITableViewCell()
        moreCell.textLabel?.text = "More"
        moreCell.textLabel?.textAlignment = .center
        
        switch indexPath.section {
        case 0: // Log line
            descriptionCell.descriptionTextView.text = "About a robot who..."
            return descriptionCell
            
        case 1: // Act 1
            switch indexPath.row {
            case 0: // Description Cell
                descriptionCell.descriptionTextView.text = "Setup"
                return descriptionCell
            default:
                return moreCell
            }
            
        case 2: // Act 2
            switch indexPath.row {
            case 0: // Description Cell
                descriptionCell.descriptionTextView. = "Confrontation"
                return descriptionCell
            default:
                return moreCell
            }
        case 3: // Act 3
            switch indexPath.row {
            case 0: // Description Cell
                descriptionCell.descriptionTextView.text = "Resolution"
                return descriptionCell
            default:
                return moreCell
            }
        default:
            return moreCell
        }
        
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
