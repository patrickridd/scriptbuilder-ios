//
//  EntitlementResolverTests.swift
//  DomainTests
//
//  Verifies the catalog-with-fallback entitlement logic, with special focus on
//  legacy lifetime (`unlimited_forever`) owners keeping access after the product
//  is removed from sale (and so disappears from the catalog fetch).
//

import Testing
@testable import Domain

@Suite("EntitlementResolver")
struct EntitlementResolverTests {

    let lifetime = "unlimited_forever"
    let monthly = "unlimited_monthly"
    let yearly = "unlimited_yearly"
    let character = "com.patrickridd.ScriptStarter.Character.Builder"

    var allAccessIDs: [String] {
        [character, "scene", lifetime, monthly, yearly]
    }

    // MARK: - Single product, product present in catalog

    @Test("In catalog and purchased → entitled")
    func inCatalogAndPurchasedIsEntitled() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [lifetime],
            purchasedCatalogProductIDs: [lifetime],
            entitledProductIDs: [lifetime]
        )
        #expect(EntitlementResolver.isEntitled(to: lifetime, in: snapshot))
    }

    @Test("In catalog but not purchased → not entitled")
    func inCatalogButNotPurchasedIsNotEntitled() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [lifetime],
            purchasedCatalogProductIDs: [],
            entitledProductIDs: []
        )
        #expect(!EntitlementResolver.isEntitled(to: lifetime, in: snapshot))
    }

    // MARK: - The critical regression: removed from sale

    /// Lifetime product was pulled from sale, so it's no longer in the catalog and no
    /// longer in `purchasedCatalogProductIDs`. The standing entitlement must still grant access.
    @Test("Removed from sale but still entitled → stays unlocked")
    func removedFromSaleButEntitledStillUnlocked() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [monthly, yearly], // lifetime absent from catalog
            purchasedCatalogProductIDs: [],        // and thus absent here too
            entitledProductIDs: [lifetime]         // but transaction is still valid
        )
        #expect(
            EntitlementResolver.isEntitled(to: lifetime, in: snapshot),
            "Lifetime owners must stay unlocked after the product is removed from sale."
        )
    }

    /// Confirms we don't over-grant: a removed product with no standing entitlement is denied.
    @Test("Removed from sale and not entitled → denied")
    func removedFromSaleAndNotEntitledIsDenied() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [monthly, yearly],
            purchasedCatalogProductIDs: [],
            entitledProductIDs: [] // no transaction → no access
        )
        #expect(!EntitlementResolver.isEntitled(to: lifetime, in: snapshot))
    }

    // MARK: - allAccess aggregation

    @Test("All access granted by lifetime entitlement when removed from sale")
    func allAccessGrantedByLifetimeWhenRemovedFromSale() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [monthly, yearly],
            purchasedCatalogProductIDs: [],
            entitledProductIDs: [lifetime]
        )
        #expect(EntitlementResolver.hasAllAccess(anyOf: allAccessIDs, in: snapshot))
    }

    @Test("All access granted by active subscription")
    func allAccessGrantedByActiveSubscription() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [monthly, yearly],
            purchasedCatalogProductIDs: [yearly],
            entitledProductIDs: [yearly]
        )
        #expect(EntitlementResolver.hasAllAccess(anyOf: allAccessIDs, in: snapshot))
    }

    @Test("All access denied for free user")
    func allAccessDeniedForFreeUser() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [monthly, yearly],
            purchasedCatalogProductIDs: [],
            entitledProductIDs: []
        )
        #expect(!EntitlementResolver.hasAllAccess(anyOf: allAccessIDs, in: snapshot))
    }

    @Test("All access granted by legacy per-feature non-consumable")
    func allAccessGrantedByLegacyPerFeatureNonConsumable() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [character, monthly, yearly],
            purchasedCatalogProductIDs: [character],
            entitledProductIDs: [character]
        )
        #expect(EntitlementResolver.hasAllAccess(anyOf: allAccessIDs, in: snapshot))
    }

    // MARK: - Empty catalog (e.g. products failed to load)

    @Test("Empty catalog honors standing entitlement")
    func emptyCatalogHonorsStandingEntitlement() {
        let snapshot = EntitlementSnapshot(
            catalogProductIDs: [],
            purchasedCatalogProductIDs: [],
            entitledProductIDs: [yearly]
        )
        #expect(EntitlementResolver.isEntitled(to: yearly, in: snapshot))
    }
}
