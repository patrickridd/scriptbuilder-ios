import Foundation

/// A no-backend implementation used by dev hosts and SwiftUI previews.
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

    public func signOut() throws {
        // No backend session to clear in the mock — nothing to do.
    }
}
