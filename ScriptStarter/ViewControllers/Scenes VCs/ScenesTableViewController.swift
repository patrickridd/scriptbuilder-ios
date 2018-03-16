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
        
        setupNavigationBar()
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
    }
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        if self.screenplay?.title == "" {
            screenplay?.title = "Untitled"
        }
        self.navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.screenDark, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
        
      //  let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonAsset"), style: .plain, target: self, action: #selector(handleRightSwipe(sender:)))
         let backButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(handleRightSwipe(sender:)))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    // MARK: - IBActions and Target Methods
    
    @IBAction func saveButtonTapped(sender: AnyObject) {
        self.saveScreenplay()
    }
    
  
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        if let act = Act(rawValue: sender.tag) {
            self.pushToSceneDetailView(act: act, scene: nil)
        } else {
            self.pushToSceneDetailView(act: .one, scene: nil)
        }
    }
    
    @objc func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        let swipeNotificationName = Notification.Name(swipeRightNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    
    func pushToSceneDetailView(act: Act, scene: Scene?) {
        
        guard let sceneDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "sceneDetailVC") as? SceneDetailTableViewController else { return }
        
        sceneDetailVC.scene = scene
        sceneDetailVC.act = act
        self.navigationController?.pushViewController(sceneDetailVC, animated: true)
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
        
        // Find sceneCell or noSceneCell for each Act section
        switch indexPath.section {
        case 0: // Act 1
            let scenesCount = screenplay.act1.scenes.count
           
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                guard let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as?
                    NoCharacterTableViewCell else { return UITableViewCell() }
                
                return noSceneCell
            }
            guard let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as? SceneTableViewCell else { return UITableViewCell() }
           // Find scene for this act and update sceneCell
            let scene = screenplay.act1.scenes[indexPath.row]
            sceneCell.update(with: scene)
            return sceneCell
        
        case 1: // Act 2
            let scenesCount = screenplay.act2.scenes.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                guard let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as?
                    NoCharacterTableViewCell else { return UITableViewCell() }
                
                return noSceneCell
            }
            guard let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as? SceneTableViewCell else { return UITableViewCell() }
            // Find scene for this act and update sceneCell
            let scene = screenplay.act2.scenes[indexPath.row]
            sceneCell.update(with: scene)
            return sceneCell
        case 2: // Act 3
            let scenesCount = screenplay.act3.scenes.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                guard let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as?
                    NoCharacterTableViewCell else { return UITableViewCell() }
                
                return noSceneCell
            }
            
            guard let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as? SceneTableViewCell else { return UITableViewCell() }
            // Find scene for this act and update sceneCell
            let scene = screenplay.act3.scenes[indexPath.row]
            sceneCell.update(with: scene)
            return sceneCell
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        // Act Header
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SceneHeader ?? SceneHeader(reuseIdentifier: "header")
        header.plusButtonCover.tag = section // Used to get Act enum case
        header.plusButtonCover.addTarget(self, action: #selector(plusButtonTapped(_:)), for: .touchUpInside)

        switch section {
        case 0: // Act 1
            header.titleLabel.text = "Act 1"
        case 1: // Act 2
            header.titleLabel.text = "Act 2"
        case 2: // Act 3
            header.titleLabel.text = "Act 3"
        default:
            break
        }
     
        return header
    }

   override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
   override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 000.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        var scene: Scene?
        switch indexPath.section {
        case 0:
            guard let scenes = self.screenplay?.act1.scenes, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .one, scene: nil)
                return
            }
            scene = self.screenplay?.act1.scenes[indexPath.row]
            self.pushToSceneDetailView(act: .one, scene: scene)
        case 1:
            guard let scenes = self.screenplay?.act2.scenes, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .two, scene: nil)
                return
            }
            
            scene = self.screenplay?.act2.scenes[indexPath.row]
            self.pushToSceneDetailView(act: .two, scene: scene)
            
        case 2:
            guard let scenes = self.screenplay?.act3.scenes, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .three, scene: nil)
                return
            }
            
            scene = self.screenplay?.act3.scenes[indexPath.row]
            self.pushToSceneDetailView(act: .three, scene: scene)
        default:
            break
        }
        
    }
   
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    
    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        switch indexPath.section {
        case 0: // Act 1
            if let scene = self.screenplay?.act1.scenes[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
               FirebaseController.shared.delete(scene: scene,withScreenplay: screenplay, inAct: .one)
                self.screenplay?.act1.scenes.remove(at: indexPath.row)
                
                self.reloadTableView()
            }
        case 1: // Act 2
            if let scene = self.screenplay?.act2.scenes[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
                FirebaseController.shared.delete(scene: scene,withScreenplay: screenplay, inAct: .two)
                
                self.screenplay?.act2.scenes.remove(at: indexPath.row)
                
                self.reloadTableView()
            }
        case 2: // Act 3
            if let scene = self.screenplay?.act3.scenes[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
                  FirebaseController.shared.delete(scene: scene,withScreenplay: screenplay, inAct: .three)
                
                self.screenplay?.act3.scenes.remove(at: indexPath.row)
                
                self.reloadTableView()
            }
        default:
            break
        }
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // We don't want cells with "Tap + to create a new Scene!" to be editable
        switch indexPath.section {
        case 0:
            if screenplay?.act1.scenes.count == 0 {
                return false
            }
        case 1:
            if screenplay?.act2.scenes.count == 0 {
                return false
            }
        case 2:
            if screenplay?.act3.scenes.count == 0 {
                return false
            }
        default:
            break
        }
        return true
    }
    
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


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        guard let navigationController = segue.destination as? UINavigationController, let sceneDetailTVC = navigationController.viewControllers[0] as? SceneDetailTableViewController,
//        let indexPath = self.tableView.indexPathForSelectedRow else {
//            return
//        }
//        
//        if segue.identifier == "sceneSegue" {
//            guard let indexPath = self.tableView.indexPathForSelectedRow else {
//                return
//            }
//
//            var scene: Scene?
//            switch indexPath.section {
//            case 0:
//                scene = self.screenplay?.act1.scenes[indexPath.row]
//            case 1:
//                scene = self.screenplay?.act2.scenes[indexPath.row]
//            case 2:
//                scene = self.screenplay?.act3.scenes[indexPath.row]
//            default:
//                break
//            }
//            sceneDetailTVC.scene = scene
//
//        } else if segue.identifier == "newSceneSegue" {
//
//            switch indexPath.section  {
//            case 0:
//                guard let sceneCount = self.screenplay?.act1.scenes.count else { break }
//                let scene = Scene(title: "New Scene", sceneNumber: sceneCount+1)
//                self.screenplay?.act1.scenes.append(scene)
//                sceneDetailTVC.act = .one
//                sceneDetailTVC.scene = scene
//            case 1:
//                guard let sceneCount = self.screenplay?.act2.scenes.count else { break }
//                let scene = Scene(title: "New Scene", sceneNumber: sceneCount+1)
//                self.screenplay?.act2.scenes.append(scene)
//                sceneDetailTVC.act = .two
//                sceneDetailTVC.scene = scene
//            case 2:
//                guard let sceneCount = self.screenplay?.act3.scenes.count else { break }
//                let scene = Scene(title: "New Scene", sceneNumber: sceneCount+1)
//                self.screenplay?.act3.scenes.append(scene)
//                sceneDetailTVC.act = .three
//                sceneDetailTVC.scene = scene
//            default:
//                break
//            }
//        }
//    }
    

}
