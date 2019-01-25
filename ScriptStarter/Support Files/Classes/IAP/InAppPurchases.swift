//
//  InAppPurchase.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public struct InAppPurchases {
    
    public static let noAdsAndOfflineStorage = "com.patrickridd.ScriptStarter.NoAds"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [InAppPurchases.noAdsAndOfflineStorage]
    
    public static let store = IAPHelper(productIds: InAppPurchases.productIdentifiers)
    
    public static var shouldDisplayAds: Bool {
        return !InAppPurchases.store.isProductPurchased(InAppPurchases.noAdsAndOfflineStorage)
    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

