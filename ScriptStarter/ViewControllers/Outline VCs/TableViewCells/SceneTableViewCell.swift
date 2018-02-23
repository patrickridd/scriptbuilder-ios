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
    @IBOutlet weak var sceneHeaderLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with scene: Scene) {
        sceneHeaderLabel.text = scene.header
        sceneNumberLabel.text = "\(scene.sceneNumber)."
    }

}
