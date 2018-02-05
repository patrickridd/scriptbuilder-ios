//
//  CharacterDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/2/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class CharacterDetailTableViewController: UITableViewController {
    
    var character: Character?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.screenLightGray

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // 1. Intention - What does [Character] want?
        // 2. Why does [Character] want this
        // 3. What does [Character] need to do to get this?
        // 4. What obstacles are in [character]'s way?
        // 5. What flaws does [character] have?
        // 6. Does acheiving the intention fix any
        return 6
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath)

        // Configure the cell...
        descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        // 1. Intention - What does [Character] want?
        // 2. Why does [Character] want this
        // 3. What does [Character] need to do to get this?
        // 4. What obstacles are in [character]'s way?
        // 5. What flaws does [character] have?
        // 6. Does acheiving the intention fix any
        let name = self.character?.name ?? "Character"
        
        switch section {
        case 0:
            return "  Intention - What does \(name) want?"
        case 1:
            return "  Why does \(name) want this"
        case 2:
            return "  What does \(name) need to do to get this?"
        case 3:
            return "  What obstacles are in [character]'s way"
        case 4:
            return "  What flaws does \(name) have?"
        case 5:
            return "  Does acheiving the intention fix any flaws"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.view.frame.height >= 670 {
            return self.view.frame.height * (1/8)
        } else {
            return self.view.frame.height * (1/9)
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
        if let headerTitle = view as? UITableViewHeaderFooterView {
            headerTitle.textLabel?.textColor = UIColor.screenDark
            let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
            headerTitle.textLabel?.font = font
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
