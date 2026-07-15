//
//  PaywallConfiguration.swift
//  FeaturePaywall
//
//  Host-supplied content & links so the package stays app-agnostic.
//

import SwiftUI

/// Public, localized paywall copy for hosts that render pricing outside the
/// package (e.g. the app's `Store`). Backed by the package's String Catalog.
public enum PaywallStrings {
    /// Unit label appended to weekly pricing, e.g. "$1.99/week".
    public static var perWeek: String { L10n.Paywall.perWeek }
}

public struct PaywallFeature: Identifiable, Sendable {
    public let id = UUID()
    public let symbolName: String
    public let title: String

    public init(symbolName: String, title: String) {
        self.symbolName = symbolName
        self.title = title
    }
}

public struct PaywallConfiguration: Sendable {
    public let productName: String
    public let subtitle: String
    public let glyphSymbolName: String
    public let features: [PaywallFeature]
    public let termsURL: URL?
    public let privacyURL: URL?

    public init(
        productName: String,
        subtitle: String,
        glyphSymbolName: String,
        features: [PaywallFeature],
        termsURL: URL?,
        privacyURL: URL?
    ) {
        self.productName = productName
        self.subtitle = subtitle
        self.glyphSymbolName = glyphSymbolName
        self.features = features
        self.termsURL = termsURL
        self.privacyURL = privacyURL
    }

    /// Default content matching the locked spec for FeatureAuth-Dev.
    public static func scriptBuilderPro(
        termsURL: URL?,
        privacyURL: URL?
    ) -> PaywallConfiguration {
        PaywallConfiguration(
            productName: "ScriptBuilder Pro",
            subtitle: "Everything you need to plan, write, and sync your screenplays.",
            glyphSymbolName: "film.stack.fill",
            features: [
                PaywallFeature(symbolName: "infinity", title: "Unlimited Screenplays"),
                PaywallFeature(symbolName: "person.2.fill", title: "Character Builder"),
                PaywallFeature(symbolName: "film.fill", title: "Scene Builder"),
                PaywallFeature(symbolName: "arrow.triangle.2.circlepath.icloud.fill", title: "Sync across devices")
            ],
            termsURL: termsURL,
            privacyURL: privacyURL
        )
    }
}
