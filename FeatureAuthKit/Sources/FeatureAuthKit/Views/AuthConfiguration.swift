import Foundation

/// Branding/copy used by the FeatureAuthKit screens. Pass a customized
/// instance to `AuthFlowView`, `LoginView`, or `SignUpView` to white-label
/// the experience without touching the kit's source.
public struct AuthConfiguration {
    public var appName: String
    public var loginSubtitle: String
    public var signUpSubtitle: String
    public var loginFooterPrompt: String

    public init(
        appName: String = "Script Builder",
        loginSubtitle: String = "From your screen to the silver screen",
        signUpSubtitle: String = "Create your account to start writing",
        loginFooterPrompt: String = "New to Script Builder?"
    ) {
        self.appName = appName
        self.loginSubtitle = loginSubtitle
        self.signUpSubtitle = signUpSubtitle
        self.loginFooterPrompt = loginFooterPrompt
    }

    public static let `default` = AuthConfiguration()
}
