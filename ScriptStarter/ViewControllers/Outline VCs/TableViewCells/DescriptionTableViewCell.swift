//
//  DescriptionTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 1/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import KMPlaceholderTextView

class DescriptionTableViewCell: UITableViewCell {

    @IBOutlet weak var descriptionTextView: KMPlaceholderTextView!
    
    @IBOutlet weak var expandButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        descriptionTextView.textColor = UIColor.screenDarkMediumGray
        descriptionTextView.placeholderColor = UIColor.flamenco
        self.imageView?.heroID = "descriptionId"
    }

    func updateWith(text: String?) {
        if let text = text {
            self.descriptionTextView.text = text
        }
    }
}
