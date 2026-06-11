import SwiftUI
import AuthDomain

/// The simplest way to drop the whole FeatureAuth experience into an app.
/// Presents the login screen, which itself presents sign-up as a sheet.
///
/// Inject your concrete `AuthService` (e.g. a Firebase-backed one) at the
/// composition root, and handle the authenticated user via `onAuthenticated`.
///
/// ```swift
/// import FeatureAuth
///
/// AuthFlowView(
///     config: AuthConfiguration(appName: "Script Builder"),
///     service: FirebaseAuthService()
/// ) { user in
///     session.signedIn(as: user)
/// }
/// ```
///
/// With no arguments it falls back to a `MockAuthService`, so the dev host
/// and previews run with zero configuration.
public struct AuthFlowView: View {
    private let config: AuthConfiguration
    private let theme: AuthPalette
    private let service: AuthService
    private let onAuthenticated: (AuthUser) -> Void

    public init(config: AuthConfiguration = .default,
                theme: AuthPalette = .default,
                service: AuthService = MockAuthService(),
                onAuthenticated: @escaping (AuthUser) -> Void = { _ in }) {
        self.config = config
        self.theme = theme
        self.service = service
        self.onAuthenticated = onAuthenticated
    }

    public var body: some View {
        LoginView(config: config, theme: theme, service: service, onAuthenticated: onAuthenticated)
    }
}

#Preview("AuthFlow — Light") {
    AuthFlowView()
        .preferredColorScheme(.light)
}

#Preview("AuthFlow — Dark") {
    AuthFlowView()
        .preferredColorScheme(.dark)
}
