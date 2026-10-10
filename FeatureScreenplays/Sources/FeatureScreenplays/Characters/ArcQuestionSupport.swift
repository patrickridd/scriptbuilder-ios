import Foundation
import Domain

// MARK: - Copy

extension L10n {
    /// Copy for the character arc's questions (custom, disabled, arranged).
    /// English fallbacks live here, so an untranslated key still reads well.
    /// The UI word is always "Question", never "beat".
    enum ArcQuestionCopy {
        private static func str(_ key: String, _ fallback: String) -> String {
            L10n.string("character.arcQuestion.\(key)", default: fallback)
        }

        static var insertAfter: String { str("insertAfter", "Insert Question After") }
        static var disable: String { str("disable", "Disable Question") }
        static var disabledCaption: String { str("disabledCaption", "Switched off · your answer is kept") }
        static var moveUp: String { str("moveUp", "Move Up") }
        static var moveDown: String { str("moveDown", "Move Down") }
        static var delete: String { str("delete", "Delete Question") }
        static var deleteTitle: String { str("deleteTitle", "Delete this question?") }
        static var deleteMessage: String { str("deleteMessage", "The question and your answer will be removed.") }
        static var deleteConfirm: String { str("deleteConfirm", "Delete") }
        static var cancel: String { str("cancel", "Cancel") }
        static var titlePlaceholder: String { str("titlePlaceholder", "Your question") }
        static var subtitlePlaceholder: String { str("subtitlePlaceholder", "Add a hint (optional)") }
        static var textPlaceholder: String { str("textPlaceholder", "Start writing…") }
        static var untitled: String { str("untitled", "Untitled Question") }
        static var addQuestion: String { str("addQuestion", "Add Question") }
        static var addCaption: String { str("addCaption", "Ask your own question about this character") }
        static var options: String { str("options", "Question options") }
        static var arrange: String { str("arrange", "Arrange Questions") }
        static var arrangeHint: String { str("arrangeHint", "Drag to reorder. Notes always stays at the bottom.") }
        static var lockedHint: String { str("lockedHint", "Moving built-in questions is a Pro feature. Your own questions move freely.") }
        static var reset: String { str("reset", "Reset Order") }
        static var resetTitle: String { str("resetTitle", "Reset to the standard order?") }
        static var resetMessage: String { str("resetMessage", "Your own questions go back to where you added them. Nothing is deleted.") }
        static var done: String { str("done", "Done") }
        static var standardOrder: String { str("standardOrder", "Standard order") }
        static var customOrder: String { str("customOrder", "Custom order") }
        static var yourQuestion: String { str("yourQuestion", "Your question") }
    }
}

// MARK: - Gate

extension EditorGate {
    /// Custom arc questions follow the custom-beat rule: one free per
    /// character, then Pro. Existing questions are never locked.
    func canAddArcQuestion(existingCount: Int) -> Bool {
        canAddCustomBeat(existingCount)
    }

    /// Moving the built-in questions follows the template-beat rule (Pro).
    /// Custom questions always move, and Reset is always free.
    var canMoveStockArcQuestions: Bool { canMoveTemplateBeats() }
}

// MARK: - Bindings

extension Character {
    /// Key-path friendly access to a stock answer, so views can bind with
    /// `$viewModel.draft[arcAnswer: question]` (a real, tracked binding).
    subscript(arcAnswer question: ArcTemplateQuestion) -> String {
        get { text(for: question) }
        set { setText(newValue, for: question) }
    }

    /// Key-path friendly access to a custom question by id. Writes to an id
    /// that no longer exists are dropped, so a late keystroke can't
    /// resurrect a deleted question.
    subscript(arcQuestionID id: String) -> ArcQuestion {
        get { arcQuestion(withID: id) ?? ArcQuestion(id: id) }
        set {
            guard arcQuestion(withID: id) != nil else { return }
            upsert(arcQuestion: newValue)
        }
    }
}

// MARK: - Presentation

extension CharacterArcField {
    init(_ question: ArcTemplateQuestion) {
        switch question {
        case .intention: self = .intention
        case .whyIntention: self = .whyIntention
        case .whatToDo: self = .whatToDo
        case .howDoesCharacterDoIt: self = .howDoesCharacterDoIt
        case .obstacles: self = .obstacles
        case .flaws: self = .flaws
        case .intentionFix: self = .intentionFix
        case .need: self = .need
        case .howCharacterChanged: self = .howCharacterChanged
        }
    }
}

extension ArcSlot {
    /// Title shown in nudges and the Arrange sheet.
    var displayTitle: String {
        switch self {
        case .template(let question):
            return CharacterArcField(question).title
        case .custom(let question):
            let trimmed = question.title.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? L10n.ArcQuestionCopy.untitled : trimmed
        }
    }

    var systemImage: String {
        switch self {
        case .template(let question): return CharacterArcField(question).systemImage
        case .custom: return "sparkle"
        }
    }

    var isStock: Bool {
        if case .template = self { return true }
        return false
    }
}

/// Wording for the editable custom card, so the same card serves outline
/// beats and arc questions without either borrowing the other's copy.
struct CustomFieldCopy {
    var titlePlaceholder: String
    var subtitlePlaceholder: String
    var textPlaceholder: String
    var untitled: String
    var insertAfter: String
    var delete: String
    var options: String

    static var beat: CustomFieldCopy {
        CustomFieldCopy(
            titlePlaceholder: L10n.CustomBeatCopy.titlePlaceholder,
            subtitlePlaceholder: L10n.CustomBeatCopy.subtitlePlaceholder,
            textPlaceholder: L10n.CustomBeatCopy.textPlaceholder,
            untitled: L10n.CustomBeatCopy.untitled,
            insertAfter: L10n.CustomBeatCopy.insertAfter,
            delete: L10n.CustomBeatCopy.delete,
            options: L10n.CustomBeatCopy.options
        )
    }

    static var arcQuestion: CustomFieldCopy {
        CustomFieldCopy(
            titlePlaceholder: L10n.ArcQuestionCopy.titlePlaceholder,
            subtitlePlaceholder: L10n.ArcQuestionCopy.subtitlePlaceholder,
            textPlaceholder: L10n.ArcQuestionCopy.textPlaceholder,
            untitled: L10n.ArcQuestionCopy.untitled,
            insertAfter: L10n.ArcQuestionCopy.insertAfter,
            delete: L10n.ArcQuestionCopy.delete,
            options: L10n.ArcQuestionCopy.options
        )
    }
}
