import Foundation

/// Localized string lookups for FeatureAuth.
///
/// All strings resolve against the **package's** bundle (`.module`), not the
/// host app's, so translations ship with the package and work regardless of
/// which app embeds it. The strings live in `Resources/Localizable.xcstrings`.
enum L10n {

    /// Look up a localized string by key from the package bundle.
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    // MARK: - Fallback configuration copy
    enum Config {
        static var appName: String { L10n.string("auth.config.default.appName") }
        static var loginSubtitle: String { L10n.string("auth.config.default.loginSubtitle") }
        static var signUpSubtitle: String { L10n.string("auth.config.default.signUpSubtitle") }
        static var loginFooterPrompt: String { L10n.string("auth.config.default.loginFooterPrompt") }
        static var signUpFooterPrompt: String { L10n.string("auth.config.default.signUpFooterPrompt") }
    }

    // MARK: - Fields
    enum Field {
        static var emailTitle: String { L10n.string("auth.field.email.title") }
        static var emailPlaceholder: String { L10n.string("auth.field.email.placeholder") }
        static var passwordTitle: String { L10n.string("auth.field.password.title") }
        static var passwordPlaceholder: String { L10n.string("auth.field.password.placeholder") }
        static var passwordPlaceholderMin: String { L10n.string("auth.field.password.placeholder.min") }
        static var firstNameTitle: String { L10n.string("auth.field.firstName.title") }
        static var firstNamePlaceholder: String { L10n.string("auth.field.firstName.placeholder") }
        static var lastNameTitle: String { L10n.string("auth.field.lastName.title") }
        static var lastNamePlaceholder: String { L10n.string("auth.field.lastName.placeholder") }
    }

    // MARK: - Buttons & links
    enum Action {
        static var login: String { L10n.string("auth.button.login") }
        static var createAccount: String { L10n.string("auth.button.createAccount") }
        static var forgotPassword: String { L10n.string("auth.link.forgotPassword") }
        static var signUp: String { L10n.string("auth.link.signUp") }
        static var logIn: String { L10n.string("auth.link.logIn") }
    }

    // MARK: - Dividers
    enum Divider {
        static var continueWith: String { L10n.string("auth.divider.continueWith") }
        static var signUpWith: String { L10n.string("auth.divider.signUpWith") }
    }

    // MARK: - Accessibility
    enum A11y {
        static var signInApple: String { L10n.string("auth.a11y.signInApple") }
        static var signInGoogle: String { L10n.string("auth.a11y.signInGoogle") }
        static var continueFacebook: String { L10n.string("auth.a11y.continueFacebook") }
        static var signUpApple: String { L10n.string("auth.a11y.signUpApple") }
        static var signUpGoogle: String { L10n.string("auth.a11y.signUpGoogle") }
        static var signUpFacebook: String { L10n.string("auth.a11y.signUpFacebook") }
        static var closeSignUp: String { L10n.string("auth.a11y.closeSignUp") }
    }

    // MARK: - Loading status
    enum Status {
        static var signingIn: String { L10n.string("auth.status.signingIn") }
        static var signingUp: String { L10n.string("auth.status.signingUp") }
    }

    // MARK: - Alerts & messages
    enum Alert {
        static var title: String { L10n.string("auth.alert.title") }
        static var ok: String { L10n.string("auth.alert.ok") }
    }

    enum Message {
        static var loginInvalid: String { L10n.string("auth.error.login.invalid") }
        static var signUpInvalid: String { L10n.string("auth.error.signUp.invalid") }
        static var resetNeedEmail: String { L10n.string("auth.error.reset.needEmail") }

        /// Confirmation after a reset email is sent, interpolating the address.
        static func resetSent(_ email: String) -> String {
            String(localized: "auth.reset.sent", bundle: .module).replacingOccurrences(of: "%@", with: email)
        }
    }
}
