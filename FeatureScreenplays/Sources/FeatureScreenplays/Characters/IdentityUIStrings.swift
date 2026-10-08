import Foundation

/// UI chrome for the identity pickers and character detail.
///
/// Every string resolves through the package catalog with its English wording
/// baked in as the fallback (see `L10n.string(_:default:)`), so an untranslated
/// locale renders correct English rather than a raw key. The *catalog content*
/// itself (role / archetype / story-function names, definitions and examples)
/// stays English in `IdentityCatalog` — those are craft terms of art.
enum IdentityUIStrings {
    private static func str(_ key: String, _ fallback: String) -> String {
        L10n.string("identity.ui.\(key)", default: fallback)
    }

    private static func fmt(_ key: String, _ fallback: String, _ args: any CVarArg...) -> String {
        String(format: str(key, fallback), arguments: args)
    }

    // MARK: - Sections

    static var sectionTitle: String { str("section.identity", "Identity") }
    /// Second grouping on character detail: what the character *does* in the
    /// story (story function) and how they change (arc).
    static var behaviorSectionTitle: String { str("section.behavior", "Behavior") }

    // MARK: - Arc card

    static var arcCardSubtitle: String { str("arc.subtitle", "Where they start, break and land") }
    static var arcNotApplicableTitle: String { str("arc.none.title", "This character has no arc") }
    static var arcNotApplicableSubtitle: String {
        str(
            "arc.none.subtitle",
            "Objects, forces and figures who never want anything — mark it and the arc counts as done."
        )
    }
    static var arcNotApplicableComplete: String { str("arc.none.complete", "No Arc needed") }
    static var arcNotApplicableNote: String {
        str("arc.none.note", "Arc questions are hidden. Notes stay available if you want a line about why.")
    }

    // MARK: - Character settings

    static var settingsTitle: String { str("settings.title", "Character Settings") }
    static var settingsAction: String { str("settings.action", "Character Settings") }
    static var settingsArcSection: String { str("settings.section.arc", "Dramatic Arc") }
    static var settingsNameSection: String { str("settings.section.name", "Name") }
    static var settingsNameFooter: String {
        str("settings.name.footer", "How this character appears across the cast list, scenes and exports.")
    }
    static var settingsDangerSection: String { str("settings.section.danger", "Danger Zone") }
    static var settingsDeleteAction: String { str("settings.delete.action", "Delete Character") }
    static var settingsDeleteFooter: String {
        str(
            "settings.delete.footer",
            "Removes this character and everything written about them. This cannot be undone."
        )
    }
    static var settingsFooter: String {
        str(
            "settings.footer",
            "Nothing you have written is deleted — hidden fields come straight back if you switch this off."
        )
    }
    /// Confirmation button that dismisses the Character Settings sheet.
    static var settingsSave: String { str("settings.save", "Save") }

    // MARK: - Identity rows

    static var roleRow: String { str("row.role", "Role") }
    static var archetypeRow: String { str("row.archetype", "Archetype") }
    static var storyFunctionRow: String { str("row.storyFunction", "Story Function") }
    static var noneValue: String { str("row.none", "None") }
    /// Empty-state prompts on the identity rows. A question invites a tap far
    /// better than a flat "None", and each one frames what that step decides.
    static var rolePrompt: String { str("row.role.prompt", "Where do they stand?") }
    static var archetypePrompt: String { str("row.archetype.prompt", "Who are they?") }
    static var storyFunctionPrompt: String { str("row.storyFunction.prompt", "What do they do?") }
    static var characterComplete: String { str("complete", "Fully developed — identity and arc") }
    static var intentionPrefix: String { str("intention.prefix", "Wants to:") }

    // MARK: - Name

    static var namePlaceholderTitle: String { str("name.placeholder", "Name your character") }
    static var nameFieldLabel: String { str("name.label", "Character name") }
    /// Short prompt used inside the header field, where width is precious.
    static var nameFieldPrompt: String { str("name.prompt", "Character name") }
    static var nameFieldDone: String { str("name.done", "Done") }
    /// Menu action that drops the caret into the header name field.
    static var changeNameAction: String { str("name.change", "Change Name") }
    static var moreActions: String { str("moreActions", "More actions") }
    static var chipHint: String { str("chip.hint", "Opens this choice in the picker") }

    /// Spoken form of the noun tag under an action headline, e.g. "Known as
    /// Catalyst".
    static func knownAs(_ term: String) -> String {
        fmt("knownAs", "Known as %@", term)
    }

    /// Spoken form of the scholarly caption, e.g. "Also called Deuteragonist".
    static func classicalTerm(_ term: String) -> String {
        fmt("classicalTerm", "Also called %@", term)
    }

    /// Trailing summary for a multi-select row, e.g. "2 selected".
    static func selectedCount(_ count: Int) -> String {
        fmt("selectedCount", "%d selected", count)
    }

    // MARK: - Picker chrome

    static var clearRole: String { str("role.clear", "No Role") }
    static var tierMain: String { str("tier.main", "Main") }
    static var tierMainDescription: String { str("tier.main.description", "Carries the story") }
    static var tierSupporting: String { str("tier.supporting", "Supporting") }
    static var tierSupportingDescription: String { str("tier.supporting.description", "Shapes it from the edges") }
    static var customSection: String { str("custom.section", "Custom") }
    static var customSectionDescription: String { str("custom.description", "Anything the list is missing") }
    static var savedRoleSection: String { str("role.saved.section", "Your Saved Role") }
    static var savedRoleHint: String {
        str("role.saved.hint", "Roles now come from the list above. Pick one to replace this.")
    }
    static var customTraitPlaceholder: String { str("custom.placeholder", "Add your own…") }
    static var addCustom: String { str("custom.add", "Add") }
    static var archetypeNudge: String {
        str("archetype.nudge", "Most memorable characters embody 1–3 archetypes.")
    }
    static var storyFunctionNudge: String {
        str("storyFunction.nudge", "A focused set of 1–3 story functions reads strongest.")
    }

    /// Title above the role-relevant choices. The sources it was drawn from
    /// are named in the description line beneath it.
    static var suggestedSection: String { str("suggested.section", "Suggested") }

    /// Description naming every source a suggestion set came from, e.g.
    /// "Commonly paired with **Second Lead** · **Mentor**", with each source bolded via
    /// Markdown. Nil when nothing drives the order.
    static func suggestedDescription(sources: [String]) -> String? {
        guard !sources.isEmpty else { return nil }
        let emphasized = sources.map { "**\($0)**" }.joined(separator: " · ")
        return fmt("suggested.description", "Commonly paired with %@", emphasized)
    }

    /// Disclosure label revealing the full catalog, e.g. "All Archetypes".
    static func allChoices(_ title: String) -> String {
        fmt("allChoices", "All %@s", title)
    }

    /// Badge on the disclosure showing how many choices remain hidden, e.g. "+9".
    static func moreCount(_ count: Int) -> String {
        fmt("moreCount", "+%d", count)
    }

    /// Spoken version of the disclosure label, e.g. "All Archetypes, 9 more".
    static func allChoicesAccessibility(_ title: String, count: Int) -> String {
        fmt("allChoices.accessibility", "%1$@, %2$d more", allChoices(title), count)
    }

    // MARK: - Craft sequence (soft gates)
    //
    // Role → Archetype → Story Function is the order the craft teaches, so the
    // rows are numbered and the later ones read as "not ready yet". Nothing is
    // ever locked: every row stays tappable and no saved choice is discarded.

    /// Spoken form of a row's step number, e.g. "Step 2 of 3".
    static func stepLabel(_ step: Int, of total: Int = 3) -> String {
        fmt("step", "Step %1$d of %2$d", step, total)
    }

    /// Sub-line on the Archetype row while no role is chosen.
    static var archetypeGateHint: String {
        str("archetype.gate.hint", "Pick a role first for tailored suggestions")
    }
    /// Sub-line on the Story Function row while no archetype is chosen.
    static var storyFunctionGateHint: String {
        str("storyFunction.gate.hint", "Pick an archetype for sharper suggestions")
    }

    /// Banner at the top of the Archetype picker when no role is set.
    static var archetypeGateBanner: String {
        str("archetype.gate.banner", "Set a role and we'll suggest the archetypes that fit.")
    }
    /// Banner at the top of the Story Function picker when no archetype is set.
    static var storyFunctionGateBanner: String {
        str("storyFunction.gate.banner", "Set an archetype and we'll suggest the jobs it usually does.")
    }
    /// Tappable tail of a gate banner — pops back to the Identity rows.
    static var gateBannerAction: String { str("gate.banner.action", "Back to Identity") }

    // MARK: - Hidden-choice notices
    //
    // All three share one sentence shape so the two pickers read as one voice.
    // Singular and plural are separate keys rather than an inline ternary, so a
    // translator can reshape each form for their language.

    /// Explains an archetype family the current role cannot wear, e.g.
    /// "5 Protagonist-only archetypes. Change the role to see them".
    static func roleExclusiveNotice(count: Int, roleName: String) -> String {
        count == 1
            ? fmt(
                "notice.roleExclusive.one",
                "1 %@-only archetype. Change the role to see it",
                roleName
            )
            : fmt(
                "notice.roleExclusive.other",
                "%1$d %2$@-only archetypes. Change the role to see them",
                count,
                roleName
            )
    }

    /// Explains story functions withheld because they don't fit the current role,
    /// e.g. "6 jobs restricted for Protagonist. Change the role to see them".
    /// Deliberately neutral: the hidden set can be opposition jobs (for a lead)
    /// or lead-driver jobs (for a supporting role), so the copy must fit both.
    static func blockedFunctionNotice(count: Int, roleName: String) -> String {
        count == 1
            ? fmt(
                "notice.blocked.one",
                "1 job restricted for %@. Change the role to see it",
                roleName
            )
            : fmt(
                "notice.blocked.other",
                "%1$d jobs restricted for %2$@. Change the role to see them",
                count,
                roleName
            )
    }

    /// Used when every hidden job belongs to one specific role, e.g.
    /// "3 Protagonist-only jobs. Change the role to see them".
    static func roleOnlyFunctionNotice(count: Int, roleName: String) -> String {
        count == 1
            ? fmt(
                "notice.roleOnly.one",
                "1 %@-only job. Change the role to see it",
                roleName
            )
            : fmt(
                "notice.roleOnly.other",
                "%1$d %2$@-only jobs. Change the role to see them",
                count,
                roleName
            )
    }
}
