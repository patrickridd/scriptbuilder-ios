//
//  EntitlementResolver.swift
//  Domain
//
//  Pure, dependency-free entitlement decision logic extracted from the
//  StoreKit-backed `Store` so it can be unit-tested without StoreKit.
//
//  The core rule it encodes:
//  A product grants access if EITHER
//    1. it is present in the loaded catalog AND in the purchased catalog list, OR
//    2. (catalog fallback) it is present in `entitledProductIDs` — the set derived
//       directly from `Transaction.currentEntitlements`, independent of whether the
//       product still loads in the catalog.
//
//  Rule 2 is what keeps legacy lifetime (`unlimited_forever`) owners unlocked after
//  the product is removed from sale and StoreKit stops returning it in the catalog.
//

import Foundation

/// A snapshot of the store's product/entitlement state, with no StoreKit types,
/// so the access decision can be evaluated and tested in isolation.
public struct EntitlementSnapshot: Sendable, Equatable {
    /// Product IDs currently returned by the store's catalog fetch.
    public let catalogProductIDs: Set<String>
    /// Product IDs the customer purchased that also appear in the loaded catalog
    /// (mirrors `purchasedNonConsumables` + `purchasedSubscriptions`).
    public let purchasedCatalogProductIDs: Set<String>
    /// Product IDs the customer is entitled to, derived directly from
    /// `Transaction.currentEntitlements` — NOT filtered by the loaded catalog.
    public let entitledProductIDs: Set<String>

    public init(
        catalogProductIDs: Set<String>,
        purchasedCatalogProductIDs: Set<String>,
        entitledProductIDs: Set<String>
    ) {
        self.catalogProductIDs = catalogProductIDs
        self.purchasedCatalogProductIDs = purchasedCatalogProductIDs
        self.entitledProductIDs = entitledProductIDs
    }
}

public enum EntitlementResolver {
    /// Whether the customer is entitled to a single product, applying the
    /// catalog-with-fallback rule described above.
    public static func isEntitled(
        to productID: String,
        in snapshot: EntitlementSnapshot
    ) -> Bool {
        if snapshot.catalogProductIDs.contains(productID) {
            return snapshot.purchasedCatalogProductIDs.contains(productID)
        }
        // Catalog doesn't carry the product (e.g. removed from sale); honor the
        // standing entitlement from the customer's verified transactions.
        return snapshot.entitledProductIDs.contains(productID)
    }

    /// Whether the customer should be granted full ("all access"), given the set
    /// of product IDs that each individually unlock everything.
    public static func hasAllAccess(
        anyOf accessGrantingProductIDs: [String],
        in snapshot: EntitlementSnapshot
    ) -> Bool {
        accessGrantingProductIDs.contains { isEntitled(to: $0, in: snapshot) }
    }
}
