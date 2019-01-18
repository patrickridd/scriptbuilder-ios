//
//  IAPTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class IAPTableViewCell: UITableViewCell {

    @IBOutlet weak var restoreButton: UIButton!
    
    override func awakeFromNib() {
        
        restoreButton.layer.borderColor = UIColor.screenLightBlue.cgColor
        restoreButton.layer.borderWidth = 1.0
    }
  
    
}
