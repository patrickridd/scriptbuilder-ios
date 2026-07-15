import SwiftUI
import Observation
import AuthDomain

/// Drives the login and signup screens.
///
/// The view model is **backend-agnostic**: it talks only to an injected
/// `AuthService`. Swap in a `FirebaseAuthService`, `SupabaseAuthService`,
/// or the built-in `MockAuthService` without changing any UI code.
@MainActor
@Observable
public final class AuthViewModel {

    // MARK: - Shared inputs
    public var email: String = ""
    public var password: String = ""

    // MARK: - Sign up inputs
    public var firstName: String = ""
    public var lastName: String = ""

    // MARK: - State
    public var isLoading: Bool = false
    public var errorMessage: String?
    public private(set) var currentUser: AuthUser?

    // MARK: - Dependencies
    /// Exposed so a parent screen (e.g. Login presenting Sign Up) can hand the
    /// same backend down to a child without re-storing it itself.
    @ObservationIgnored public let service: AuthService
    @ObservationIgnored public let onAuthenticated: (AuthUser) -> Void

    /// - Parameters:
    ///   - service: the auth backend. Defaults to `MockAuthService` so the
    ///     dev host and previews work with no configuration.
    ///   - onAuthenticated: called on the main actor after a successful
    ///     sign-in / sign-up. The composition root uses this to route the
    ///     user into the app.
    public init(service: AuthService = MockAuthService(),
                onAuthenticated: @escaping (AuthUser) -> Void = { _ in }) {
        self.service = service
        self.onAuthenticated = onAuthenticated
    }

    // MARK: - Validation

    public var isLoginValid: Bool {
        isValidEmail(email) && password.count >= 6
    }

    public var isSignUpValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
            && isValidEmail(email)
            && password.count >= 6
    }

    // MARK: - Actions

    public func login() {
        guard isLoginValid else {
            errorMessage = L10n.Message.loginInvalid
            return
        }
        perform { try await self.service.signIn(email: self.email, password: self.password) }
    }

    public func signUp() {
        guard isSignUpValid else {
            errorMessage = L10n.Message.signUpInvalid
            return
        }
        perform {
            try await self.service.signUp(firstName: self.firstName, lastName: self.lastName,
                                          email: self.email, password: self.password)
        }
    }

    public func continueWithApple() { social(.apple) }
    public func continueWithFacebook() { social(.facebook) }
    public func continueWithGoogle() { social(.google) }

    public func forgotPassword() {
        guard isValidEmail(email) else {
            errorMessage = L10n.Message.resetNeedEmail
            return
        }
        let address = email
        runTask {
            try await self.service.sendPasswordReset(email: address)
            self.errorMessage = L10n.Message.resetSent(address)
        }
    }

    // MARK: - Helpers

    private func social(_ provider: SocialAuthProvider) {
        perform { try await self.service.signIn(with: provider) }
    }

    /// Runs an authenticating request and routes the resulting user out.
    private func perform(_ work: @escaping () async throws -> AuthUser) {
        runTask {
            let user = try await work()
            self.currentUser = user
            self.onAuthenticated(user)
        }
    }

    /// Shared loading + error-handling wrapper for any async auth call.
    private func runTask(_ work: @escaping () async throws -> Void) {
        errorMessage = nil
        isLoading = true
        Task {
            defer { isLoading = false }
            do {
                try await work()
            } catch let error where error.isAuthCancellation {
                // User backed out of the sign-in flow — not a real error.
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
