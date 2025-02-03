//
//  PersonalInfoTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 2/22/19.
//  Copyright © 2019 patrickridd. All rights reserved.
//

import UIKit
import FirebaseAuth

class PersonalInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var screenplaysHeaderLabel: UILabel!
    @IBOutlet weak var screenplaysCountLabel: UILabel!
    
    @IBOutlet weak var charactersHeaderLabel: UILabel!
    @IBOutlet weak var charactersCountLabel: UILabel!
    
    @IBOutlet weak var scenesHeaderLabel: UILabel!
    @IBOutlet weak var scenesCountLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        screenplaysHeaderLabel.font = UIFont.systemFont(ofSize: 14,
                                                        weight: .light)
        screenplaysCountLabel.font = UIFont.systemFont(ofSize: 16,
                                                       weight: .light)
        screenplaysCountLabel.textColor = Theme.scriptBuilderUIColor
        charactersHeaderLabel.font = UIFont.systemFont(ofSize: 14,
                                                       weight: .light)
        charactersCountLabel.font =  UIFont.systemFont(ofSize: 16,
                                                       weight: .light)
        charactersCountLabel.textColor = Theme.scriptBuilderUIColor
        scenesHeaderLabel.font = UIFont.systemFont(ofSize: 14,
                                                   weight: .light)
        scenesCountLabel.font = UIFont.systemFont(ofSize: 16,
                                                  weight: .light)
        scenesCountLabel.textColor = Theme.scriptBuilderUIColor
        
        nameLabel.font = UIFont.systemFont(ofSize: 28,
                                           weight: .regular)
        nameLabel.textColor = UIColor.label
        
        emailLabel.font = UIFont.systemFont(ofSize: 14,
                                            weight: .light)
        emailLabel.textColor = UIColor.lightGray
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func updateCell(with user: User?, and screenplays: [Screenplay]) {
        nameLabel.text = user?.displayName ?? ""
        emailLabel.text = user?.email ?? ""
        
        self.screenplaysCountLabel.text = "\(screenplays.count)"
        
        var characterCount = 0
        for screenplay in screenplays {
            characterCount += screenplay.characters.count
        }
        
        self.charactersCountLabel.text = "\(characterCount)"
        
        var sceneCount = 0
        for screenplay in screenplays {
            sceneCount += screenplay.act1ScenesArray.count
            sceneCount += screenplay.act2ScenesArray.count
            sceneCount += screenplay.act3ScenesArray.count
        }
        
        self.scenesCountLabel.text = "\(sceneCount)"
    }

}
