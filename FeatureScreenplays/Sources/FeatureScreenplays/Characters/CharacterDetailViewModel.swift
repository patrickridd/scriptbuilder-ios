import Foundation
import Observation
import Domain

/// Owns all editing logic for a single character screen: the working `draft`,
/// the role bucket + free-form custom role, debounced autosave, and the final
/// flush on exit. Extracted out of `CharacterDetailView` so the view stays
/// declarative and the "when do we persist" ownership lives in one place.
@MainActor
@Observable
final class CharacterDetailViewModel {

    /// The live working copy the form binds to. Mutating any field schedules a
    /// debounced save automatically via `didSet`.
    var draft: Character { didSet { scheduleSave() } }

    /// The selected role bucket. Changing it (or `customRole`) reschedules a save.
    var role: CharacterRole { didSet { scheduleSave() } }

    /// Free-form role text, only meaningful when `role == .custom`.
    var customRole: String { didSet { scheduleSave() } }

    @ObservationIgnored private let viewModel: CharactersViewModel
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private let debounce: Duration
    /// Set once the user taps Delete so the exit `flush()` doesn't re-persist
    /// (and thereby resurrect) the character that's on its way out.
    @ObservationIgnored private var isDeleting = false

    init(
        character: Character,
        viewModel: CharactersViewModel,
        debounce: Duration = .milliseconds(500)
    ) {
        self.viewModel = viewModel
        self.debounce = debounce
        self.draft = character
        let bucket = CharacterRole.bucket(for: character.role)
        self.role = bucket
        self.customRole = bucket == .custom ? (character.role ?? "") : ""
    }

    /// Title shown in the navigation bar.
    var navigationTitle: String {
        draft.name.isEmpty ? "Character" : draft.name
    }

    /// Whether the name field should grab focus when the detail view appears.
    /// True for a brand-new (still unnamed) character so the user can start
    /// typing immediately; false when editing an existing, named character.
    var shouldFocusName: Bool {
        draft.name.isEmpty
    }

    /// The character to write out, with the role string resolved from the
    /// picker + custom field.
    private var resolvedCharacter: Character {
        var toSave = draft
        switch role {
        case .custom:
            let trimmed = customRole.trimmingCharacters(in: .whitespacesAndNewlines)
            toSave.role = trimmed.isEmpty ? nil : trimmed
        default:
            toSave.role = role.rawValue
        }
        return toSave
    }

    /// Debounced autosave so inline edits persist as you type, not only on exit.
    private func scheduleSave() {
        saveTask?.cancel()
        let character = resolvedCharacter
        saveTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.viewModel.update(character)
        }
    }

    /// Cancel any pending debounce and flush the latest state immediately.
    /// Called when the screen is leaving so nothing is lost. On exit we also
    /// bubble the finished character (and its role section) to the top, so
    /// reordering happens once at the end rather than on every keystroke.
    func flush() async {
        guard !isDeleting else { return }
        saveTask?.cancel()
        saveTask = nil
        let character = resolvedCharacter
        await viewModel.update(character)
        viewModel.moveToTop(character)
    }

    /// Confirmation-alert copy shown before deleting this character.
    var deleteConfirmMessage: String {
        let name = draft.name.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = name.isEmpty ? L10n.CharacterUI.deleteSubjectFallbackCapitalized : name
        return L10n.CharacterUI.deleteMessage(subject)
    }

    /// Cancel any pending autosave and delete this character. Called only after
    /// the user has confirmed on the detail screen's alert, so we delete
    /// directly rather than re-prompting via the list's pending-delete flow.
    func requestDelete() {
        isDeleting = true
        saveTask?.cancel()
        saveTask = nil
        let character = resolvedCharacter
        Task { await viewModel.delete(character) }
    }
}
