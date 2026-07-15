import Testing
@testable import FeatureAuth
import AuthDomain

@MainActor
@Suite("AuthViewModel")
struct AuthViewModelTests {

    @Test("Login validation rejects an invalid email and short password")
    func loginValidationRejectsBadInput() {
        // Given
        let sut = AuthViewModel()

        // When
        sut.email = "not-an-email"
        sut.password = "123"

        // Then
        #expect(sut.isLoginValid == false)
    }

    @Test("Login validation accepts a well-formed email and password")
    func loginValidationAcceptsGoodInput() {
        // Given
        let sut = AuthViewModel()

        // When
        sut.email = "jane@example.com"
        sut.password = "hunter2"

        // Then
        #expect(sut.isLoginValid)
    }

    @Test("Sign-up validation requires every field to be filled")
    func signUpValidationRequiresAllFields() {
        // Given
        let sut = AuthViewModel()
        sut.email = "jane@example.com"
        sut.password = "hunter2"

        // When / Then — names still missing
        #expect(sut.isSignUpValid == false)

        // When — names provided
        sut.firstName = "Jane"
        sut.lastName = "Doe"

        // Then
        #expect(sut.isSignUpValid)
    }

    @Test("A successful login routes the user through the callback")
    func successfulLoginRoutesUserThroughCallback() async {
        // Given
        var received: AuthUser?
        let sut = AuthViewModel(service: MockAuthService(delay: 0)) { received = $0 }
        sut.email = "jane@example.com"
        sut.password = "hunter2"

        // When
        sut.login()
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(received?.email == "jane@example.com")
        #expect(sut.currentUser?.email == "jane@example.com")
        #expect(sut.errorMessage == nil)
    }

    @Test("A failing service surfaces an error message and no user")
    func failingServiceSurfacesErrorMessage() async {
        // Given
        let sut = AuthViewModel(service: FailingAuthService())
        sut.email = "jane@example.com"
        sut.password = "hunter2"

        // When
        sut.login()
        try? await Task.sleep(nanoseconds: 50_000_000)

        // Then
        #expect(sut.errorMessage != nil)
        #expect(sut.currentUser == nil)
    }
}

/// A stub that always fails, to verify error handling.
private struct FailingAuthService: AuthService {
    func signIn(email: String, password: String) async throws -> AuthUser {
        throw AuthServiceError.message("Invalid credentials")
    }
    func signUp(firstName: String, lastName: String,
                email: String, password: String) async throws -> AuthUser {
        throw AuthServiceError.message("Could not create account")
    }
    func signIn(with provider: SocialAuthProvider) async throws -> AuthUser {
        throw AuthServiceError.notImplemented(provider.rawValue)
    }
    func sendPasswordReset(email: String) async throws {
        throw AuthServiceError.message("Reset failed")
    }
}
