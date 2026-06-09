//
//  FirebaseAuthService.swift
//  Data
//
//  Created by ScriptBuilder Team on 2/1/26.
//

import Domain
import FirebaseAuth
import Foundation
import GoogleSignIn

// Disambiguate: Domain.AuthCredential vs FirebaseAuth.AuthCredential
public typealias DomainAuthCredential = Domain.AuthCredential
public typealias DomainAuthProvider = Domain.AuthProvider
typealias FirebaseAuthCredential = FirebaseAuth.AuthCredential

/// Firebase implementation of AuthService.
///
/// **Sendable safety invariant:** All methods are async and stateless; `logger` is only called
/// from within those methods. No shared mutable state. Safe to use from any isolation domain.
public final class FirebaseAuthService: AuthService, Sendable {

    private let logger: AppLogger

    public init(logger: AppLogger) {
        self.logger = logger
        // Firebase should be configured in app initialization (MindsetApp.swift)
    }

    // MARK: - Shared Helper Properties

    fileprivate var currentUser: FirebaseAuth.User? {
        Auth.auth().currentUser
    }

    fileprivate var isAnonymouslySignedIn: Bool {
        currentUser?.isAnonymous ?? false
    }
}

// MARK: - SignInService

extension FirebaseAuthService: SignInService {

    public func signIn(with credential: DomainAuthCredential) async throws -> String {
        
        logger.log("🔐 Auth sign-in started for credential: \(credential)")

        // Check if already logged in
        if isAuthenticated(), let userId = await getCurrentUserID() {
            logger.log("User already signed in with '\(authCredentialIdentifier?.uppercased() ?? "unknown".uppercased())' provider and has id: \(userId)")
            return userId
        }
        
        do {
            switch credential {
            case .oauth(let identityToken, let nonce, let accessToken, let fullName):
                return try await signInWithOAuth(
                    identityToken: identityToken,
                    nonce: nonce,
                    accessToken: accessToken,
                    fullName: fullName
                )

            case .phone(let verificationID, let verificationCode):
                return try await signInWithPhone(
                    verificationID: verificationID,
                    verificationCode: verificationCode
                )

            case .anonymous:
                return try await signInAnonymously()
            }
        } catch {
            logger.log("❌ Auth sign-in failed: \(error.localizedDescription)")
            throw error
        }
    }

    public func signInAnonymously() async throws -> String {
        if let uid = await getCurrentUserID(), isAnonymouslySignedIn {
            logger.log("🤫 Anonymous sign-in skipped ⏭️ (already authenticated)")
            return uid
        }

        logger.log("🤫 Signing in anonymously...")
        do {
            let result = try await Auth.auth().signInAnonymously()
            logger.log("🥸 Signed in anonymously...")
            return result.user.uid
        } catch {
            logger.log("❌ Anonymous sign-in failed: \(error.localizedDescription)")
            throw error
        }
    }

    // MARK: - SignInService Private Helpers

    private func signInWithOAuth(
        identityToken: String,
        nonce: String?,
        accessToken: String?,
        fullName: String?
    ) async throws -> String {
        // Determine provider based on presence of nonce (Apple) or accessToken (Google)
        if let nonce = nonce {
            // Apple Sign In uses nonce
            let firebaseCredential = OAuthProvider.credential(
                providerID: .apple,
                idToken: identityToken,
                rawNonce: nonce
            )
            do {
                let result = try await Auth.auth().signIn(with: firebaseCredential)
                let uid = result.user.uid

                // Store full name if provided (first sign-in only)
                if let fullName = fullName, !fullName.isEmpty {
                    try await updateUserProfile(displayName: fullName)
                }
                logger.log("🍎 Apple sign-in successful ✅ uid=\(uid)")
                return uid
            } catch {
                logger.log("📵 Apple sign-in Error \(error.localizedDescription)")
                throw error
            }
        } else {
            // Google Sign In - Use credential when tokens provided (SDK flow), else web flow
            if let accessToken = accessToken, !identityToken.isEmpty, !accessToken.isEmpty {
                let credential = GoogleAuthProvider.credential(
                    withIDToken: identityToken,
                    accessToken: accessToken
                )
                let result = try await Auth.auth().signIn(with: credential)
                logger.log("🤖 Gmail sign-in successful ✅ uid=\(result.user.uid)")
                return result.user.uid
            }
            #if canImport(UIKit)
                return try await signInWithGoogleViaFirebase()
            #else
                throw NSError(
                    domain: "FirebaseAuthService",
                    code: -1,
                    userInfo: [
                        NSLocalizedDescriptionKey:
                            "Google web OAuth is not supported on this platform"
                    ]
                )
            #endif
        }
    }

    #if canImport(UIKit)
        private func signInWithGoogleViaFirebase() async throws -> String {
            let provider = OAuthProvider(providerID: "google.com")
            provider.scopes = ["email", "profile"]
            provider.customParameters = ["prompt": "select_account"]

            return try await withCheckedThrowingContinuation { continuation in
                Auth.auth().signIn(with: provider, uiDelegate: nil) {
                    [weak self] authResult, error in
                    if let error = error {
                        self?.logger.log("📵 Gmail sign-in Error \(error.localizedDescription)")
                        continuation.resume(throwing: error)
                    } else if let uid = authResult?.user.uid {
                        self?.logger.log("🤖 Gmail sign-in successful ✅ uid=\(uid)")
                        continuation.resume(returning: uid)
                    } else {
                        continuation.resume(
                            throwing: NSError(
                                domain: "FirebaseAuthService",
                                code: -1,
                                userInfo: [
                                    NSLocalizedDescriptionKey: "Unknown error during Google sign in"
                                ]
                            ))
                    }
                }
            }
        }
    #else
        private func signInWithGoogleViaFirebase() async throws -> String {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [
                    NSLocalizedDescriptionKey: "Google web OAuth is not supported on this platform"
                ]
            )
        }
    #endif

    private func signInWithPhone(
        verificationID: String,
        verificationCode: String
    ) async throws -> String {
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: verificationCode
        )
        let result = try await Auth.auth().signIn(with: credential)
        logger.log("📱 Phone Sign-In successful ✅ uid=\(result.user.uid)")
        return result.user.uid
    }

    private func updateUserProfile(displayName: String) async throws {
        guard let user = currentUser else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]
            )
        }

        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = displayName
        try await changeRequest.commitChanges()
    }
}

// MARK: - AuthStateQuery

extension FirebaseAuthService: AuthStateQuery {

    public func getCurrentUserID() async -> String? {
        currentUser?.uid
    }

    public func isAuthenticated() -> Bool {
        currentUser != nil
    }

    public func isAnonymousAccountLinked() -> Bool {
        isAuthenticated() && !isAnonymouslySignedIn
    }

    public var authCredentialIdentifier: String? {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            return nil
        }
        let authCredentialIdentifier = providerData.map { $0.providerID }.first
        return authCredentialIdentifier
    }
}

// MARK: - AuthSessionManagement

extension FirebaseAuthService: AuthSessionManagement {

    public func signOut() async throws {
        logger.log("🚪 Auth sign-out requested")
        try Auth.auth().signOut()
        logger.log("✅ Auth sign-out completed")
    }

    public func linkAccount(with provider: DomainAuthProvider) async throws {
        let providerDescription: String = {
            switch provider {
            case .credential(let credential):
                switch credential {
                case .anonymous:
                    return "anonymous"
                case .phone:
                    return "phone"
                case .oauth(_, let nonce, let accessToken, _):
                    if nonce != nil { return "apple" }
                    if accessToken != nil { return "google" }
                    return "oauth"
                }
            }
        }()

        logger.log("🔗 Link account started (provider: \(providerDescription))")

        guard let currentUser = currentUser else {
            logger.log("❌ Link account failed: no authenticated user")
            throw Domain.AuthLinkError.notAuthenticated
        }

        let domainCredential: DomainAuthCredential
        let firebaseCredential: FirebaseAuthCredential
        switch provider {
        case .credential(let dc):
            domainCredential = dc
            firebaseCredential = try makeFirebaseCredentialForLinking(from: dc)
        }

        do {
            try await withCheckedThrowingContinuation {
                (continuation: CheckedContinuation<Void, Error>) in
                currentUser.link(with: firebaseCredential) { _, error in
                    if let error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }

            logger.log(
                "✅ Link account successful (provider: \(providerDescription)) uid=\(currentUser.uid)"
            )
            await applyOAuthDisplayNameToFirebaseAfterLink(from: domainCredential)
        } catch {
            if let nsError = error as NSError?,
                AuthErrorCode(_bridgedNSError: nsError) == .credentialAlreadyInUse
            {
                logger.log(
                    "⚠️ Link account failed: credential already in use (provider: \(providerDescription))"
                )
                throw Domain.AuthLinkError.credentialAlreadyInUse
            }

            logger.log(
                "❌ Link account failed (provider: \(providerDescription)): \(error.localizedDescription)"
            )
            throw error
        }
    }

    /// Sets Firebase `displayName` when linking with Apple/Google and the credential carries a name.
    private func applyOAuthDisplayNameToFirebaseAfterLink(from credential: DomainAuthCredential) async {
        guard case .oauth(_, _, _, let fullName?) = credential else { return }
        let trimmed = fullName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        try? await updateUserProfile(displayName: trimmed)
    }

    public func deleteCurrentUser() async throws {
        guard let user = currentUser else {
            throw NSError(
                domain: "FirebaseAuthService",
                code: -1,
                userInfo: [NSLocalizedDescriptionKey: "No authenticated user"]
            )
        }

        try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<Void, Error>) in
            user.delete { [logger] error in
                if let error {
                    logger.log("Failed 🚨 to delete Firebase user. Error: \(error)")
                    continuation.resume(throwing: error)
                } else {
                    logger.log("Deleted 🧹 Firebase user")
                    continuation.resume(returning: ())
                }
            }
        }
    }

    // MARK: - AuthSessionManagement Private Helpers

    private func makeFirebaseCredentialForLinking(from credential: DomainAuthCredential) throws
        -> FirebaseAuthCredential
    {
        switch credential {
        case .anonymous:
            throw Domain.AuthLinkError.invalidProviderCredential

        case .phone(let verificationID, let verificationCode):
            return PhoneAuthProvider.provider().credential(
                withVerificationID: verificationID,
                verificationCode: verificationCode
            )

        case .oauth(let identityToken, let nonce, let accessToken, _):
            if let nonce {
                guard !identityToken.isEmpty else {
                    throw Domain.AuthLinkError.invalidProviderCredential
                }
                return OAuthProvider.credential(
                    providerID: .apple,
                    idToken: identityToken,
                    rawNonce: nonce
                )
            }

            guard
                let accessToken,
                !identityToken.isEmpty,
                !accessToken.isEmpty
            else {
                throw Domain.AuthLinkError.invalidProviderCredential
            }

            return GoogleAuthProvider.credential(
                withIDToken: identityToken, accessToken: accessToken)
        }
    }
}

// MARK: - OAuthCallbackHandler

extension FirebaseAuthService: OAuthCallbackHandler {

    public func handleAuthCallback(url: URL) -> Bool {
        #if canImport(UIKit)
            // Google Sign-In SDK handles its own OAuth redirect URLs
            if GIDSignIn.sharedInstance.handle(url) {
                return true
            }
            return Auth.auth().canHandle(url)
        #else
            logger.log("⚠️ OAuth callback handling is not supported on this platform")
            return false
        #endif
    }
}
