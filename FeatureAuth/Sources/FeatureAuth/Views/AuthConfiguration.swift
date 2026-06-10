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
        appName: String? = nil,
        loginSubtitle: String? = nil,
        signUpSubtitle: String? = nil,
        loginFooterPrompt: String? = nil,
        signUpFooterPrompt: String? = nil
    ) {
        self.appName = appName ?? L10n.Config.appName
        self.loginSubtitle = loginSubtitle ?? L10n.Config.loginSubtitle
        self.signUpSubtitle = signUpSubtitle ?? L10n.Config.signUpSubtitle
        self.loginFooterPrompt = loginFooterPrompt ?? L10n.Config.loginFooterPrompt
        self.signUpFooterPrompt = signUpFooterPrompt ?? L10n.Config.signUpFooterPrompt
    }

    public static let `default` = AuthConfiguration()
}
