//
//  SceneDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SceneDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate {

    var scene: Scene?
    var expandableSections: [ExpandableTableViewSection] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
    }
    

    func setupExpandableSections() {
        let sectionTitles = Scene.sceneTitles
        for index in 0...sectionTitles.count-1 {
            let title = Scene.sceneTitles[index]
            let subtitle = "" //act.sectionSubTitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // 0. Scene # and Scene Header
        // 1. Scene Description
        // 2. Dialogue
        // 3. Action
        // 4. Characters
        // 5. How scene moves story forward
        // 6. Notes
        return 7
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        switch section {
        case 0:
            return 1
        default:
            return expandableSections[section-1].collapsed ? 0 : 1
        }
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            guard let sceneHeadingCell = tableView.dequeueReusableCell(withIdentifier: "sceneHeadingCell", for: indexPath) as? SceneHeaderTableViewCell, let scene = self.scene else { return UITableViewCell() }
            sceneHeadingCell.update(with: scene)
            return sceneHeadingCell
        default:
            guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
            return descriptionCell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        // Create Collapsible Header for Scene details
        switch section {
        case 0:
            return nil
        default:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-1].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = Scene.sceneTitles[section-1]
           // header.subtitleLabel.text = act.sectionSubTitles[section-self.sectionBesidesBeats]
            header.setCollapsed(expandableSections[section-1].collapsed)
            header.section = section
            header.delegate = self
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 0.0001
        default:
            return 60
        }
    }
    
    
    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section-1].collapsed
            // Toggle collapse
            self.expandableSections[section-1].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
