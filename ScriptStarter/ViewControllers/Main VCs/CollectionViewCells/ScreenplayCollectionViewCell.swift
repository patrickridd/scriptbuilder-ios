//
//  ScreenplayCollectionViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ScreenplayCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleLabel.textColor = .label
        nameLabel.textColor = .label
    }
    
    func update(title: String, name: String) {
        self.titleLabel.text = title
        self.nameLabel.text = name
        contentView.backgroundColor = Theme.secondarySystemBackground
    }
}
