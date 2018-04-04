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
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.oldPasswordTextField.addToolBar()
        self.oldPasswordTextField.delegate = self
        
        self.newPasswordTextField.addToolBar()
        self.newPasswordTextField.delegate = self
    }
    
    @IBAction func changePasswordButtonTapped(_ sender: Any) {
        
    }
    
    
    // MARK: - UITextFieldDelegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return
        self.endEditing(true)
    }
}
