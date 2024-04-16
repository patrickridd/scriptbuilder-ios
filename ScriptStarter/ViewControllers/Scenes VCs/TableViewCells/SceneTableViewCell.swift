//
//  SceneTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SceneTableViewCell: UITableViewCell {

    
    @IBOutlet weak var sceneNumberLabel: UILabel!
    @IBOutlet weak var sceneTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        backgroundColor = Theme.descriptionTextViewBackground
        sceneTitleLabel.textColor = Theme.descriptionTextColor
        sceneNumberLabel.textColor = Theme.descriptionTextColor
    }
    
    func update(with scene: Scene) {
        sceneTitleLabel.text = scene.title
        sceneNumberLabel.text = "\(scene.sceneNumber)."
    }

}
