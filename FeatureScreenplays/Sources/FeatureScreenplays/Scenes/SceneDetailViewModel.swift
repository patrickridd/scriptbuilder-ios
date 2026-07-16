import Foundation
import Observation
import Domain

/// Owns all editing logic for a single scene screen: the working `draft`, the
/// selected act (which drives cross-act relocation), debounced autosave, and the
/// final flush on exit. Extracted out of `SceneDetailView` so the view stays
/// declarative and the "when do we persist" ownership lives in one place.
@MainActor
@Observable
final class SceneDetailViewModel {

    /// The live working copy the form binds to. Mutating any field schedules a
    /// debounced save automatically via `didSet`.
    var draft: Scene { didSet { scheduleSave() } }

    /// The act this scene belongs to. Changing it relocates the scene across
    /// acts immediately (append last + renumber), mirroring the legacy Act #
    /// popover, and updates the draft's scene number to match.
    var act: Act {
        didSet {
            guard act != oldValue else { return }
            relocate(to: act)
        }
    }

    @ObservationIgnored private let viewModel: ScenesViewModel
    @ObservationIgnored private var saveTask: Task<Void, Never>?
    @ObservationIgnored private let debounce: Duration
    /// Set once the user asks to delete from the editor, so the exit `flush()`
    /// won't re-save (and resurrect) the row.
    @ObservationIgnored private var isDeleting = false

    init(
        scene: Scene,
        act: Act,
        viewModel: ScenesViewModel,
        debounce: Duration = .milliseconds(500)
    ) {
        self.viewModel = viewModel
        self.debounce = debounce
        self.draft = scene
        self.act = act
    }

    /// Title shown in the navigation bar.
    var navigationTitle: String {
        let trimmed = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? "Scene \(draft.sceneNumber)" : trimmed
    }

    /// Whether the title field should grab focus when the detail view appears —
    /// true for a brand-new (still untitled) scene.
    var shouldFocusTitle: Bool {
        draft.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    /// Bound to the Scene # text field. Parses to an Int and defaults to 1 on
    /// empty/invalid input so the collision cascade always has a valid number.
    var sceneNumberText: String {
        get { String(draft.sceneNumber) }
        set {
            let digits = newValue.filter(\.isNumber)
            draft.sceneNumber = max(1, Int(digits) ?? 1)
        }
    }

    /// Relocate the scene to a new act via the shared view model, then sync the
    /// draft's scene number to the appended value so the editor shows it live.
    private func relocate(to newAct: Act) {
        saveTask?.cancel()
        viewModel.moveScene(draft.uuid, to: newAct)
        // The scene was appended last; reflect its new number in the draft
        // without re-triggering a save loop.
        if let relocated = viewModel.scenes(in: newAct).first(where: { $0.uuid == draft.uuid }) {
            var updated = draft
            updated.sceneNumber = relocated.sceneNumber
            draft = updated
        }
    }

    /// Debounced autosave so inline edits persist as you type, not only on exit.
    private func scheduleSave() {
        saveTask?.cancel()
        let scene = draft
        saveTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.viewModel.update(scene)
        }
    }

    /// Confirmation-alert copy shown before deleting this scene.
    var deleteConfirmMessage: String {
        let title = draft.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let subject = title.isEmpty ? L10n.SceneUI.deleteSubjectFallbackCapitalized : "“\(title)”"
        return L10n.SceneUI.deleteMessage(subject)
    }

    /// Delete this scene from the editor. Cancels any pending autosave (so it
    /// can't resurrect the row after removal) and deletes directly — called only
    /// after the user confirms on the detail screen's alert. The caller
    /// dismisses the screen.
    func requestDelete() {
        isDeleting = true
        saveTask?.cancel()
        saveTask = nil
        let scene = draft
        Task { await viewModel.delete(scene) }
    }

    /// Cancel any pending debounce and flush the latest state immediately.
    /// Called when the screen leaves so nothing is lost, and highlight the row.
    func flush() async {
        guard !isDeleting else { return }
        saveTask?.cancel()
        saveTask = nil
        let scene = draft
        await viewModel.update(scene)
        viewModel.highlight(scene.uuid)
    }
}
