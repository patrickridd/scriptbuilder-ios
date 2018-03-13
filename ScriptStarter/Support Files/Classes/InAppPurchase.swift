//
//  InAppPurchase.swift
//  ScriptStarter
//
//  Created by Patrick Ridd (patrick.ridd@stgconsulting.com) on 3/12/18.
//  Copyright © 2018 patrickridd. All rights reserved.
//

import Foundation

public struct InAppPurchase {
    
    public static let noAdOfflineCapabilities = "noAdOfflineCapabilities"
    
    fileprivate static let productIdentifiers: Set<ProductIdentifier> = [InAppPurchase.noAdOfflineCapabilities]
    
    public static let store = IAPHelper(productIds: InAppPurchase.productIdentifiers)
}

func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
    return productIdentifier.components(separatedBy: ".").last
}

