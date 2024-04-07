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
        darkModeSwitch.onTintColor = UIColor.screenLightBlue
        let isOn = userDefaults.bool(forKey: Constants.darkModeEnabled.rawValue)
        darkModeSwitch.isOn = isOn
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
