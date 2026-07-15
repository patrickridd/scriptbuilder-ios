//
//  PaywallProduct.swift
//  FeaturePaywall
//
//  StoreKit-free value types so the paywall UI never imports StoreKit.
//  The app target maps StoreKit.Product into these via an adapter.
//

import Foundation

/// Which plan a paywall product represents.
public enum PaywallPlan: String, Sendable, Hashable {
    case monthly
    case yearly
}

/// A StoreKit-free description of a purchasable plan shown on the paywall.
public struct PaywallProduct: Identifiable, Sendable, Hashable {
    public let id: String
    public let plan: PaywallPlan
    /// Localized, currency-formatted price (e.g. "$39.99").
    public let displayPrice: String
    /// Raw decimal price used to compute savings/per-month math.
    public let price: Decimal
    /// Whether this product carries an introductory free trial offer the user is eligible for.
    public let hasEligibleFreeTrial: Bool
    /// Human label for the trial (e.g. "7-day free trial"), when present.
    public let trialDescription: String?

    public init(
        id: String,
        plan: PaywallPlan,
        displayPrice: String,
        price: Decimal,
        hasEligibleFreeTrial: Bool = false,
        trialDescription: String? = nil
    ) {
        self.id = id
        self.plan = plan
        self.displayPrice = displayPrice
        self.price = price
        self.hasEligibleFreeTrial = hasEligibleFreeTrial
        self.trialDescription = trialDescription
    }
}

/// Outcome of a purchase attempt, mapped from StoreKit by the adapter.
public enum PaywallPurchaseResult: Sendable, Equatable {
    case success
    case cancelled
    case pending
    case failed(message: String)
}
