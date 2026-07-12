//
//  StoreTests.swift
//  FeatureAuth-DevTests
//
//  Swift Testing suite for the app-target StoreKit 2 `Store` object.
//
//  Unlike the FeaturePaywall `PurchaseBehaviorTests` (which exercise the
//  StoreKit-free `PaywallStore` seam with a spy), these tests drive the *real*
//  `Store` through actual StoreKit purchase flows using `SKTestSession` backed
//  by the app's `ScriptBuilderStore.storekit` configuration. They verify:
//
//    • Product catalog loading (subscriptions parsed & sorted by price)
//    • Entitlement flags before any purchase (locked)
//    • A real subscription purchase unlocking `allAccessEnabled`
//    • The catalog-fallback entitlement for the lifetime non-consumable
//    • The `Store` → `PaywallStore` adapter mapping (monthly/yearly products,
//      hasFullAccess, and a full purchase round-trip returning `.success`)
//
//  StoreKitTest runs these in-process against the local `.storekit` file, so
//  there is no network, no App Store Connect, and no flakiness.
//

import Testing
import StoreKit
import StoreKitTest
import FeaturePaywall
@testable import ScriptStarter

/// `.serialized` is required: these tests drive `SKTestSession`, whose
/// transaction store is **process-global**. Swift Testing runs test methods in
/// parallel by default, so without serialization one test's `makeSession()`
/// (which calls `resetToDefaultState()` + `clearTransactions()`) or its
/// purchases would clobber another test's StoreKit state mid-run. That's why
/// `lifetimeEntitlementGrantsAccess` passed in isolation but failed in the full
/// suite: a concurrently-running test wiped the lifetime transaction it depends
/// on. Serializing makes each test own the shared StoreKit state exclusively.
@MainActor
@Suite(.serialized)
struct StoreTests {

    // Product identifiers from ScriptBuilderStore.storekit / Products.plist.
    private static let monthlyID = "unlimited_monthly"
    private static let yearlyID = "unlimited_yearly"
    private static let lifetimeID = "unlimited_forever"

    /// Spins up a fresh, isolated StoreKitTest session with all transactions
    /// cleared, then builds a `Store` and waits for its async product load.
    private func makeSession() throws -> SKTestSession {
        let session = try SKTestSession(configurationFileNamed: "ScriptBuilderStore")
        session.resetToDefaultState()
        session.clearTransactions()
        session.disableDialogs = true
        return session
    }

    /// Builds a `Store` and polls until its catalog finishes loading (or times out).
    private func makeLoadedStore() async throws -> Store {
        let store = Store()
        try await waitUntil { !store.subscriptions.isEmpty }
        return store
    }

    /// Polls a condition on the main actor until true or a timeout elapses.
    private func waitUntil(
        timeout: Duration = .seconds(5),
        _ condition: @escaping () -> Bool
    ) async throws {
        let deadline = ContinuousClock.now.advanced(by: timeout)
        while ContinuousClock.now < deadline {
            if condition() { return }
            try await Task.sleep(for: .milliseconds(50))
        }
        #expect(condition(), "Timed out waiting for condition")
    }

    // MARK: - Product loading

    @Test("Store loads the subscription catalog and sorts it by price")
    func loadsSubscriptionCatalog() async throws {
        let session = try makeSession()
        _ = session
        let store = try await makeLoadedStore()

        let ids = Set(store.subscriptions.map(\.id))
        #expect(ids.contains(Self.monthlyID))
        #expect(ids.contains(Self.yearlyID))

        // Verify the store's price sort is ascending.
        let prices = store.subscriptions.map(\.price)
        #expect(prices == prices.sorted())
    }

    // MARK: - Entitlement flags

    @Test("Fresh store with no purchases reports no access")
    func noAccessBeforePurchase() async throws {
        let session = try makeSession()
        _ = session
        let store = try await makeLoadedStore()

        #expect(store.allAccessEnabled == false)
        #expect(store.unlimitedMonthlyEnabled == false)
        #expect(store.unlimitedYearlyEnabled == false)
        #expect(store.unlimitedForeverEnabled == false)
    }

    @Test("Purchasing the monthly subscription unlocks all access")
    func monthlyPurchaseUnlocksAccess() async throws {
        let session = try makeSession()
        let store = try await makeLoadedStore()

        guard let monthly = store.subscriptions.first(where: { $0.id == Self.monthlyID }) else {
            Issue.record("Monthly product missing from catalog")
            return
        }

        _ = try await store.purchase(monthly)
        _ = session

        try await waitUntil { store.unlimitedMonthlyEnabled }
        #expect(store.unlimitedMonthlyEnabled)
        #expect(store.allAccessEnabled)
    }

    @Test("Owning the lifetime product still grants access after it's removed from sale")
    func lifetimeEntitlementGrantsAccess() async throws {
        let session = try makeSession()
        // Simulate a customer who bought lifetime *before* it was pulled from sale.
        // The `.storekit` config still describes the product (so StoreKitTest can mint
        // the transaction), but the app no longer offers it: `unlimited_forever` was
        // removed from `Products.plist`, so `Store` never requests it and it never
        // appears in the loaded catalog.
        try await session.buyProduct(identifier: Self.lifetimeID)

        let store = try await makeLoadedStore()
        try await waitUntil { store.unlimitedForeverEnabled }

        // The product is not for sale — it must be absent from the loaded catalog...
        let catalogIDs = Set(store.subscriptions.map(\.id))
            .union(store.nonConsumables.map(\.id))
        #expect(!catalogIDs.contains(Self.lifetimeID),
                "Lifetime is removed from sale, so it must not appear in the catalog.")

        // ...yet the standing entitlement from the prior purchase keeps the owner unlocked.
        #expect(store.unlimitedForeverEnabled)
        #expect(store.allAccessEnabled)
    }

    // MARK: - PaywallStore adapter

    @Test("Adapter exposes monthly and yearly PaywallProducts with correct plans")
    func adapterMapsProducts() async throws {
        let session = try makeSession()
        _ = session
        let store = try await makeLoadedStore()

        let monthly = store.monthlyProduct
        let yearly = store.yearlyProduct

        #expect(monthly?.id == Self.monthlyID)
        #expect(monthly?.plan == .monthly)
        #expect(monthly?.displayPrice.isEmpty == false)

        #expect(yearly?.id == Self.yearlyID)
        #expect(yearly?.plan == .yearly)
        #expect(yearly?.displayPrice.isEmpty == false)
    }

    @Test("Adapter reports hasFullAccess false before purchase, true after")
    func adapterFullAccessReflectsPurchase() async throws {
        let session = try makeSession()
        let store = try await makeLoadedStore()
        #expect(store.hasFullAccess == false)

        guard let yearly = store.monthlyProduct ?? store.yearlyProduct else {
            Issue.record("No paywall product available")
            return
        }

        let result = await store.purchase(yearly)
        _ = session
        #expect(result == .success)

        try await waitUntil { store.hasFullAccess }
        #expect(store.hasFullAccess)
    }

    @Test("Adapter purchase of an unknown product fails gracefully")
    func adapterUnknownProductFails() async throws {
        let session = try makeSession()
        _ = session
        let store = try await makeLoadedStore()

        let bogus = PaywallProduct(
            id: "does.not.exist",
            plan: .monthly,
            displayPrice: "$0.00",
            price: 0
        )
        let result = await store.purchase(bogus)
        if case .failed = result {
            #expect(Bool(true))
        } else {
            Issue.record("Expected .failed for unknown product, got \(result)")
        }
    }
}
