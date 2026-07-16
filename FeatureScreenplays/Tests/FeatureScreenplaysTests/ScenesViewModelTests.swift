import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

@Suite("ScenesViewModel")
@MainActor
struct ScenesViewModelTests {

    // MARK: - Helpers

    private func makeSUT(
        act1: [Domain.Scene] = [],
        act2: [Domain.Scene] = [],
        act3: [Domain.Scene] = [],
        repository: ScreenplayRepositorySpy = ScreenplayRepositorySpy()
    ) -> (sut: ScenesViewModel, spy: ScreenplayRepositorySpy) {
        let sut = ScenesViewModel(
            screenplayID: "sp-1",
            act1: act1,
            act2: act2,
            act3: act3,
            repository: repository
        )
        return (sut, repository)
    }

    private func scene(_ title: String, _ number: Int) -> Domain.Scene {
        Domain.Scene(title: title, sceneNumber: number)
    }

    // MARK: - Initial snapshot

    @Test("Init always renders all three acts, sorted by scene number")
    func initRendersThreeSortedActs() {
        let (sut, _) = makeSUT(
            act1: [scene("B", 2), scene("A", 1)],
            act2: [],
            act3: [scene("C", 1)]
        )

        #expect(sut.sections.map(\.act) == [.one, .two, .three])
        #expect(sut.scenes(in: .one).map(\.title) == ["A", "B"])
        #expect(sut.scenes(in: .two).isEmpty)
        #expect(sut.scenes(in: .three).map(\.title) == ["C"])
    }

    @Test("isEmpty is true only when every act is empty")
    func isEmptyReflectsAllActs() {
        let (empty, _) = makeSUT()
        #expect(empty.isEmpty)

        let (full, _) = makeSUT(act2: [scene("A", 1)])
        #expect(!full.isEmpty)
    }

    // MARK: - addScene

    @Test("Adding a scene appends it to the act with the next number and persists")
    func addSceneAppendsAndPersists() async {
        let (sut, spy) = makeSUT(act1: [scene("A", 1)])

        let created = await sut.addScene(to: .one)

        #expect(created.sceneNumber == 2)
        #expect(sut.scenes(in: .one).map(\.uuid).last == created.uuid)
        #expect(spy.saveSceneCallCount == 1)
        #expect(spy.savedScenes.last?.act == .one)
    }

    @Test("Adding into an empty act starts numbering at 1")
    func addSceneEmptyActStartsAtOne() async {
        let (sut, _) = makeSUT()

        let created = await sut.addScene(to: .three)

        #expect(created.sceneNumber == 1)
        #expect(sut.scenes(in: .three).map(\.uuid) == [created.uuid])
    }

    // MARK: - act(of:)

    @Test("act(of:) locates the act a scene lives in")
    func actOfLocatesScene() {
        let s = scene("A", 1)
        let (sut, _) = makeSUT(act2: [s])

        #expect(sut.act(of: s.uuid) == .two)
        #expect(sut.act(of: "ghost") == nil)
    }

    // MARK: - moveScene(_:to:) — cross-act relocation

    @Test("Moving a scene to another act appends it last, renumbered, and re-persists")
    func moveToActAppendsAndRenumbers() async {
        let a = scene("A", 1)
        let (sut, spy) = makeSUT(act1: [a], act2: [scene("X", 1), scene("Y", 2)])

        sut.moveScene(a.uuid, to: .two)

        #expect(sut.scenes(in: .one).isEmpty)
        #expect(sut.scenes(in: .two).map(\.uuid).last == a.uuid)
        // Appended last in act 2 => number 3.
        #expect(sut.scenes(in: .two).last?.sceneNumber == 3)

        // Let the persistence Task run.
        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(spy.deletedScenes.contains { $0.sceneID == a.uuid && $0.act == .one })
        #expect(spy.savedScenes.contains { $0.scene.uuid == a.uuid && $0.act == .two })
    }

    @Test("Moving a scene to the act it's already in is a no-op")
    func moveToSameActNoOp() async {
        let a = scene("A", 1)
        let (sut, spy) = makeSUT(act1: [a])

        sut.moveScene(a.uuid, to: .one)

        #expect(sut.scenes(in: .one).map(\.uuid) == [a.uuid])
        await Task.yield()
        #expect(spy.deleteSceneCallCount == 0)
    }

    // MARK: - moveScene(_:before:in:) — reorder / relocate

    @Test("Reordering within an act inserts before the target and reindexes 1-based")
    func reorderWithinActReindexes() async {
        let a = scene("A", 1)
        let b = scene("B", 2)
        let c = scene("C", 3)
        let (sut, _) = makeSUT(act1: [a, b, c])

        // Drag C to before A => order C, A, B.
        sut.moveScene(c.uuid, before: a.uuid, in: .one)

        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(sut.scenes(in: .one).map(\.title) == ["C", "A", "B"])
        #expect(sut.scenes(in: .one).map(\.sceneNumber) == [1, 2, 3])
    }

    @Test("Dropping onto its own row is a no-op")
    func reorderOntoSelfNoOp() async {
        let a = scene("A", 1)
        let b = scene("B", 2)
        let (sut, _) = makeSUT(act1: [a, b])

        sut.moveScene(a.uuid, before: a.uuid, in: .one)

        #expect(sut.scenes(in: .one).map(\.title) == ["A", "B"])
    }

    @Test("Cross-act drop onto a row inserts there and reindexes both acts")
    func crossActReorderReindexesBoth() async {
        let a = scene("A", 1)
        let x = scene("X", 1)
        let y = scene("Y", 2)
        let (sut, spy) = makeSUT(act1: [a], act2: [x, y])

        // Drag A into act 2, before Y => act2 order X, A, Y.
        sut.moveScene(a.uuid, before: y.uuid, in: .two)

        await Task.yield()
        try? await Task.sleep(for: .milliseconds(50))
        #expect(sut.scenes(in: .one).isEmpty)
        #expect(sut.scenes(in: .two).map(\.title) == ["X", "A", "Y"])
        #expect(sut.scenes(in: .two).map(\.sceneNumber) == [1, 2, 3])
        #expect(spy.deletedScenes.contains { $0.sceneID == a.uuid && $0.act == .one })
    }

    // MARK: - update / scene-number cascade

    @Test("Editing a scene without changing its number keeps order and persists it")
    func updateNoNumberChangeKeepsOrder() async {
        let a = scene("A", 1)
        let b = scene("B", 2)
        let (sut, spy) = makeSUT(act1: [a, b])

        var edited = a
        edited.title = "A (revised)"
        await sut.update(edited)

        #expect(sut.scenes(in: .one).map(\.title) == ["A (revised)", "B"])
        #expect(spy.savedScenes.last?.scene.title == "A (revised)")
    }

    @Test("Changing a scene number to collide cascades siblings upward and re-sorts")
    func updateNumberCollisionCascades() async {
        let a = scene("A", 1)
        let b = scene("B", 2)
        let c = scene("C", 3)
        let (sut, _) = makeSUT(act1: [a, b, c])

        // Set A's number to 2 => collides with B; B bumps to 3, C bumps to 4.
        var edited = a
        edited.sceneNumber = 2
        await sut.update(edited)

        let numbers = Dictionary(uniqueKeysWithValues: sut.scenes(in: .one).map { ($0.title, $0.sceneNumber) })
        #expect(numbers["A"] == 2)
        #expect(numbers["B"] == 3)
        #expect(numbers["C"] == 4)
        // Numbers stay unique after the cascade.
        let all = sut.scenes(in: .one).map(\.sceneNumber)
        #expect(Set(all).count == all.count)
    }

    // MARK: - Delete

    @Test("requestDelete records the pending target without mutating the list")
    func requestDeleteRecordsPending() {
        let a = scene("A", 1)
        let (sut, _) = makeSUT(act1: [a])

        sut.requestDelete(a)

        #expect(sut.pendingDelete?.uuid == a.uuid)
        #expect(sut.scenes(in: .one).count == 1)
    }

    @Test("delete removes the scene and forwards id + act to the repository")
    func deleteRemovesAndForwards() async {
        let a = scene("A", 1)
        let (sut, spy) = makeSUT(act2: [a])

        await sut.delete(a)

        #expect(sut.scenes(in: .two).isEmpty)
        #expect(spy.deletedScenes.contains { $0.sceneID == a.uuid && $0.act == .two })
    }

    @Test("Deleting a scene not in any act is a safe no-op")
    func deleteMissingNoOp() async {
        let (sut, spy) = makeSUT(act1: [scene("A", 1)])

        await sut.delete(scene("Ghost", 9))

        #expect(sut.scenes(in: .one).count == 1)
        #expect(spy.deleteSceneCallCount == 0)
    }

    // MARK: - pendingDeleteMessage

    @Test("Delete confirmation uses the scene title when present")
    func pendingDeleteMessageUsesTitle() {
        let (sut, _) = makeSUT()
        sut.pendingDelete = scene("Opening", 1)

        #expect(sut.pendingDeleteMessage.contains("“Opening”"))
    }

    @Test("Delete confirmation falls back to a generic subject for a blank title")
    func pendingDeleteMessageBlankTitle() {
        let (sut, _) = makeSUT()
        sut.pendingDelete = scene("   ", 1)

        #expect(sut.pendingDeleteMessage.hasPrefix("this scene"))
    }

    // MARK: - cardIdentity

    @Test("cardIdentity changes when any displayed field changes")
    func cardIdentityReactsToFields() {
        let (sut, _) = makeSUT()
        var s = scene("A", 1)
        s.header = "EXT. STREET"

        let original = sut.cardIdentity(for: s)

        var renamed = s; renamed.title = "A2"
        var renumbered = s; renumbered.sceneNumber = 2
        var reheaded = s; reheaded.header = "INT. ROOM"

        #expect(sut.cardIdentity(for: renamed) != original)
        #expect(sut.cardIdentity(for: renumbered) != original)
        #expect(sut.cardIdentity(for: reheaded) != original)
    }

    // MARK: - structureID

    @Test("structureID changes when a scene moves across acts")
    func structureIDReflectsMoves() {
        let a = scene("A", 1)
        let (sut, _) = makeSUT(act1: [a])

        let before = sut.structureID
        sut.moveScene(a.uuid, to: .three)

        #expect(sut.structureID != before)
    }

    // MARK: - Highlight

    @Test("highlight flags the scene as just-edited")
    func highlightFlagsScene() {
        let a = scene("A", 1)
        let (sut, _) = makeSUT(act1: [a])

        sut.highlight(a.uuid)

        #expect(sut.isHighlighted(a))
        #expect(sut.highlightedSceneID == a.uuid)
    }

    // MARK: - Error handling

    @Test("A failing scene save surfaces the error message")
    func addSurfacesSaveError() async {
        let repo = FailingScreenplayRepositorySpy(message: "Disk is full")
        let sut = ScenesViewModel(screenplayID: "sp-1", act1: [], act2: [], act3: [], repository: repo)

        _ = await sut.addScene(to: .one)

        #expect(repo.saveSceneCallCount == 1)
        #expect(sut.errorMessage == "Disk is full")
    }

    @Test("A failing scene delete surfaces the error but still removes locally")
    func deleteSurfacesError() async {
        let a = scene("A", 1)
        let repo = FailingScreenplayRepositorySpy(message: "Network down")
        let sut = ScenesViewModel(screenplayID: "sp-1", act1: [a], act2: [], act3: [], repository: repo)

        await sut.delete(a)

        #expect(sut.scenes(in: .one).isEmpty)
        #expect(sut.errorMessage == "Network down")
    }
}
