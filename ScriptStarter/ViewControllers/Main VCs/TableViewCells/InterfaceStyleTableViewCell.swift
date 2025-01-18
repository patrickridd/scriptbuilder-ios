//
//  EnableDarkModeTableViewCell.swift
//  ScriptStarter
//
//  Created by patrick ridd on 4/6/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import UIKit

class InterfaceStyleTableViewCell: UITableViewCell {

    let userDefaults = UserDefaults()

    @IBOutlet weak var segmentControl: UISegmentedControl!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        segmentControl.selectedSegmentTintColor = Theme.scriptBuilderUIColor
        let segmentSelected = userDefaults.integer(forKey: InterfaceStyle.userDefaultsKey)
        segmentControl.selectedSegmentIndex = segmentSelected
    }

    @IBAction func segmentControlChanged(_ sender: UISegmentedControl) {
        userDefaults.setValue(sender.selectedSegmentIndex, forKey: InterfaceStyle.userDefaultsKey)
        guard let interfaceStyle = InterfaceStyle(rawValue: sender.selectedSegmentIndex) else { return }
        if let window = UIApplication.shared.mainWindow {
            UIView.transition (with: window, duration: 0.3, options: .transitionCrossDissolve, animations: {
                window.overrideUserInterfaceStyle = interfaceStyle.systemInterfaceStyle
            }, completion: nil)
        }
    }

}
