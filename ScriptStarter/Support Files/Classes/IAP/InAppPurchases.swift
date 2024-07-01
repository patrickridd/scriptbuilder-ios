//
//  InAppPurchase.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import StoreKit

public class InAppPurchases {
    
    public static let noAdsIdentifier = "com.patrickridd.ScriptStarter.NoAds"
    public static let characterFeatureIdentifier = "com.patrickridd.ScriptStarter.Character.Builder"
    public static let sceneFeatureIdentifier = "com.patrickridd.ScriptStarter.Scene.Builder"
    public static let unlimitedMonthly = "unlimited_monthly"
    public static let unlimitedYearly = "unlimited_yearly"
    public static let unlimitedForever = "unlimited_forever"
    var productsPurchased: [SKProduct]?

    init() {
        // Retrieves in app purchases from apple
        InAppPurchases.store.requestProducts { [weak self] (_, products) in
            self?.productsPurchased = products
        }
    }

    private static let productIdentifiers: Set<ProductIdentifier> = [InAppPurchases.noAdsIdentifier,
                                                                     InAppPurchases.characterFeatureIdentifier,
                                                                     InAppPurchases.sceneFeatureIdentifier,
                                                                     InAppPurchases.unlimitedMonthly, 
                                                                     InAppPurchases.unlimitedYearly,
                                                                     InAppPurchases.unlimitedForever]

    public static let store = IAPHelper(productIds: InAppPurchases.productIdentifiers)
    
    public static var shouldDisplayAds: Bool {
        !InAppPurchases.store.isProductPurchased(InAppPurchases.noAdsIdentifier)
    }

    public static var characterFeatureEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.characterFeatureIdentifier)
    }

    public static var sceneFeatureEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.sceneFeatureIdentifier)
    }

    public static var unlimitedMonthlyEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedMonthly)
    }

    public static var unlimitedYearlyEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedYearly)
    }

    public static var unlimitedForeverEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedForever)
    }

    public static var allAccessEnabled: Bool {
        // Give legacy in-app purchase all access
        if InAppPurchases.characterFeatureEnabled && InAppPurchases.sceneFeatureEnabled { return true }
        // Check if they have subscription
        return InAppPurchases.unlimitedForeverEnabled || InAppPurchases.unlimitedMonthlyEnabled || InAppPurchases.unlimitedYearlyEnabled
    }
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

