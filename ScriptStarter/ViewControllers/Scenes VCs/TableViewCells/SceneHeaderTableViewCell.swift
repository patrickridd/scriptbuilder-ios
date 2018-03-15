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
    @IBOutlet var actTextField: UITextField!
    
    @IBOutlet weak var sceneNumberTextFieldContainer: UIView!
    @IBOutlet weak var headerTextFieldContainer: UIView!
    @IBOutlet var sceneActTextFieldContainer: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
//        headerTextFieldContainer.layer.borderWidth = 0.5
//        headerTextFieldContainer.layer.borderColor = UIColor.screenMediumGray.cgColor
//
//        sceneNumberTextFieldContainer.layer.borderColor = UIColor.screenMediumGray.cgColor
//        sceneNumberTextFieldContainer.layer.borderWidth = 0.5
        addToolBar(textField: self.actTextField)
        addToolBar(textField: self.sceneNumberTextField)
        addToolBar(textField: self.sceneHeadingTextField)
    }
    
    func update(with scene: Scene) {
        self.sceneNumberTextField.text = "\(scene.sceneNumber)"
        self.sceneHeadingTextField.text = scene.header
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
}
