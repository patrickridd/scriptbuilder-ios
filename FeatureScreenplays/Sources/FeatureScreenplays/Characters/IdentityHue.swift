//
//  IdentityHue.swift
//  FeatureScreenplays
//
//  Colour coding for identity facets. Archetypes ride the app accent; story
//  functions get their own violet hue so the two chip families are instantly
//  distinguishable. Both variants are tuned per colour scheme so text stays
//  legible on light and dark surfaces.
//

import SwiftUI

enum IdentityHue {

    /// Violet, brightened for dark mode and deepened for light mode so the
    /// chip label always clears contrast against a translucent card.
    static let storyFunction = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark
            ? UIColor(red: 0.76, green: 0.65, blue: 1.00, alpha: 1)
            : UIColor(red: 0.42, green: 0.26, blue: 0.76, alpha: 1)
    })
}
