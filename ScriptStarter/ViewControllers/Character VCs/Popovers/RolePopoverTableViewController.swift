//
//  RolePopoverTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class RolePopoverTableViewController: UITableViewController {

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
        return Role.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let roleCell = tableView.dequeueReusableCell(withIdentifier: "roleTableViewCell", for: indexPath) as? RoleTableViewCell else { return UITableViewCell() }

        guard let role = Role(rawValue: indexPath.row) else {
            roleCell.setupCustomLabel()
            return roleCell
        }
        roleCell.update(with: role)
        return roleCell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
