//
//  RoleTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/19/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class RoleTableViewCell: UITableViewCell {

    @IBOutlet weak var roleLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with role: Role) {
        let attributedText = NSAttributedString(string:role.title,
                                                attributes: [NSAttributedString.Key.foregroundColor:UIColor.screenDarkMediumGray])
        roleLabel.attributedText = attributedText
    }
    
    func setupCustomLabel() {
        let attributedText = NSAttributedString(string: "Custom".localized,
                                                attributes: [NSAttributedString.Key.foregroundColor: Theme.scriptBuilderUIColor])
        roleLabel.attributedText = attributedText
    }
}
