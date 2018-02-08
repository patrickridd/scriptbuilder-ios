//
//  ActDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ActDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    var expandableSections: [ExpandableTableViewSection] = []
    var act: Act = .one
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupExpandableSections()
        self.title = act.title
        
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.tableView.separatorColor = self.tableView.backgroundColor

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
        
        switch act {
        case .one:
            switch indexPath.section {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.actOneDescription
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act1.oldWorldDescription
            case 3: descriptionCell.descriptionTextView.text = screenplay?.act1.incitingIncident
            case 4: descriptionCell.descriptionTextView.text = screenplay?.act1.callToAdventure
            case 5: descriptionCell.descriptionTextView.text = screenplay?.act1.theme
            case 6: descriptionCell.descriptionTextView.text = screenplay?.act1.refusal
            case 7: descriptionCell.descriptionTextView.text = screenplay?.act1.reasonToAdventure
            case 8: descriptionCell.descriptionTextView.text = screenplay?.act1.enemyAtTheGates
            default:
                break
            }
        case .two:
            switch indexPath.section {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.actTwoDescription
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act2.newWorldDescription
            case 3: descriptionCell.descriptionTextView.text = screenplay?.act2.enemiesFriends
            case 4: descriptionCell.descriptionTextView.text = screenplay?.act2.obstacles
            case 5: descriptionCell.descriptionTextView.text = screenplay?.act2.theDeadlyEncounter
            case 6: descriptionCell.descriptionTextView.text = screenplay?.act2.celebrate
            case 7: descriptionCell.descriptionTextView.text = screenplay?.act2.stormGathers
            case 8: descriptionCell.descriptionTextView.text = screenplay?.act2.badGuysStrikeBack
            case 9: descriptionCell.descriptionTextView.text = screenplay?.act2.allIsLost
            default:
                break
            }
        case .three:
            switch indexPath.section {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.actThreeDescription
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act3.theUltimateAnswer
            case 3: descriptionCell.descriptionTextView.text = screenplay?.act3.rewards
            case 4: descriptionCell.descriptionTextView.text = screenplay?.act3.untangleStory
            default:
                break
            }
        }
        
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
            header.titleLabel.text = "Act Beats"
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
