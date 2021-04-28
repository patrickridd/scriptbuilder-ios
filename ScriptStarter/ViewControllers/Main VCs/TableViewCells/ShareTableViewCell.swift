//
//  ShareTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ShareTableViewCell: UITableViewCell {

    @IBOutlet weak var shareLabel: UILabel!
    
    override func awakeFromNib() {
        shareLabel.font = UIFont.systemFont(ofSize: 17,
                                            weight: .light)
        shareLabel.text = "Share Script Builder".localized
    }
    
}
