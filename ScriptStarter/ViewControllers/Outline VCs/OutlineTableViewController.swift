//
//  OutlineTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import GoogleMobileAds
import MBProgressHUD
import Firebase

let swipeLeftNotificationKey = "com.scriptstarter.swipedleftInTabBar"
let swipeRightNotificationKey = "com.scriptstarter.swipedRightInTabBar"

protocol DescriptionDelegate: class {
    func updatedText(_ text: String, in section: Int)
}

class OutlineTableViewController: UITableViewController {
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-1297096402264538/3462578381"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()

    @IBOutlet weak var titleTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        setupNavigationBar()
        self.tableView.reloadData()
        setupTabBar()
        adBannerView.load(GADRequest())
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
        self.present(enlargedNavigationController,
                     animated: true,
                     completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
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
            screenplay?.title = "Untitled"
        }
        navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.screenDark,
                          NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                          weight: .semibold)]
        navigationController?.navigationBar.titleTextAttributes = attributes
        navigationController?.navigationBar.tintColor = .screenLightBlue
        navigationController?.navigationBar.barTintColor = .white
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonAsset"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleRightSwipe(sender:)))
        navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    func setupTabBar() {
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.screenLightBlue
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
       
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell",
                                                            for: indexPath) as? DescriptionTableViewCell
        descriptionCell?.delegate = self
        descriptionCell?.defaultHeight = self.getDefaultHeightOfCell()
        descriptionCell?.update(viewController: .outline,
                               section: indexPath.section,
                               act: nil)
        descriptionCell?.contentView.backgroundColor = UIColor.screenLightGray
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
            
            sectionName = "Idea"
//             let loglineSection = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ActBeatSectionHeader ?? ActBeatSectionHeader(reuseIdentifier: "header")
//            loglineSection.titleLabel.text = "Log line"
//             loglineSection.titleLabel.centerYAnchor.constraint(equalTo: loglineSection.centerYAnchor, constant: 0).isActive = true
//             loglineSection.infoButton.addTarget(self, action: #selector(informationButtonTapped(sender:)), for: .touchUpInside)
//            return loglineSection
        case 1:
            sectionName = " Act 1"
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        case 2:
            sectionName = "Act 2"
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        case 3:
            sectionName = "Act 3"
            sectionHeader.moreButton.isHidden = false
            sectionHeader.navigationButton.isEnabled = true
        default:
            break
        }
        
        sectionHeader.navigationButton.tag = section
        sectionHeader.navigationButton.addTarget(self,
                                                 action: #selector(pushToDetailView(sender:)),
                                                 for: .touchUpInside)
        sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
        sectionHeader.sectionLabel.textColor = UIColor.screenDark

        sectionHeader.sectionLabel.text = sectionName
        return sectionHeader
   }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "footer") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "footer")
        sectionHeader.contentView.backgroundColor = UIColor.athensGray
        sectionHeader.moreButton.isHidden = true
        sectionHeader.sectionLabel.isHidden = true
        return sectionHeader
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
    
//    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        var text: String
//        switch indexPath.section {
//        case 0: // Basic Info
//            text = self.screenplay?.logLine ?? ""
//        case 1: // Act 1
//            text = self.screenplay?.actOneDescription ?? ""
//        case 2: // Act 2
//            text = self.screenplay?.actTwoDescription ?? ""
//        case 3: // Act 3
//            text = self.screenplay?.actThreeDescription ?? ""
//        default:
//            return self.getDefaultHeightOfCell()
//        }
//        return self.getDescriptionCellHeight(with:text)
//    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
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


extension OutlineTableViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView.tableFooterView?.frame = bannerView.frame
        tableView.tableFooterView = bannerView
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
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
    }
}

extension OutlineTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}



