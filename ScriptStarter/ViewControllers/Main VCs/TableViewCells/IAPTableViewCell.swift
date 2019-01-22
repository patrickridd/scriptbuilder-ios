//
//  IAPTableViewCell.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 4/4/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import UIKit
import StoreKit

class IAPTableViewCell: UITableViewCell {

    @IBOutlet weak var restoreButton: UIButton!
    @IBOutlet weak var purchaseButton: UIButton!
    
    var inAppPurchase: SKProduct?
    
    var purchaseButtonHandler: ((_ product: SKProduct) -> Void)?
    var restoreButtonHandler: ((_ product: SKProduct) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        restoreButton.layer.borderColor = UIColor.screenLightBlue.cgColor
        restoreButton.layer.borderWidth = 1.0
        
        InAppPurchases.store.requestProducts { [weak self] (_, products) in
            if let product = products?.first {
                self?.inAppPurchase = product
                self?.restoreButton.isEnabled = true
                self?.purchaseButton.isEnabled = true
            }
        }
    }
    
    @IBAction func purchaseButtonTapped(_ sender: Any) {
        if let inAppPurchase = self.inAppPurchase {
            purchaseButtonHandler?(inAppPurchase)
        }
    }
    
    @IBAction func restoreButtonTapped(_ sender: Any) {
        if let inAppPurchase = self.inAppPurchase {
            restoreButtonHandler?(inAppPurchase)
        }
    }
    
    
}
