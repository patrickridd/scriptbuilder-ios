import SwiftUI

/// Drives the login and signup screens. UI-only for now — wire up to a
/// real auth backend later. Validation messages are written to be clear
/// and friendly for assistive technologies.
@MainActor
final class AuthViewModel: ObservableObject {

    // MARK: - Shared inputs
    @Published var email: String = ""
    @Published var password: String = ""

    // MARK: - Sign up inputs
    @Published var firstName: String = ""
    @Published var lastName: String = ""

    // MARK: - State
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Validation

    var isLoginValid: Bool {
        isValidEmail(email) && password.count >= 6
    }

    var isSignUpValid: Bool {
        !firstName.trimmingCharacters(in: .whitespaces).isEmpty
            && !lastName.trimmingCharacters(in: .whitespaces).isEmpty
            && isValidEmail(email)
            && password.count >= 6
    }

    // MARK: - Actions (placeholder logic)

    func login() {
        guard isLoginValid else {
            errorMessage = "Enter a valid email and a password of at least 6 characters."
            return
        }
        runMockRequest()
    }

    func signUp() {
        guard isSignUpValid else {
            errorMessage = "Please fill in every field. Passwords need at least 6 characters."
            return
        }
        runMockRequest()
    }

    func continueWithApple() { runMockRequest() }
    func continueWithFacebook() { runMockRequest() }
    func continueWithGoogle() { runMockRequest() }

    func forgotPassword() {
        errorMessage = "Password reset isn't connected yet."
    }

    // MARK: - Helpers

    private func runMockRequest() {
        errorMessage = nil
        isLoading = true
        Task {
            try? await Task.sleep(nanoseconds: 800_000_000)
            isLoading = false
        }
    }

    private func isValidEmail(_ value: String) -> Bool {
        let pattern = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return value.range(of: pattern, options: .regularExpression) != nil
    }
}
