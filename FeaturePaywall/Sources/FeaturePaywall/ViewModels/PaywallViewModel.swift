//
//  PaywallViewModel.swift
//  FeaturePaywall
//

import SwiftUI
import Combine

@MainActor
final class PaywallViewModel: ObservableObject {
    enum Phase: Equatable {
        case loading
        case ready
        case purchasing
        case restoring
        case alreadySubscribed
        case error(String)
    }

    let configuration: PaywallConfiguration
    private let store: any PaywallStore
    private var cancellables = Set<AnyCancellable>()
    private var loadTimeoutTask: Task<Void, Never>?

    @Published var phase: Phase = .loading
    @Published var selectedPlan: PaywallPlan = .yearly

    init(configuration: PaywallConfiguration, store: any PaywallStore) {
        self.configuration = configuration
        self.store = store
        // Re-evaluate whenever the store reports a change (e.g. async product
        // load completing) so we don't sit on `.loading` forever.
        store.changePublisher
            .receive(on: RunLoop.main)
            .sink { [weak self] in self?.refreshPhase() }
            .store(in: &cancellables)
        refreshPhase()
    }

    var monthly: PaywallProduct? { store.monthlyProduct }
    var yearly: PaywallProduct? { store.yearlyProduct }

    var selectedProduct: PaywallProduct? {
        selectedPlan == .yearly ? yearly : monthly
    }

    var isBusy: Bool {
        phase == .purchasing || phase == .restoring
    }

    /// "Save 44%" style string comparing yearly vs. 12× monthly.
    var savingsBadgeText: String? {
        guard let monthly, let yearly else { return nil }
        let twelveMonths = monthly.price * 12
        guard twelveMonths > 0, yearly.price < twelveMonths else { return nil }
        let saved = (twelveMonths - yearly.price) / twelveMonths
        let percent = Int((saved as NSDecimalNumber).doubleValue * 100)
        guard percent > 0 else { return nil }
        return "Save \(percent)%"
    }

    var ctaTitle: String {
        if let yearly, selectedPlan == .yearly, yearly.hasEligibleFreeTrial {
            return "Start 7-Day Free Trial"
        }
        switch selectedPlan {
        case .yearly:
            return "Continue"
        case .monthly:
            return "Continue"
        }
    }

    var ctaSubline: String? {
        guard selectedPlan == .yearly, let yearly, yearly.hasEligibleFreeTrial else {
            return "Cancel anytime"
        }
        return "No charge today · Cancel anytime"
    }

    func refreshPhase() {
        if store.hasFullAccess {
            loadTimeoutTask?.cancel()
            phase = .alreadySubscribed
        } else if store.isLoadingProducts || (store.monthlyProduct == nil && store.yearlyProduct == nil) {
            // Stay in loading only if we don't already have an error showing.
            if case .error = phase { return }
            phase = .loading
        } else {
            loadTimeoutTask?.cancel()
            phase = .ready
            // Prefer yearly (trial-forward); fall back if it's missing.
            if yearly == nil, monthly != nil {
                selectedPlan = .monthly
            }
        }
    }

    /// Called when the paywall appears. Kicks off a product (re)load and arms a
    /// timeout so a stalled/empty StoreKit fetch surfaces an error with a
    /// Retry affordance instead of an infinite spinner.
    func onAppear() {
        guard phase == .loading else { return }
        Task { await store.reloadProducts(); refreshPhase() }
        armLoadTimeout()
    }

    /// User-initiated retry from the error state.
    func retry() {
        phase = .loading
        Task { await store.reloadProducts(); refreshPhase() }
        armLoadTimeout()
    }

    private func armLoadTimeout() {
        loadTimeoutTask?.cancel()
        loadTimeoutTask = Task { [weak self] in
            try? await Task.sleep(nanoseconds: 10_000_000_000) // 10s
            guard let self, !Task.isCancelled else { return }
            if self.phase == .loading {
                self.phase = .error("Couldn't load subscription options. Check your connection and try again.")
            }
        }
    }

    func select(_ plan: PaywallPlan) {
        selectedPlan = plan
    }

    /// Cancels any in-flight load-timeout timer. Called from the view's
    /// `onDisappear` so a pending 10s timer can't outlive the paywall and flip
    /// `phase` to `.error` after the screen is gone.
    func onDisappear() {
        loadTimeoutTask?.cancel()
        loadTimeoutTask = nil
    }

    /// Returns true on a completed purchase so the view can dismiss.
    func purchaseSelected() async -> Bool {
        guard let product = selectedProduct else { return false }
        phase = .purchasing
        let result = await store.purchase(product)
        switch result {
        case .success:
            return true
        case .cancelled, .pending:
            refreshPhase()
            return false
        case .failed(let message):
            phase = .error(message)
            return false
        }
    }

    func restore() async {
        phase = .restoring
        await store.restorePurchases()
        refreshPhase()
    }
}
