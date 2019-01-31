//
//  InAppPurchase.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public struct InAppPurchases {
    
    public static let noAdsIdentifier = "com.patrickridd.ScriptStarter.NoAds"
    public static let characterFeatureIdentifier = "com.patrickridd.ScriptStarter.Character.Builder"
    public static let sceneFeatureIdentifier = "com.patrickridd.ScriptStarter.Scene.Builder"
    
    private static let productIdentifiers: Set<ProductIdentifier> = [InAppPurchases.noAdsIdentifier,
                                                                     InAppPurchases.characterFeatureIdentifier,
                                                                     InAppPurchases.sceneFeatureIdentifier]
    
    public static let store = IAPHelper(productIds: InAppPurchases.productIdentifiers)
    
    public static var shouldDisplayAds: Bool {
        return !InAppPurchases.store.isProductPurchased(InAppPurchases.noAdsIdentifier)
    }
    
    public static var characterFeatureEnabled: Bool {
        return InAppPurchases.store.isProductPurchased(InAppPurchases.characterFeatureIdentifier)
    }
    
    public static var sceneFeatureEnabled: Bool {
        return InAppPurchases.store.isProductPurchased(InAppPurchases.sceneFeatureIdentifier)
    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

