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
}
