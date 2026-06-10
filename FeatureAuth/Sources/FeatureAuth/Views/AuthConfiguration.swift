import Foundation

/// Branding/copy used by the FeatureAuth screens. Pass a customized
/// instance to `AuthFlowView`, `LoginView`, or `SignUpView` to white-label
/// the experience without touching the kit's source.
public struct AuthConfiguration {
    public var appName: String
    public var loginSubtitle: String
    public var signUpSubtitle: String
    public var loginFooterPrompt: String
    public var signUpFooterPrompt: String

    public init(
        appName: String = "Your App Name",
        loginSubtitle: String = "Your personal app subtitle here",
        signUpSubtitle: String = "Create your account to start",
        loginFooterPrompt: String = "New to [your app name]?",
        signUpFooterPrompt: String = "Already have an account?"
    ) {
        self.appName = appName
        self.loginSubtitle = loginSubtitle
        self.signUpSubtitle = signUpSubtitle
        self.loginFooterPrompt = loginFooterPrompt
        self.signUpFooterPrompt = signUpFooterPrompt
    }

    public static let `default` = AuthConfiguration()
}
