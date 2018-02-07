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

//      1.  Old World - What is life like before the story begins?
//      2.  Inciting incident - What event, person, or thing creates disharmony in the old world?
//      3.  Call to Adventure - What must your hero or world do to bring harmony?
//      4.  Theme - Are there any premises, beliefs, or ideas that can be tested in the adventure?
//      5. I don't want to go - Does your hero(s) have doubts about the adventure ahead?
//      6. I must go - What convinces your hero(s) to go on their adventure?
//      7.  Enemy at the gates - Are there any obstacles or enemies in getting the adventure started?
        
        return act.sectionsTitles.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return expandableSections[section].collapsed ? 0 : 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell", for: indexPath) as? DescriptionTableViewCell else { return UITableViewCell() }

        // Configure the cell...
        descriptionCell.contentView.backgroundColor = UIColor.screenLightGray
        
        switch act {
        case .one:
            switch indexPath.row {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.act1.oldWorldDescription
            case 1: descriptionCell.descriptionTextView.text = screenplay?.act1.incitingIncident
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act1.callToAdventure
            case 3: descriptionCell.descriptionTextView.text = screenplay?.act1.theme
            case 4: descriptionCell.descriptionTextView.text = screenplay?.act1.refusal
            case 5: descriptionCell.descriptionTextView.text = screenplay?.act1.reasonToAdventure
            case 6: descriptionCell.descriptionTextView.text = screenplay?.act1.enemyAtTheGates
            default:
                break
            }
        case .two:
            switch indexPath.row {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.act2.newWorldDescription
            case 1: descriptionCell.descriptionTextView.text = screenplay?.act2.enemiesFriends
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act2.obstacles
            case 3: descriptionCell.descriptionTextView.text = screenplay?.act2.theDeadlyEncounter
            case 4: descriptionCell.descriptionTextView.text = screenplay?.act2.celebrate
            case 5: descriptionCell.descriptionTextView.text = screenplay?.act2.stormGathers
            case 6: descriptionCell.descriptionTextView.text = screenplay?.act2.badGuysStrikeBack
            case 7: descriptionCell.descriptionTextView.text = screenplay?.act2.allIsLost
            default:
                break
            }
        case .three:
            switch indexPath.row {
            case 0: descriptionCell.descriptionTextView.text = screenplay?.act3.theUltimateAnswer
            case 1: descriptionCell.descriptionTextView.text = screenplay?.act3.rewards
            case 2: descriptionCell.descriptionTextView.text = screenplay?.act3.untangleStory
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

        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
       
        header.contentView.backgroundColor = expandableSections[section].collapsed ? .white : UIColor.screenLightGray
        header.titleLabel.text = act.sectionsTitles[section]
        header.subtitleLabel.text = act.sectionSubTitles[section]
        

//        let attributedReviewNumberText = NSAttributedString(string: "(\(companyReviewSections[section-1].reviews.count))", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
//
//        let subtitleFont = UIFont.systemFont(ofSize: 12)
//        let attributedCompanyCityText = NSAttributedString(string: companyReviewSections[section-1].companyCity ?? "City Unavailable", attributes: [NSForegroundColorAttributeName:UIColor.lightGray, NSFontAttributeName:subtitleFont])

       // header.subtitleLabel.attributedText = attributedCompanyCityText
      //  header.numberOfReviewsLabel.attributedText = attributedReviewNumberText
        header.setCollapsed(expandableSections[section].collapsed)

        header.section = section
        header.delegate = self
        return header
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        DispatchQueue.main.async {
            let collapsed = !self.expandableSections[section].collapsed
            // Toggle collapse
            self.expandableSections[section].collapsed = collapsed
            header.setCollapsed(collapsed)
           
            // Reload section tapped
            let indexSet = IndexSet(integer: section)
            self.tableView.beginUpdates()
            self.tableView.reloadSections(indexSet, with: .automatic)
            self.tableView.endUpdates()
        }
    }
    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
