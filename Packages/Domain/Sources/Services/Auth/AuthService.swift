//
//  AuthService.swift
//  Domain
//
//  Created by Mindset Team on 2/1/26.
//

import Foundation

/// Authentication credential types supported
/// Domain defines the credential structure without coupling to specific providers
public enum AuthCredential: Sendable {
    /// OAuth credential with identity token (e.g., Apple Sign In, Google Sign In)
    /// - identityToken: OAuth identity token
    /// - nonce: Optional security nonce for providers that require it (e.g. Apple)
    /// - accessToken: Optional access token for providers that use it (e.g. Google)
    /// - fullName: Optional user's full name (provided on first sign-in)
    case oauth(
        identityToken: String,
        nonce: String? = nil,
        accessToken: String? = nil,
        fullName: String? = nil
    )

    /// Phone number credential (e.g. Firebase SMS verification)
    /// - verificationID: From PhoneVerificationProvider.requestVerificationCode
    /// - verificationCode: SMS code entered by user
    case phone(verificationID: String, verificationCode: String)

    /// Anonymous credential for trial/testing without account
    case anonymous
}

/// Provider used to link a permanent account to an existing session (e.g., link Apple to anonymous).
///
/// This stays provider-agnostic by reusing `AuthCredential` as the payload.
public enum AuthProvider: Sendable {
    case credential(AuthCredential)
}

/// Authentication service protocol for user sign-in and identity management
/// Protocol is provider-agnostic - implementations handle specific providers (Firebase, Supabase, etc.)
///
/// Composes capability protocols so the Composition Root can inject a single instance.
/// Features receive narrower protocols (SignInService, AuthStateQuery, etc.) via their ViewModels.
public protocol AuthService: SignInService, AuthStateQuery, AuthSessionManagement,
    OAuthCallbackHandler, Sendable {}
