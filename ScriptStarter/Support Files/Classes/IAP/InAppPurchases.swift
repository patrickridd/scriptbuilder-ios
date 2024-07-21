//
//  InAppPurchase.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation
import StoreKit

public struct InAppPurchases {
    
    public static let noAdsIdentifier = "com.patrickridd.ScriptStarter.NoAds"
    public static let characterFeatureIdentifier = "com.patrickridd.ScriptStarter.Character.Builder"
    public static let sceneFeatureIdentifier = "com.patrickridd.ScriptStarter.Scene.Builder"
    public static let unlimitedMonthlyIdentifier = "unlimited_monthly"
    public static let unlimitedYearlyIdentifier = "unlimited_yearly"
    public static let unlimitedForeverIdentifier = "unlimited_forever"

    private static let productIdentifiers: Set<ProductIdentifier> = [InAppPurchases.noAdsIdentifier,
                                                                     InAppPurchases.characterFeatureIdentifier,
                                                                     InAppPurchases.sceneFeatureIdentifier,
                                                                     InAppPurchases.unlimitedMonthlyIdentifier, 
                                                                     InAppPurchases.unlimitedYearlyIdentifier,
                                                                     InAppPurchases.unlimitedForeverIdentifier]

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
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedMonthlyIdentifier)
    }

    public static var unlimitedYearlyEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedYearlyIdentifier)
    }

    public static var unlimitedForeverEnabled: Bool {
        InAppPurchases.store.isProductPurchased(InAppPurchases.unlimitedForeverIdentifier)
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

enum InAppSubscription {
    case monthly
    case yearly
    case lifetime
    
    var title: String {
        switch self {
        case .monthly:
            return "1 Month"
        case .yearly:
            return "1 Year"
        case .lifetime:
            return "Lifetime"
        }
    }
    
    var price: String {
        switch self {
        case .monthly:
            return "$0.68/week"
        case .yearly:
            return "$0.38/week"
        case .lifetime:
            return "$89.99"
        }
    }
    
    var subtitle: String? {
        switch self {
        case .monthly:
            return nil
        case .yearly:
            return "56.6% savings"
        case .lifetime:
            return "Never pay again"
        }
    }
    
}
