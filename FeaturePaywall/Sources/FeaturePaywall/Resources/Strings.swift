import Foundation

/// Localized string lookups for FeaturePaywall.
///
/// All strings resolve against the **package's** bundle (`.module`), not the
/// host app's, so translations ship with the package and work regardless of
/// which app embeds it. The strings live in `Resources/Localizable.xcstrings`.
enum L10n {

    /// Look up a localized string by key from the package bundle.
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    // MARK: - Paywall
    enum Paywall {
        /// Unit label appended to weekly pricing, e.g. "$1.99/week".
        static var perWeek: String { L10n.string("paywall.price.perWeek") }
    }
}
