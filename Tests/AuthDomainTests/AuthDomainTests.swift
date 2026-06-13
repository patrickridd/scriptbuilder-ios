import Testing
import Foundation
@testable import AuthDomain

@Suite("MockAuthService")
struct MockAuthServiceTests {

    @Test("Email sign-in returns a user carrying the supplied email")
    func signInReturnsUserWithEmail() async throws {
        // Given
        let sut = MockAuthService(delay: 0)

        // When
        let user = try await sut.signIn(email: "jane@example.com", password: "hunter2")

        // Then
        #expect(user.email == "jane@example.com")
        #expect(user.id.isEmpty == false)
    }

    @Test("Sign-up composes the display name from first and last name")
    func signUpComposesDisplayName() async throws {
        // Given
        let sut = MockAuthService(delay: 0)

        // When
        let user = try await sut.signUp(firstName: "Jane", lastName: "Doe",
                                        email: "jane@example.com", password: "hunter2")

        // Then
        #expect(user.displayName == "Jane Doe")
        #expect(user.email == "jane@example.com")
    }

    @Test("Social sign-in labels the user by provider")
    func socialSignInLabelsUserByProvider() async throws {
        // Given
        let sut = MockAuthService(delay: 0)

        // When
        let user = try await sut.signIn(with: .apple)

        // Then
        #expect(user.displayName == "Apple User")
    }
}

@Suite("AuthServiceError")
struct AuthServiceErrorTests {

    @Test("notImplemented produces a descriptive message")
    func notImplementedDescription() {
        // Given
        let error = AuthServiceError.notImplemented("Google sign-in")

        // When
        let description = error.errorDescription

        // Then
        #expect(description == "Google sign-in isn't available yet.")
    }

    @Test("message passes its text straight through")
    func messagePassesTextThrough() {
        // Given
        let error = AuthServiceError.message("Invalid credentials")

        // When
        let description = error.errorDescription

        // Then
        #expect(description == "Invalid credentials")
    }
}
