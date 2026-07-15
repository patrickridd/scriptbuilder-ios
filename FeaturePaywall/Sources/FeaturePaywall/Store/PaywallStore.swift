//
//  PaywallStore.swift
//  FeaturePaywall
//
//  The seam between the paywall UI and whatever fulfills purchases.
//  Today the app's StoreKit 2 `Store` conforms to this. A future
//  RevenueCat adapter could conform to the same protocol with zero
//  changes to the paywall UI.
//

import Foundation
import Combine

@MainActor
public protocol PaywallStore: AnyObject {
    /// The monthly plan, if available from the store.
    var monthlyProduct: PaywallProduct? { get }
    /// The yearly plan, if available from the store.
    var yearlyProduct: PaywallProduct? { get }
    /// Whether the user already has full access (any active sub or legacy lifetime).
    var hasFullAccess: Bool { get }
    /// True while products are still being loaded from the store.
    var isLoadingProducts: Bool { get }

    /// Emits whenever the store's product/entitlement state changes, so the
    /// paywall can re-evaluate its phase (e.g. after async product loading
    /// finishes). Stores backed by `ObservableObject` should return their
    /// `objectWillChange`. Defaults to a publisher that never fires.
    var changePublisher: AnyPublisher<Void, Never> { get }

    /// Kicks off (or retries) loading products from the store. Called when the
    /// paywall appears so a previously-failed/empty load can recover instead
    /// of spinning forever. Defaults to a no-op.
    func reloadProducts() async

    /// Attempt to purchase the given plan.
    func purchase(_ product: PaywallProduct) async -> PaywallPurchaseResult
    /// Restore previously purchased entitlements.
    func restorePurchases() async
}

public extension PaywallStore {
    var changePublisher: AnyPublisher<Void, Never> {
        Empty<Void, Never>(completeImmediately: false).eraseToAnyPublisher()
    }

    func reloadProducts() async {}
}
