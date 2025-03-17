//
//  LegalTableViewCellCell.swift
//  ScriptStarter
//
//  Created by patrick ridd on 12/16/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import UIKit

class LegalTableViewCellCell: UITableViewCell {

    @IBOutlet weak var versionLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        versionLabel.text = "Version \(Bundle.main.releaseVersionNumber ?? "")"
    }

    @IBAction func privacyPolicyTapped(_ sender: Any) {
        // Open Privacy Policy
        if let privacyPolicyURL = URL(string: "https://www.scriptbuilderapp.com/_files/ugd/b622d0_f5722cd213394590bbd181559a0af540.pdf") {
            UIApplication.shared.open(privacyPolicyURL)
        }
    }

    @IBAction func termsOfUseTapped(_ sender: Any) {
        // Open Terms of Use
        if let termsOfUseURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
            UIApplication.shared.open(termsOfUseURL)
        }
    }
}
