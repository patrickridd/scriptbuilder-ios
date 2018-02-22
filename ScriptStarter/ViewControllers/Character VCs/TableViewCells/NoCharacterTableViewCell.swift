//
//  NoCharacterTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/21/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class NoCharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var noCharacterLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        noCharacterLabel.numberOfLines = 1
        noCharacterLabel.adjustsFontSizeToFitWidth = true
        noCharacterLabel.lineBreakMode = .byClipping
    }
    
}
