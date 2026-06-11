import Foundation

/// Errors a service can surface to consumers in a friendly way.
public enum AuthServiceError: LocalizedError {
    case notImplemented(String)
    case message(String)

    public var errorDescription: String? {
        switch self {
        case .notImplemented(let what): return "\(what) isn't available yet."
        case .message(let text): return text
        }
    }
}
