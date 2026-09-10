import Foundation

/// Localized string lookups for FeatureScreenplays.
///
/// All strings resolve against the **package's** bundle (`.module`), so
/// translations ship with the package regardless of which app embeds it. The
/// strings live in `Resources/Localizable.xcstrings`.
///
/// Mirrors the pattern established in FeatureAuth, FeaturePaywall, and
/// FeatureProfile.
enum L10n {

    /// Look up a localized string by key from the package bundle.
    static func string(_ key: String.LocalizationValue) -> String {
        String(localized: key, bundle: .module)
    }

    /// Look up a localized string by a **runtime-built** key.
    ///
    /// Dynamic keys (e.g. `"scene.field.\(field.key).title"`) must NOT be
    /// passed through `String.LocalizationValue` string interpolation: that
    /// collapses the interpolated segment into a `%@` format specifier, so the
    /// lookup happens against `"scene.field.%@.title"` instead of the concrete
    /// `"scene.field.description.title"` — which returns the raw key. Resolving
    /// against the localized table by the exact key string avoids that trap.
    static func dynamic(_ key: String) -> String {
        Bundle.module.localizedString(forKey: key, value: key, table: nil)
    }

    /// Look up a localized string by key, falling back to the English literal
    /// baked into the call site when the catalog has no entry for that key yet.
    ///
    /// This is what makes an incremental localization pass safe: the copy is
    /// resolved through the catalog (so any language added later lights up with
    /// no code change), but an untranslated key renders correct English instead
    /// of leaking a raw `identity.row.role`-style key into the UI.
    static func string(_ key: String, default fallback: String) -> String {
        Bundle.module.localizedString(forKey: key, value: fallback, table: nil)
    }

    /// `string(_:default:)` for copy that interpolates values.
    static func format(_ key: String, default fallback: String, _ arguments: any CVarArg...) -> String {
        String(format: L10n.string(key, default: fallback), arguments: arguments)
    }

    // MARK: - Scene fields (title + guiding prompt)
    enum Scene {
        static func title(_ field: SceneField) -> String {
            L10n.dynamic("scene.field.\(field.key).title")
        }
        static func prompt(_ field: SceneField) -> String {
            L10n.dynamic("scene.field.\(field.key).prompt")
        }
    }

    // MARK: - Character arc fields (title + guiding prompt)
    enum Character {
        static func title(_ field: CharacterArcField) -> String {
            L10n.dynamic("character.field.\(field.key).title")
        }
        static func prompt(_ field: CharacterArcField) -> String {
            L10n.dynamic("character.field.\(field.key).prompt")
        }

        /// Localized display name for a stock role. `rawValue` stays the stable,
        /// persisted English identifier — this is UI-only.
        static func role(_ role: CharacterRole) -> String {
            L10n.dynamic("character.role.\(role.key)")
        }
    }

    // MARK: - Common actions
    enum Action {
        static var delete: String { L10n.string("common.action.delete") }
        static var cancel: String { L10n.string("common.action.cancel") }
        static var save: String { L10n.string("common.action.save") }
        static var ok: String { L10n.string("common.action.ok") }
        static var tryAgain: String { L10n.string("common.action.tryAgain") }
        static var close: String { L10n.string("common.action.close") }
        static var untitled: String { L10n.string("common.untitled") }
        /// Capsule marking a paid-tier affordance. Kept as-is in most locales.
        static var pro: String { L10n.string("common.pro", default: "PRO") }

        /// Spoken form of a gated affordance, e.g. "New Scene (Pro)".
        static func withPro(_ title: String) -> String {
            L10n.format("common.pro.suffixed", default: "%@ (Pro)", title)
        }
        static var somethingWentWrong: String { L10n.string("common.somethingWentWrong") }

        static func optional(_ title: String) -> String {
            String(format: L10n.string("common.optionalSuffix"), title)
        }
    }

    // MARK: - Scene editor / list
    enum SceneUI {
        static var deleteTitle: String { L10n.string("scene.delete.title") }
        static var deleteButton: String { L10n.string("scene.delete.button") }
        static var fieldTitle: String { L10n.string("scene.field.title.label") }
        static var fieldAct: String { L10n.string("scene.field.act.label") }
        static var fieldNumber: String { L10n.string("scene.field.number.label") }
        static var fieldHeading: String { L10n.string("scene.field.heading.label") }
        static var addScene: String { L10n.string("scene.list.add") }
        static var unlockMore: String { L10n.string("scene.list.unlockMore") }
        static var progressTitle: String { L10n.string("scene.progress.title") }
        static var progressComplete: String { L10n.string("scene.progress.complete") }
        static var titlePlaceholder: String { L10n.string("scene.field.title.placeholder") }
        static var headingPlaceholder: String { L10n.string("scene.field.heading.placeholder") }

        static func deleteMessage(_ subject: String) -> String {
            String(format: L10n.string("scene.delete.message"), subject)
        }
        static var deleteSubjectFallback: String { L10n.string("scene.delete.subject.fallback") }
        static var deleteSubjectFallbackCapitalized: String { L10n.string("scene.delete.subject.fallback.capitalized") }

        static var noMatchesTitle: String {
            L10n.string("scene.noMatches.title", default: "No scenes found")
        }
        static func noMatchesMessage(_ query: String) -> String {
            L10n.format("scene.noMatches.message", default: "Nothing matches “%@” yet.", query)
        }
        static func createNamed(_ query: String) -> String {
            L10n.format("scene.noMatches.create", default: "Create “%@”", query)
        }
        static var searchPlaceholder: String {
            L10n.string("scene.list.searchPlaceholder", default: "Search scenes")
        }
        static var newScene: String { L10n.string("scene.list.newScene", default: "New Scene") }
        static var untitledScene: String { L10n.string("scene.untitled", default: "Untitled Scene") }
        static var noHeadingYet: String {
            L10n.string("scene.heading.empty", default: "No heading set yet")
        }
        static func addToAct(_ act: String) -> String {
            L10n.format("scene.list.addToAct", default: "Add to %@", act)
        }
        static func addAccessibility(locked: Bool) -> String {
            locked
                ? L10n.string("scene.list.add.a11y.pro", default: "New scene (Pro)")
                : L10n.string("scene.list.add.a11y", default: "New scene")
        }
        static func addToActAccessibility(_ act: String, locked: Bool) -> String {
            locked
                ? L10n.format("scene.list.addToAct.a11y.pro", default: "Add scene to %@ (Pro)", act)
                : L10n.format("scene.list.addToAct.a11y", default: "Add scene to %@", act)
        }
        static var unlockProHint: String {
            L10n.string("scene.list.unlockPro.hint", default: "Unlock ScriptBuilder Pro to add more scenes")
        }
        static var deleteAccessibility: String {
            L10n.string("scene.delete.a11y", default: "Delete scene")
        }
    }

    // MARK: - Character identity pickers (chrome only; catalog copy is English)
    enum Identity {
        static var examplesLabel: String {
            L10n.string("identity.card.examples", default: "Examples:")
        }
        static var keyTakeaway: String {
            L10n.string("identity.intro.keyTakeaway", default: "KEY TAKEAWAY")
        }
    }

    // MARK: - Character editor / list
    enum CharacterUI {
        static var deleteTitle: String { L10n.string("character.delete.title") }
        static var deleteButton: String { L10n.string("character.delete.button") }
        static var fieldName: String { L10n.string("character.field.name.label") }
        static var fieldRole: String { L10n.string("character.field.role.label") }
        static var customRolePlaceholder: String { L10n.string("character.field.role.custom.placeholder") }
        static var arcTitle: String { L10n.string("character.arc.title") }
        static var arcComplete: String { L10n.string("character.arc.complete") }

        static func arcFieldsComplete(_ done: Int, _ total: Int) -> String {
            String(format: L10n.string("character.arc.fieldsComplete"), done, total)
        }
        static func arcAccessibility(_ done: Int, _ total: Int) -> String {
            String(format: L10n.string("character.arc.accessibility"), done, total)
        }
        static var emptyTitle: String { L10n.string("character.empty.title") }
        static var emptyMessage: String { L10n.string("character.empty.message") }
        static var noMatchesTitle: String { L10n.string("character.noMatches.title") }

        static func noMatchesMessage(_ query: String) -> String {
            String(format: L10n.string("character.noMatches.message"), query)
        }
        static func deleteMessage(_ subject: String) -> String {
            String(format: L10n.string("character.delete.message"), subject)
        }
        static var deleteSubjectFallback: String { L10n.string("character.delete.subject.fallback") }
        static var deleteSubjectFallbackCapitalized: String { L10n.string("character.delete.subject.fallback.capitalized") }

        /// Label on the dashed pill pinned above the cast list.
        static var newCharacter: String {
            L10n.string("character.list.newCharacter", default: "New Character")
        }
        static func createNamed(_ query: String) -> String {
            L10n.format("character.noMatches.create", default: "Create “%@”", query)
        }
        static var searchPlaceholder: String {
            L10n.string("character.list.searchPlaceholder", default: "Search cast")
        }
        static var castTitle: String { L10n.string("character.list.title", default: "Cast") }
        static var newCharacterCaption: String {
            L10n.string("character.list.newCharacter.caption", default: "Add someone to the cast")
        }
        static func addAccessibility(locked: Bool) -> String {
            locked
                ? L10n.string("character.list.add.a11y.pro", default: "New character (Pro)")
                : L10n.string("character.list.add.a11y", default: "New character")
        }
        static var unlockProHint: String {
            L10n.string("character.list.unlockPro.hint", default: "Unlock ScriptBuilder Pro to add more characters")
        }
    }

    // MARK: - Outline
    enum Outline {
        static var storyOutline: String { L10n.string("outline.storyOutline") }
        static var threeActStructure: String { L10n.string("outline.threeActStructure") }
        static var actBeats: String { L10n.string("outline.actBeats") }
        static var aboutActBeats: String { L10n.string("outline.aboutActBeats") }
        static var overallDescription: String { L10n.string("outline.overallDescription") }
        static var complete: String { L10n.string("outline.complete") }

        static func sectionsComplete(_ done: Int, _ total: Int) -> String {
            String(format: L10n.string("outline.sectionsComplete"), done, total)
        }

        static var sectionComplete: String { L10n.string("outline.section.complete") }

        static func overallPrompt(_ section: String) -> String {
            String(format: L10n.string("outline.overallPrompt"), section)
        }

        static func sectionTitle(_ section: OutlineSection) -> String {
            L10n.dynamic("outline.section.\(section.key).title")
        }
        static func sectionSubtitle(_ section: OutlineSection) -> String {
            L10n.dynamic("outline.section.\(section.key).subtitle")
        }
        static func sectionPlaceholder(_ section: OutlineSection) -> String {
            L10n.dynamic("outline.section.\(section.key).placeholder")
        }
    }

    // MARK: - Shared progress header
    enum Progress {
        static func fieldsComplete(_ done: Int, _ total: Int) -> String {
            String(format: L10n.string("progress.fieldsComplete"), done, total)
        }

        static func accessibility(_ title: String, _ done: Int, _ total: Int) -> String {
            String(format: L10n.string("progress.accessibility"), title, done, total)
        }

        static func nextUp(_ field: String) -> String {
            String(format: L10n.string("progress.nextUp"), field)
        }

        static var nextUpHint: String { L10n.string("progress.nextUp.hint") }
        static var celebrationSubtitle: String { L10n.string("progress.celebration.subtitle") }
        static var editTitle: String { L10n.string("progress.editTitle") }
    }

    // MARK: - Idea fields
    enum Idea {
        static func title(_ key: String) -> String {
            L10n.dynamic("idea.field.\(key).title")
        }
        static func prompt(_ key: String) -> String {
            L10n.dynamic("idea.field.\(key).prompt")
        }
    }

    // MARK: - Screenplays home / cover / edit
    enum Home {
        static var welcomeBack: String { L10n.string("home.welcomeBack") }
        static var newScript: String { L10n.string("home.newScript") }
        static var startFreshDraft: String { L10n.string("home.startFreshDraft") }
        static var continueWriting: String { L10n.string("home.continueWriting") }
        static var addScreenplay: String { L10n.string("home.addScreenplay") }
        static var newScreenplay: String { L10n.string("home.newScreenplay") }
        static var emptyMessage: String { L10n.string("home.empty.message") }
        static var loadErrorTitle: String { L10n.string("home.loadError.title") }
        static var loadingMessage: String { L10n.string("home.loadingMessage") }
        static var searchPlaceholder: String {
            L10n.string("home.searchPlaceholder", default: "Search scripts")
        }
        static var profileHint: String {
            L10n.string("home.hero.profileHint", default: "Opens your profile")
        }
        static var statScripts: String { L10n.string("home.stat.scripts", default: "Scripts") }
        static var statScenes: String { L10n.string("home.stat.scenes", default: "Scenes") }
        static var statLastEdit: String { L10n.string("home.stat.lastEdit", default: "Last edit") }

        static func greeting(_ name: String) -> String {
            String(format: L10n.string("home.greeting"), name)
        }
    }

    enum Cover {
        static var writtenBy: String { L10n.string("cover.writtenBy") }
        static var startWriting: String { L10n.string("cover.startWriting") }
        static var shareScreenplay: String { L10n.string("cover.shareScreenplay") }
        static var chooseFormat: String { L10n.string("cover.chooseFormat") }
        static var pdfDocument: String { L10n.string("cover.pdfDocument") }
        static var plainText: String { L10n.string("cover.plainText") }
        static var screenplaySettings: String { L10n.string("cover.screenplaySettings") }
        static var coverLabel: String { L10n.string("cover.coverLabel") }
        static var startWritingHint: String {
            L10n.string(
                "cover.startWriting.hint",
                default: "Opens the outline, characters, and scenes editor"
            )
        }
        static var shareHint: String {
            L10n.string(
                "cover.share.hint",
                default: "Exports the full screenplay as a PDF or plain text you can share or print"
            )
        }
    }

    enum EditSheet {
        static var titleSection: String { L10n.string("edit.section.title") }
        static var authorSection: String { L10n.string("edit.section.author") }
        static var navigationTitle: String { L10n.string("edit.navigationTitle") }
        static var deleteScreenplay: String { L10n.string("edit.deleteScreenplay") }

        static func deleteMessage(_ title: String) -> String {
            String(format: L10n.string("edit.delete.message"), title)
        }
    }
}
