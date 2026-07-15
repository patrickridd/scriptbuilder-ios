//
//  ReviewTriggerTests.swift
//  DomainTests
//
//  Exercises the pure review-prompt decision logic and its guardrails without
//  touching UserDefaults or StoreKit.
//

import Testing
import Foundation
@testable import Domain

private final class InMemoryStore: ReviewTriggerStore, @unchecked Sendable {
    private var ints: [String: Int] = [:]
    private var dates: [String: Date] = [:]
    private var strings: [String: String] = [:]

    func integer(forKey key: String) -> Int { ints[key] ?? 0 }
    func set(_ value: Int, forKey key: String) { ints[key] = value }
    func date(forKey key: String) -> Date? { dates[key] }
    func set(_ value: Date?, forKey key: String) { dates[key] = value }
    func string(forKey key: String) -> String? { strings[key] }
    func set(_ value: String?, forKey key: String) { strings[key] = value }
}

@Suite("ReviewTrigger")
struct ReviewTriggerTests {

    private func trigger(store: ReviewTriggerStore, now: Date = Date()) -> ReviewTrigger {
        ReviewTrigger(store: store, appVersion: "3.0.1", now: { now })
    }

    @Test("Never prompts a brand-new user with too few active days")
    func requiresDistinctDays() {
        let store = InMemoryStore()
        let t = trigger(store: store)
        // Only one active day recorded.
        _ = t.record(.appOpened(on: Date()))
        #expect(t.record(.screenplayExported) == false)
    }

    @Test("Prompts after export once engagement guardrails pass")
    func promptsAfterExportWhenEngaged() {
        let store = InMemoryStore()
        var day = DateComponents(calendar: .current, year: 2026, month: 1, day: 1).date!
        let t = trigger(store: store, now: day)
        // Three distinct active days.
        for _ in 0..<3 {
            _ = t.record(.appOpened(on: day))
            day = day.addingTimeInterval(60 * 60 * 24)
        }
        #expect(t.record(.screenplayExported) == true)
    }

    @Test("Does not re-prompt within the same app version")
    func onePromptPerVersion() {
        let store = InMemoryStore()
        let day = DateComponents(calendar: .current, year: 2026, month: 1, day: 1).date!
        var d = day
        let t = trigger(store: store, now: day)
        for _ in 0..<3 { _ = t.record(.appOpened(on: d)); d = d.addingTimeInterval(86_400) }
        #expect(t.record(.screenplayExported) == true)
        t.markPrompted()
        #expect(t.record(.outlineCompleted) == false)
    }

    @Test("Second screenplay qualifies but the first does not")
    func createTriggerThreshold() {
        let store = InMemoryStore()
        let day = DateComponents(calendar: .current, year: 2026, month: 1, day: 1).date!
        var d = day
        let t = trigger(store: store, now: day)
        for _ in 0..<3 { _ = t.record(.appOpened(on: d)); d = d.addingTimeInterval(86_400) }
        #expect(t.record(.screenplayCreated(total: 1)) == false)
        #expect(t.record(.screenplayCreated(total: 2)) == true)
    }
}
