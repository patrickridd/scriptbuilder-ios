//
//  ActNumberPopTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/16/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ActNumberPopTableViewCell: UITableViewCell {

    @IBOutlet weak var actNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        actNumberLabel.textColor = Theme.descriptionTextColor
        contentView.backgroundColor = Theme.systemBackground
    }
    
    func update(with actNumber: Int) {
        self.actNumberLabel.text = "\(actNumber)"
    }
}
