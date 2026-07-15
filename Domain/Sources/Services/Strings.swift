//
//  Strings.swift
//  Domain
//
//  Localized string lookups for the Domain module's user-facing model text
//  (act labels and narrative beat titles/subtitles).
//
//  All strings resolve against the **package's** bundle (`.module`), so
//  translations ship with the package regardless of which app embeds it. The
//  strings live in `Resources/Localizable.xcstrings`.
//
//  Mirrors the pattern established in FeatureScreenplays, FeatureAuth,
//  FeaturePaywall, and FeatureProfile.
//

import Foundation

enum L10n {

    /// Look up a localized string by a compile-time literal key.
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    /// Look up a localized string by a **runtime-built** key.
    ///
    /// Dynamic keys (e.g. `"beat.\(rawValue).title"`) must NOT be passed
    /// through `String.LocalizationValue` interpolation: that collapses the
    /// interpolated segment into a `%@` format specifier, so the lookup happens
    /// against `"beat.%@.title"` instead of the concrete key. Resolving against
    /// the localized table by the exact key string avoids that trap.
    static func dynamic(_ key: String) -> String {
        Bundle.module.localizedString(forKey: key, value: key, table: nil)
    }
}
