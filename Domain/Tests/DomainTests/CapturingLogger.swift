//
//  CapturingLogger.swift
//  DomainTests
//
//  A test double that records every log call so assertions can verify the
//  level and message a unit under test emitted, without touching the real
//  Unified Logging System.
//

import Foundation
@testable import Domain

/// An `AppLogger` that captures each `(level, message)` it receives.
///
/// Thread-safe: an internal lock guards `entries`, so it can be injected into
/// code that logs from concurrent contexts. Only the single protocol
/// requirement is implemented — the convenience methods (`debug`, `info`, …)
/// come from the protocol extension and funnel through `log`, so they are
/// covered for free.
final class CapturingLogger: AppLogger, @unchecked Sendable {

    struct Entry: Equatable {
        let level: LogLevel
        let message: String
    }

    private let lock = NSLock()
    private var _entries: [Entry] = []

    /// All captured entries, in the order they were logged.
    var entries: [Entry] {
        lock.lock(); defer { lock.unlock() }
        return _entries
    }

    /// Messages captured for a specific level.
    func messages(for level: LogLevel) -> [String] {
        entries.filter { $0.level == level }.map(\.message)
    }

    func log(_ level: LogLevel, _ message: String) {
        lock.lock(); defer { lock.unlock() }
        _entries.append(Entry(level: level, message: message))
    }
}
