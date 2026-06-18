//
//  ActDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase

class ActDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: SaveBarButtonItem!
    
    var expandableSections: [ExpandableTableViewSection] = []
    var act: OutlineSection = .idea
    var sectionBesidesBeats: Int = 2

    var isExpandingCell: Bool = false
    var isCollapsingCell: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        saveButton.view = self
        
        setupExpandableSections()
        title = act.title
        tableView.backgroundColor = Theme.tableViewBackgroundColor
        tableView.separatorColor = tableView.backgroundColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
    }
    
    @objc func expandButtonTapped(sender: UIButton) {
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard
            let enlargedNavigationController = self.storyboard?.instantiateViewController(withIdentifier: "enlargedNavigationController") as? UINavigationController,
            let enlargedVC = enlargedNavigationController.children[0] as? EnlargedDescriptionViewController,
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        enlargedNavigationController.modalPresentationStyle = .fullScreen
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
        let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell",
                                                            for: indexPath) as? DescriptionTableViewCell
        // Configure the cell...
        descriptionCell?.contentView.backgroundColor = Theme.tableViewBackgroundColor
        descriptionCell?.delegate = self
        descriptionCell?.defaultHeight = self.getDefaultHeightOfCell()
        descriptionCell?.update(viewController: .actDetail,
                                section: indexPath.section,
                                act: self.act)
        descriptionCell?.expandButton.tag = indexPath.section
        descriptionCell?.expandButton.addTarget(self,
                                                action: #selector(expandButtonTapped(sender:)),
                                                for: .touchUpInside)
        return descriptionCell ?? UITableViewCell()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let descriptionCell = cell as? DescriptionTableViewCell else { return }

            if self.isExpandingCell {
                descriptionCell.descriptionTextView.becomeFirstResponder()
                descriptionCell.descriptionTextView.isHidden = false
                self.isExpandingCell = false
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.async {
            guard let descriptionCell = cell as? DescriptionTableViewCell else { return }

            if self.isCollapsingCell {
                descriptionCell.descriptionTextView.resignFirstResponder()
                descriptionCell.resignFirstResponder()
                self.isCollapsingCell = false
            }
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        switch section {
        case 0:
            // Overall Description
            let sectionHeader = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            sectionHeader.contentView.backgroundColor = Theme.tableViewBackgroundColor
            sectionHeader.moreButton.isHidden = true
            sectionHeader.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16,
                                         weight: .bold)
            sectionHeader.sectionLabel.font = font
            sectionHeader.sectionLabel.textColor = Theme.navTitleColor
            sectionHeader.sectionLabel.text = "Overall description".localized
            return sectionHeader
        case 1:
            if self.act == .idea { return nil }
            // Act Beats i section
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? ActBeatSectionHeader ?? ActBeatSectionHeader(reuseIdentifier: "header")
            switch act {
            case .idea:
                return nil
            default:
                header.titleLabel.text = "Act Beats".localized
                header.titleLabel.textColor = Theme.navTitleColor
                header.infoButton.addTarget(self,
                                            action: #selector(informationButtonTapped),
                                            for: .touchUpInside)
            }
            return header

        default:
            // Create Collapsible Header for Act Beats
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-self.sectionBesidesBeats].collapsed ? Theme.tableViewSectionCollapsedColor : Theme.tableViewSectionExpandedColor
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
            return 15
        default:
            // Act Beat Expandable sections
            return 60
        }
    }
    
}

extension ActDetailTableViewController: CollapsibleHeaderDelegate {
    
    func setupExpandableSections() {
        
        let sectionTitles = act.sectionsTitles
        for index in 0...sectionTitles.count-1 {
            let title = act.sectionsTitles[index]
            let subtitle = act.sectionSubTitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
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
            self.tableView.performBatchUpdates({
                 self.tableView.reloadSections(indexSet, with: .automatic)
            }, completion: nil)
            
        }
    
    }
}

extension ActDetailTableViewController: DescriptionDelegate {
    
    // MARK: DescriptionDelegate Methods
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        descriptionCell.descriptionTextView.text = text
        descriptionCell.textViewDidChange(descriptionCell.descriptionTextView)
    }
    
}

extension ActDetailTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}
