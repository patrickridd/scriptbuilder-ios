import Foundation

extension L10n {
    /// Copy for writer-authored beats on the act editors and hub cards.
    /// English fallbacks live here, so an untranslated key still reads well.
    /// Named `CustomBeatCopy` so it never shadows the Domain `CustomBeat` type.
    enum CustomBeatCopy {
        private static func str(_ key: String, _ fallback: String) -> String {
            L10n.string("outline.customBeat.\(key)", default: fallback)
        }

        static var titlePlaceholder: String { str("titlePlaceholder", "Name this beat") }
        static var subtitlePlaceholder: String {
            str("subtitlePlaceholder", "Add a guiding line (optional)")
        }
        static var expand: String { str("expand", "Expand beat to full screen") }
        static var disable: String { str("disable", "Disable Beat") }
        static var enable: String { str("enable", "Enable") }
        static var disabledCaption: String { str("disabledCaption", "Disabled · skipped in progress and export") }
        static func enableLabel(_ beatTitle: String) -> String {
            String(format: str("enableLabel", "Enable %@"), beatTitle)
        }
        static var untitled: String { str("untitled", "Untitled Beat") }
        static var textPlaceholder: String { str("textPlaceholder", "What happens here?") }
        static var addTitle: String { str("addTitle", "Add Beat") }
        static func addCaption(_ actTitle: String) -> String {
            String(format: str("addCaption", "Your own moment at the end of %@"), actTitle)
        }
        static var insertAfter: String { str("insertAfter", "Insert Beat After") }
        static var delete: String { str("delete", "Delete Beat") }
        static var options: String { str("options", "Beat options") }
        static var doneEditing: String { str("doneEditing", "Done editing beat") }
        static var deleteConfirmTitle: String { str("deleteConfirm.title", "Delete this beat?") }
        static var deleteConfirmMessage: String {
            str("deleteConfirm.message", "What you've written here will be removed from the outline.")
        }
        static func customCount(_ count: Int) -> String {
            count == 1
                ? str("count.one", "1 custom beat")
                : String(format: str("count.other", "%d custom beats"), count)
        }
    }
}
