//
//  ScenesTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/15/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ScenesTableViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    // MARK: - IBActions
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.saveScreenplay()
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        
        // Acts 1,2,3
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       
        guard let screenplay = self.screenplay else { return 1 }
       
        // Return the amount scenes for each Act
        switch section {
        case 0: // Act 1
            if screenplay.act1.scenes.count == 0 {
                return 1
            } else {
                return screenplay.act1.scenes.count
            }
        case 1: // Act 2
            if screenplay.act2.scenes.count == 0 {
                return 1
            } else {
                return screenplay.act2.scenes.count
            }
        case 2: // Act 3
            if screenplay.act3.scenes.count == 0 {
                return 1
            } else {
                return screenplay.act3.scenes.count
            }
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let screenplay = self.screenplay else {
            return UITableViewCell()
        }
        
         guard let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as? SceneTableViewCell else { return UITableViewCell() }
        
        guard let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as?
            NoCharacterTableViewCell else { return UITableViewCell() }
        
        // Find sceneCell or noSceneCell for each Act section
        switch indexPath.section {
        case 0: // Act 1
            let scenesCount = screenplay.act1.scenes.count
           
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                return noSceneCell
            }
            
           // Find scene for this act and update sceneCell
            let scene = screenplay.act1.scenes[indexPath.row]
            sceneCell.update(with: scene)
            
        case 1: // Act 2
            let scenesCount = screenplay.act2.scenes.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                return noSceneCell
            }
            
            // Find scene for this act and update sceneCell
            let scene = screenplay.act2.scenes[indexPath.row]
            sceneCell.update(with: scene)
            
        case 2: // Act 3
            let scenesCount = screenplay.act3.scenes.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                return noSceneCell
            }
            
            // Find scene for this act and update sceneCell
            let scene = screenplay.act3.scenes[indexPath.row]
            sceneCell.update(with: scene)
            
        default:
            return UITableViewCell()
        }
        
        return sceneCell
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
