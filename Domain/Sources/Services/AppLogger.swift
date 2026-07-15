//
//  AppLogger.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//

/// Severity levels for app logging. Maps 1:1 onto the levels of Apple's
/// Unified Logging System (`os.Logger`), so a concrete `SystemLogger` can
/// forward each case to the matching `os.Logger` method.
public enum LogLevel: Sendable, Equatable {
    case debug
    case info
    case notice
    case error
    case fault
}

/// Dependency-free logging seam for the app. Consumers depend on this
/// protocol; the composition root injects a concrete implementation
/// (e.g. `SystemLogger`). Tests/previews can inject a no-op or capturing mock.
public protocol AppLogger: Sendable {
    /// Logs `message` at the given severity `level`.
    func log(_ level: LogLevel, _ message: String)
}

public extension AppLogger {
    /// Convenience for `log(.debug, _:)`.
    func debug(_ message: String) { log(.debug, message) }
    /// Convenience for `log(.info, _:)`.
    func info(_ message: String) { log(.info, message) }
    /// Convenience for `log(.notice, _:)`.
    func notice(_ message: String) { log(.notice, message) }
    /// Convenience for `log(.error, _:)`.
    func error(_ message: String) { log(.error, message) }
    /// Convenience for `log(.fault, _:)`.
    func fault(_ message: String) { log(.fault, message) }
}
