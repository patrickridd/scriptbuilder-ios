import Testing
import AuthDomain
@testable import FeatureProfile

@Suite("FeatureProfile")
struct FeatureProfileTests {
    @Test("Initials from a two-word name")
    func initialsFromTwoWordName() {
        let config = ProfileConfiguration(displayName: "Ada Lovelace", onSignOut: {})
        #expect(config.initials == "AL")
    }

    @Test("Initials fall back to '?' for an empty name")
    func initialsFallbackForEmptyName() {
        let config = ProfileConfiguration(displayName: "", onSignOut: {})
        #expect(config.initials == "?")
    }

    @Test("Change password succeeds")
    @MainActor
    func changePasswordSucceeds() async {
        let service = MockAuthService(delay: 0)
        _ = try? await service.signIn(email: "ada@example.com", password: "secret123")
        let vm = ProfileViewModel(service: service)
        await vm.changePassword(to: "newSecret123")
        #expect(vm.errorMessage == nil)
        #expect(vm.successMessage == "Password updated.")
    }

    @Test("Delete account clears the session")
    @MainActor
    func deleteAccountClearsSession() async {
        let service = MockAuthService(delay: 0)
        _ = try? await service.signIn(email: "ada@example.com", password: "secret123")
        let vm = ProfileViewModel(service: service)
        let success = await vm.deleteAccount()
        #expect(success)
        #expect(service.currentUser == nil)
    }
}
