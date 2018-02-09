//
//  InformationPopTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/9/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class InformationPopTableViewCell: UITableViewCell {

    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var learnMoreButton: UIButton!
    @IBOutlet weak var gotItButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    func update(with infoNote: InformationNote) {
        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        paragraphStyle.lineHeightMultiple = 1.25
        let informationAttributedText = NSAttributedString(string: infoNote.description, attributes: [NSAttributedStringKey.foregroundColor:UIColor.flamenco, NSAttributedStringKey.paragraphStyle:paragraphStyle, NSAttributedStringKey.font: font])
        informationLabel.attributedText = informationAttributedText
    }
}
