import Foundation

/// A lightweight, UI-facing representation of an authenticated user.
///
/// `FeatureAuth` is intentionally backend-agnostic, so this is the *only*
/// user shape the UI knows about. Concrete services (Firebase, Supabase,
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

/// The contract the auth UI depends on.
///
/// `FeatureAuth` never imports Firebase (or any SDK). It only knows about
/// this protocol. The app's composition root injects a concrete
/// implementation — e.g. a `FirebaseAuthService` from a separate `Auth`
/// package — so the UI stays pure, testable, and provider-agnostic.
///
/// ```swift
/// // In a separate "Auth" package that imports FirebaseAuth:
/// import FeatureAuth
/// import FirebaseAuth
///
/// public final class FirebaseAuthService: AuthService {
///     public func signIn(email: String, password: String) async throws -> AuthUser {
///         let result = try await Auth.auth().signIn(withEmail: email, password: password)
///         return AuthUser(id: result.user.uid, email: result.user.email)
///     }
///     // ...
/// }
///
/// // In the app's composition root:
/// AuthFlowView(config: .init(appName: "Script Builder"),
///              service: FirebaseAuthService())
/// ```
public protocol AuthService: Sendable {
    /// Email + password sign-in. Throws on failure.
    func signIn(email: String, password: String) async throws -> AuthUser

    /// Email + password registration. Throws on failure.
    func signUp(firstName: String, lastName: String,
                email: String, password: String) async throws -> AuthUser

    /// Social sign-in. Implement the providers your app supports; throw
    /// `AuthServiceError.notImplemented` for any you don't.
    func signIn(with provider: SocialAuthProvider) async throws -> AuthUser

    /// Begin a password reset for the given email.
    func sendPasswordReset(email: String) async throws
}

/// Social identity providers the UI can request.
public enum SocialAuthProvider: String, Sendable {
    case apple
    case google
    case facebook
}

/// Errors a service can surface to the UI in a friendly way.
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

/// A no-backend implementation used by the dev host and SwiftUI previews.
///
/// It simulates latency and always succeeds, so you can build and preview
/// the entire auth experience with **no Firebase, no network, no config.**
public final class MockAuthService: AuthService {
    private let delay: UInt64

    /// - Parameter delay: simulated latency in seconds.
    public init(delay: TimeInterval = 0.8) {
        self.delay = UInt64(delay * 1_000_000_000)
    }

    public func signIn(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        return AuthUser(id: UUID().uuidString, email: email)
    }

    public func signUp(firstName: String, lastName: String,
                       email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        return AuthUser(id: UUID().uuidString, email: email,
                        displayName: "\(firstName) \(lastName)")
    }

    public func signIn(with provider: SocialAuthProvider) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        return AuthUser(id: UUID().uuidString, displayName: provider.rawValue.capitalized + " User")
    }

    public func sendPasswordReset(email: String) async throws {
        try await Task.sleep(nanoseconds: delay)
    }
}
