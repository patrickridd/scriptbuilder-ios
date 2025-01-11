//
//  CharacterDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/2/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Firebase

protocol NameChangedDelegate: class {
    func nameChanged(name: String)
}

protocol RoleCellSelected: class {
    var customSelected: Bool { get set}
    func updateRoleTextField(with row: Int)
}

class CharacterDetailTableViewController: UITableViewController {
    
    @IBOutlet weak var saveButton: SaveBarButtonItem!
    
    var expandableSections: [ExpandableTableViewSection] = []

    var character: Character?
    
    var isExpandingCell: Bool = false
    var isCollapsingCell: Bool = false
    
    var customSelected: Bool = false // RoleCellSelected

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveButton.view = self
        
        let font = UIFont.systemFont(ofSize: 20,
                                     weight: UIFont.Weight.light)
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font:font]
        self.tableView.backgroundColor = Theme.tableViewBackgroundColor
        self.tableView.separatorColor = Theme.tableViewBackgroundColor
        self.tableView.showsVerticalScrollIndicator = false

        self.setupExpandableSections()
      
        self.title = self.character?.name ?? "New Character".localized
      
       
        guard let _ = self.character else {
            let character = Character(name: "")
            self.character = character
            ScreenplayController.shared.add(character: character)
            return
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Resizes Cells Dynamically
        self.tableView.estimatedRowHeight = 100
        self.tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if character?.name == "" {
            character?.name = "Unnamed".localized
        }
    }
    
    // MARK: IBActions
    
    @objc func expandButtonTapped(sender: UIButton) {
        let storyboard = UIStoryboard(name: "Outline", bundle: nil)
        let indexPath = IndexPath(row: 0, section: sender.tag)
        guard
            let enlargedNavigationController = storyboard.instantiateViewController(withIdentifier: "enlargedNavigationController") as? UINavigationController,
            let enlargedVC = enlargedNavigationController.children[0] as? EnlargedDescriptionViewController,
            let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell
        else {
            return
        }
        enlargedNavigationController.modalPresentationStyle = .fullScreen
        enlargedVC.act = nil
        enlargedVC.character = self.character
        enlargedVC.text = descriptionCell.descriptionTextView.text
        enlargedVC.section = sender.tag
        enlargedVC.delegate = self
        enlargedVC.viewController = .characterDetail

        self.present(enlargedNavigationController,
                     animated: true,
                     completion: nil)
    }
    
    @objc func roleButtonTapped(_ sender: UIButton) {
        guard let rolePopTVC = self.storyboard?.instantiateViewController(withIdentifier: "rolePopoverTVC") as? RolePopoverTableViewController else { return }
        rolePopTVC.modalPresentationStyle = .popover // So it knows to present it as a popover

        // Access the popController instance and configure its settings
        let popController = rolePopTVC.popoverPresentationController
        popController?.permittedArrowDirections = [.up,
                                                   .down] // allow arrow to go both .up and .down
        popController?.delegate = self
        popController?.backgroundColor = .white // Makes the arrow white
        rolePopTVC.view.layer.cornerRadius = 0 // Unround the view's corner.
        popController?.sourceView = sender
        popController?.sourceRect = sender.bounds

        rolePopTVC.delegate = self // RoleCellSelected protocol

        // change size of view controller to the size of my three cells.
        let contentHeightSize = (Role.count+1) * 40
        rolePopTVC.preferredContentSize = CGSize(width: self.view.bounds.width,
                                                 height: CGFloat(contentHeightSize))

        self.present(rolePopTVC,
                     animated: true,
                     completion: nil)
    }
    
    // MARK: - TableView Data Source & Delegate Methods
    
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
           
           basicCharacterCell.character = character
           basicCharacterCell.updateCharacterInfo()
           basicCharacterCell.delegate = self
           
           if customSelected {
                basicCharacterCell.customRoleSelected()
           }
           basicCharacterCell.roleButton.addTarget(self,
                                                   action: #selector(roleButtonTapped(_:)),
                                                   for: .touchUpInside)
           return basicCharacterCell
        default:
            let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell",
                                                                for: indexPath) as? DescriptionTableViewCell
            descriptionCell?.delegate = self
            descriptionCell?.defaultHeight = self.getDefaultHeightOfCell()
            descriptionCell?.update(viewController: .characterDetail,
                                   section: indexPath.section,
                                   act: nil,
                                   character: self.character)
            descriptionCell?.expandButton.tag = indexPath.section
            descriptionCell?.expandButton.addTarget(self,
                                                   action: #selector(expandButtonTapped(sender:)),
                                                   for: .touchUpInside)
            return descriptionCell ?? UITableViewCell()
        }
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
        case 0,1:
            
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? SectionHeaderView ?? SectionHeaderView(reuseIdentifier: "header")
            header.contentView.backgroundColor = Theme.tableViewBackgroundColor
            header.moreButton.isHidden = true
            header.sectionLabel.bottomAnchor.constraint(equalTo: header.bottomAnchor, constant: 5).isActive = true
            header.navigationButton.isEnabled = false
            let font = UIFont.systemFont(ofSize: 16, weight: .bold)
            header.sectionLabel.font = font
            header.sectionLabel.text = (section == 1) ? "Character Arc".localized : "Basic Info".localized
            //header.subtitleLabel.text = "Character Arc"
            
            return header
        default:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
            header.contentView.backgroundColor = expandableSections[section-2].collapsed ? Theme.tableViewSectionCollapsedColor : Theme.tableViewSectionExpandedColor
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
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0 {
            return 10.0
        }
        return 0
    }
}

extension CharacterDetailTableViewController: DescriptionDelegate {
    
    func updatedText(_ text: String, in section: Int) {
        let indexPath = IndexPath(row: 0, section: section)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell else { return }
        
        descriptionCell.descriptionTextView.text = text
        descriptionCell.textViewDidChange(descriptionCell.descriptionTextView)
    }
    
    
}

extension CharacterDetailTableViewController: CollapsibleHeaderDelegate {
    
    func setupExpandableSections() {
        let sectionTitles = CharacterSection.sectionTitles
        for index in 0...sectionTitles.count-1 {
            let title = CharacterSection.sectionTitles[index]
            let subtitle = CharacterSection.sectionSubtitles[index]
            let section = ExpandableTableViewSection(sectionTitle: title,
                                                     sectionSubtitle: subtitle)
            expandableSections.append(section)
        }
    }
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section-2].collapsed
            // Toggle collapse
            self.expandableSections[section-2].collapsed = collapsed
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

extension CharacterDetailTableViewController: UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension CharacterDetailTableViewController: RoleCellSelected {
    
    func updateRoleTextField(with row: Int) {
        DispatchQueue.main.async {
            
            if let role = Role(rawValue: row) {
                self.character?.role = role.title.localized
                self.customSelected = false
            } else {
                self.customSelected = true
            }
            self.tableView.reloadSections(.init(integer: 0), with: .none)
        }
    }
}

extension CharacterDetailTableViewController: NameChangedDelegate {
    
    func nameChanged(name: String) {
        self.title = name
    }
    
}
