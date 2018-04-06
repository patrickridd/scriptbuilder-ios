//
//  ChangePasswordTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class ChangePasswordTableViewCell: UITableViewCell {

    @IBOutlet weak var oldPasswordTextField: UITextField!
    @IBOutlet weak var newPasswordTextField: UITextField!
    
    @IBOutlet weak var changeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.oldPasswordTextField.addToolBar()
        self.oldPasswordTextField.delegate = self
        self.oldPasswordTextField.tag = 0
        
        self.newPasswordTextField.addToolBar()
        self.newPasswordTextField.delegate = self
        self.newPasswordTextField.tag = 1
    }
    
   
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        switch textField.tag {
        case 0:
            self.newPasswordTextField.becomeFirstResponder()
        case 1:
            self.endEditing(true)
        default:
            break
        }
        
        return true
    }
}
