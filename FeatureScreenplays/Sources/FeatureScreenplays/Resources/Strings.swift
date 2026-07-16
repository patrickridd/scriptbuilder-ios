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

        static func deleteMessage(_ subject: String) -> String {
            String(format: L10n.string("scene.delete.message"), subject)
        }
        static var deleteSubjectFallback: String { L10n.string("scene.delete.subject.fallback") }
        static var deleteSubjectFallbackCapitalized: String { L10n.string("scene.delete.subject.fallback.capitalized") }
    }

    // MARK: - Character editor / list
    enum CharacterUI {
        static var deleteTitle: String { L10n.string("character.delete.title") }
        static var deleteButton: String { L10n.string("character.delete.button") }
        static var fieldName: String { L10n.string("character.field.name.label") }
        static var fieldRole: String { L10n.string("character.field.role.label") }
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
