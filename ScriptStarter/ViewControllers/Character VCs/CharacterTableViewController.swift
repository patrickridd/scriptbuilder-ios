//
//  CharacterTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

class CharacterTableViewController: UITableViewController, GADBannerViewDelegate {
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-1297096402264538/3462578381"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //  tableView.tableFooterView = UIView(frame: .zero)
        
        // Set Google Analytics Screen Name
        Analytics.setScreenName("CharacterTableView", screenClass: "CharacterTableViewController")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.screenLightGray
        
        self.tableView.reloadData()
        setupNavigationBar()
        adBannerView.load(GADRequest())
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
        let backButton = UIBarButtonItem(title: "Home", style: .plain, target: self, action: #selector(handleRightSwipe(sender:)))
       // let backButton = UIBarButtonItem(image: #imageLiteral(resourceName: "backButtonAsset"), style: .plain, target: self, action: #selector(handleRightSwipe(sender:)))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    
    // MARK: IBActions
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    // MARK: Swipe gestures
    
    @objc func handleRightSwipe(sender: UISwipeGestureRecognizer) {
        let swipeNotificationName = Notification.Name(swipeRightNotificationKey)
        let swipeNotification = Notification(name: swipeNotificationName)
        NotificationCenter.default.post(swipeNotification)
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

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if screenplay?.characters.count == 0 {
            return 1
        } else {
            return self.screenplay?.characters.count ?? 0
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if screenplay?.characters.count == 0 {
            guard let noCharacterCell = tableView.dequeueReusableCell(withIdentifier: "noCharacterCell", for: indexPath) as? NoCharacterTableViewCell else {
                return UITableViewCell()
            }
            return noCharacterCell
        }
        
        guard let characterCell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as? CharacterTableViewCell else { return UITableViewCell() }
        
        // Configure the cell...
        if let character = screenplay?.characters[indexPath.row] {
            characterCell.updateCell(with: character)
        }
        
        return characterCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if self.screenplay?.characters.count == 0 {
            return 80
        } else {
            return 100
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
        header.contentView.backgroundColor = UIColor.screenLightGray
        header.moreButton.isHidden = true
        header.sectionLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 5).isActive = true
        header.navigationButton.isEnabled = false
        let font = UIFont.systemFont(ofSize: 16, weight: .bold)
        header.sectionLabel.font = font
        header.sectionLabel.text = "Characters"
        //header.subtitleLabel.text = "Character Arc"
        
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if let character = self.screenplay?.characters[indexPath.row],
            let screenplay = self.screenplay, editingStyle == .delete {
            FirebaseController.shared.delete(character: character, screenplay: screenplay)
            
            self.screenplay?.characters.remove(at: indexPath.row)
            reloadTableView()
        }
        
    }
    
    func reloadTableView() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
         guard let characterDetailVC = segue.destination as? CharacterDetailTableViewController else { return }
        if segue.identifier == "newCharacterSegue" {
           
        } else if segue.identifier == "characterSegue" {
            guard let indexPath = self.tableView.indexPathForSelectedRow,
                let character = self.screenplay?.characters[indexPath.row] else {
                return
            }
            characterDetailVC.character = character
        }
    }
    

}
