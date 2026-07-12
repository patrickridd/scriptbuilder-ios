//
//  ReviewSupport.swift
//  ScriptStarter
//
//  App-layer glue for the review-prompt feature. The decision logic lives in
//  `Domain` (`ReviewTrigger`); this file provides the concrete, platform-bound
//  pieces the composition root injects:
//    • `UserDefaultsReviewTriggerStore` — persists counters/dates.
//    • `StoreKitReviewRequestService` — presents Apple's native review sheet.
//    • `ReviewCoordinator` — records signals and, when the trigger says so,
//      asks StoreKit to prompt, then marks it as shown.
//

import Domain
import Foundation
import StoreKit
import UIKit

/// `UserDefaults`-backed implementation of `Domain.ReviewTriggerStore`.
final class UserDefaultsReviewTriggerStore: ReviewTriggerStore, @unchecked Sendable {
    private let defaults: UserDefaults
    init(defaults: UserDefaults = .standard) { self.defaults = defaults }

    func integer(forKey key: String) -> Int { defaults.integer(forKey: key) }
    func set(_ value: Int, forKey key: String) { defaults.set(value, forKey: key) }
    func date(forKey key: String) -> Date? { defaults.object(forKey: key) as? Date }
    func set(_ value: Date?, forKey key: String) { defaults.set(value, forKey: key) }
    func string(forKey key: String) -> String? { defaults.string(forKey: key) }
    func set(_ value: String?, forKey key: String) { defaults.set(value, forKey: key) }
}

/// Presents Apple's native App Store review prompt via StoreKit. This is the
/// only sanctioned way to solicit an App Store rating in-app.
struct StoreKitReviewRequestService: ReviewRequestService {
    @MainActor
    func requestReview() {
        guard let scene = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .first(where: { $0.activationState == .foregroundActive })
        else { return }
        SKStoreReviewController.requestReview(in: scene)
    }
}

/// Ties the pure `ReviewTrigger` decision to the StoreKit presenter. The
/// composition root records engagement signals through this coordinator.
@MainActor
final class ReviewCoordinator {
    private let trigger: ReviewTrigger
    private let service: ReviewRequestService
    private let logger: AppLogger

    init(
        store: ReviewTriggerStore = UserDefaultsReviewTriggerStore(),
        service: ReviewRequestService = StoreKitReviewRequestService(),
        logger: AppLogger = SystemLogger(category: "Review"),
        appVersion: String = Bundle.main.releaseVersionNumber ?? "0"
    ) {
        self.trigger = ReviewTrigger(store: store, appVersion: appVersion)
        self.service = service
        self.logger = logger
    }

    /// Records an engagement signal and, if the trigger green-lights it,
    /// presents the native review prompt.
    func record(_ signal: ReviewSignal) {
        let shouldAsk = trigger.record(signal)
        guard shouldAsk else { return }
        logger.info("Requesting App Store review after \(String(describing: signal))")
        service.requestReview()
        trigger.markPrompted()
    }
}
