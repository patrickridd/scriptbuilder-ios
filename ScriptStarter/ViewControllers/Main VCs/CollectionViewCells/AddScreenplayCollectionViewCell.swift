//
//  AddScreenplayCollectionViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class AddScreenplayCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var addButtonLabel: UILabel!
    
    func updateCell(isRestricted: Bool) {
        contentView.backgroundColor = Theme.secondarySystemBackground
        addButtonLabel.textColor = isRestricted ? .lightGray : .screenMediumBlue
    }
}
