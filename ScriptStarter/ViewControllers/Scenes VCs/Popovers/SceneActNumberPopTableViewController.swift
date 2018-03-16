//
//  SceneActNumberPopTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/16/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SceneActNumberPopTableViewController: UITableViewController {

    weak var delegate: SceneActSelected?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 3
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let actNumberPopCell = tableView.dequeueReusableCell(withIdentifier: "actNumberCell", for: indexPath) as? ActNumberPopTableViewCell else { return UITableViewCell() }
        
        // Configure the cell...
        actNumberPopCell.update(with:indexPath.row+1)
        
        return actNumberPopCell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 30
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let act = Act(rawValue: indexPath.row) {
            delegate?.selected(newAct: act)
        }
        self.dismiss(animated: true, completion: nil)
    }
}
