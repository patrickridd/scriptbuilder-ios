//
//  Store.swift
//  ScriptStarter
//
//  Created by patrick ridd on 11/17/24.
//  Copyright © 2024 patrickridd. All rights reserved.
//

import Combine
import Domain
import FeaturePaywall
import StoreKit

typealias Transaction = StoreKit.Transaction
typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo
typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

public enum StoreError: Error {
    case failedVerification
}

// Define the app's subscription entitlements by level of service, with the highest level of service first.
// The numerical-level value matches the subscription's level that you configure in
// the StoreKit configuration file or App Store Connect.
public enum ServiceEntitlement: Int, Comparable {
    case notEntitled = 0
    
    case pro = 1
    case premium = 2
    case standard = 3
    
    init?(for product: Product) {
        // The product must be a subscription to have service entitlements.
        guard let subscription = product.subscription else {
            return nil
        }
        self.init(rawValue: subscription.groupLevel)
    }

    public static func < (lhs: Self, rhs: Self) -> Bool {
        // Subscription-group levels are in descending order.
        return lhs.rawValue > rhs.rawValue
    }
}

/// The StoreKit 2 purchase store. Owned as a single instance at the composition
/// root (`AppDelegate`) and injected into consumers.
///
/// `@unchecked Sendable`: all mutable `@Published` state is written only on the
/// main actor (StoreKit callbacks + `@MainActor` PaywallStore adapter), and the
/// entitlement flags read by the gate closures are simple value snapshots. This
/// lets the `@Sendable` gate closures capture the injected instance without the
/// former global-singleton escape hatch.
final class Store: ObservableObject, @unchecked Sendable {

    private let logger: AppLogger = SystemLogger(category: "Store")

    @Published private(set) var subscriptions: [Product] = []
    @Published private(set) var nonRenewableSubscriptions: [Product] = []
    @Published private(set) var nonConsumables: [Product] = []
    @Published private(set) var purchasedNonConsumables: [Product] = []
    @Published private(set) var purchasedSubscriptions: [Product] = []
    @Published private(set) var purchasedNonRenewableSubscriptions: [Product] = []
    @Published private(set) var subscriptionGroupStatus: Product.SubscriptionInfo.Status?

    /// Product IDs the customer is entitled to, derived directly from `Transaction.currentEntitlements`
    /// and NOT filtered by the loaded product catalog. This lets us keep honoring purchases (e.g. the
    /// legacy lifetime `unlimited_forever`) even after a product is removed from sale and StoreKit
    /// stops returning it in the products metadata fetch.
    @Published private(set) var entitledProductIDs: Set<String> = []

    
    var updateListenerTask: Task<Void, Error>? = nil
    private let productIds: [String]

    let noAdsIdentifier = "com.patrickridd.ScriptStarter.NoAds"
    let characterFeatureIdentifier = "com.patrickridd.ScriptStarter.Character.Builder"
    let sceneFeatureIdentifier = "com.patrickridd.ScriptStarter.Scene.Builder"
    let unlimitedMonthlyIdentifier = "unlimited_monthly"
    let unlimitedYearlyIdentifier = "unlimited_yearly"
    let unlimitedForeverIdentifier = "unlimited_forever"

    /// A StoreKit-free snapshot of the current product/entitlement state, fed into the
    /// pure `EntitlementResolver` so the access decision is unit-testable in `Domain`.
    private var entitlementSnapshot: EntitlementSnapshot {
        let catalog = Set(nonConsumables.map(\.id)).union(subscriptions.map(\.id))
        let purchasedCatalog = Set(purchasedNonConsumables.map(\.id))
            .union(purchasedSubscriptions.map(\.id))
        return EntitlementSnapshot(
            catalogProductIDs: catalog,
            purchasedCatalogProductIDs: purchasedCatalog,
            entitledProductIDs: entitledProductIDs
        )
    }

    var characterFeatureEnabled: Bool {
        EntitlementResolver.isEntitled(to: characterFeatureIdentifier, in: entitlementSnapshot)
    }

    var sceneFeatureEnabled: Bool {
        EntitlementResolver.isEntitled(to: sceneFeatureIdentifier, in: entitlementSnapshot)
    }

    var unlimitedForeverEnabled: Bool {
        EntitlementResolver.isEntitled(to: unlimitedForeverIdentifier, in: entitlementSnapshot)
    }

    var unlimitedMonthlyEnabled: Bool {
        EntitlementResolver.isEntitled(to: unlimitedMonthlyIdentifier, in: entitlementSnapshot)
    }

    var unlimitedYearlyEnabled: Bool {
        EntitlementResolver.isEntitled(to: unlimitedYearlyIdentifier, in: entitlementSnapshot)
    }

    var allAccessEnabled: Bool {
        // Any of these products individually unlocks all access — legacy lifetime &
        // legacy per-feature non-consumables, plus the current subscriptions.
        EntitlementResolver.hasAllAccess(
            anyOf: [
                characterFeatureIdentifier,
                sceneFeatureIdentifier,
                unlimitedForeverIdentifier,
                unlimitedMonthlyIdentifier,
                unlimitedYearlyIdentifier
            ],
            in: entitlementSnapshot
        )
    }
    
    init() {
        productIds = Store.loadProductIds()
        
        // Start a transaction listener as close to app launch as possible so you don't miss any transactions.
        updateListenerTask = listenForTransactions()

        Task {
            // During store initialization, request products from the App Store.
            await requestProducts()

            // Deliver products that the customer purchases.
            await updateCustomerProductStatus()
        }
    }

    deinit {
        updateListenerTask?.cancel()
    }

    static func loadProductIds() -> [String] {
        guard
            let path = Bundle.main.path(forResource: "Products", ofType: "plist"),
            let plist = FileManager.default.contents(atPath: path),
            let dictionary = (try? PropertyListSerialization.propertyList(from: plist, format: nil)) as? [String: String]
        else {
            return []
        }
        let productIds = dictionary.compactMap({ $0.value })
        guard !productIds.isEmpty
        else {
            return []
        }
        return productIds
    }

    func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            // Iterate through any transactions that don't come from a direct call to `purchase()`.
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)

                    // Deliver products to the user.
                    await self.updateCustomerProductStatus()

                    // Always finish a transaction.
                    await transaction.finish()
                } catch {
                    // StoreKit has a transaction that fails verification. Don't deliver content to the user.
                    self.logger.error("Transaction failed verification.")
                }
            }
        }
    }

    @MainActor
    func requestProducts() async {
        do {
            // Request products from the App Store using the identifiers that the `Products.plist` file defines.
            let storeProducts = try await Product.products(for: productIds)
            
            var newNonConsumable: [Product] = []
            var newSubscriptions: [Product] = []
            var newNonRenewableSubscriptions: [Product] = []

            // Filter the products into categories based on their type.
            for product in storeProducts {
                switch product.type {
                case .nonConsumable:
                    newNonConsumable.append(product)
                case .autoRenewable:
                    newSubscriptions.append(product)
                case .nonRenewable:
                    newNonRenewableSubscriptions.append(product)
                default:
                   break
                }
            }
            
            // Sort each product category by price, lowest to highest, to update the store.
            self.nonConsumables = newNonConsumable
            self.subscriptions = sortByPrice(newSubscriptions)
            self.nonRenewableSubscriptions = sortByPrice(newNonRenewableSubscriptions)
        } catch {
            logger.error("[Store] requestProducts FAILED: \(error.localizedDescription)")
        }
    }
    
    func purchase(_ product: Product) async throws -> Transaction? {
        // Begin purchasing the `Product` the user selects.
        let result = try await product.purchase()

        switch result {
        case .success(let verification):
            // Check whether the transaction is verified. If it isn't,
            // this function rethrows the verification error.
            let transaction = try checkVerified(verification)

            // The transaction is verified. Deliver content to the user.
            await updateCustomerProductStatus()

            // Always finish a transaction.
            await transaction.finish()

            return transaction
        case .userCancelled, .pending:
            return nil
        default:
            return nil
        }
    }

    func isPurchased(_ product: Product) async throws -> Bool {
        // Determine whether the user purchases a given product.
        switch product.type {
        case .nonRenewable:
            return purchasedNonRenewableSubscriptions.contains(product)
        case .nonConsumable:
            return purchasedNonConsumables.contains(product)
        case .autoRenewable:
            return purchasedSubscriptions.contains(product)
        default:
            return false
        }
    }

    func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        // Check whether the JWS passes StoreKit verification.
        switch result {
        case .unverified:
            // StoreKit parses the JWS, but it fails verification.
            throw StoreError.failedVerification
        case .verified(let safe):
            // The result is verified. Return the unwrapped value.
            return safe
        }
    }

    @MainActor
    func updateCustomerProductStatus() async {
        var purchasedSubscriptions: [Product] = []
        var purchasedNonRenewableSubscriptions: [Product] = []
        var purchasedNonConsumables: [Product] = []
        var entitledIDs: Set<String> = []

        // Iterate through all of the user's purchased products.
        for await result in Transaction.currentEntitlements {
            do {
                // Check whether the transaction is verified. If it isn’t, catch `failedVerification` error.
                let transaction = try checkVerified(result)

                // Record the entitlement directly from the verified transaction, independent of whether
                // the product still loads in the catalog. This keeps lifetime owners (and any other
                // removed-from-sale product owners) unlocked.
                switch transaction.productType {
                case .nonConsumable:
                    entitledIDs.insert(transaction.productID)
                case .autoRenewable:
                    if let expirationDate = transaction.expirationDate, expirationDate > Date() {
                        entitledIDs.insert(transaction.productID)
                    }
                case .nonRenewable:
                    entitledIDs.insert(transaction.productID)
                default:
                    break
                }

                // Check the `productType` of the transaction and get the corresponding product from the store.
                switch transaction.productType {
                case .nonConsumable:
                    if let purchasedNonConsumable = nonConsumables.first(where: { $0.id == transaction.productID }) {
                        purchasedNonConsumables.append(purchasedNonConsumable)
                    }
                case .nonRenewable:
                    if let nonRenewable = subscriptions.first(where: { $0.id == transaction.productID }),
                       transaction.productID == "nonRenewing.standard", let expirationDate = Calendar(identifier: .gregorian).date(byAdding: DateComponents(year: 1), to: transaction.purchaseDate) {
                        // Non-renewing subscriptions have no inherent expiration date, so `Transaction.currentEntitlements`
                        // always contains them after the user purchases them.
                        // This app defines this non-renewing subscription's expiration date to be one year after purchase.
                        // If the current date is within one year of the `purchaseDate`, the user is still entitled to this
                        // product.
                        if expirationDate > Date()  {
                            purchasedNonRenewableSubscriptions.append(nonRenewable)
                        }
                    }
                case .autoRenewable:
                    if let subscription = subscriptions.first(where: { $0.id == transaction.productID }),
                       let expirationDate = transaction.expirationDate, expirationDate > Date() {
                            purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
            } catch {
                logger.error("[Store] updateCustomerProductStatus transaction error: \(error.localizedDescription)")
            }
        }

        // Update the store information with the purchased products.
        self.purchasedNonConsumables = purchasedNonConsumables
        self.purchasedNonRenewableSubscriptions = purchasedNonRenewableSubscriptions
        // Update the store information with auto-renewable subscription products.
        self.purchasedSubscriptions = purchasedSubscriptions
        // Catalog-independent entitlements (honors removed-from-sale products like legacy lifetime).
        self.entitledProductIDs = entitledIDs

        // Check the `subscriptionGroupStatus` to learn the auto-renewable subscription state to determine whether the customer
        // is new (never subscribed), active, or inactive (expired subscription).
        // This app has only one subscription group, so products in the subscriptions array all belong to the same group.
        // Customers can be subscribed to only one product in the subscription group.
        // The statuses that `product.subscription.status` returns apply to the entire subscription group.
        do {
            subscriptionGroupStatus = try await subscriptions.first?.subscription?.status.max { lhs, rhs in
                // There may be multiple statuses for different family members, because this app supports Family Sharing.
                // The subscriber is entitled to service for the status with the highest level of service.
                let lhsEntitlement = entitlement(for: lhs)
                let rhsEntitlement = entitlement(for: rhs)
                return lhsEntitlement < rhsEntitlement
            }
        } catch {
            logger.error("[Store] subscriptionGroupStatus fetch failed: \(error.localizedDescription)")
        }
    }

    func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { return $0.price < $1.price })
    }

    // Get a subscription's level of service using the product ID.
    func entitlement(for status: Product.SubscriptionInfo.Status) -> ServiceEntitlement {
        // If the status is expired, then the customer is not entitled.
        if status.state == .expired || status.state == .revoked {
            return .notEntitled
        }
        // Get the product associated with the subscription status.
        let productID = status.transaction.unsafePayloadValue.productID
        guard let product = subscriptions.first(where: { $0.id == productID }) else {
            return .notEntitled
        }
        // Finally, get the corresponding entitlement for this product.
        return ServiceEntitlement(for: product) ?? .notEntitled
    }

    func resourceNameForProductIdentifier(_ productIdentifier: String) -> String? {
        return productIdentifier.components(separatedBy: ".").last
    }

    func sync() async {
        Task {
            try? await AppStore.sync()
        }
    }
}

enum InAppSubscription: Equatable {
    case monthly(_ product: Product?)
    case yearly(_ product: Product?)
    case lifetime(_ product: Product?)
    
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
    
    var totalPrice: String {
        switch self {
        case .monthly(let product):
            if let priceString = product?.price as? NSNumber,
               let currencySymbol = Locale.current.currencySymbol {
                let monthlyPrice = Double(truncating: priceString)
                let formattedPrice = monthlyPrice.truncate(places: 2)
                return "\(currencySymbol)\(formattedPrice)"
            } else {
                return "$2.99"
            }
        case .yearly(let product):
            if let priceString = product?.price as? NSNumber,
               let currencySymbol = Locale.current.currencySymbol {
                let yearlyPrice = Double(truncating: priceString)
                let formattedPrice = yearlyPrice.truncate(places: 2)
                return "\(currencySymbol)\(formattedPrice)"
            } else {
                return "$19.99"
            }
        case .lifetime(let product):
            if let priceString = product?.price as? NSNumber,
               let currencySymbol = Locale.current.currencySymbol {
                return "\(currencySymbol)\(priceString)"
            } else {
                return "$69.99"
            }
        }
    }
    
    var subtitle: String? {
        switch self {
        case .monthly(let product):
            if let priceString = product?.price as? NSNumber,
               let currencySymbol = Locale.current.currencySymbol {
                let monthlyPrice = Double(truncating: priceString)
                let weeklyPrice = (monthlyPrice/30.43) * 7
                let formattedPrice = weeklyPrice.truncate(places: 2)
                return "\(currencySymbol)\(formattedPrice)/\(PaywallStrings.perWeek)"
            } else {
                return "$0.68/week"
            }
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
