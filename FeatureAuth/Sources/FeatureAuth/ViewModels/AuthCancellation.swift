import Foundation
import AuthDomain

/// Shared sentinel used to detect a user-cancelled sign-in flow.
///
/// `AuthServiceError` (AuthDomain 1.0.0) has no dedicated `.cancelled` case, so
/// data-layer coordinators throw `.message(AuthCancellation.sentinel)` and this
/// view layer suppresses the error alert when it matches. Keep this string
/// identical to the copy in the FirebaseAuthData package.
enum AuthCancellation {
    static let sentinel = "com.superapp.featureauth.cancelled"
}

extension Error {
    /// `true` when this error represents a deliberate user cancellation.
    var isAuthCancellation: Bool {
        if let authError = self as? AuthServiceError,
           case let .message(text) = authError {
            return text == AuthCancellation.sentinel
        }
        return false
    }
}
