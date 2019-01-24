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
       
        restoreButton.layer.borderWidth = 1.0
        // Disable Purchase and Restore buttons until In App Purchase is available
        restoreButton.layer.borderColor = UIColor.screenDarkGray.cgColor
        restoreButton.setTitleColor(UIColor.screenDarkGray,
                                    for: .normal)
        purchaseButton.backgroundColor = UIColor.screenDarkGray
        
        InAppPurchases.store.requestProducts { [weak self] (_, products) in
            if let product = products?.first {
                DispatchQueue.main.async {
                    self?.inAppPurchase = product
                    self?.restoreButton.isEnabled = true
                    self?.purchaseButton.isEnabled = true
                    self?.purchaseButton.backgroundColor = UIColor.screenLightBlue
                    self?.restoreButton.layer.borderColor = UIColor.screenLightBlue.cgColor
                    self?.restoreButton.setTitleColor(UIColor.screenLightBlue,
                                                      for: .normal)
                    self?.setAccessory()
                }
            }
        }
    }
    
    func setAccessory() {
        // If no Ads IAP has been purchased, place check mark next to box
        if !InAppPurchases.shouldDisplayAds {
            self.accessoryType = .checkmark
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
