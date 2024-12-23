//
//  ScenesTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/15/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD
import StoreKit
import SwiftUI

class ScenesTableViewController: UITableViewController {
    
    @IBOutlet weak var addSceneButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: SaveBarButtonItem!
    
    var newScene: Bool = false
    var loadingNotification = MBProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.view = self

        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.separatorColor = Theme.tableViewBackgroundColor
        self.tableView.showsVerticalScrollIndicator = false
        if newScene, Store.shared.allAccessEnabled {
            self.pushToSceneDetailView(act: .one,
                                       scene: nil)
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.reloadTableView()
        setupNavigationBar()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func longPressGestureRecognized(gestureRecognizer: UIGestureRecognizer) {
        guard let longPress = gestureRecognizer as? UILongPressGestureRecognizer else { return }
        
        let state = longPress.state
        let locationInView = longPress.location(in: tableView)
        guard
            let indexPath = tableView.indexPathForRow(at: locationInView),
            let screenplay = self.screenplay
        else {
            return
        }
        
        struct My {
            static var cellSnapshot : UIView? = nil
        }
        struct Path {
            static var initialIndexPath : IndexPath? = nil
        }
        
        switch state {
        case UIGestureRecognizer.State.began:
            Path.initialIndexPath = indexPath
            guard let cell = tableView.cellForRow(at: indexPath) else { return }
            My.cellSnapshot  = snapshopOfCell(inputView: cell)
            var center = cell.center
            My.cellSnapshot?.center = center
            My.cellSnapshot?.alpha = 0.0
            if let cellSnapShot = My.cellSnapshot {
                self.tableView.addSubview(cellSnapShot)
            }
            
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                center.y = locationInView.y
                My.cellSnapshot?.center = center
                My.cellSnapshot?.transform = CGAffineTransform(scaleX: 1.05,
                                                               y: 1.05)
                My.cellSnapshot?.alpha = 0.98
                cell.alpha = 0.0
                
            }, completion: { (finished) -> Void in
                if finished {
                    cell.isHidden = true
                }
            })
        case UIGestureRecognizer.State.changed:
            var center = My.cellSnapshot?.center
            center?.y = locationInView.y
            if let center = center {
                My.cellSnapshot?.center = center
            }
            guard let initialIndexPath = Path.initialIndexPath else { return }
            switch indexPath.section {
            case 0: // Act 1
                if (indexPath != initialIndexPath) {
                    swap(&screenplay.act1ScenesArray[indexPath.row],
                         &screenplay.act1ScenesArray[initialIndexPath.row])
                    tableView.moveRow(at: initialIndexPath,
                                      to: indexPath)
                    Path.initialIndexPath = indexPath
                }
            case 1: // Act 2
                if (indexPath != initialIndexPath) {
                    swap(&screenplay.act2ScenesArray[indexPath.row],
                         &screenplay.act2ScenesArray[initialIndexPath.row])
                    tableView.moveRow(at: initialIndexPath,
                                      to: indexPath)
                    Path.initialIndexPath = indexPath
                }
            case 2: // Act 3
                if (indexPath != initialIndexPath) {
                    swap(&screenplay.act3ScenesArray[indexPath.row],
                         &screenplay.act3ScenesArray[initialIndexPath.row])
                    tableView.moveRow(at: initialIndexPath,
                                      to: indexPath)
                    Path.initialIndexPath = indexPath
                }
                
            default:
                guard
                    let initialIndexPath = Path.initialIndexPath,
                    let cell = tableView.cellForRow(at: initialIndexPath)
                else {
                    return
                }
                cell.isHidden = false
                cell.alpha = 0.0
                UIView.animate(withDuration: 0.25,
                               animations: { () -> Void in
                    My.cellSnapshot?.center = cell.center
                    My.cellSnapshot?.transform = CGAffineTransform.identity
                    My.cellSnapshot?.alpha = 0.0
                    cell.alpha = 1.0
                }, completion: { (finished) -> Void in
                    if finished {
                        Path.initialIndexPath = nil
                        My.cellSnapshot?.removeFromSuperview()
                        My.cellSnapshot = nil
                    }
                })
            }
        default:
            break
        }
    }
    
    func snapshopOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size,
                                               false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let cellSnapshot : UIView = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize.init(width:-5.0,
                                                      height:0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        guard let _ = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.reloadTableView()
            }
            return
        }
        
        // Remove Navigation bar shadow and borderline
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        if self.screenplay?.title == "" {
            screenplay?.title = "Untitled".localized
        }
        navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        let attributes =  [NSAttributedString.Key.foregroundColor: Theme.navTitleColor,
                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                          weight: .semibold)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = Theme.scriptBuilderUIColor
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.navigationBarBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        let backButton = UIBarButtonItem(title: "Home".localized,
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleRightSwipe(sender:)))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view, animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool, displayImage: Bool) {
        DispatchQueue.main.async {
            self.loadingNotification.mode = .customView
            if !displayImage {
                self.loadingNotification.hide(animated: true)
                return
            }
            if success {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                return
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
            }
        }
        
    }
    
    // MARK: - IBActions and Target Methods
  
    @IBAction func plusButtonTapped(_ sender: UIButton) {
        guard Store.shared.allAccessEnabled else {
            presentIAPSubscriptionView()
            return
        }
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
        self.navigationController?.pushViewController(sceneDetailVC,
                                                      animated: true)
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // Acts 1,2,3
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard let screenplay = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.reloadTableView()
            }
            return 1
        }
        
        // Return the amount scenes for each Act
        switch section {
        case 0: // Act 1
            if screenplay.act1ScenesArray.count == 0 {
                return 1
            } else {
                return screenplay.act1ScenesArray.count
            }
        case 1: // Act 2
            if screenplay.act2ScenesArray.count == 0 {
                return 1
            } else {
                return screenplay.act2ScenesArray.count
            }
        case 2: // Act 3
            if screenplay.act3ScenesArray.count == 0 {
                return 1
            } else {
                return screenplay.act3ScenesArray.count
            }
        default:
            return 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let screenplay = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.reloadTableView()
            }
            return UITableViewCell()
        }
        
        // Find sceneCell or noSceneCell for each Act section
        switch indexPath.section {
        case 0: // Act 1
            let scenesCount = screenplay.act1ScenesArray.count
           
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier",
                                                                      for: indexPath) as?NoCharacterTableViewCell
                noSceneCell?.update(with: "Tap + to create a new Scene!".localized)
                return noSceneCell ?? UITableViewCell()
            }
            let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell",
                                                          for: indexPath) as? SceneTableViewCell
           // Find scene for this act and update sceneCell
            let scene = screenplay.act1ScenesArray[indexPath.row]
            sceneCell?.update(with: scene)
            return sceneCell ?? UITableViewCell()
        
        case 1: // Act 2
            let scenesCount = screenplay.act2ScenesArray.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as? NoCharacterTableViewCell
                
                noSceneCell?.update(with: "Tap + to create a new Scene!".localized)

                return noSceneCell ?? UITableViewCell()
            }
            let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell",
                                                          for: indexPath) as? SceneTableViewCell
            // Find scene for this act and update sceneCell
            let scene = screenplay.act2ScenesArray[indexPath.row]
            sceneCell?.update(with: scene)
            return sceneCell ?? UITableViewCell()
        case 2: // Act 3
            let scenesCount = screenplay.act3ScenesArray.count
            
            // If no scenes in this act return the noSceneCell
            if scenesCount == 0 {
                let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as? NoCharacterTableViewCell
                
                noSceneCell?.update(with: "Tap + to create a new Scene!".localized)
                
                return noSceneCell ?? UITableViewCell()
            }
            
            let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell",
                                                          for: indexPath) as? SceneTableViewCell
            // Find scene for this act and update sceneCell
            let scene = screenplay.act3ScenesArray[indexPath.row]
            sceneCell?.update(with: scene)
            return sceneCell ?? UITableViewCell()
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
        header.plusButtonCover.addTarget(self,
                                         action: #selector(plusButtonTapped(_:)),
                                         for: .touchUpInside)

        switch section {
        case 0: // Act 1
            header.titleLabel.text = "Act 1".localized
        case 1: // Act 2
            header.titleLabel.text = "Act 2".localized
        case 2: // Act 3
            header.titleLabel.text = "Act 3".localized
            
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
        guard Store.shared.allAccessEnabled else {
            presentIAPSubscriptionView()
            return
        }

        guard let _ = self.screenplay else {
            self.reloadScreenplaysWithAnimation {
                self.reloadTableView()
            }
            return
        }

        var scene: Scene?
        switch indexPath.section {
        case 0:
            guard let scenes = self.screenplay?.act1ScenesArray, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .one,
                                           scene: nil)
                return
            }
            scene = self.screenplay?.act1ScenesArray[indexPath.row]
            self.pushToSceneDetailView(act: .one,
                                       scene: scene)
        case 1:
            guard let scenes = self.screenplay?.act2ScenesArray, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .two,
                                           scene: nil)
                return
            }
            
            scene = self.screenplay?.act2ScenesArray[indexPath.row]
            self.pushToSceneDetailView(act: .two,
                                       scene: scene)
        case 2:
            guard let scenes = self.screenplay?.act3ScenesArray, scenes.count != 0 else {
                self.pushToSceneDetailView(act: .three,
                                           scene: nil)
                return
            }
            
            scene = self.screenplay?.act3ScenesArray[indexPath.row]
            self.pushToSceneDetailView(act: .three,
                                       scene: scene)
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
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        guard let _ = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.reloadTableView()
            }
            return
        }
        
        switch indexPath.section {
        case 0: // Act 1
            if let scene = self.screenplay?.act1ScenesArray[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
               FirebaseController.shared.delete(scene: scene,
                                                withScreenplay: screenplay,
                                                inAct: .one)
                self.screenplay?.act1ScenesArray.remove(at: indexPath.row)
                
                self.reloadTableView()
            }
        case 1: // Act 2
            if let scene = self.screenplay?.act2ScenesArray[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
                FirebaseController.shared.delete(scene: scene,
                                                 withScreenplay: screenplay,
                                                 inAct: .two)
                self.screenplay?.act2ScenesArray.remove(at: indexPath.row)
                self.reloadTableView()
            }
        case 2: // Act 3
            if let scene = self.screenplay?.act3ScenesArray[indexPath.row],
                let screenplay = self.screenplay, editingStyle == .delete {
                  FirebaseController.shared.delete(scene: scene,
                                                   withScreenplay: screenplay,
                                                   inAct: .three)
                self.screenplay?.act3ScenesArray.remove(at: indexPath.row)
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
            if screenplay?.act1ScenesArray.count == 0 { return false }
        case 1:
            if screenplay?.act2ScenesArray.count == 0 { return false }
        case 2:
            if screenplay?.act3ScenesArray.count == 0 { return false }
        default:
            break
        }
        return true
    }

}
