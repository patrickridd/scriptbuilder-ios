//
//  BasicInfoCharacterTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/15/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit


enum Role {
    case protagonist
    case antagonist
    case mentor
    case lover
    case friend
    case jester
    case enemy
    case ally
    case mysterious
    
    var title: String {
        switch self {
        case .protagonist:
            return "Protagonist"
        case .antagonist:
            return "Antagonist"
        case .mentor:
            return "Mentor"
        case .lover:
            return "Lover"
        case .friend:
            return "Friend"
        case .jester:
            return "Jester"
        case .enemy:
            return "Enemy"
        case .ally:
            return "Ally"
        case .mysterious:
            return "Mysterious"
        }
    }
    
}

class BasicInfoCharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var roleTextField: UITextField!
    @IBOutlet weak var roleButton: UIButton!
    
    var character: Character?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        nameTextField.delegate = self
        roleTextField.delegate = self
        
        addToolBar(textField: self.nameTextField)
        addToolBar(textField: self.roleTextField)
    }

    @IBAction func nameTextFieldChanged(_ sender: Any) {
        guard let name = nameTextField.text else { return }
        self.character?.name = name
    }
    
    @IBAction func roleTextFieldChanged(_ sender: Any) {
        guard let role = roleTextField.text else { return }
        self.character?.role = role
    }
}
