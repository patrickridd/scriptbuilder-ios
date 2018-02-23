//
//  SceneHeaderTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/23/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class SceneHeaderTableViewCell: UITableViewCell {

    @IBOutlet weak var sceneNumberTextField: UITextField!
    @IBOutlet weak var sceneHeadingTextField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func update(with scene: Scene) {
        self.sceneNumberTextField.text = scene.sceneNumber
        self.sceneHeadingTextField.text = scene.header
    }
    
}
