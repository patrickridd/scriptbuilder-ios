//
//  RolePopoverTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class RolePopoverTableViewController: UITableViewController {

    weak var delegate: RoleCellSelected?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Role.count + 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let roleCell = tableView.dequeueReusableCell(withIdentifier: "roleTableViewCell",
                                                     for: indexPath) as? RoleTableViewCell
        guard let role = Role(rawValue: indexPath.row) else {
            roleCell?.setupCustomLabel()
            return roleCell ?? UITableViewCell()
        }
        
        roleCell?.update(with: role)
        return roleCell ?? UITableViewCell()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        delegate?.updateRoleTextField(with: indexPath.row)
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}
