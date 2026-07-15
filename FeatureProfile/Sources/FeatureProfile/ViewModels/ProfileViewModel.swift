import Foundation
import Observation
import AuthDomain

/// Drives all account-management operations for the profile screen.
///
/// Holds an injected `AuthService` (the protocol only — never a concrete SDK)
/// and surfaces each sensitive operation as an `async` method that maps the
/// service's `throw`s onto observable UI state. This mirrors how
/// `AuthViewModel` works in `FeatureAuth`, so both auth-adjacent modules share
/// one mental model.
@MainActor
@Observable
public final class ProfileViewModel {

    // MARK: - Dependencies

    private let service: any AuthService

    // MARK: - Identity (read live from the service)

    /// The currently signed-in user, refreshed from the service.
    public private(set) var user: AuthUser?

    /// Whether the signed-in user authenticated with email + password (vs. a
    /// social provider only). Password changes are only offered to these users,
    /// matching the legacy Settings behaviour.
    public var canChangePassword: Bool {
        guard let user else { return false }
        // Social-only accounts have at least one linked provider and no
        // password credential; email+password users surface no social provider.
        return user.linkedProviders.isEmpty
    }

    /// Whether to offer the "Verify email" affordance.
    public var needsEmailVerification: Bool {
        guard let user, user.email != nil else { return false }
        return !user.isEmailVerified
    }

    // MARK: - Transient UI state

    /// Set while any account operation is in flight, used to drive overlays and
    /// disable controls.
    public private(set) var isWorking = false

    /// The most recent error message, surfaced via an `.alert`. Cleared on the
    /// next successful operation or when the user dismisses it.
    public var errorMessage: String?

    /// A short success confirmation (e.g. "Password updated"), surfaced via a
    /// transient banner / alert.
    public var successMessage: String?

    // MARK: - Init

    public init(service: any AuthService) {
        self.service = service
        self.user = service.currentUser
    }

    // MARK: - Actions

    /// Refreshes the cached user from the service (e.g. after returning to the
    /// screen) so verification state and display name stay current.
    public func refresh() {
        user = service.currentUser
    }

    /// The current display name split into first / last parts, used to
    /// pre-fill the edit-name fields. Everything after the first space is
    /// treated as the last name.
    public var nameParts: (first: String, last: String) {
        let name = user?.displayName?.trimmingCharacters(in: .whitespaces) ?? ""
        guard !name.isEmpty else { return ("", "") }
        let components = name.split(separator: " ", maxSplits: 1).map(String.init)
        let first = components.first ?? ""
        let last = components.count > 1 ? components[1] : ""
        return (first, last)
    }

    /// Maximum characters allowed per name field.
    public static let maxNameFieldLength = 40

    /// Updates the signed-in user's display name from first + last name fields.
    ///
    /// Applies light validation before persisting: trims surrounding
    /// whitespace, collapses repeated inner spaces, requires a non-empty first
    /// name, and enforces a per-field length cap.
    public func updateName(firstName: String, lastName: String) async {
        let first = Self.cleaned(firstName)
        let last = Self.cleaned(lastName)

        guard !first.isEmpty else {
            errorMessage = L10n.Message.enterFirstName
            return
        }
        guard first.count <= Self.maxNameFieldLength,
              last.count <= Self.maxNameFieldLength else {
            errorMessage = L10n.Message.nameTooLong(Self.maxNameFieldLength)
            return
        }

        let joined = [first, last]
            .filter { !$0.isEmpty }
            .joined(separator: " ")

        // Skip the network round-trip if nothing actually changed.
        if joined == user?.displayName?.trimmingCharacters(in: .whitespaces) {
            successMessage = L10n.Message.nameUpdated
            return
        }

        await perform(success: L10n.Message.nameUpdated) {
            try await self.service.updateDisplayName(joined)
        }
    }

    /// Trims leading/trailing whitespace and collapses any runs of inner
    /// whitespace into a single space.
    private static func cleaned(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }

    /// Updates the signed-in user's password. Re-authenticates first if the
    /// provider reports the session is too old.
    public func changePassword(to newPassword: String) async {
        await perform(success: L10n.Message.passwordUpdated) {
            try await self.service.updatePassword(newPassword)
        }
    }

    /// Sends a verification email to the user's address.
    public func sendEmailVerification() async {
        await perform(success: L10n.Message.verificationSent) {
            try await self.service.sendEmailVerification()
        }
    }

    /// Permanently deletes the account. The view must confirm with the user
    /// before calling this.
    public func deleteAccount() async -> Bool {
        await perform(success: nil) {
            try await self.service.deleteAccount()
        }
    }

    // MARK: - Helper

    /// Runs an async account operation, toggling `isWorking` and mapping any
    /// thrown error onto `errorMessage`. Returns `true` on success.
    @discardableResult
    private func perform(
        success: String?,
        _ operation: @escaping () async throws -> Void
    ) async -> Bool {
        guard !isWorking else { return false }
        isWorking = true
        errorMessage = nil
        defer { isWorking = false }
        do {
            try await operation()
            user = service.currentUser
            if let success { successMessage = success }
            return true
        } catch let error as AuthServiceError {
            errorMessage = error.errorDescription ?? L10n.Message.generic
            return false
        } catch {
            errorMessage = error.localizedDescription
            return false
        }
    }
}
