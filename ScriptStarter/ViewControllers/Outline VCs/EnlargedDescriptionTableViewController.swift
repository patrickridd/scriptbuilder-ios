//
//  EnlargedDescriptionTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase
import FBAudienceNetwork
import MoPub

class EnlargedDescriptionTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var viewController: ViewController = .outline
    var section: Int = 0
    var act: Act?
    var scene: Scene?
    var character: Character?
    
    var interstitial: MPInterstitialAdController?
    var adService: MoPubAdServicLogic?
    var adView: MPAdView?
    var facebookAdService: FacebookAdService?

    var text: String?
    
    weak var delegate: DescriptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookAdService = FacebookAdService()
        adService = MoPubAdServic()

        self.tableView.backgroundColor = .screenLightGray
        setupNavigationBar()
        
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
    }
    
    lazy var descriptionCell: DescriptionTableViewCell? = {
        let indexPath = IndexPath(row: 0, section: 0)
        return tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        if InAppPurchases.shouldDisplayAds {
//            if let facebookAdView = self.facebookAdService?.loadBannerAd(for: self, with: kFBAdSizeHeight50Banner) {
////                facebookAdView.delegate = self
//                facebookAdView.loadAd()
//                tableView.tableFooterView?.frame = facebookAdView.frame
//                tableView.tableFooterView = facebookAdView
//            }
//        }
        
        if InAppPurchases.shouldDisplayAds {
            if let adView = self.adService?.loadBannerAd() {
                self.adView = adView
                adView.delegate = self
                tableView.tableFooterView?.frame = adView.frame
                tableView.tableFooterView = adView
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        // If interstitial is not ready load one
        if !interstitialIsReady(interstitial: interstitial) {
            interstitial = adService?.loadInterstitial(for: self)
        }
        
        // Display ad if we have one loaded and we have interstitial ads enabled
        display(interstitial: interstitial)
        
        // Make sure the keyboard is visible at all times on this screen
        guard let descriptionCell = descriptionCell else { return }
        descriptionCell.descriptionTextView.becomeFirstResponder()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
      
        guard
            let descriptionCell = descriptionCell,
            let text = descriptionCell.descriptionTextView.text
        else {
            return
        }
        
        delegate?.updatedText(text,
                              in: self.section)
    }

    // MARK: - IBAction Methods

    @IBAction func reduceScreenButtonTapped(_ sender: Any) {
        self.dismiss(animated: true,
                     completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        saveButton.isEnabled = false
        guard
            let descriptionCell = descriptionCell,
            let text = descriptionCell.descriptionTextView.text
        else {
            self.saveScreenplay {
                DispatchQueue.main.async {
                    self.saveButton.isEnabled = true
                }
            }
            return
        }
        
        delegate?.updatedText(text,
                              in: self.section)
        self.saveScreenplay {
            DispatchQueue.main.async {
                self.saveButton.isEnabled = true
            }
        }
    }
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        var title: String = screenplay?.title ?? ""
        var font = UIFont.systemFont(ofSize: 20,
                                     weight: .semibold)
        switch viewController {
        case .actDetail:
            title = act?.title ?? title
            font = UIFont.systemFont(ofSize: 20,
                                     weight: .light)
        case .characterDetail:
            title = character?.name ?? title
            font = UIFont.systemFont(ofSize: 20,
                                     weight: .light)
        case .outline, .sceneDetail:
            break
        }
        // Remove Navigation bar shadow and borderline
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = false
        navigationController?.navigationBar.topItem?.title = title
        let attributes = [NSAttributedString.Key.foregroundColor: UIColor.screenDark,
                          NSAttributedString.Key.font: font]
        navigationController?.navigationBar.titleTextAttributes = attributes
           
        navigationController?.navigationBar.tintColor = .screenLightBlue
        navigationController?.navigationBar.barTintColor = .white
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as? DescriptionTableViewCell else { return UITableViewCell() }
        
        descriptionCell.update(viewController: self.viewController,
                               section: section,
                               act: self.act,
                               character: self.character,
                               scene: self.scene)
        descriptionCell.backgroundColor = .screenLightGray
        addToolBar(textView: descriptionCell.descriptionTextView)
        
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderSubtitle ?? SectionHeaderSubtitle(reuseIdentifier: "header")
        
        switch viewController {
        case .outline:
            sectionHeader.subtitleLabel.text = "Overall description".localized
            switch self.section {
            case 0: // "Basic Idea (Log Line)"
                sectionHeader.sectionLabel.text = "Idea".localized
            default: // "Acts"
                sectionHeader.sectionLabel.text = act?.title
            }
            
        case .actDetail:
            guard let act = act else { break }
            if self.section == 0 {
                sectionHeader.sectionLabel.text = act.title
                sectionHeader.subtitleLabel.text = "Overall description".localized
            } else {
                sectionHeader.sectionLabel.text = act.sectionsTitles[self.section-2]
                sectionHeader.subtitleLabel.text = act.sectionSubTitles[self.section-2]
            }
        case .characterDetail:
            sectionHeader.sectionLabel.text = CharacterSection.sectionTitles[self.section-2]
            sectionHeader.subtitleLabel.text = CharacterSection.sectionSubtitles[self.section-2]
        case .sceneDetail:
            sectionHeader.sectionLabel.text = Scene.sceneTitles[self.section]
        }
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let noBannerAdConstant: CGFloat = InAppPurchases.shouldDisplayAds ? 0 : adView?.frame.height ?? 0
        
        return self.view.frame.height * (1/3) + noBannerAdConstant
    }

}
