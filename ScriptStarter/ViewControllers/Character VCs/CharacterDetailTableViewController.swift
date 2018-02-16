//
//  CharacterDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/2/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class CharacterDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate {
    
    var expandableSections: [ExpandableTableViewSection] = []

    var character: Character?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.backgroundColor = UIColor.screenLightGray
        self.setupExpandableSections()
    }
    
    func setupExpandableSections() {
        let sectionTitles = CharacterSection.sectionTitles
        for index in 0...sectionTitles.count-1 {
            let title = CharacterSection.sectionTitles[index]
            let subtitle = CharacterSection.sectionSubtitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        
        // 1. Intention - What does [Character] want?
        // 2. Why does [Character] want this
        // 3. What does [Character] need to do to get this?
        // 4. What obstacles are in [character]'s way?
        // 5. What flaws does [character] have?
        // 6. Does acheiving the intention fix any
        // 7. What the character needs
        return CharacterSection.sectionTitles.count + 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1 // Basic Character description
        default:
            return expandableSections[section-1].collapsed ? 0 : 1
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        // Configure the cell...
        switch indexPath.section {
        case 0:
           guard let basicCharacterCell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCharacterCell", for: indexPath) as? BasicInfoCharacterTableViewCell else { return UITableViewCell() }
           
           
           return basicCharacterCell
        default:
            guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
            descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
            return descriptionCell
        }
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch section {
        case 0,1:
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            header.contentView.backgroundColor = UIColor.screenLightGray
            header.moreButton.isHidden = true
            header.sectionLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 5).isActive = true
            header.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16, weight: .bold)
            header.sectionLabel.font = font
            header.sectionLabel.text = (section == 1) ? "Character Arc" : "Basic Info"
            //header.subtitleLabel.text = "Character Arc"
            
            return header
        default:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-1].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = CharacterSection.sectionTitles[section-1]
            header.subtitleLabel.text = CharacterSection.sectionSubtitles[section-1]
            header.setCollapsed(expandableSections[section-1].collapsed)
            header.section = section
            header.delegate = self
            
            return header
        }
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        // 1. Intention - What does [Character] want?
//        // 2. Why does [Character] want this
//        // 3. What does [Character] need to do to get this?
//        // 4. What obstacles are in [character]'s way?
//        // 5. What flaws does [character] have?
//        // 6. Does acheiving the intention fix any
//        let name = self.character?.name ?? "Character"
//
//        switch section {
//        case 0:
//            return "  Intention - What does \(name) want?"
//        case 1:
//            return "  Why does \(name) want this"
//        case 2:
//            return "  What does \(name) need to do to get this?"
//        case 3:
//            return "  What obstacles are in [character]'s way"
//        case 4:
//            return "  What flaws does \(name) have?"
//        case 5:
//            return "  Does acheiving the intention fix any flaws"
//        default:
//            return ""
//        }
//    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 1:
            return 30
        default:
            return 60
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        switch indexPath.section {
        case 0:
            return 90
        default:
            if self.view.frame.height >= 670 {
                return self.view.frame.height * (1/8)
            } else {
                return self.view.frame.height * (1/9)
            }
        }
    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection: Int) {
//        if let headerTitle = view as? UITableViewHeaderFooterView {
//            headerTitle.textLabel?.textColor = UIColor.screenDark
//            let font = UIFont.systemFont(ofSize: 14, weight: .semibold)
//            headerTitle.textLabel?.font = font
//        }
//    }

    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section-1].collapsed
            // Toggle collapse
            self.expandableSections[section-1].collapsed = collapsed
            header.setCollapsed(collapsed)
            
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
