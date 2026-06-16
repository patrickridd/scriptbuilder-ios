import Foundation

/// A no-backend implementation used by dev hosts and SwiftUI previews.
///
/// It simulates latency and always succeeds, so you can build and preview
/// the entire auth experience with **no Firebase, no network, no config.**
public final class MockAuthService: AuthService {
    private let delay: UInt64

    /// The simulated signed-in user. Mutations (sign-in, link, profile updates)
    /// keep this in sync so previews behave like a real session.
    private let state = MockState()

    /// - Parameter delay: simulated latency in seconds. A slightly longer
    ///   default (1.6s) lets loading states — like the shimmering auth overlay —
    ///   read clearly in dev hosts and previews.
    public init(delay: TimeInterval = 1.6) {
        self.delay = UInt64(delay * 1_000_000_000)
    }

    public func signIn(email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        let user = AuthUser(id: UUID().uuidString, email: email, isEmailVerified: true)
        state.set(user)
        return user
    }

    public func signUp(firstName: String, lastName: String,
                       email: String, password: String) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        let user = AuthUser(id: UUID().uuidString, email: email,
                            displayName: "\(firstName) \(lastName)")
        state.set(user)
        return user
    }

    public func signIn(with provider: SocialAuthProvider) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        let user = AuthUser(id: UUID().uuidString,
                            displayName: provider.rawValue.capitalized + " User",
                            isEmailVerified: true,
                            linkedProviders: [provider])
        state.set(user)
        return user
    }

    public func sendPasswordReset(email: String) async throws {
        try await Task.sleep(nanoseconds: delay)
    }

    public func signOut() throws {
        state.set(nil)
    }

    public func deleteAccount() async throws {
        try await Task.sleep(nanoseconds: delay)
        state.set(nil)
        // In the mock there is no real account — deletion always succeeds.
    }

    // MARK: - Session

    public var currentUser: AuthUser? { state.current }

    public func authStateStream() -> AsyncStream<AuthUser?> {
        state.makeStream()
    }

    // MARK: - Linking

    @discardableResult
    public func linkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        guard let current = state.current else {
            throw AuthServiceError.message("No signed-in account to link.")
        }
        var providers = current.linkedProviders
        if !providers.contains(provider) { providers.append(provider) }
        let updated = AuthUser(id: current.id, email: current.email,
                               displayName: current.displayName,
                               isEmailVerified: current.isEmailVerified,
                               linkedProviders: providers)
        state.set(updated)
        return updated
    }

    @discardableResult
    public func unlinkProvider(_ provider: SocialAuthProvider) async throws -> AuthUser {
        try await Task.sleep(nanoseconds: delay)
        guard let current = state.current else {
            throw AuthServiceError.message("No signed-in account to unlink.")
        }
        let updated = AuthUser(id: current.id, email: current.email,
                               displayName: current.displayName,
                               isEmailVerified: current.isEmailVerified,
                               linkedProviders: current.linkedProviders.filter { $0 != provider })
        state.set(updated)
        return updated
    }

    public func reauthenticate(with provider: SocialAuthProvider) async throws {
        try await Task.sleep(nanoseconds: delay)
    }

    // MARK: - Email verification

    public func sendEmailVerification() async throws {
        try await Task.sleep(nanoseconds: delay)
    }

    // MARK: - Profile & credential updates

    public func updateDisplayName(_ name: String) async throws {
        try await Task.sleep(nanoseconds: delay)
        guard let current = state.current else { return }
        state.set(AuthUser(id: current.id, email: current.email,
                           displayName: name, isEmailVerified: current.isEmailVerified,
                           linkedProviders: current.linkedProviders))
    }

    public func updateEmail(_ email: String) async throws {
        try await Task.sleep(nanoseconds: delay)
        guard let current = state.current else { return }
        state.set(AuthUser(id: current.id, email: email,
                           displayName: current.displayName, isEmailVerified: false,
                           linkedProviders: current.linkedProviders))
    }

    public func updatePassword(_ password: String) async throws {
        try await Task.sleep(nanoseconds: delay)
    }
}

/// Thread-safe holder for the mock's session state, with auth-state streaming.
private final class MockState: @unchecked Sendable {
    private let lock = NSLock()
    private var user: AuthUser?
    private var continuations: [UUID: AsyncStream<AuthUser?>.Continuation] = [:]

    var current: AuthUser? {
        lock.lock(); defer { lock.unlock() }
        return user
    }

    func set(_ newValue: AuthUser?) {
        lock.lock()
        user = newValue
        let conts = Array(continuations.values)
        lock.unlock()
        conts.forEach { $0.yield(newValue) }
    }

    func makeStream() -> AsyncStream<AuthUser?> {
        AsyncStream { continuation in
            let id = UUID()
            lock.lock()
            continuations[id] = continuation
            let snapshot = user
            lock.unlock()
            continuation.yield(snapshot)
            continuation.onTermination = { [weak self] _ in
                self?.lock.lock()
                self?.continuations[id] = nil
                self?.lock.unlock()
            }
        }
    }
}
