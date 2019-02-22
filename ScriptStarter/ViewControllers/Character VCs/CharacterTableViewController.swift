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
import MBProgressHUD

class CharacterTableViewController: UITableViewController {
    
    @IBOutlet weak var addCharacterButton: UIBarButtonItem!
    
    var interstitial: GADInterstitial?
    var rewardBasedAd: GADRewardBasedVideoAd?
    
    var products: [SKProduct]?
    var loadingNotification = MBProgressHUD()

    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = GoogleAds.bannerAdUnitId
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var roleCharacterSections: [CharacterTableViewSection] = [] {
        didSet {
            self.reloadTableView()
        }
    }
    
    var newCharacter: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let rightSwipe = UISwipeGestureRecognizer(target: self,
                                                  action: #selector(handleRightSwipe(sender:)))
        rightSwipe.direction = .right
        view.addGestureRecognizer(rightSwipe)
        
        if newCharacter, InAppPurchases.characterFeatureEnabled {
            self.performSegue(withIdentifier: "newCharacterSegue",
                              sender: nil)
        }
    
        // If RewardBased Ad is not ready load one
        if !rewardBasedAdReady(rewardBasedAd: rewardBasedAd) {
            rewardBasedAd = GADRewardBasedVideoAd.sharedInstance()
            rewardBasedAd?.delegate = self
            rewardBasedAd?.load(GADRequest(),
                                withAdUnitID: GoogleAds.characterBuilderRewardAdId)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tableView.backgroundColor = UIColor.screenLightGray
        
        self.tableView.reloadData()
        setupNavigationBar()
        setupRoleSections()
        
        // If RewardBased Ad is not ready load one
        if !rewardBasedAdReady(rewardBasedAd: rewardBasedAd) {
            rewardBasedAd = GADRewardBasedVideoAd.sharedInstance()
            rewardBasedAd?.delegate = self
            rewardBasedAd?.load(GADRequest(),
                                withAdUnitID: GoogleAds.characterBuilderRewardAdId)
        }

        if InAppPurchases.shouldDisplayAds {
            adBannerView.load(GADRequest())
        }
        
        // Retrieves in app purchases from apple
        InAppPurchases.store.requestProducts { (_, products) in
            self.products = products
        }
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // If interstitial is not ready load one
        if !interstitialIsReady(interstitial: interstitial) {
            interstitial = createAndLoadInterstitial()
        }
        
        // Display ad if we have one loaded and we have interstitial ads enabled
        display(interstitial: interstitial)
        checkForCharacterFeatureEnabled()
    }
    
    // MARK: UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = self.screenplay?.title
        let attributes =  [NSAttributedString.Key.foregroundColor: UIColor.screenDark,
                           NSAttributedString.Key.font: UIFont.systemFont(ofSize: 20,
                                                                          weight: .semibold)]
        self.navigationController?.navigationBar.titleTextAttributes = attributes
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
        let backButton = UIBarButtonItem(title: "Home".localized,
                                         style: .plain,
                                         target: self,
                                         action: #selector(handleRightSwipe(sender:)))
        self.navigationController?.navigationBar.topItem?.leftBarButtonItem = backButton
    }
    
    @objc func checkForCharacterFeatureEnabled() {
        if InAppPurchases.characterFeatureEnabled || self.characterBuilderRewarded() {
            enableView()
        } else {
            disableView()
            presentIapAlert()
        }
    }
    
    func disableView() {
        self.view.alpha = 0.8
        self.view.isUserInteractionEnabled = false
        self.addCharacterButton.isEnabled = false
    }
    
    func enableView() {
        self.view.alpha = 1.0
        self.view.isUserInteractionEnabled = true
        self.addCharacterButton.isEnabled = true
    }
    
    func presentIapAlert() {
        let alert = UIAlertController(title: "Character Builder disabled\n😥".localized,
                                      message: "The Character Builder feature requires a one time purchase.".localized,
                                      preferredStyle: .alert)
        let purchaseAction = UIAlertAction(title: "$0.99 😎".localized,
                                           style: .default) { [weak self] (_) in
            if let characterFeatureProduct = self?.products?.filter({$0.productIdentifier == InAppPurchases.characterFeatureIdentifier}).first {
                InAppPurchases.store.delegate = self
                InAppPurchases.store.buyProduct(characterFeatureProduct)
            }
        }
        alert.addAction(purchaseAction)
        
        let restoreAction = UIAlertAction(title: "Restore".localized,
                                          style: .default) { [weak self] (_) in
            InAppPurchases.store.delegate = self
            InAppPurchases.store.restorePurchases()
        }
        alert.addAction(restoreAction)
      
        let tryAction = UIAlertAction(title: "Try by watching Ad 🎥".localized,
                                      style: .default) { [weak self] (_) in
                                        
            guard let strongSelf = self else { return }
            strongSelf.rewardBasedAd?.present(fromRootViewController: strongSelf)
            
        }
        
        if rewardBasedAdReady(rewardBasedAd: rewardBasedAd) {
            alert.addAction(tryAction)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized,
                                         style: .default,
                                         handler: nil)
        alert.addAction(cancelAction)
        present(alert,
                animated: true,
                completion: nil)
    }
    
    // MARK: UI Methods
    
    func showActivityIndicator() {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
            self.loadingNotification =
                MBProgressHUD.showAdded(to: self.view,
                                        animated: true)
            self.loadingNotification.mode = MBProgressHUDMode.indeterminate
            self.loadingNotification.animationType = .fade
            self.loadingNotification.label.text = "loading".localized
        }
    }
    
    func hideActivityIndicator(success: Bool, displayImage: Bool, completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            self.loadingNotification.mode = .customView
            
            if !displayImage {
                self.loadingNotification.hide(animated: true)
                return
            }
            
            if success {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "blueCheckMarkAsset 1"))
                self.loadingNotification.label.text = "success".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                completion?()
            } else {
                self.loadingNotification.customView = UIImageView(image: #imageLiteral(resourceName: "redFrownieFaceAsset 1"))
                self.loadingNotification.label.text = "failed".localized
                self.loadingNotification.hide(animated: true, afterDelay: 1)
                completion?()
            }
        }
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

    // MARK: - Data Source helper methods
    
    func setupRoleSections() {
        guard let screenplay = screenplay else { return }
        
        var characterTableViewSections: Set<CharacterTableViewSection> = []
        
        // Avoid duplicate role titles
        for character in screenplay.characters {
            if let role = character.role, role != "" {
                var roleCharactersArray: [Character] = []
                let roleCharacters = self.screenplay?.characters.filter({ $0.role == role })
                roleCharactersArray.append(contentsOf: roleCharacters!)
                let characterSection = CharacterTableViewSection(roleTitle: role,
                                                                 characters: roleCharactersArray)
                characterTableViewSections.insert(characterSection)
            } else {
                let noRoleCharactersSet = screenplay.characters.filter({ $0.role == nil || $0.role == "" })
                var noRoleCharactersArray: [Character] = []
                noRoleCharactersArray.append(contentsOf:noRoleCharactersSet)
                
                
                let noRoleCharacterSection = CharacterTableViewSection(roleTitle: "Character".localized,
                                                                       characters: noRoleCharactersArray)
                characterTableViewSections.insert(noRoleCharacterSection)
            }
        }
        
        var orderedCharacterSections: [CharacterTableViewSection] = []
        orderedCharacterSections.append(contentsOf: characterTableViewSections)
        orderedCharacterSections.sort(by: {$0.roleTitle < $1.roleTitle})
        
        self.roleCharacterSections = orderedCharacterSections
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        if roleCharacterSections.count == 0 {
            return 1
        } else {
              return self.roleCharacterSections.count
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if roleCharacterSections.count == 0 {
            return 1
        } else {
            
        let roleCharacterSection = self.roleCharacterSections[section]
            return roleCharacterSection.characters.count
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      
        if roleCharacterSections.count == 0 {
            guard let noCharacterCell = tableView.dequeueReusableCell(withIdentifier: "noCharacterCell", for: indexPath) as? NoCharacterTableViewCell else {
                return UITableViewCell()
            }
            return noCharacterCell
            
        } else {
            guard
                let characterCell = tableView.dequeueReusableCell(withIdentifier: "characterCell",
                                                                  for: indexPath) as? CharacterTableViewCell
            else {
                return UITableViewCell()
            }
            
            // Configure the cell...
            let characterSection = self.roleCharacterSections[indexPath.section]
            let character = characterSection.characters[indexPath.row]
            characterCell.updateCell(with:character)
            
            return characterCell
        }
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
      
        if self.roleCharacterSections.count == 0 {
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            header.contentView.backgroundColor = UIColor.screenLightGray
            header.moreButton.isHidden = true
            header.sectionLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 5).isActive = true
            header.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16, weight: .bold)
            header.sectionLabel.font = font
            header.sectionLabel.text = "Characters".localized
            header.sectionLabel.textColor = UIColor.screenDarkGray
            //header.subtitleLabel.text = "Character Arc"
            
            return header
    
        } else {
            // Get Role title section
            let roleTitle = self.roleCharacterSections[section].roleTitle
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            header.contentView.backgroundColor = UIColor.screenLightGray
            header.moreButton.isHidden = true
            header.sectionLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 5).isActive = true
            header.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16, weight: .bold)
            
            header.sectionLabel.font = font
            header.sectionLabel.text = roleTitle
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard let screenplay = self.screenplay else { return }
        
        let character = self.roleCharacterSections[indexPath.section].characters[indexPath.row]
        
        FirebaseController.shared.delete(character: character,
                                         withScreenplay: screenplay)
        
        screenplay.characters.remove(character)
        
        self.roleCharacterSections[indexPath.section].characters.remove(at: indexPath.row)
        if roleCharacterSections[indexPath.section].characters.count == 0 {
            self.roleCharacterSections.remove(at: indexPath.section)
        }
        
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        if indexPath.row == 0 && self.roleCharacterSections.count == 0 {
            return .none
        } else {
            return .delete
        }
    }
    
    func reloadTableView() {
        self.tableView.reloadData()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
         guard let characterDetailVC = segue.destination as? CharacterDetailTableViewController else { return }
        if segue.identifier == "newCharacterSegue" {
           
        } else if segue.identifier == "characterSegue" {
            guard let indexPath = self.tableView.indexPathForSelectedRow else {
                return
            }
            
            let character = self.roleCharacterSections[indexPath.section].characters[indexPath.row]
            characterDetailVC.character = character
        }
    }
    

}

extension CharacterTableViewController: GADBannerViewDelegate {
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        tableView.tableFooterView?.frame = bannerView.frame
        tableView.tableFooterView = bannerView
    }
    
}

extension CharacterTableViewController: InAppPurchaseDelegate {
    
    func startingTransaction() {
        self.showActivityIndicator()
    }
    
    func didCompleteTransaction(for productIdentifier: String,
                                with error: Error?,
                                displayLoadingImage: Bool = true) {
        
        self.hideActivityIndicator(success: error == nil,
                                   displayImage: displayLoadingImage)
        if let error = error {
            present(error: error)
        }
        if productIdentifier == InAppPurchases.characterFeatureIdentifier ||
           productIdentifier.isEmpty {
            checkForCharacterFeatureEnabled()
        }
    }
}
