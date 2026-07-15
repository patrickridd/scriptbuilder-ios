import Foundation

/// Localized string lookups for FeatureProfile.
///
/// All strings resolve against the **package's** bundle (`.module`), not the
/// host app's, so translations ship with the package and work regardless of
/// which app embeds it. The strings live in `Resources/Localizable.xcstrings`.
///
/// Mirrors the pattern established in FeatureAuth and FeaturePaywall.
enum L10n {

    /// Look up a localized string by key from the package bundle.
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    // MARK: - Card titles
    enum Card {
        static var yourName: String { L10n.string("profile.card.yourName") }
        static var changePassword: String { L10n.string("profile.card.changePassword") }
        static var appearance: String { L10n.string("profile.card.appearance") }
        static var haptics: String { L10n.string("profile.card.haptics") }
        static var aboutLegal: String { L10n.string("profile.card.aboutLegal") }
        static var email: String { L10n.string("profile.card.email") }
    }

    // MARK: - Rows
    enum Row {
        static var accountDetails: String { L10n.string("profile.row.accountDetails") }
        static var accountDetailsSubtitleFull: String { L10n.string("profile.row.accountDetails.subtitle.full") }
        static var accountDetailsSubtitleNamePassword: String { L10n.string("profile.row.accountDetails.subtitle.namePassword") }
    }

    // MARK: - Fields
    enum Field {
        static var newPassword: String { L10n.string("profile.field.newPassword") }
        static var confirmPassword: String { L10n.string("profile.field.confirmPassword") }
        static var firstName: String { L10n.string("profile.field.firstName") }
        static var lastName: String { L10n.string("profile.field.lastName") }
        static var theme: String { L10n.string("profile.field.theme") }
    }

    // MARK: - Buttons & links
    enum Action {
        static var updatePassword: String { L10n.string("profile.action.updatePassword") }
        static var saveName: String { L10n.string("profile.action.saveName") }
        static var signOut: String { L10n.string("profile.action.signOut") }
        static var deleteAccount: String { L10n.string("profile.action.deleteAccount") }
        static var delete: String { L10n.string("profile.action.delete") }
        static var cancel: String { L10n.string("profile.action.cancel") }
        static var ok: String { L10n.string("profile.action.ok") }
        static var verifyEmail: String { L10n.string("profile.action.verifyEmail") }
    }

    enum Link {
        static var shareApp: String { L10n.string("profile.link.shareApp") }
        static var privacy: String { L10n.string("profile.link.privacy") }
        static var terms: String { L10n.string("profile.link.terms") }
    }

    // MARK: - Appearance options
    enum Style {
        static var system: String { L10n.string("profile.style.system") }
        static var light: String { L10n.string("profile.style.light") }
        static var dark: String { L10n.string("profile.style.dark") }
    }

    // MARK: - Header
    enum Header {
        /// Provider badge, interpolating the provider name (e.g. "Apple").
        static func provider(_ name: String) -> String {
            String(format: L10n.string("profile.header.provider"), name)
        }

        /// Pluralized screenplay-count stat pill.
        static func screenplayCount(_ count: Int) -> String {
            String(format: L10n.string("profile.header.screenplayCount"), count)
        }
    }

    // MARK: - Danger zone
    enum Danger {
        static var signOutTitle: String { L10n.string("profile.danger.signOut.title") }
        static var signOutMessage: String { L10n.string("profile.danger.signOut.message") }
        static var deleteTitle: String { L10n.string("profile.danger.delete.title") }
        static var deleteMessage: String { L10n.string("profile.danger.delete.message") }
    }

    // MARK: - Alerts
    enum Alert {
        static var error: String { L10n.string("profile.alert.error") }
        static var done: String { L10n.string("profile.alert.done") }
    }

    // MARK: - Validation & messages
    enum Validation {
        static var passwordShort: String { L10n.string("profile.validation.passwordShort") }
        static var passwordsMismatch: String { L10n.string("profile.validation.passwordsMismatch") }
    }

    enum Message {
        static var enterFirstName: String { L10n.string("profile.message.enterFirstName") }
        static var nameUpdated: String { L10n.string("profile.message.nameUpdated") }
        static var passwordUpdated: String { L10n.string("profile.message.passwordUpdated") }
        static var verificationSent: String { L10n.string("profile.message.verificationSent") }
        static var generic: String { L10n.string("profile.message.generic") }

        /// Validation error for over-length names, interpolating the max length.
        static func nameTooLong(_ max: Int) -> String {
            String(format: L10n.string("profile.message.nameTooLong"), max)
        }
    }

    // MARK: - Accessibility
    enum A11y {
        /// App-version footer label, interpolating the version string.
        static func appVersion(_ version: String) -> String {
            String(format: L10n.string("profile.a11y.appVersion"), version)
        }
    }
}
