import Foundation

/// Social identity providers a consumer can request.
public enum SocialAuthProvider: String, Sendable {
    case apple
    case google
    case facebook
}
