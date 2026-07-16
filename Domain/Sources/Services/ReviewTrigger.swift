//
//  ReviewTrigger.swift
//  Domain
//
//  Pure, testable engagement-tracking logic that decides *when* it's a good
//  moment to ask for an App Store review. It records lightweight signals and
//  exposes a single `shouldRequestReview()` decision, applying conservative
//  guardrails on top of whatever rate-limiting the OS already enforces.
//
//  The trigger owns no StoreKit and no UI. The app layer records signals as
//  they happen, then — when `shouldRequestReview()` returns true — calls the
//  injected `ReviewRequestService`. State persists via the injected
//  `ReviewTriggerStore` (a `UserDefaults`-backed impl in the app layer, or an
//  in-memory dictionary in tests).
//

import Foundation

/// A minimal key/value persistence seam for the trigger's counters and dates,
/// so the decision logic can be exercised without touching `UserDefaults`.
public protocol ReviewTriggerStore: AnyObject, Sendable {
    func integer(forKey key: String) -> Int
    func set(_ value: Int, forKey key: String)
    func date(forKey key: String) -> Date?
    func set(_ value: Date?, forKey key: String)
    func string(forKey key: String) -> String?
    func set(_ value: String?, forKey key: String)
}

/// Signals the app records as the user engages with the product. Each is a
/// "moment of delight" or an engagement milestone.
public enum ReviewSignal: Sendable, Equatable {
    /// The user exported/shared a finished screenplay — the strongest moment.
    case screenplayExported
    /// The user filled in all three acts of an outline.
    case outlineCompleted
    /// The user created a screenplay (pass the running total they now own).
    case screenplayCreated(total: Int)
    /// The app became active on a given calendar day (for "days active").
    case appOpenedOn(date: Date)
}

/// Decides when to request a review, based on recorded engagement signals.
public struct ReviewTrigger: Sendable {

    // MARK: Tunable policy

    /// Minimum number of distinct days the user must have opened the app.
    public let minDistinctActiveDays: Int
    /// Minimum number of screenplays owned before a "created" signal qualifies.
    public let minScreenplaysForCreateTrigger: Int
    /// Minimum spacing between prompts we initiate ourselves (belt & braces on
    /// top of the OS cap).
    public let minInterval: TimeInterval
    /// Current app version, so we never re-prompt within the same version once
    /// a prompt has been shown for it (mirrors Apple's own per-version cap).
    public let appVersion: String

    private let store: ReviewTriggerStore
    private let now: @Sendable () -> Date

    // MARK: Keys

    private enum Key {
        static let distinctDays = "review.distinctActiveDays"
        static let lastActiveDay = "review.lastActiveDay"
        static let lastPromptDate = "review.lastPromptDate"
        static let lastPromptVersion = "review.lastPromptVersion"
        static let pendingDelight = "review.pendingDelight"
    }

    public init(
        store: ReviewTriggerStore,
        appVersion: String,
        minDistinctActiveDays: Int = 3,
        minScreenplaysForCreateTrigger: Int = 2,
        minInterval: TimeInterval = 60 * 60 * 24 * 14,
        now: @escaping @Sendable () -> Date = Date.init
    ) {
        self.store = store
        self.appVersion = appVersion
        self.minDistinctActiveDays = minDistinctActiveDays
        self.minScreenplaysForCreateTrigger = minScreenplaysForCreateTrigger
        self.minInterval = minInterval
        self.now = now
    }

    // MARK: Recording signals

    /// Records an engagement signal. Returns `true` when — after recording —
    /// the app should present a review prompt now.
    @discardableResult
    public func record(_ signal: ReviewSignal) -> Bool {
        switch signal {
        case .appOpenedOn(let day):
            recordActiveDay(day)
            return false
        case .screenplayCreated(let total):
            guard total >= minScreenplaysForCreateTrigger else { return false }
            return markDelightAndDecide()
        case .screenplayExported, .outlineCompleted:
            return markDelightAndDecide()
        }
    }

    /// The standalone decision, without recording a new signal.
    public func shouldRequestReview() -> Bool {
        guard store.integer(forKey: Key.pendingDelight) > 0 else { return false }
        return passesGuardrails()
    }

    /// Call after a prompt was actually presented, so we don't re-ask too soon.
    public func markPrompted() {
        store.set(0, forKey: Key.pendingDelight)
        store.set(now(), forKey: Key.lastPromptDate)
        store.set(appVersion, forKey: Key.lastPromptVersion)
    }

    // MARK: - Internals

    private func markDelightAndDecide() -> Bool {
        store.set(1, forKey: Key.pendingDelight)
        return passesGuardrails()
    }

    private func passesGuardrails() -> Bool {
        // Never in the same app version we already prompted for.
        if store.string(forKey: Key.lastPromptVersion) == appVersion { return false }
        // Require genuine, multi-day engagement.
        if store.integer(forKey: Key.distinctDays) < minDistinctActiveDays { return false }
        // Respect our own minimum spacing between prompts.
        if let last = store.date(forKey: Key.lastPromptDate),
           now().timeIntervalSince(last) < minInterval {
            return false
        }
        return true
    }

    private func recordActiveDay(_ day: Date) {
        let key = Self.dayKey(for: day)
        if store.string(forKey: Key.lastActiveDay) == key { return }
        store.set(key, forKey: Key.lastActiveDay)
        store.set(store.integer(forKey: Key.distinctDays) + 1, forKey: Key.distinctDays)
    }

    private static func dayKey(for date: Date) -> String {
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = TimeZone(identifier: "UTC") ?? .current
        let c = cal.dateComponents([.year, .month, .day], from: date)
        return "\(c.year ?? 0)-\(c.month ?? 0)-\(c.day ?? 0)"
    }
}
