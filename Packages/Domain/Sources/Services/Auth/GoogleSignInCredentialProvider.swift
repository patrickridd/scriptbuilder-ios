//
//  GoogleSignInCredentialProvider.swift
//  Domain
//
//  Created by Mindset Team on 3/8/26.
//

import Foundation

/// Errors thrown by GoogleSignInCredentialProvider implementations.
public enum GoogleSignInError: Error, Sendable, Equatable {
    case noRootViewController
    case missingIDToken
    case missingAccessToken
    case userCancelled
    case unsupportedPlatform
}

/// Protocol for fetching Google Sign-In credentials.
/// Enables DI and testing without coupling to the Google Sign-In SDK.
public protocol GoogleSignInCredentialProvider: Sendable {
    /// Fetches an AuthCredential by presenting the Google Sign-In flow.
    /// - Returns: OAuth credential with idToken and accessToken for Firebase
    /// - Throws: When user cancels, network fails, or configuration is invalid
    func fetchCredential() async throws -> AuthCredential
}
