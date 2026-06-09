//
//  AuthCapabilities.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Capability: Sign-in flows (credential-based and anonymous).
public protocol SignInService: Sendable {
    /// Sign in with the provided credential
    /// - Parameter credential: Authentication credential (OAuth, phone, or anonymous)
    /// - Returns: Authenticated user ID
    func signIn(with credential: AuthCredential) async throws -> String

    /// Sign in anonymously (used for progressive authentication during onboarding).
    ///
    /// Implementations should be idempotent (no-op if already authenticated).
    func signInAnonymously() async throws -> String
}

/// Capability: Read-only auth state queries.
public protocol AuthStateQuery: Sendable {
    /// Get the current authenticated user ID if available
    /// - Returns: User ID if signed in, nil otherwise
    func getCurrentUserID() async -> String?

    /// Check if user is currently authenticated
    func isAuthenticated() -> Bool

    /// Check if current user's anonymous account has been linked with provider (gmail, apple, phone, etc...)
    func isAnonymousAccountLinked() -> Bool
    
    /// To find out which providers are linked to a user, use the providerData property of the User
    var authCredentialIdentifier: String? { get }
}

/// Capability: Session lifecycle and account linking.
public protocol AuthSessionManagement: Sendable {
    /// Sign out the current user
    func signOut() async throws

    /// Link a permanent account to the currently authenticated user (typically anonymous).
    ///
    /// Implementations must throw a domain error when the credential is already in use so UI can
    /// guide the user to switch accounts instead of linking.
    func linkAccount(with provider: AuthProvider) async throws

    /// Permanently delete the currently authenticated user account.
    ///
    /// Implementations may require a recent login and should surface that error to callers.
    func deleteCurrentUser() async throws
}

/// Capability: App-level OAuth callback URL handling (Composition Root only).
public protocol OAuthCallbackHandler: Sendable {
    /// Handle OAuth callback URL (e.g., from Safari after Google Sign In)
    /// - Parameter url: The callback URL from the OAuth flow
    /// - Returns: True if the URL was handled, false otherwise
    func handleAuthCallback(url: URL) -> Bool
}
