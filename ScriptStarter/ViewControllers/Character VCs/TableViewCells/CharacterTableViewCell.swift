//
//  CharacterTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/1/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit

class CharacterTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var roleLabel: UILabel!
    @IBOutlet weak var intentionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func updateCell(with character: Character) {
        self.intentionLabel.text = character.intention
        self.roleLabel.text = character.role ?? ""
        self.nameLabel.text = character.name
    }
}
