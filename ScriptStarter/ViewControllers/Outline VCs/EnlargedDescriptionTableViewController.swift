//
//  EnlargedDescriptionTableViewController.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Hero

class EnlargedDescriptionTableViewController: UITableViewController {
    
    var screenplay: Screenplay? {
        return ScreenplayController.shared.currentScreenplay
    }
    
    var text: String?
    var section: Int = 0
    weak var delegate: DescriptionDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = .screenLightGray
        setupNavigationBar()
    }

    // MARK: - IBAction Methods

    @IBAction func reduceScreenButtonTapped(_ sender: Any) {
        let indexPath = IndexPath(row: 0, section: 0)
        guard let descriptionCell = tableView.cellForRow(at: indexPath) as? DescriptionTableViewCell, let text = descriptionCell.descriptionTextView.text else { return }
        delegate?.updatedText(text, in: self.section)
        hero_dismissViewController()
    }
    
    // MARK: - UI Methods
    
    func setupNavigationBar() {
        
        // Remove Navigation bar shadow and borderline
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.topItem?.title = "Untitled"
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.screenDark, NSAttributedStringKey.font: UIFont.systemFont(ofSize: 20, weight: .semibold)]
        self.navigationController?.navigationBar.tintColor = .screenLightBlue
        self.navigationController?.navigationBar.barTintColor = .white
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let descriptionCell = tableView.dequeueReusableCell(withIdentifier: "descriptionCell") as? DescriptionTableViewCell else { return UITableViewCell() }
        
    
        descriptionCell.update(section: section)
        descriptionCell.backgroundColor = .screenLightGray
        return descriptionCell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch self.section {
        case 0:
            return "  Basic Idea (Log Line)"
        case 1:
            return "  Act 1"
        case 2:
            return "  Act 2"
        case 3:
            return "  Act 3"
        default:
            return ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.height * (3/4)
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
