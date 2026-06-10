import XCTest
@testable import FeatureAuth

@MainActor
final class AuthViewModelTests: XCTestCase {

    func testLoginValidationRejectsBadInput() {
        let vm = AuthViewModel()
        vm.email = "not-an-email"
        vm.password = "123"
        XCTAssertFalse(vm.isLoginValid)
    }

    func testLoginValidationAcceptsGoodInput() {
        let vm = AuthViewModel()
        vm.email = "jane@example.com"
        vm.password = "hunter2"
        XCTAssertTrue(vm.isLoginValid)
    }

    func testSignUpValidationRequiresAllFields() {
        let vm = AuthViewModel()
        vm.email = "jane@example.com"
        vm.password = "hunter2"
        XCTAssertFalse(vm.isSignUpValid, "Missing names should fail")
        vm.firstName = "Jane"
        vm.lastName = "Doe"
        XCTAssertTrue(vm.isSignUpValid)
    }

    func testSuccessfulLoginRoutesUserThroughCallback() async {
        var received: AuthUser?
        let vm = AuthViewModel(service: MockAuthService(delay: 0)) { received = $0 }
        vm.email = "jane@example.com"
        vm.password = "hunter2"
        vm.login()
        // Let the async auth task complete.
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertEqual(received?.email, "jane@example.com")
        XCTAssertEqual(vm.currentUser?.email, "jane@example.com")
        XCTAssertNil(vm.errorMessage)
    }

    func testFailingServiceSurfacesErrorMessage() async {
        let vm = AuthViewModel(service: FailingAuthService())
        vm.email = "jane@example.com"
        vm.password = "hunter2"
        vm.login()
        try? await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertNotNil(vm.errorMessage)
        XCTAssertNil(vm.currentUser)
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
