//
//  ScreenplayCollectionViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Hero

class ScreenplayCollectionViewCell: UICollectionViewCell {
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        self.contentView.hero.id = "screenplay"
    }
    
    func update(title: String, name: String, heroId: String) {
        self.titleLabel.text = title
        self.nameLabel.text = name
        self.contentView.hero.id = heroId
    }
}
