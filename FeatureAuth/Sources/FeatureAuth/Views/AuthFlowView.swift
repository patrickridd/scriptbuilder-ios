import SwiftUI

/// The simplest way to drop the whole FeatureAuth experience into an app.
/// Presents the login screen, which itself presents sign-up as a sheet.
///
/// ```swift
/// import FeatureAuth
///
/// struct ContentView: View {
///     var body: some View {
///         AuthFlowView()
///     }
/// }
/// ```
public struct AuthFlowView: View {
    private let config: AuthConfiguration

    public init(config: AuthConfiguration = .default) {
        self.config = config
    }

    public var body: some View {
        LoginView(config: config)
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
