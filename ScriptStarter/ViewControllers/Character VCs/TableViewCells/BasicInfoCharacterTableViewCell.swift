//
//  BasicInfoCharacterTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/15/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class BasicInfoCharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!
    @IBOutlet weak var roleButton: UIButton!
    @IBOutlet weak var separatorLineView: UIView!
    
    var character: Character?
    weak var delegate: NameChangedDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        nameTextField.delegate = self
        roleTextField.delegate = self
        
        self.nameTextField.textColor = Theme.characterNameTextFieldColor
        self.roleTextField.textColor = Theme.scriptBuilderUIColor
        self.nameTextField.backgroundColor = Theme.descriptionTextViewBackground
        self.roleTextField.backgroundColor = Theme.descriptionTextViewBackground
        self.contentView.backgroundColor = Theme.descriptionTextViewBackground
        separatorLineView.backgroundColor = Theme.lineSeparatorcolor
        self.addToolBar(textField: self.nameTextField)
        self.addToolBar(textField: self.roleTextField)
    }
    
    func updateCharacterInfo() {
        self.nameTextField.text = self.character?.name ?? ""
        self.roleTextField.text = self.character?.role ?? ""
    }
    
    func customRoleSelected() {
        DispatchQueue.main.async {
            self.nameTextField.resignFirstResponder()
            self.roleTextField.becomeFirstResponder()
        }
    }

    @IBAction func nameTextFieldChanged(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        self.character?.name = name
        delegate?.nameChanged(name: name)
    }
    
    @IBAction func roleTextFieldChanged(_ sender: Any) {
        guard let role = roleTextField.text else { return }
        self.character?.role = role
    }
    
}
