import Foundation

extension L10n {
    /// Copy for rearranging beats (Arrange screen + beat "Move" menu items).
    /// English fallbacks live here, so an untranslated key still reads well.
    enum ArrangeCopy {
        private static func str(_ key: String, _ fallback: String) -> String {
            L10n.string("outline.arrange.\(key)", default: fallback)
        }

        static var title: String { str("title", "Arrange Beats") }
        static var openButton: String { str("open", "Arrange Beats") }
        static var openCaption: String { str("openCaption", "Reorder beats or move them between acts") }
        static var customOrderBadge: String { str("customOrder", "Custom order") }
        static var done: String { str("done", "Done") }
        static var intro: String {
            str("intro", "Drag beats to reorder them or move them into another act. Your writing travels with each beat.")
        }
        static var proIntro: String {
            str("proIntro", "Your own beats move freely. Moving the structure's beats is a Pro feature.")
        }
        static var dropHere: String { str("dropHere", "Drop a beat here") }
        static var dropHereCaption: String { str("dropHereCaption", "This act is empty for now") }
        static func usuallyIn(_ sectionTitle: String) -> String {
            String(format: str("usuallyIn", "Usually in %@"), sectionTitle)
        }
        static var disabledTag: String { str("disabledTag", "Disabled") }
        static var lockedHint: String { str("lockedHint", "Unlock Pro to move this beat") }
        static var reset: String { str("reset", "Reset to Standard Order") }
        static var resetConfirmTitle: String { str("resetConfirm.title", "Reset beat order?") }
        static var resetConfirmMessage: String {
            str("resetConfirm.message", "Every beat goes back to its usual act and position. Nothing you've written is lost.")
        }
        static var resetConfirmButton: String { str("resetConfirm.button", "Reset") }
        static var moveUp: String { str("moveUp", "Move Up") }
        static var moveDown: String { str("moveDown", "Move Down") }
        static func moveTo(_ sectionTitle: String) -> String {
            String(format: str("moveTo", "Move to %@"), sectionTitle)
        }
        static var noBeatsYet: String { str("noBeatsYet", "No beats yet") }
        static var noBeatsCaption: String {
            str("noBeatsCaption", "Add your own beat below, or move one here from another act.")
        }
    }
}
