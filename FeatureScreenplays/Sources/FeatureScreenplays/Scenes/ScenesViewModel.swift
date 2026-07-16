import Foundation
import Observation
import Domain
import SwiftUI

/// Owns the scenes for one screenplay, bucketed into the three fixed acts.
/// Mirrors the crash-safe snapshot pattern used by `CharactersViewModel`:
/// a single frozen `sections` snapshot is materialized once per mutation so
/// `List` never samples section-count and row-count from two different states
/// mid-diff.
///
/// Supports:
///  - within-act reorder via `.onMove` (matches legacy long-press swap),
///  - cross-act relocation (drag a row into another act's section) — appends
///    the scene last in the target act with `highestSceneNumber + 1` and
///    renumbers, reusing the legacy `selected(newAct:)` semantics,
///  - add scoped to a specific act (the section header `+`),
///  - swipe-to-delete,
///  - the legacy `adjustSceneNumbers` collision-cascade when a scene number
///    changes in the editor,
///  - debounced granular autosave through the non-destructive repository writes.
@MainActor
@Observable
public final class ScenesViewModel {

    /// The scene most recently finished editing — drives a transient accent
    /// border on its row so the user can spot where their edit landed.
    private(set) var highlightedSceneID: String?

    /// The scene awaiting delete confirmation, if any.
    var pendingDelete: Domain.Scene?

    @ObservationIgnored private var highlightClearTask: Task<Void, Never>?
    @ObservationIgnored private let screenplayID: String
    @ObservationIgnored private let repository: ScreenplayRepository

    /// Live per-act ordered arrays. These are the working source of truth;
    /// `sections` is the frozen snapshot the List reads.
    @ObservationIgnored private var buckets: [Act: [Domain.Scene]] = [:]

    public init(
        screenplayID: String,
        act1: [Domain.Scene],
        act2: [Domain.Scene],
        act3: [Domain.Scene],
        repository: ScreenplayRepository
    ) {
        self.screenplayID = screenplayID
        self.repository = repository
        buckets[.one] = act1.sorted { $0.sceneNumber < $1.sceneNumber }
        buckets[.two] = act2.sorted { $0.sceneNumber < $1.sceneNumber }
        buckets[.three] = act3.sorted { $0.sceneNumber < $1.sceneNumber }
        rebuildSections()
    }

    // MARK: - Snapshot

    /// One act plus its ordered scenes, snapshotted together.
    struct ActSection: Identifiable {
        let act: Act
        let scenes: [Domain.Scene]
        var id: Act { act }
    }

    /// A single **stored** atomic snapshot of all three acts and their rows,
    /// materialized once per mutation and frozen until the next one. The List
    /// reads section count and each section's row count from this same frozen
    /// value throughout an update pass, so it can never crash mid-diff.
    private(set) var sections: [ActSection] = []

    /// Rebuild the stored snapshot from the live `buckets`. Always renders all
    /// three acts (fixed sections) so empty acts can show a placeholder.
    private func rebuildSections() {
        sections = Act.allCases.map { act in
            ActSection(act: act, scenes: buckets[act] ?? [])
        }
    }

    /// A fingerprint of the current structure — which scene IDs live in each
    /// act. The view attaches this as the List's `.id` so any cross-act move
    /// swaps the List identity and forces a clean rebuild instead of an
    /// animated batch update.
    var structureID: String {
        sections
            .map { "\($0.act.rawValue):" + $0.scenes.map(\.uuid).joined(separator: ",") }
            .joined(separator: "|")
    }

    /// Scenes for a given act, read from the frozen snapshot so it matches
    /// exactly what the List is diffing.
    func scenes(in act: Act) -> [Domain.Scene] {
        sections.first(where: { $0.act == act })?.scenes ?? []
    }

    /// The act a given scene currently lives in, if any.
    func act(of sceneID: String) -> Act? {
        for act in Act.allCases where (buckets[act] ?? []).contains(where: { $0.uuid == sceneID }) {
            return act
        }
        return nil
    }

    /// Total scene count across all acts (drives the empty state).
    var isEmpty: Bool {
        buckets.values.allSatisfy { $0.isEmpty }
    }

    /// Structural identity for a row that changes whenever the displayed
    /// content changes, forcing a refresh after an edit bubbles back.
    func cardIdentity(for scene: Domain.Scene) -> String {
        "\(scene.uuid)|\(scene.sceneNumber)|\(scene.title)|\(scene.header)"
    }

    /// Confirmation-dialog copy for the scene pending deletion.
    var pendingDeleteMessage: String {
        let title = pendingDelete?.title.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let subject = title.isEmpty ? L10n.SceneUI.deleteSubjectFallback : "“\(title)”"
        return L10n.SceneUI.deleteMessage(subject)
    }

    // MARK: - Add

    /// Insert a brand-new blank scene at the end of a specific act and persist.
    /// The scene number is the next available in that act.
    func addScene(to act: Act) async -> Domain.Scene {
        var current = buckets[act] ?? []
        let nextNumber = (current.map(\.sceneNumber).max() ?? 0) + 1
        let new = Domain.Scene(title: "", sceneNumber: nextNumber)
        current.append(new)
        buckets[act] = current
        rebuildSections()
        await save(new, in: act)
        return new
    }

    // MARK: - Edit / autosave

    /// Merge an edited scene back into its act **without reordering**, then
    /// autosave just that one. Used for debounced autosave while typing. If the
    /// scene number changed we run the legacy collision-cascade so siblings stay
    /// unique, then re-sort by number and persist any bumped siblings too.
    func update(_ scene: Domain.Scene) async {
        guard let act = act(of: scene.uuid) else {
            // Not found in any act (shouldn't happen) — treat as an add to act 1.
            buckets[.one, default: []].append(scene)
            rebuildSections()
            await save(scene, in: .one)
            return
        }

        var current = buckets[act] ?? []
        guard let index = current.firstIndex(where: { $0.uuid == scene.uuid }) else { return }

        let numberChanged = current[index].sceneNumber != scene.sceneNumber
        current[index] = scene

        var bumped: [Domain.Scene] = []
        if numberChanged {
            bumped = adjustSceneNumbers(for: scene, in: &current)
            current.sort { $0.sceneNumber < $1.sceneNumber }
        }

        buckets[act] = current
        rebuildSections()

        await save(scene, in: act)
        for sibling in bumped { await save(sibling, in: act) }
    }

    // MARK: - Drag & drop moves

    /// Relocate a scene from its current act into `newAct`, appended last with
    /// `highestSceneNumber + 1`. Mirrors the legacy `selected(newAct:)`:
    /// remove from the old act (and its Firebase node), insert into the new act,
    /// and save to the new node. No-op if the scene is already in `newAct`.
    func moveScene(_ sceneID: String, to newAct: Act) {
        guard let oldAct = act(of: sceneID), oldAct != newAct else { return }
        guard var oldScenes = buckets[oldAct],
              let index = oldScenes.firstIndex(where: { $0.uuid == sceneID }) else { return }

        var scene = oldScenes.remove(at: index)
        var newScenes = buckets[newAct] ?? []
        scene.sceneNumber = (newScenes.map(\.sceneNumber).max() ?? 0) + 1
        newScenes.append(scene)

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            buckets[oldAct] = oldScenes
            buckets[newAct] = newScenes
            rebuildSections()
        }

        let movedScene = scene
        Task {
            do {
                try await repository.delete(sceneID: movedScene.uuid, from: oldAct, of: screenplayID)
                try await repository.save(scene: movedScene, in: newAct, of: screenplayID)
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }

    /// Insert the dragged scene immediately **before** `targetID` within
    /// `targetAct`. Handles both within-act reorder (drop onto a sibling) and
    /// cross-act relocation (drop onto a row in another act). After the move,
    /// every affected act is reindexed so `sceneNumber` matches visual order and
    /// each changed scene is persisted to the correct Firebase node.
    func moveScene(_ draggedID: String, before targetID: String, in targetAct: Act) {
        guard draggedID != targetID else { return }
        guard let sourceAct = act(of: draggedID) else { return }

        var sourceScenes = buckets[sourceAct] ?? []
        guard let sourceIndex = sourceScenes.firstIndex(where: { $0.uuid == draggedID }) else { return }
        let dragged = sourceScenes.remove(at: sourceIndex)

        // Target array is the (possibly already-mutated) source array when the
        // move is within the same act.
        var targetScenes = sourceAct == targetAct ? sourceScenes : (buckets[targetAct] ?? [])
        let insertIndex = targetScenes.firstIndex(where: { $0.uuid == targetID }) ?? targetScenes.count
        targetScenes.insert(dragged, at: insertIndex)

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            if sourceAct == targetAct {
                buckets[targetAct] = targetScenes
            } else {
                buckets[sourceAct] = sourceScenes
                buckets[targetAct] = targetScenes
            }
            rebuildSections()
        }

        let crossAct = sourceAct != targetAct
        Task {
            if crossAct {
                // The scene left `sourceAct`'s Firebase node.
                do {
                    try await repository.delete(sceneID: draggedID, from: sourceAct, of: screenplayID)
                } catch { errorMessage = error.localizedDescription }
                await reindexAndSave(sourceAct)
            }
            await reindexAndSave(targetAct)
        }
    }

    /// Renumber an act's scenes to their visual order (1-based) and persist any
    /// scene whose number changed.
    private func reindexAndSave(_ act: Act) async {
        var current = buckets[act] ?? []
        var changed: [Domain.Scene] = []
        for (offset, var scene) in current.enumerated() {
            let newNumber = offset + 1
            if scene.sceneNumber != newNumber {
                scene.sceneNumber = newNumber
                current[offset] = scene
                changed.append(scene)
            }
        }
        buckets[act] = current
        rebuildSections()
        for scene in changed { await save(scene, in: act) }
    }

    // MARK: - Delete

    /// Ask to delete a scene (from the swipe action). Records the pending target
    /// instead of mutating the list inside the swipe transaction.
    func requestDelete(_ scene: Domain.Scene) {
        pendingDelete = scene
    }

    /// Confirm the pending deletion from the alert, deferred one runloop tick so
    /// the alert-dismissal transaction commits before we change list shape.
    func confirmPendingDelete() {
        guard let scene = pendingDelete else { return }
        pendingDelete = nil
        Task { @MainActor in
            await Task.yield()
            await delete(scene)
        }
    }

    func delete(_ scene: Domain.Scene) async {
        guard let act = act(of: scene.uuid) else { return }
        if highlightedSceneID == scene.uuid {
            highlightClearTask?.cancel()
            highlightedSceneID = nil
        }

        var transaction = Transaction()
        transaction.disablesAnimations = true
        withTransaction(transaction) {
            buckets[act]?.removeAll { $0.uuid == scene.uuid }
            rebuildSections()
        }

        do {
            try await repository.delete(sceneID: scene.uuid, from: act, of: screenplayID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Highlight

    func isHighlighted(_ scene: Domain.Scene) -> Bool {
        highlightedSceneID == scene.uuid
    }

    /// Flag a scene as just-edited (called on editor exit) and fade it out later.
    func highlight(_ sceneID: String) {
        highlightedSceneID = sceneID
        highlightClearTask?.cancel()
        highlightClearTask = Task { [weak self] in
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation(.easeInOut(duration: 0.4)) {
                self?.highlightedSceneID = nil
            }
        }
    }

    // MARK: - Errors

    var errorMessage: String?

    // MARK: - Renumbering cascade (port of SceneController.adjustSceneNumbers)

    /// After `scene`'s number changes, bump the first colliding sibling upward
    /// and cascade so numbers stay unique. Returns every sibling whose number
    /// was bumped (so callers can persist them).
    @discardableResult
    private func adjustSceneNumbers(for scene: Domain.Scene, in scenes: inout [Domain.Scene]) -> [Domain.Scene] {
        var bumped: [Domain.Scene] = []
        bumpCollisions(for: scene, in: &scenes, bumped: &bumped)
        return bumped
    }

    private func bumpCollisions(for scene: Domain.Scene, in scenes: inout [Domain.Scene], bumped: inout [Domain.Scene]) {
        guard let index = scenes.firstIndex(where: {
            $0.uuid != scene.uuid && $0.sceneNumber == scene.sceneNumber
        }) else { return }
        scenes[index].sceneNumber = scene.sceneNumber + 1
        let next = scenes[index]
        bumped.append(next)
        bumpCollisions(for: next, in: &scenes, bumped: &bumped)
    }

    // MARK: - Persistence

    private func save(_ scene: Domain.Scene, in act: Act) async {
        do {
            try await repository.save(scene: scene, in: act, of: screenplayID)
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
