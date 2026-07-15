//
//  PurchaseBehaviorTests.swift
//  FeaturePaywallTests
//
//  Exercises the full purchase/restore/entitlement lifecycle through the
//  `PaywallStore` seam and `PaywallViewModel`. Uses a configurable spy so we
//  can drive every StoreKit outcome (success / cancel / pending / failure)
//  deterministically without touching StoreKit.
//

import Combine
import Testing
@testable import FeaturePaywall

/// A `PaywallStore` test double whose purchase/restore outcomes and product
/// catalog are fully controllable, and which reports state changes through
/// `changePublisher` exactly like the real `ObservableObject`-backed store.
@MainActor
final class SpyPaywallStore: PaywallStore {
    var monthlyProduct: PaywallProduct?
    var yearlyProduct: PaywallProduct?
    var hasFullAccess: Bool
    var isLoadingProducts: Bool

    /// The result the next `purchase(_:)` call will return.
    var purchaseResult: PaywallPurchaseResult
    /// When true, a successful purchase flips `hasFullAccess` and emits a change.
    var grantsAccessOnSuccess: Bool
    /// When true, `restorePurchases()` flips `hasFullAccess` and emits a change.
    var restoreGrantsAccess: Bool

    private(set) var purchaseCallCount = 0
    private(set) var restoreCallCount = 0
    private(set) var reloadCallCount = 0
    private(set) var lastPurchased: PaywallProduct?

    private let subject = PassthroughSubject<Void, Never>()

    init(
        monthlyProduct: PaywallProduct? = .init(id: "unlimited_monthly", plan: .monthly, displayPrice: "$5.99", price: 5.99),
        yearlyProduct: PaywallProduct? = .init(id: "unlimited_yearly", plan: .yearly, displayPrice: "$39.99", price: 39.99, hasEligibleFreeTrial: true, trialDescription: "7-day free trial"),
        hasFullAccess: Bool = false,
        isLoadingProducts: Bool = false,
        purchaseResult: PaywallPurchaseResult = .success,
        grantsAccessOnSuccess: Bool = true,
        restoreGrantsAccess: Bool = false
    ) {
        self.monthlyProduct = monthlyProduct
        self.yearlyProduct = yearlyProduct
        self.hasFullAccess = hasFullAccess
        self.isLoadingProducts = isLoadingProducts
        self.purchaseResult = purchaseResult
        self.grantsAccessOnSuccess = grantsAccessOnSuccess
        self.restoreGrantsAccess = restoreGrantsAccess
    }

    var changePublisher: AnyPublisher<Void, Never> { subject.eraseToAnyPublisher() }

    func reloadProducts() async {
        reloadCallCount += 1
        subject.send(())
    }

    func purchase(_ product: PaywallProduct) async -> PaywallPurchaseResult {
        purchaseCallCount += 1
        lastPurchased = product
        if case .success = purchaseResult, grantsAccessOnSuccess {
            hasFullAccess = true
            subject.send(())
        }
        return purchaseResult
    }

    func restorePurchases() async {
        restoreCallCount += 1
        if restoreGrantsAccess {
            hasFullAccess = true
            subject.send(())
        }
    }
}

@Suite("Purchase Behavior")
@MainActor
struct PurchaseBehaviorTests {

    private func makeViewModel(_ store: SpyPaywallStore) -> PaywallViewModel {
        PaywallViewModel(
            configuration: .scriptBuilderPro(termsURL: nil, privacyURL: nil),
            store: store
        )
    }

    /// Deterministically waits until `condition` holds (or a generous timeout),
    /// yielding to the main actor between checks so queued async work (the
    /// `reloadProducts` Task and the `changePublisher` sink hop) can run.
    /// Replaces fixed `Task.sleep` waits that made timing-dependent tests flaky.
    private func waitUntil(
        timeout: Duration = .seconds(2),
        _ condition: () -> Bool
    ) async {
        let deadline = ContinuousClock.now + timeout
        while ContinuousClock.now < deadline {
            if condition() { return }
            await Task.yield()
            try? await Task.sleep(nanoseconds: 1_000_000) // 1ms
        }
    }

    // MARK: - Successful purchase

    @Test("Successful purchase completes and signals dismissal")
    func successfulPurchaseCompletes() async {
        let store = SpyPaywallStore(purchaseResult: .success)
        let vm = makeViewModel(store)

        let didComplete = await vm.purchaseSelected()

        #expect(didComplete == true)
        #expect(store.purchaseCallCount == 1)
        #expect(store.hasFullAccess == true)
    }

    @Test("Purchases the currently selected plan")
    func purchasesSelectedPlan() async {
        let store = SpyPaywallStore()
        let vm = makeViewModel(store)
        vm.select(.monthly)

        _ = await vm.purchaseSelected()

        #expect(store.lastPurchased?.plan == .monthly)
    }

    // MARK: - Cancelled / pending purchase

    @Test("Cancelled purchase does not complete and returns to ready")
    func cancelledPurchaseReturnsToReady() async {
        let store = SpyPaywallStore(purchaseResult: .cancelled, grantsAccessOnSuccess: false)
        let vm = makeViewModel(store)

        let didComplete = await vm.purchaseSelected()

        #expect(didComplete == false)
        #expect(store.hasFullAccess == false)
        #expect(vm.phase == .ready)
    }

    @Test("Pending purchase does not complete and returns to ready")
    func pendingPurchaseReturnsToReady() async {
        let store = SpyPaywallStore(purchaseResult: .pending, grantsAccessOnSuccess: false)
        let vm = makeViewModel(store)

        let didComplete = await vm.purchaseSelected()

        #expect(didComplete == false)
        #expect(vm.phase == .ready)
    }

    // MARK: - Failed purchase

    @Test("Failed purchase surfaces an error phase")
    func failedPurchaseSurfacesError() async {
        let store = SpyPaywallStore(
            purchaseResult: .failed(message: "Card declined"),
            grantsAccessOnSuccess: false
        )
        let vm = makeViewModel(store)

        let didComplete = await vm.purchaseSelected()

        #expect(didComplete == false)
        #expect(vm.phase == .error("Card declined"))
    }

    // MARK: - Restore

    @Test("Restore that finds an entitlement moves to alreadySubscribed")
    func restoreGrantingAccessMovesToSubscribed() async {
        let store = SpyPaywallStore(restoreGrantsAccess: true)
        let vm = makeViewModel(store)

        await vm.restore()

        #expect(store.restoreCallCount == 1)
        #expect(vm.phase == .alreadySubscribed)
    }

    @Test("Restore with nothing to restore returns to ready")
    func restoreWithoutEntitlementReturnsToReady() async {
        let store = SpyPaywallStore(restoreGrantsAccess: false)
        let vm = makeViewModel(store)

        await vm.restore()

        #expect(store.restoreCallCount == 1)
        #expect(vm.phase == .ready)
    }

    // MARK: - Entitlement gating on launch

    @Test("Existing full access short-circuits to alreadySubscribed")
    func existingAccessShortCircuits() {
        let store = SpyPaywallStore(hasFullAccess: true)
        let vm = makeViewModel(store)

        #expect(vm.phase == .alreadySubscribed)
    }

    // MARK: - Product loading

    @Test("Loading state resolves to ready once products arrive")
    func loadingResolvesToReady() async {
        let store = SpyPaywallStore(
            monthlyProduct: nil,
            yearlyProduct: nil,
            isLoadingProducts: true
        )
        let vm = makeViewModel(store)
        #expect(vm.phase == .loading)

        // Products arrive; store stops loading and reload emits a change.
        store.isLoadingProducts = false
        store.monthlyProduct = .init(id: "unlimited_monthly", plan: .monthly, displayPrice: "$5.99", price: 5.99)
        store.yearlyProduct = .init(id: "unlimited_yearly", plan: .yearly, displayPrice: "$39.99", price: 39.99)
        vm.onAppear()

        // Wait deterministically for the reload Task + change publisher to
        // propagate rather than racing a fixed sleep.
        await waitUntil { vm.phase == .ready }

        #expect(store.reloadCallCount == 1)
        #expect(vm.phase == .ready)
    }
}
