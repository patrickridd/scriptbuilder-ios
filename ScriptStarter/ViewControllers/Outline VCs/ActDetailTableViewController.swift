//
//  ActDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import GoogleMobileAds

class ActDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate, GADBannerViewDelegate, DescriptionDelegate, UIPopoverPresentationControllerDelegate {
    
    var expandableSections: [ExpandableTableViewSection] = []
    var act: Act = .idea
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-1297096402264538/3462578381"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
        self.title = act.title
        
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
       
        adBannerView.load(GADRequest())
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard let enlargedNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "enlargedNavigation") as? UINavigationController, let enlargedVC = enlargedNavigationController.childViewControllers[0] as? EnlargedDescriptionTableViewController, let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        enlargedVC.viewController = .actDetail
        enlargedVC.act = self.act
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        
        self.present(enlargedNavigationController, animated: true, completion: nil)
    }
    
    @objc func informationButtonTapped(sender: UIButton) {
        guard let informationPopTVC = self.storyboard?.instantiateViewController(withIdentifier: "informationPopTVC") as? InformationPopTableViewController else { return }
        informationPopTVC.modalPresentationStyle = .popover
        let popController = informationPopTVC.popoverPresentationController
        popController?.delegate = self
        popController?.backgroundColor = .white // Makes the arrow white
        popController?.permittedArrowDirections = [.up,.down] // allow arrow to go both .up and .down
        popController?.sourceView = sender
        popController?.sourceRect = sender.bounds
        let contentHeightSize = InformationNote.actBeats.contentHeight
        informationPopTVC.informationNote = .actBeats
        informationPopTVC.preferredContentSize = CGSize(width: self.view.bounds.width, height: CGFloat(contentHeightSize))
        informationPopTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        self.present(informationPopTVC, animated: true, completion: nil)
    }
    
    // MARK: DescriptionDelegate Methods
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        descriptionCell.descriptionTextView.text = text
    }
    
    func setupExpandableSections() {
        
        let sectionTitles = act.sectionsTitles
        for index in 0...sectionTitles.count-1 {
            let title = act.sectionsTitles[index]
            let subtitle = act.sectionSubTitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    // MARK: UIPopoverPresentationControllerDelegate Methods
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return act.sectionsTitles.count + 2 // + 2 for the "Overall description" + "Act Beats" section
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1 // Overall Act Description
        case 1:
            return 0 // Act Beats section
        default:
            return expandableSections[section-2].collapsed ? 0 : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }

        // Configure the cell...
        descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
         descriptionCell.update(viewController: .actDetail, section: indexPath.section, act: self.act)
        descriptionCell.expandButton.tag = indexPath.section
        descriptionCell.expandButton.addTarget(self, action: #selector(expandButtonTapped(sender:)), for: .touchUpInside)
        
        return descriptionCell
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch section {
        case 0:
            let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
            sectionHeader.moreButton.isHidden = true
            sectionHeader.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16, weight: .bold)
            sectionHeader.sectionLabel.font = font
            sectionHeader.sectionLabel.text = "Overall description"
            return sectionHeader
        case 1:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ActBeatSectionHeader ?? ActBeatSectionHeader(reuseIdentifier: "header")

            switch act {
            case .idea:
                header.titleLabel.text = ""
                header.infoButton.isHidden = true
            default:
            header.titleLabel.text = "Act Beats"
            header.infoButton.addTarget(self, action: #selector(informationButtonTapped), for: .touchUpInside)
            }
            return header

        default:
            // Create Collapsible Header for Act Beats
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-2].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = act.sectionsTitles[section-2]
            header.subtitleLabel.text = act.sectionSubTitles[section-2]
            header.setCollapsed(expandableSections[section-2].collapsed)
            header.section = section
            header.delegate = self
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return 45
        case 1:
            return 25
        default:
            return 60
        }
    }

//    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        switch indexPath.section {
//        case 0,1:
//            break
//        default:
//           self.view.endEditing(true)
//        }
//    }
    
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
    
    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section-2].collapsed
            // Toggle collapse
            self.expandableSections[section-2].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    
}
