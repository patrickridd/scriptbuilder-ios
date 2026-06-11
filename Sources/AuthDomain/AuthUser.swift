import Foundation

/// A lightweight, UI-facing representation of an authenticated user.
///
/// The auth contract is intentionally backend-agnostic, so this is the *only*
/// user shape consumers know about. Concrete services (Firebase, Supabase,
/// your own API) map their richer user objects down to this.
public struct AuthUser: Equatable, Sendable {
    public let id: String
    public let email: String?
    public let displayName: String?

    public init(id: String, email: String? = nil, displayName: String? = nil) {
        self.id = id
        self.email = email
        self.displayName = displayName
    }
}
