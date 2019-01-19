//
//  ActDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import GoogleMobileAds
import Firebase

class ActDetailTableViewController: UITableViewController {
    
    var expandableSections: [ExpandableTableViewSection] = []
    var act: Act = .idea
    var sectionBesidesBeats: Int = 2
    
    lazy var adBannerView: GADBannerView = {
        let adBannerView = GADBannerView(adSize: kGADAdSizeSmartBannerPortrait)
        adBannerView.adUnitID = "ca-app-pub-1297096402264538/3462578381"
        adBannerView.delegate = self
        adBannerView.rootViewController = self
        
        return adBannerView
    }()
    
    var isExpandingCell: Bool = false
    var isCollapsingCell: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
        
        title = act.title
        tableView.backgroundColor = UIColor.screenLightGray
        tableView.separatorColor = self.tableView.backgroundColor
        tableView.keyboardDismissMode = .onDrag
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //reloadSceneSection()
        adBannerView.load(GADRequest())
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
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
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard
            let enlargedNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "enlargedNavigation") as? UINavigationController,
            let enlargedVC = enlargedNavigationController.children[0] as? EnlargedDescriptionTableViewController,
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        
        enlargedVC.viewController = .actDetail
        enlargedVC.act = self.act
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        
        self.present(enlargedNavigationController,
                     animated: true,
                     completion: nil)
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
        let contentHeightSize = InformationNote.actBeats.contentHeight
        informationPopTVC.informationNote = .actBeats
        informationPopTVC.preferredContentSize = CGSize(width: self.view.bounds.width,
                                                        height: CGFloat(contentHeightSize))
        informationPopTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        self.present(informationPopTVC,
                     animated: true,
                     completion: nil)
    }
    
    @objc func navigateToNewScene() {
        self.performSegue(withIdentifier: "newSceneSegue", sender: nil)
//        guard let sceneDetail = self.storyboard?.instantiateViewController(withIdentifier: "sceneDetailVC") as? SceneDetailTableViewController else { return }
//        sceneDetail.act = self.act
//        self.navigationController?.pushViewController(sceneDetail, animated: true)
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
            return 0 // Act Beats Section Header
            
        default:     // Act Beats
            return expandableSections[section-self.sectionBesidesBeats].collapsed ? 0 : 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
//        case 1:
//            var sceneCount = 0
//            switch act {
//            case .one:
//                sceneCount = self.screenplay?.act1.scenes.count ?? 0
//            case .two:
//                sceneCount = self.screenplay?.act2.scenes.count ?? 0
//            case .three:
//                sceneCount = self.screenplay?.act3.scenes.count ?? 0
//            default:
//                break
//            }
//            if sceneCount == 0 {
//                 guard let noSceneCell = tableView.dequeueReusableCell(withIdentifier: "noSceneIdentifier", for: indexPath) as?
//                        NoCharacterTableViewCell else { return UITableViewCell() }
//
//                return noSceneCell
//            } else {
//                 guard let sceneCell = tableView.dequeueReusableCell(withIdentifier: "sceneCell", for: indexPath) as? SceneTableViewCell else { return UITableViewCell() }
//
//                var scene: Scene
//                switch act {
//                case .one:
//                    guard let act1Scenes = self.screenplay?.act1.scenes else { break }
//                    scene = act1Scenes[indexPath.row]
//                    sceneCell.update(with: scene)
//                case .two:
//                    guard let act2Scenes = self.screenplay?.act2.scenes else { break }
//                    scene = act2Scenes[indexPath.row]
//                    sceneCell.update(with: scene)
//                case .three:
//                    guard let act3Scenes = self.screenplay?.act3.scenes else { break }
//                    scene = act3Scenes[indexPath.row]
//                    sceneCell.update(with: scene)
//                default:
//                    break
//                }
//
//                return sceneCell
//            }
        default:
            guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
            
            // Configure the cell...
            descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
            descriptionCell.delegate = self
            descriptionCell.defaultHeight = self.getDefaultHeightOfCell()
            descriptionCell.update(viewController: .actDetail,
                                   section: indexPath.section,
                                   act: self.act)
            descriptionCell.expandButton.tag = indexPath.section
            descriptionCell.expandButton.addTarget(self,
                                                   action: #selector(expandButtonTapped(sender:)),
                                                   for: .touchUpInside)

            return descriptionCell
        }
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
           
            guard let descriptionCell = cell as?DescriptionTableViewCell else { return }
            
            if self.isExpandingCell {
                descriptionCell.descriptionTextView.becomeFirstResponder()
                self.isExpandingCell = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        guard let descriptionCell = cell as?DescriptionTableViewCell else { return }
        
        if self.isCollapsingCell {
            descriptionCell.descriptionTextView.resignFirstResponder()
            descriptionCell.resignFirstResponder()
            self.isCollapsingCell = false
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch section {
        case 0:
            // Overall Description
            let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            sectionHeader.contentView.backgroundColor = UIColor.screenLightGray
            sectionHeader.moreButton.isHidden = true
            sectionHeader.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16,
                                         weight: .bold)
            sectionHeader.sectionLabel.font = font
            sectionHeader.sectionLabel.text = "Overall description"
            return sectionHeader
       
//        case 1:
//            if self.act == .idea { return nil }
//            // Scenes Header
//            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SceneHeader ?? SceneHeader(reuseIdentifier: "header")
//            header.titleLabel.text = "Scenes"
//            header.plusButtonCover.addTarget(self, action: #selector(navigateToNewScene), for: .touchUpInside)
//            return header
        case 1:
            if self.act == .idea { return nil }
            // Act Beats i section
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ActBeatSectionHeader ?? ActBeatSectionHeader(reuseIdentifier: "header")
            switch act {
            case .idea:
                return nil
            default:
                header.titleLabel.text = "Act Beats"
                header.infoButton.addTarget(self,
                                            action: #selector(informationButtonTapped),
                                            for: .touchUpInside)
            }
            return header

        default:
            // Create Collapsible Header for Act Beats
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-self.sectionBesidesBeats].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = act.sectionsTitles[section-self.sectionBesidesBeats]
            header.subtitleLabel.text = act.sectionSubTitles[section-self.sectionBesidesBeats]
            header.setCollapsed(expandableSections[section-self.sectionBesidesBeats].collapsed)
            header.section = section
            header.delegate = self
            return header
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            // Overall description header
            return 45
        case 1:
            // Act Beats Header
            if self.act == .idea { return 0.0001 }
            return 25
        default:
            // Act Beat Expandable sections
            return 60
        }
    }
    
}

extension ActDetailTableViewController: CollapsibleHeaderDelegate {
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section-self.sectionBesidesBeats].collapsed
            // Toggle collapse
            self.expandableSections[section-self.sectionBesidesBeats].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            if collapsed {
                self.isExpandingCell = false
                self.isCollapsingCell = true
            } else {
                self.isExpandingCell = true
                self.isCollapsingCell = false
            }
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet,
                                          with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
}

extension ActDetailTableViewController: GADBannerViewDelegate {
    
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

extension ActDetailTableViewController: DescriptionDelegate {
    
    // MARK: DescriptionDelegate Methods
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        descriptionCell.descriptionTextView.text = text
    }
    
}

extension ActDetailTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
