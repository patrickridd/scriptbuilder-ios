//
//  Store+PaywallStore.swift
//  ScriptStarter
//
//  Adapter that conforms the existing StoreKit 2 `Store` singleton to the
//  StoreKit-free `PaywallStore` protocol from the FeaturePaywall package.
//  This keeps the paywall UI decoupled from StoreKit and leaves Store.swift
//  untouched — a future RevenueCat adapter could conform the same protocol.
//

import Foundation
import StoreKit
import Combine
import FeaturePaywall

@MainActor
extension Store: PaywallStore {

    public var changePublisher: AnyPublisher<Void, Never> {
        objectWillChange.map { _ in () }.eraseToAnyPublisher()
    }

    public func reloadProducts() async {
        // Retry the StoreKit product fetch; safe to call repeatedly. Publishing
        // `subscriptions` via `@Published` flips the paywall out of `.loading`.
        if subscriptions.isEmpty {
            await requestProducts()
        }
    }

    public var monthlyProduct: PaywallProduct? {
        guard let product = subscriptions.first(where: { $0.id == unlimitedMonthlyIdentifier }) else {
            return nil
        }
        return makePaywallProduct(from: product, plan: .monthly)
    }

    public var yearlyProduct: PaywallProduct? {
        guard let product = subscriptions.first(where: { $0.id == unlimitedYearlyIdentifier }) else {
            return nil
        }
        return makePaywallProduct(from: product, plan: .yearly)
    }

    public var hasFullAccess: Bool {
        allAccessEnabled
    }

    public var isLoadingProducts: Bool {
        subscriptions.isEmpty
    }

    public func purchase(_ product: PaywallProduct) async -> PaywallPurchaseResult {
        guard let storeProduct = subscriptions.first(where: { $0.id == product.id }) else {
            return .failed(message: "That plan isn't available right now. Please try again.")
        }
        do {
            let transaction = try await purchase(storeProduct)
            return transaction != nil ? .success : .cancelled
        } catch {
            return .failed(message: "Purchase couldn't be completed. Please try again.")
        }
    }

    public func restorePurchases() async {
        await sync()
        await updateCustomerProductStatus()
    }

    // MARK: - Mapping

    private func makePaywallProduct(from product: Product, plan: PaywallPlan) -> PaywallProduct {
        let trialInfo = introductoryTrial(for: product)
        return PaywallProduct(
            id: product.id,
            plan: plan,
            displayPrice: product.displayPrice,
            price: product.price,
            hasEligibleFreeTrial: trialInfo != nil,
            trialDescription: trialInfo
        )
    }

    /// Returns a human-readable free-trial description (e.g. "7-day free trial")
    /// only when the product has an introductory free offer. Eligibility for the
    /// offer is confirmed by StoreKit at purchase time.
    private func introductoryTrial(for product: Product) -> String? {
        guard
            let offer = product.subscription?.introductoryOffer,
            offer.paymentMode == .freeTrial
        else {
            return nil
        }
        let count = offer.period.value
        let unit: String
        switch offer.period.unit {
        case .day: unit = "day"
        case .week: unit = "week"
        case .month: unit = "month"
        case .year: unit = "year"
        @unknown default: unit = "day"
        }
        return "\(count)-\(unit) free trial"
    }
}
