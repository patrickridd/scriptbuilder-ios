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
        // Initialization code
        setupView()
    }
    
    func setupView() {
        
//        informationView.layer.borderWidth = 1.0
//        informationView.layer.borderColor = UIColor.screenDarkGray.cgColor
//        learnMoreButton.layer.borderWidth = 1.0
//        learnMoreButton.layer.borderColor = UIColor.screenDarkGray.cgColor
//        gotItButton.layer.borderWidth = 1.0
//        gotItButton.layer.borderColor = UIColor.screenDarkGray.cgColor
        
    }
    
}
