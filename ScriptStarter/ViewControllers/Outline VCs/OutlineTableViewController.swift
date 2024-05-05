//
//  OutlineTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import MBProgressHUD
import Firebase

let swipeLeftNotificationKey = "com.scriptstarter.swipedleftInTabBar"
let swipeRightNotificationKey = "com.scriptstarter.swipedRightInTabBar"

protocol DescriptionDelegate: class {
    func updatedText(_ text: String, in section: Int)
}

class OutlineTableViewController: UITableViewController {
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var saveButton: SaveBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        saveButton.view = self
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.separatorColor = tableView.backgroundColor
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        setupNavigationBar()
        self.tableView.reloadData()
        setupTabBar()
    
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.view.endEditing(true)
    }
    
    // MARK: IBActions/Target Methods
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard
            let enlargedNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "enlargedNavigation") as? UINavigationController,
            let enlargedVC = enlargedNavigationController.children[0] as? EnlargedDescriptionTableViewController,
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        
        enlargedVC.viewController = .outline
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        switch sender.tag {
        case 1:
            enlargedVC.act = .one
        case 2:
            enlargedVC.act = .two
        case 3:
            enlargedVC.act = .three
        default:
            enlargedVC.act = nil
        }
        enlargedNavigationController.modalPresentationStyle = .fullScreen
        self.present(enlargedNavigationController,
                     animated: true,
                     completion: nil)
    }
    
    // MARK: Swipe gestures
    
    @objc func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        let swipeNotificationName = Notification.Name(swipeRightNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    
    @objc func informationButtonTapped(sender: UIButton) {
        guard let informationPopTVC = self.storyboard?.instantiateViewController(withIdentifier: "informationPopTVC") as? InformationPopTableViewController else { return }
        informationPopTVC.modalPresentationStyle = .popover
        let popController = informationPopTVC.popoverPresentationController
        popController?.delegate = self
        popController?.backgroundColor = .white // Makes the arrow white
        popController?.permittedArrowDirections = [.up,
                                                   .down] // allow arrow to go both .up and .down
        popController?.sourceView = sender
        popController?.sourceRect = sender.bounds
        let contentHeightSize = InformationNote.logline.contentHeight
        informationPopTVC.informationNote = .logline
        informationPopTVC.preferredContentSize = CGSize(width: self.view.bounds.width,
                                                        height: CGFloat(contentHeightSize))
        informationPopTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        self.present(informationPopTVC,
                     animated: true,
                     completion: nil)
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
       // Remove Navigation bar shadow and borderline
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        if self.screenplay?.title == "" {
            screenplay?.title = "Untitled".localized
        }
        navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        let attributes = [NSAttributedString.Key.foregroundColor: Theme.navTitleColor,
                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                          weight: .semibold)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = .screenLightBlue
        let appearance = UINavigationBarAppearance()
        appearance.titleTextAttributes = attributes
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.navigationBarBackground
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonAsset"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleRightSwipe(sender:)))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    func setupTabBar() {
        let appearance = UITabBarAppearance()
        let selectedColor = UIColor.screenLightBlue
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = Theme.navigationBarBackground
        appearance.inlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.compactInlineLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.inlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor : selectedColor]
        appearance.compactInlineLayoutAppearance.selected.titleTextAttributes = [.foregroundColor : selectedColor]
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor : selectedColor]
        tabBarController?.tabBar.standardAppearance = appearance
        tabBarController?.tabBar.scrollEdgeAppearance = tabBarController?.tabBar.standardAppearance
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
        guard let _ = self.screenplay else {
            reloadScreenplaysWithAnimation {
                self.tableView.reloadData()
            }
            return UITableViewCell()
        }
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell",
                                                            for: indexPath) as? DescriptionTableViewCell
        descriptionCell?.delegate = self
        descriptionCell?.defaultHeight = self.getDefaultHeightOfCell()
        descriptionCell?.update(viewController: .outline,
                               section: indexPath.section,
                               act: nil)
        descriptionCell?.contentView.backgroundColor = Theme.tableViewBackgroundColor
        descriptionCell?.expandButton.tag = indexPath.section
        descriptionCell?.expandButton.addTarget(self,
                                               action: #selector(expandButtonTapped(sender:)),
                                               for: .touchUpInside)
        
        return descriptionCell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        
        var sectionName = String()
        switch section {
        case 0:
            sectionName = "Idea".localized
        case 1:
            sectionName = "Act 1".localized
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        case 2:
            sectionName = "Act 2".localized
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        case 3:
            sectionName = "Act 3".localized
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        default:
            break
        }
        
        sectionHeader.navigationButton.tag = section
        sectionHeader.navigationButton.addTarget(self,
                                                 action: #selector(pushToDetailView(sender:)),
                                                 for: .touchUpInside)
        sectionHeader.contentView.backgroundColor = Theme.tableViewBackgroundColor
        sectionHeader.sectionLabel.textColor = Theme.navTitleColor

        sectionHeader.sectionLabel.text = sectionName
        return sectionHeader
   }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "footer")
        sectionHeader.contentView.backgroundColor = Theme.sectionHeaderSeparatorColor
        sectionHeader.moreButton.isHidden = true
        sectionHeader.sectionLabel.isHidden = true
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
    // MARK: Navigation
    
    @objc func pushToDetailView(sender: UIButton) {
        
        if let actDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "actDetailVC") as? ActDetailTableViewController {
            
            // Switch on the Act to segue to based on button tag
            switch sender.tag {
            case 0:
                actDetailVC.act = .idea
            case 1:
                actDetailVC.act = .one
            case 2:
                actDetailVC.act = .two
            case 3:
                actDetailVC.act = .three
            default:
                break
            }
            self.navigationController?.pushViewController(actDetailVC,
                                                          animated: true)
        }
    }
}

extension OutlineTableViewController: DescriptionDelegate {
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
       
        guard
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        
        descriptionCell.descriptionTextView.text = text
        descriptionCell.textViewDidChange(descriptionCell.descriptionTextView)
    }
}

extension OutlineTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
