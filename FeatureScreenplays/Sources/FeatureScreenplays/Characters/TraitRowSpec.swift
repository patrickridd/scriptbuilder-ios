import SwiftUI

/// Everything a multi-select identity row needs in order to draw itself *and*
/// to push its `TraitPickerDetailView`. Bundling it means the row, each of its
/// selected chips, and the header's "Next up" nudge all open the exact same
/// destination instead of re-assembling the arguments three times.
struct TraitRowSpec {
    /// Position in the identity sequence (1 Role · 2 Archetype · 3 Story Function).
    let step: Int
    let title: String
    /// Question shown on the right of the row while nothing is chosen.
    let prompt: String
    let intro: IdentitySectionIntro
    let catalog: [IdentityCatalogEntry]
    let nudge: String
    let suggestedSlugs: [String]
    var suggestionSources: [IdentityRelevance.SuggestionSource]? = nil
    /// Soft-gate hint shown while the previous step is still empty.
    var gateHint: String? = nil
    var gateBanner: String? = nil
    var roleExclusiveFamilies: [IdentityRelevance.RoleExclusiveFamily] = []
    var blockedNotice: String? = nil
    let tint: Color
    let glyph: String
}
