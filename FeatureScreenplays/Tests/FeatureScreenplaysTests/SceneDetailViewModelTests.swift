import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

@Suite("SceneDetailViewModel")
@MainActor
struct SceneDetailViewModelTests {

    // MARK: - Helpers

    /// Builds a detail view model wired to a real `ScenesViewModel` (the same
    /// object the production view uses) backed by a recording spy, so relocation
    /// and autosave can be asserted end-to-end.
    private func makeSUT(
        scene: Domain.Scene,
        act: Act = .one,
        otherAct1: [Domain.Scene] = [],
        otherAct2: [Domain.Scene] = [],
        otherAct3: [Domain.Scene] = [],
        debounce: Duration = .milliseconds(10)
    ) -> (sut: SceneDetailViewModel, parent: ScenesViewModel, spy: ScreenplayRepositorySpy) {
        let spy = ScreenplayRepositorySpy()
        var a1 = otherAct1, a2 = otherAct2, a3 = otherAct3
        switch act {
        case .one: a1.append(scene)
        case .two: a2.append(scene)
        case .three: a3.append(scene)
        }
        let parent = ScenesViewModel(
            screenplayID: "sp-1",
            act1: a1, act2: a2, act3: a3,
            repository: spy
        )
        let sut = SceneDetailViewModel(scene: scene, act: act, viewModel: parent, debounce: debounce)
        return (sut, parent, spy)
    }

    private func scene(_ title: String, _ number: Int) -> Domain.Scene {
        Domain.Scene(title: title, sceneNumber: number)
    }

    // MARK: - navigationTitle

    @Test("navigationTitle uses the trimmed title when present")
    func navigationTitleUsesTitle() {
        let (sut, _, _) = makeSUT(scene: scene("  Opening  ", 1))
        #expect(sut.navigationTitle == "Opening")
    }

    @Test("navigationTitle falls back to Scene # for a blank title")
    func navigationTitleFallsBack() {
        let (sut, _, _) = makeSUT(scene: scene("   ", 7))
        #expect(sut.navigationTitle == "Scene 7")
    }

    // MARK: - shouldFocusTitle

    @Test("shouldFocusTitle is true only for an untitled scene")
    func shouldFocusTitleForUntitled() {
        let (blank, _, _) = makeSUT(scene: scene("", 1))
        #expect(blank.shouldFocusTitle)

        let (named, _, _) = makeSUT(scene: scene("Named", 1))
        #expect(!named.shouldFocusTitle)
    }

    // MARK: - sceneNumberText

    @Test("sceneNumberText reads the current number as a string")
    func sceneNumberTextReads() {
        let (sut, _, _) = makeSUT(scene: scene("A", 4))
        #expect(sut.sceneNumberText == "4")
    }

    @Test("sceneNumberText parses digits and clamps to a minimum of 1")
    func sceneNumberTextParsesAndClamps() {
        let (sut, _, _) = makeSUT(scene: scene("A", 1))

        sut.sceneNumberText = "12"
        #expect(sut.draft.sceneNumber == 12)

        sut.sceneNumberText = "0"
        #expect(sut.draft.sceneNumber == 1)

        sut.sceneNumberText = ""
        #expect(sut.draft.sceneNumber == 1)

        sut.sceneNumberText = "a9b"
        #expect(sut.draft.sceneNumber == 9)
    }

    // MARK: - Debounced autosave

    @Test("Editing the draft autosaves the latest value after the debounce")
    func editAutosavesAfterDebounce() async {
        let s = scene("A", 1)
        let (sut, _, spy) = makeSUT(scene: s)

        sut.draft.title = "A (edited)"

        // Wait past the (short) debounce plus the update Task.
        try? await Task.sleep(for: .milliseconds(60))
        #expect(spy.savedScenes.contains { $0.scene.title == "A (edited)" })
    }

    @Test("Rapid edits collapse to a single autosave of the final value")
    func rapidEditsDebounceToLatest() async {
        let s = scene("A", 1)
        let (sut, _, spy) = makeSUT(scene: s, debounce: .milliseconds(30))

        sut.draft.title = "one"
        sut.draft.title = "two"
        sut.draft.title = "three"

        try? await Task.sleep(for: .milliseconds(90))
        let titlesForScene = spy.savedScenes.filter { $0.scene.uuid == s.uuid }.map(\.scene.title)
        #expect(titlesForScene.last == "three")
        // The intermediate values were cancelled, not persisted.
        #expect(!titlesForScene.contains("one"))
        #expect(!titlesForScene.contains("two"))
    }

    // MARK: - flush

    @Test("flush persists the latest draft immediately and highlights the row")
    func flushPersistsAndHighlights() async {
        let s = scene("A", 1)
        let (sut, parent, spy) = makeSUT(scene: s, debounce: .seconds(5))

        sut.draft.notes = "final notes"
        await sut.flush()

        #expect(spy.savedScenes.contains { $0.scene.notes == "final notes" })
        #expect(parent.highlightedSceneID == s.uuid)
    }

    // MARK: - Act relocation

    @Test("Changing act relocates the scene through the parent and syncs the draft number")
    func changingActRelocatesAndSyncsNumber() async {
        let s = scene("A", 1)
        let (sut, parent, spy) = makeSUT(
            scene: s, act: .one,
            otherAct2: [scene("X", 1), scene("Y", 2)]
        )

        sut.act = .two

        // Relocation is synchronous on the parent; persistence Task follows.
        #expect(parent.scenes(in: .one).isEmpty)
        #expect(parent.scenes(in: .two).map(\.uuid).last == s.uuid)
        // Appended last in act 2 => number 3, reflected in the draft.
        #expect(sut.draft.sceneNumber == 3)

        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(spy.deletedScenes.contains { $0.sceneID == s.uuid && $0.act == .one })
    }

    @Test("Setting the act to its current value is a no-op")
    func settingSameActNoOp() async {
        let s = scene("A", 1)
        let (sut, parent, spy) = makeSUT(scene: s, act: .one)

        sut.act = .one

        #expect(parent.scenes(in: .one).map(\.uuid) == [s.uuid])
        await Task.yield()
        #expect(spy.deleteSceneCallCount == 0)
    }

    // MARK: - requestDelete (editor)

    @Test("requestDelete removes the scene directly (confirmation already happened in the editor)")
    func requestDeleteRemovesScene() async {
        let s = scene("A", 1)
        let (sut, parent, _) = makeSUT(scene: s)

        sut.requestDelete()

        // The editor now confirms in its own alert, so requestDelete deletes
        // directly rather than staging a pending delete on the parent.
        try? await Task.sleep(for: .milliseconds(80))
        #expect(parent.pendingDelete == nil)
        #expect(parent.scenes(in: .one).isEmpty)
    }

    @Test("requestDelete cancels a pending autosave so it can't resurrect the row")
    func requestDeleteCancelsPendingAutosave() async {
        let s = scene("A", 1)
        // A long debounce guarantees the scheduled save is still pending when we
        // delete; if the cancel fails, the edit would persist after this line.
        let (sut, _, spy) = makeSUT(scene: s, debounce: .seconds(5))

        sut.draft.title = "A (edited)"   // schedules a debounced save
        sut.requestDelete()              // should cancel it

        // Wait well past the debounce window to prove nothing landed.
        try? await Task.sleep(for: .milliseconds(80))
        #expect(!spy.savedScenes.contains { $0.scene.title == "A (edited)" })
    }

    @Test("After requestDelete, flush is a no-op so the deleted scene isn't re-saved")
    func flushSkipsAfterRequestDelete() async {
        let s = scene("A", 1)
        let (sut, parent, spy) = makeSUT(scene: s, debounce: .seconds(5))

        sut.draft.notes = "trailing edit"
        sut.requestDelete()

        // Simulate the screen leaving after the delete was requested.
        await sut.flush()

        // The guard must skip the save entirely and must not highlight the row.
        #expect(!spy.savedScenes.contains { $0.scene.notes == "trailing edit" })
        #expect(parent.highlightedSceneID == nil)
    }

    @Test("flush still persists normally when no delete was requested")
    func flushPersistsWhenNotDeleting() async {
        let s = scene("A", 1)
        let (sut, _, spy) = makeSUT(scene: s, debounce: .seconds(5))

        sut.draft.notes = "kept"
        await sut.flush()

        #expect(spy.savedScenes.contains { $0.scene.notes == "kept" })
    }
}
