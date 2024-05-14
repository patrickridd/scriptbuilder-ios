//
//  InformationPopTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/9/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class InformationPopTableViewCell: UITableViewCell {

    @IBOutlet weak var parentView: UIView!
    @IBOutlet weak var informationView: UIView!
    @IBOutlet weak var informationLabel: UILabel!
    @IBOutlet weak var gotItButton: UIButton!
    @IBOutlet weak var separatorLine: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        parentView.backgroundColor = Theme.enlargedNavigationDescriptionBackground
        separatorLine.backgroundColor = Theme.lineSeparatorcolor
    }
    
    func update(with infoNote: InformationNote) {

        let paragraphStyle = NSMutableParagraphStyle()
        let font = UIFont.systemFont(ofSize: 14,
                                     weight: .semibold)
        paragraphStyle.lineHeightMultiple = 1.25
        let attributes = [NSAttributedString.Key.foregroundColor:Theme.descriptionTextColor,
                          NSAttributedString.Key.paragraphStyle:paragraphStyle,
                          NSAttributedString.Key.font: font]
        let informationAttributedText = NSAttributedString(string: infoNote.description,
                                                           attributes: attributes)
        informationLabel.attributedText = informationAttributedText
    }
}
