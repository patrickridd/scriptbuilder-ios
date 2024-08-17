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

    public static let transactionObserver = PaymentTransactionObserver(productIds: InAppPurchases.productIdentifiers)

    public static var characterFeatureEnabled: Bool {
        InAppPurchases.transactionObserver.isProductPurchased(InAppPurchases.characterFeatureIdentifier)
    }

    public static var sceneFeatureEnabled: Bool {
        InAppPurchases.transactionObserver.isProductPurchased(InAppPurchases.sceneFeatureIdentifier)
    }

    public static var unlimitedMonthlyEnabled: Bool {
        InAppPurchases.transactionObserver.isProductPurchased(InAppPurchases.unlimitedMonthlyIdentifier)
    }

    public static var unlimitedYearlyEnabled: Bool {
        InAppPurchases.transactionObserver.isProductPurchased(InAppPurchases.unlimitedYearlyIdentifier)
    }

    public static var unlimitedForeverEnabled: Bool {
        InAppPurchases.transactionObserver.isProductPurchased(InAppPurchases.unlimitedForeverIdentifier)
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

enum InAppSubscription: Equatable {
    case monthly(_ product: SKProduct?)
    case yearly(_ product: SKProduct?)
    case lifetime(_ product: SKProduct?)
    
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
        case .monthly(let product):
            if let monthlyPriceString = product?.price, let currency = product?.priceLocale.currencySymbol {
                let monthlyPrice = Double(truncating: monthlyPriceString)
                let weeklyPrice = (monthlyPrice/30.43) * 7
                let formattedPrice = weeklyPrice.truncate(places: 2)
                return "\(currency)\(formattedPrice)/\("week".localized)"
            } else {
                return "$0.68/week"
            }
        case .yearly(let product):
            if let yearlyPriceString = product?.price, let currency = product?.priceLocale.currencySymbol {
                let yearlyPrice = Double(truncating: yearlyPriceString)
                let weeklyPrice = (yearlyPrice/365.0) * 7.0
                let formattedPrice = weeklyPrice.truncate(places: 2)
                return "\(currency)\(formattedPrice)/\("week".localized)"
            } else {
                return "$0.38/week"
            }
        case .lifetime(let product):
            if let price = product?.price, let currency = product?.priceLocale.currencySymbol {
                return "\(currency)\(price)"
            } else {
                return "$89.99"
            }
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

extension Double {
    func truncate(places : Int) -> Double {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}
