//
//  EnableDarkModeTableViewCell.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import UIKit

class EnableDarkModeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var darkModeSwitch: UISwitch!
    let userDefaults = UserDefaults()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        let isOn = userDefaults.bool(forKey: Constants.darkModeEnabled.rawValue)
        darkModeSwitch.isOn = isOn
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        userDefaults.setValue(sender.isOn, forKey: Constants.darkModeEnabled.rawValue)

        if sender.isOn {
            UIApplication.shared.mainWindow?.overrideUserInterfaceStyle = .dark
        } else {
            UIApplication.shared.mainWindow?.overrideUserInterfaceStyle = .light
        }
    }
    
}
