//
//  SystemLogger.swift
//  Domain
//
//  Created by patrick ridd on 3/1/26.
//

import os

/// `AppLogger` backed by Apple's Unified Logging System (`os.Logger`).
///
/// Output lands in Console.app and the system log archive, with structured
/// levels, subsystem/category filtering, and near-zero cost for levels that
/// aren't being collected. Only depends on Apple's `os` framework, so it's
/// safe to live in the dependency-free Domain layer.
public struct SystemLogger: AppLogger {
    private let logger: Logger
    private let categoryEmoji: String

    /// - Parameters:
    ///   - subsystem: Reverse-DNS identifier, typically the app's bundle id.
    ///   - category: A label used to group and filter related log entries.
    public init(subsystem: String = "com.scriptbuilder.app", category: String = "App") {
        self.logger = Logger(subsystem: subsystem, category: category)
        self.categoryEmoji = Self.emoji(for: category)
    }

    public func log(_ level: LogLevel, _ message: String) {
        // Prefix with the category emoji + the level emoji so a glance at
        // Console.app tells you both *where* a line came from and *how loud*
        // it is, e.g. "🚪 ℹ️ User signed in".
        let line = "\(categoryEmoji) \(Self.emoji(for: level)) \(message)"
        switch level {
        case .debug:
            logger.debug("\(line, privacy: .public)")
        case .info:
            logger.info("\(line, privacy: .public)")
        case .notice:
            logger.notice("\(line, privacy: .public)")
        case .error:
            logger.error("\(line, privacy: .public)")
        case .fault:
            logger.fault("\(line, privacy: .public)")
        }
    }

    /// Maps a known category to a memorable emoji, with a sensible fallback for
    /// any category we haven't tagged yet.
    private static func emoji(for category: String) -> String {
        switch category {
        case "Gate":       return "🚪"  // auth/paywall gating
        case "Store":      return "🛒"  // StoreKit / purchases
        case "Repository": return "🗄️"  // data persistence
        case "Auth":       return "🔐"  // sign-in flows
        case "App":        return "📱"  // general app lifecycle
        default:           return "🏷️"  // untagged category
        }
    }

    /// Maps a severity level to an emoji so the eye can rank lines at a glance.
    private static func emoji(for level: LogLevel) -> String {
        switch level {
        case .debug:  return "💬"
        case .info:   return "ℹ️"
        case .notice: return "📣"
        case .error:  return "❌"
        case .fault:  return "🔥"
        }
    }
}
