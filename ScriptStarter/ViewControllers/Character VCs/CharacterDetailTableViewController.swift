//
//  CharacterDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/2/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class CharacterDetailTableViewController: UITableViewController, DescriptionDelegate, CollapsibleHeaderDelegate {
    
    var expandableSections: [ExpandableTableViewSection] = []

    var character: Character?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = character?.name
        self.tableView.backgroundColor = UIColor.screenLightGray
        self.setupExpandableSections()
    }
    
    
    // MARK: IBActions
    
    @objc func expandButtonTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Outline", bundle: nil)
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard let enlargedNavigationController =
            storyboard.instantiateViewController(withIdentifier: "enlargedNavigation") as? UINavigationController, let enlargedVC = enlargedNavigationController.childViewControllers[0] as? EnlargedDescriptionTableViewController, let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        enlargedVC.act = nil
        enlargedVC.character = self.character
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        enlargedVC.viewController = .characterDetail

        self.present(enlargedNavigationController, animated: true, completion: nil)
    }
   
    @IBAction func saveButtonTapped(_ sender: Any) {
        self.saveScreenplay()
    }
    
    @objc func archTypeButtonTapped() {
        
    }
    

    // MARK: - Table view data source

    // Helper method that helps setup datasource
    func setupExpandableSections() {
        let sectionTitles = CharacterSection.sectionTitles
        for index in 0...sectionTitles.count-1 {
            let title = CharacterSection.sectionTitles[index]
            let subtitle = CharacterSection.sectionSubtitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title, sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        // Basic description
        // Character arc
        // 1. Intention - What does [Character] want?
        // 2. Why does [Character] want this
        // 3. What does [Character] need to do to get this?
        // 4. What obstacles are in [character]'s way?
        // 5. What flaws does [character] have?
        // 6. Does acheiving the intention fix any
        // 7. What the character needs
        return CharacterSection.sectionTitles.count + 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        switch section {
        case 0:
            return 1 // Basic Character description
        case 1:
            return 0
        default:
            return expandableSections[section-2].collapsed ? 0 : 1
        }
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Configure the cell...
        switch indexPath.section {
        case 0:
           guard let basicCharacterCell = tableView.dequeueReusableCell(withIdentifier: "basicInfoCharacterCell", for: indexPath) as? BasicInfoCharacterTableViewCell else { return UITableViewCell() }
           basicCharacterCell.character = self.character
           
           return basicCharacterCell
        default:
            guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }
            descriptionCell.update(viewController: .characterDetail, section: indexPath.section, act: nil, character: self.character)
            descriptionCell.expandButton.tag = indexPath.section
            descriptionCell.expandButton.addTarget(self, action: #selector(expandButtonTapped(sender:)), for: .touchUpInside)
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
            header.contentView.backgroundColor = expandableSections[section-2].collapsed ? .white : UIColor.screenLightGray
            header.titleLabel.text = CharacterSection.sectionTitles[section-2]
            header.subtitleLabel.text = CharacterSection.sectionSubtitles[section-2]
            header.setCollapsed(expandableSections[section-2].collapsed)
            header.section = section
            header.delegate = self
            
            return header
        }
    }
    
    
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
    
    // MARK: DescriptionDelegate Methods
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        descriptionCell.descriptionTextView.text = text
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
