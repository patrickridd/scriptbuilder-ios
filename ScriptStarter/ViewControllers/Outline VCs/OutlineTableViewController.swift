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

let swipeLeftNotificationKey = "com.scriptstarter.swipedleftInTabBar"
let swipeRightNotificationKey = "com.scriptstarter.swipedRightInTabBar"

class OutlineTableViewController: UITableViewController, DescriptionDelegate, GADBannerViewDelegate {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
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
        let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor

        setupNavigationBar()
        self.tableView.reloadData()
        setupTabBar()
        adBannerView.load(GADRequest())
    }
    
    // MARK: IBActions/Target Methods
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard let enlargedNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "enlargedNavigation") as? UINavigationController, let enlargedVC = enlargedNavigationController.childViewControllers[0] as? EnlargedDescriptionTableViewController, let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        switch sender.tag {
        case 0:
            enlargedVC.view.heroID = "About a robot lizard who..."
        case 1:
            enlargedVC.view.heroID = "Setup"
        case 2:
            enlargedVC.view.heroID = "Confrontation"
        case 3:
            enlargedVC.view.heroID = "Resolution"
        default:
            break
        }
        
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        
        self.present(enlargedNavigationController, animated: true, completion: nil)
    }
    
    
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        let loadingNotification = MBProgressHUD.showAdded(to: view, animated: true)
        loadingNotification.mode = MBProgressHUDMode.annularDeterminate
        loadingNotification.animationType = .fade
        loadingNotification.label.text = "saving"
        
        if let screenplay = screenplay {
            FirebaseController.shared.save(screenplay: screenplay, completion: { (success) in
                DispatchQueue.main.async {
                    loadingNotification.mode = .customView
                    if success {
                        loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                        loadingNotification.label.text = "success"
                        loadingNotification.hide(animated: true, afterDelay: 1)
                        return
                    }
                    loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                    loadingNotification.label.text = "failed"
                    loadingNotification.hide(animated: true, afterDelay: 1)
                }
            })
        }
    }
    
    // MARK: DescriptionDelegate Methods
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        descriptionCell.descriptionTextView.text = text
    }
    
    // MARK: Swipe gestures
    
    @objc func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        let swipeNotificationName = Notification.Name(swipeRightNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
       // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.screenDark, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
        
        let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonAsset"), style: .plain, target: self, action: #selector(handleRightSwipe(sender:)))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    func setupTabBar() {
        self.tabBarController?.tabBar.barTintColor = UIColor.white
        self.tabBarController?.tabBar.tintColor = UIColor.screenLightBlue
    }
    
    
    // MARK: GADBannerViewDelegate Methods
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner loaded successfully")
        tableView.tableFooterView?.frame = bannerView.frame
        tableView.tableFooterView = bannerView
    }
    
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("Fail to receive ads")
        print(error)
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
       
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else {
            return UITableViewCell() }
        
        descriptionCell.update(viewController: .outline, section: indexPath.section, act: nil)
        descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
        descriptionCell.expandButton.tag = indexPath.section
        descriptionCell.expandButton.addTarget(self, action: #selector(expandButtonTapped(sender:)), for: .touchUpInside)
        
        return descriptionCell
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        switch section {
//        case 0:
//            return "  Basic Idea (Log Line)"
//        case 1:
//            return "  Act 1"
//        case 2:
//            return "  Act 2"
//        case 3:
//            return "  Act 3"
//        default:
//            return ""
//        }
//    }
//
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
//        if let headerTitle = view as? UITableViewHeaderFooterView {
//            headerTitle.textLabel?.textColor = UIColor.screenDark
//            let font = UIFont.systemFont(ofSize: 17, weight: .semibold)
//            headerTitle.textLabel?.font = font
//        }
//    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        
        var sectionName = String()
        switch section {
        case 0:
            sectionName = "Basic Idea - Log line"
            sectionHeader.moreButton.isHidden = true
            sectionHeader.navigationButton.isEnabled = false
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
        sectionHeader.navigationButton.addTarget(self, action: #selector(pushToDetailView(sender:)), for: .touchUpInside)
        sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
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
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.view.frame.height >= 670 {
            return self.view.frame.height * (1/7)
        } else {
            return self.view.frame.height * (1/7.5)
        }
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        arg.translatesAutoresizingMaskIntoConstraints = true
        arg.sizeToFit()
        arg.isScrollEnabled = false
    }
    
    
    // MARK: Navigation
    
    @objc func pushToDetailView(sender: UIButton) {
        
        guard let actDetailVC = self.storyboard?.instantiateViewController(withIdentifier: "actDetailVC") as? ActDetailTableViewController else { return }
        
        // Switch on the Act to segue to based on button tag
        switch sender.tag {
        case 1:
            actDetailVC.act = .one
        case 2:
            actDetailVC.act = .two
        case 3:
            actDetailVC.act = .three
        default:
            break
        }
        self.navigationController?.pushViewController(actDetailVC, animated: true)
    }
    
}



protocol DescriptionDelegate: class {
    func updatedText(_ text: String, in section: Int)
}
