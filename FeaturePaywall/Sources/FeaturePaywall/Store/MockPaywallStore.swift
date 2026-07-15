//
//  MockPaywallStore.swift
//  FeaturePaywall
//
//  Drives SwiftUI previews and unit tests without StoreKit.
//

import Foundation

@MainActor
public final class MockPaywallStore: PaywallStore {
    public var monthlyProduct: PaywallProduct?
    public var yearlyProduct: PaywallProduct?
    public var hasFullAccess: Bool
    public var isLoadingProducts: Bool

    public init(
        monthlyProduct: PaywallProduct? = .init(
            id: "unlimited_monthly",
            plan: .monthly,
            displayPrice: "$5.99",
            price: 5.99
        ),
        yearlyProduct: PaywallProduct? = .init(
            id: "unlimited_yearly",
            plan: .yearly,
            displayPrice: "$39.99",
            price: 39.99,
            hasEligibleFreeTrial: true,
            trialDescription: "7-day free trial"
        ),
        hasFullAccess: Bool = false,
        isLoadingProducts: Bool = false
    ) {
        self.monthlyProduct = monthlyProduct
        self.yearlyProduct = yearlyProduct
        self.hasFullAccess = hasFullAccess
        self.isLoadingProducts = isLoadingProducts
    }

    public func purchase(_ product: PaywallProduct) async -> PaywallPurchaseResult {
        try? await Task.sleep(nanoseconds: 600_000_000)
        hasFullAccess = true
        return .success
    }

    public func restorePurchases() async {
        try? await Task.sleep(nanoseconds: 400_000_000)
    }
}
