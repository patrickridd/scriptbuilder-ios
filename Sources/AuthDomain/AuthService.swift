import Foundation

/// The contract the auth UI depends on.
///
/// The UI layer (`FeatureAuth`) never imports Firebase (or any SDK). It only
/// knows about this protocol. The app's composition root injects a concrete
/// implementation — e.g. a `FirebaseAuthService` from a separate
/// `FirebaseAuthData` package — so the UI stays pure, testable, and
/// provider-agnostic.
///
/// ```swift
/// // In a separate "FirebaseAuthData" package that imports FirebaseAuth:
/// import AuthDomain
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

    /// Sign the current user out.
    ///
    /// Implementations should clear **every** session the app holds — the
    /// primary auth session (e.g. Firebase) as well as any social SDK
    /// sessions (Google, Facebook). Otherwise a subsequent social sign-in may
    /// silently reuse a cached account.
    func signOut() throws

    /// Permanently delete the currently signed-in account and all associated
    /// data.
    ///
    /// Firebase (and most identity providers) require the user to have signed
    /// in **recently** before a destructive operation like account deletion is
    /// allowed. Concrete implementations are responsible for triggering
    /// re-authentication when the provider reports `requiresRecentLogin`.
    ///
    /// - Throws: `AuthServiceError` — typically `.message` with a localised
    ///   description. The caller should present a confirmation dialog **before**
    ///   calling this method.
    func deleteAccount() async throws
}

public extension AuthService {
    /// Default implementation so existing conformers don't break when the
    /// requirement is added. Override to provide real sign-out behaviour.
    func signOut() throws {
        throw AuthServiceError.notImplemented("Sign out")
    }

    /// Default implementation so existing conformers don't break when the
    /// requirement is added. Override to provide real account-deletion
    /// behaviour.
    func deleteAccount() async throws {
        throw AuthServiceError.notImplemented("Delete account")
    }
}
