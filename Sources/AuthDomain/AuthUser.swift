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

    /// Whether the user's email address has been verified with the provider.
    /// Defaults to `false` for services that don't expose verification state.
    public let isEmailVerified: Bool

    /// The identity providers currently linked to this account (e.g. `.apple`,
    /// `.google`, `.facebook`). Used to drive account-linking UI — for example,
    /// bridging a Facebook-only user onto an additional provider.
    ///
    /// Email+password is not represented here; it is tracked separately by
    /// concrete services if needed.
    public let linkedProviders: [SocialAuthProvider]

    public init(id: String,
                email: String? = nil,
                displayName: String? = nil,
                isEmailVerified: Bool = false,
                linkedProviders: [SocialAuthProvider] = []) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.isEmailVerified = isEmailVerified
        self.linkedProviders = linkedProviders
    }
}
