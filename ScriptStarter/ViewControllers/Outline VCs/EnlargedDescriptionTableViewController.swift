//
//  EnlargedDescriptionTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import GoogleMobileAds

class EnlargedDescriptionTableViewController: UITableViewController, GADBannerViewDelegate {
    
    let name = "EnlargedDescriptionTableViewController"
    var viewController: ViewController = .outline
    var section: Int = 0
    var act: Act?
    var character: Character?

    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-1297096402264538/3462578381"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var text: String?
    
    weak var delegate: DescriptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .screenLightGray
        setupNavigationBar()
        
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adBannerView.load(GADRequest())
        
        guard let tracker = GAI.sharedInstance().defaultTracker else { return }
        tracker.set(kGAIScreenName, value: self.name)
        
        
        guard let builder = GAIDictionaryBuilder.createScreenView() else { return }
        tracker.send(builder.build() as [NSObject : AnyObject])
    }

    // MARK: - IBAction Methods

    @IBAction func reduceScreenButtonTapped(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell, let text = descriptionCell.descriptionTextView.text else { return }
        delegate?.updatedText(text, in: self.section)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        var title: String = screenplay?.title ?? ""
        var font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        switch viewController {
        case .actDetail:
            title = act?.title ?? title
            font = UIFont.systemFont(ofSize: 20, weight: .light)
        case .characterDetail:
            title = character?.name ?? title
            font = UIFont.systemFont(ofSize: 20, weight: .light)
        case .outline, .sceneDetail:
            break
        }
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = title
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.screenDark, NSAttributedStringKey.font: font]
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
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
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as? DescriptionTableViewCell else { return UITableViewCell() }
        
        descriptionCell.update(viewController: self.viewController, section: section, act: self.act )
        descriptionCell.backgroundColor = .screenLightGray
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderSubtitle ?? SectionHeaderSubtitle(reuseIdentifier: "header")
        
        switch viewController {
        case .outline:
            sectionHeader.subtitleLabel.text = "Overall description"
            switch self.section {
            case 0: // "Basic Idea (Log Line)"
                sectionHeader.sectionLabel.text = "Basic Idea (Log Line)"
            default: // "Acts"
                sectionHeader.sectionLabel.text = act?.title
            }
            
        case .actDetail:
            guard let act = act else { break }
            if self.section == 0 {
                sectionHeader.sectionLabel.text = act.title
                sectionHeader.subtitleLabel.text = "Overall description"
            } else {
                sectionHeader.sectionLabel.text = act.sectionsTitles[self.section-2]
                sectionHeader.subtitleLabel.text = act.sectionSubTitles[self.section-2]
            }
        case .characterDetail:
            sectionHeader.sectionLabel.text = CharacterSection.sectionTitles[self.section-2]
            sectionHeader.subtitleLabel.text = CharacterSection.sectionSubtitles[self.section-2]
        case .sceneDetail:
            sectionHeader.sectionLabel.text = Scene.sceneTitles[self.section-1]
        }
        return sectionHeader
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * (1/3)
    }

}
