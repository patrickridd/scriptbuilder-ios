import Foundation

public enum AuthLinkError: Error, LocalizedError, Sendable {
    /// The provided credential is already associated with a different account.
    /// UI should prompt the user to switch accounts instead of linking.
    case credentialAlreadyInUse

    /// No authenticated user exists to link against.
    case notAuthenticated

    /// The provider/credential cannot be used for linking (e.g., `.anonymous`).
    case invalidProviderCredential

    public var errorDescription: String? {
        switch self {
        case .credentialAlreadyInUse:
            return "This account is already in use. Please switch accounts to continue."
        case .notAuthenticated:
            return "No signed-in user to link this account to."
        case .invalidProviderCredential:
            return "That sign-in method can’t be linked to this account."
        }
    }
}

