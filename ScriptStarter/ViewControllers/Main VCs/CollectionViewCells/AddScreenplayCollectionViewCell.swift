//
//  AddScreenplayCollectionViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/29/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import Hero

class AddScreenplayCollectionViewCell: UICollectionViewCell {
    
    override func awakeFromNib() {
        
    }
    
    func update(heroId: String) {
        self.contentView.heroID = heroId
    }
}
