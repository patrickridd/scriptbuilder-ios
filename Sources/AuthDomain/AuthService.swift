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

    // MARK: - Session

    /// The currently signed-in user, or `nil` if no session is active.
    ///
    /// Lets the UI restore state on relaunch without re-running a sign-in call.
    var currentUser: AuthUser? { get }

    /// An async stream that emits the current user whenever auth state changes
    /// (sign-in, sign-out, token refresh, profile update). Emits the current
    /// value immediately on subscription.
    func authStateStream() -> AsyncStream<AuthUser?>

    // MARK: - Account linking / provider bridging

    /// Links an additional social provider to the **currently signed-in**
    /// account, keeping the same user id. Use this to bridge a user from one
    /// provider onto another (e.g. add Google to a Facebook-only account)
    /// before optionally unlinking the old one.
    ///
    /// - Throws: `AuthServiceError` — e.g. when the credential is already in
    ///   use by another account, or re-authentication is required.
    @discardableResult
    func linkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser

    /// Removes a linked social provider from the currently signed-in account.
    /// At least one sign-in method must remain after unlinking.
    @discardableResult
    func unlinkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser

    /// Re-authenticates the current user with the given provider. Required
    /// before sensitive operations (deletion, email/password change, unlink)
    /// when the provider reports the session is too old.
    func reauthenticate(with provider: SocialAuthProvider) async throws

    // MARK: - Email verification

    /// Sends a verification email to the currently signed-in user's address.
    func sendEmailVerification() async throws

    // MARK: - Profile & credential updates

    /// Updates the signed-in user's display name.
    func updateDisplayName(_ name: String) async throws

    /// Updates the signed-in user's email address. May require recent login.
    func updateEmail(_ email: String) async throws

    /// Updates the signed-in user's password. May require recent login.
    func updatePassword(_ password: String) async throws
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

    // MARK: - Session defaults

    /// Defaults to `nil` — services that can expose the current session should
    /// override this.
    var currentUser: AuthUser? { nil }

    /// Default stream emits a single `nil` then finishes. Override to bridge a
    /// real auth-state listener.
    func authStateStream() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            continuation.yield(currentUser)
            continuation.finish()
        }
    }

    // MARK: - Linking defaults

    @discardableResult
    func linkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser {
        throw AuthServiceError.notImplemented("Link \(provider.rawValue.capitalized)")
    }

    @discardableResult
    func unlinkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser {
        throw AuthServiceError.notImplemented("Unlink \(provider.rawValue.capitalized)")
    }

    func reauthenticate(with provider: SocialAuthProvider) async throws {
        throw AuthServiceError.notImplemented("Re-authenticate")
    }

    // MARK: - Email verification default

    func sendEmailVerification() async throws {
        throw AuthServiceError.notImplemented("Email verification")
    }

    // MARK: - Profile update defaults

    func updateDisplayName(_ name: String) async throws {
        throw AuthServiceError.notImplemented("Update display name")
    }

    func updateEmail(_ email: String) async throws {
        throw AuthServiceError.notImplemented("Update email")
    }

    func updatePassword(_ password: String) async throws {
        throw AuthServiceError.notImplemented("Update password")
    }
}
