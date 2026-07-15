//
//  PaywallPalette.swift
//  FeaturePaywall
//
//  Derives all paywall colors from the shared `DesignSystem` palette
//  (`AppPalette`) so the paywall matches FeatureAuth and FeatureScreenplays —
//  the app's signature blue → teal brand identity, light/dark-ready.
//
//  Unlike a static enum, this is an instance built from whatever `AppPalette`
//  is live in the SwiftUI environment (`\.appPalette`), so any per-screen
//  palette override the host injects is respected at runtime.
//

import SwiftUI
import DesignSystem

struct PaywallPalette {
    /// The source of truth — the palette the host injected via `\.appPalette`.
    let base: AppPalette

    init(_ base: AppPalette) {
        self.base = base
    }

    /// Brand gradient used in the header glyph and primary CTA.
    var brandGradient: LinearGradient { base.primaryButtonGradient }

    /// Accent for selected state / checkmarks.
    var accent: Color { base.accent }

    /// "Best value" badge gradient — on-brand teal → blue so it harmonizes
    /// with the rest of the brand instead of clashing.
    var badgeGradient: LinearGradient {
        LinearGradient(
            colors: [base.brandSecondary, base.brandPrimary],
            startPoint: .leading,
            endPoint: .trailing
        )
    }

    var cardFill: Color { base.cardSurface }
    var selectedCardStroke: Color { base.accent }
    var unselectedCardStroke: Color { base.cardStroke }
}
