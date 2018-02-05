//
//  ActDetailTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/5/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ActDetailTableViewController: UITableViewController, CollapsibleHeaderDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    /*
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }
    */

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//
//        if section == 0 { return nil }
//        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "header") as? CollapsibleHeader ?? CollapsibleHeader(reuseIdentifier: "header")
//        header.contentView.backgroundColor = companyReviewSections[section-1].collapsed ? .white : UIColor.defaultTableViewSectionColor
//        header.titleLabel.text = companyReviewSections[section - 1].companyName
//        header.arrowImageView.image = #imageLiteral(resourceName: "collapsedTriangle")
//
//        let attributedReviewNumberText = NSAttributedString(string: "(\(companyReviewSections[section-1].reviews.count))", attributes: [NSForegroundColorAttributeName:UIColor.lightGray])
//
//        let subtitleFont = UIFont.systemFont(ofSize: 12)
//        let attributedCompanyCityText = NSAttributedString(string: companyReviewSections[section-1].companyCity ?? "City Unavailable", attributes: [NSForegroundColorAttributeName:UIColor.lightGray, NSFontAttributeName:subtitleFont])
//
//        header.subtitleLabel.attributedText = attributedCompanyCityText
//        header.numberOfReviewsLabel.attributedText = attributedReviewNumberText
//        header.setCollapsed(companyReviewSections[section-1].collapsed)
//
//        header.section = section
//        header.delegate = self
//        return header
//    }
    
    // MARK: CollapsibleHeaderDelegate
    
    func toggleSection(_ header: CollapsibleHeader, section: Int) {
        
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
