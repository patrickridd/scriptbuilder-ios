import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

/// Regression suite for the "tab switch shows stale data" bug.
///
/// The editor's tabs used to rebuild their view models from the screenplay
/// snapshot taken when the script was opened, so a tab round trip dropped new
/// characters/scenes, reverted outline text, and let a stale row save old
/// values over newer ones. `EditorWorkspace` now owns one model per tab for
/// the editor's whole lifetime; these tests pin that contract down.
@Suite("EditorWorkspace")
@MainActor
struct EditorWorkspaceTests {

    // MARK: - Helpers

    private func makeSUT(
        screenplay: Screenplay = Screenplay(uuid: "sp-1", title: "The Vault Gambit")
    ) -> (sut: EditorWorkspace, spy: ScreenplayRepositorySpy) {
        let spy = ScreenplayRepositorySpy()
        let sut = EditorWorkspace(screenplay: screenplay, repository: spy)
        return (sut, spy)
    }

    // MARK: - Outline tab

    @Test("The outline tab gets the same view model on every visit")
    func outlineModelIsReused() {
        let (sut, _) = makeSUT()

        let firstVisit = sut.outline(onOutlineCompleted: {})
        let secondVisit = sut.outline(onOutlineCompleted: {})

        #expect(firstVisit === secondVisit)
    }

    @Test("Outline text typed before a tab switch is still there afterwards")
    func outlineEditsSurviveTabRoundTrip() {
        var screenplay = Screenplay(uuid: "sp-1", title: "The Vault Gambit")
        screenplay.logLine = "Opening snapshot"
        let (sut, _) = makeSUT(screenplay: screenplay)

        sut.outline(onOutlineCompleted: {}).binding(for: .logLine).wrappedValue = "Edited line"
        sut.outline(onOutlineCompleted: {}).binding(for: .incitingIncident).wrappedValue = "The call"

        let revisited = sut.outline(onOutlineCompleted: {})
        #expect(revisited.screenplay.logLine == "Edited line")
        #expect(revisited.screenplay.act1.incitingIncident == "The call")
    }

    @Test("flushOutline is a no-op before the outline tab was ever opened")
    func flushOutlineWithoutModelDoesNothing() async {
        let (sut, spy) = makeSUT()

        sut.flushOutline()
        try? await Task.sleep(for: .milliseconds(30))

        #expect(spy.updateOutlineCallCount == 0)
        #expect(spy.updateActBeatsCallCount == 0)
    }

    // MARK: - Characters tab

    @Test("The characters tab gets the same view model on every visit")
    func charactersModelIsReused() {
        let (sut, _) = makeSUT()
        #expect(sut.characters === sut.characters)
    }

    @Test("A character added before a tab switch is still listed afterwards")
    func newCharacterSurvivesTabRoundTrip() async {
        let (sut, _) = makeSUT()

        let created = await sut.characters.addCharacter(named: "Ripley", role: "Protagonist")
        _ = sut.outline(onOutlineCompleted: {})

        #expect(sut.characters.characters.contains { $0.uuid == created.uuid })
    }

    @Test("Editing a character after a tab switch starts from its latest values")
    func characterEditAfterRoundTripIsNotStale() async {
        let (sut, spy) = makeSUT()
        var created = await sut.characters.addCharacter(named: "Ripley", role: nil)
        created.name = "Ellen Ripley"
        await sut.characters.update(created)

        _ = sut.scenes
        let current = sut.characters.characters.first { $0.uuid == created.uuid }
        #expect(current?.name == "Ellen Ripley")

        guard var revisited = current else { return }
        revisited.intention = "Get everyone home"
        await sut.characters.update(revisited)

        let lastSaved = spy.savedCharacters.last
        #expect(lastSaved?.name == "Ellen Ripley")
        #expect(lastSaved?.intention == "Get everyone home")
    }

    // MARK: - Scenes tab

    @Test("The scenes tab gets the same view model on every visit")
    func scenesModelIsReused() {
        let (sut, _) = makeSUT()
        #expect(sut.scenes === sut.scenes)
    }

    @Test("A scene added before a tab switch is still listed afterwards")
    func newSceneSurvivesTabRoundTrip() async {
        let (sut, spy) = makeSUT()

        let created = await sut.scenes.addScene(to: .two, titled: "The heist")
        _ = sut.characters

        #expect(sut.scenes.scenes(in: .two).contains { $0.uuid == created.uuid })
        #expect(spy.savedScenes.contains { $0.scene.uuid == created.uuid && $0.act == .two })
    }
}

/// Autosave guarantees the workspace relies on: pending outline edits must
/// reach the repository when the editor closes or the app backgrounds.
@Suite("OutlineViewModel flush")
@MainActor
struct OutlineFlushTests {

    private func blankScreenplay() -> Screenplay {
        Screenplay(uuid: "sp-1", title: "Untitled")
    }

    @Test("flush sends a pending outline edit without waiting for the debounce")
    func flushSendsPendingOutlineEdit() async {
        let spy = ScreenplayRepositorySpy()
        let sut = OutlineViewModel(screenplay: blankScreenplay(), repository: spy, debounce: .seconds(30))

        sut.binding(for: .logLine).wrappedValue = "Last keystroke"
        await sut.flush()

        #expect(spy.updatedOutlines.contains { $0[.logLine] == "Last keystroke" })
    }

    @Test("flush sends a pending beat edit to its own act")
    func flushSendsPendingBeatEdit() async {
        let spy = ScreenplayRepositorySpy()
        let sut = OutlineViewModel(screenplay: blankScreenplay(), repository: spy, debounce: .seconds(30))

        sut.binding(for: .allIsLost).wrappedValue = "Rock bottom"
        await sut.flush()

        #expect(spy.updatedActBeats.contains { $0.act == .two && $0.beats[.allIsLost] == "Rock bottom" })
    }

    @Test("flush cancels the debounced save so the edit is written only once")
    func flushDoesNotDoubleWrite() async {
        let spy = ScreenplayRepositorySpy()
        let sut = OutlineViewModel(screenplay: blankScreenplay(), repository: spy, debounce: .milliseconds(20))

        sut.binding(for: .idea).wrappedValue = "Only once"
        await sut.flush()
        try? await Task.sleep(for: .milliseconds(80))

        #expect(spy.updatedOutlines.compactMap { $0[.idea] } == ["Only once"])
    }

    @Test("flush with nothing pending writes nothing")
    func flushWithoutEditsIsSilent() async {
        let spy = ScreenplayRepositorySpy()
        let sut = OutlineViewModel(screenplay: blankScreenplay(), repository: spy, debounce: .milliseconds(20))

        await sut.flush()

        #expect(spy.updateOutlineCallCount == 0)
        #expect(spy.updateActBeatsCallCount == 0)
    }

    @Test("A debounced edit still lands after the view model is released")
    func pendingSaveSurvivesRelease() async {
        let spy = ScreenplayRepositorySpy()
        var sut: OutlineViewModel? = OutlineViewModel(
            screenplay: blankScreenplay(),
            repository: spy,
            debounce: .milliseconds(20)
        )

        // `.theme` exists on both OutlineField and ActBeatField, so name the type.
        sut?.binding(for: OutlineField.theme).wrappedValue = "Trust is a currency"
        sut = nil
        try? await Task.sleep(for: .milliseconds(100))

        #expect(sut == nil)
        #expect(spy.updatedOutlines.contains { $0[.theme] == "Trust is a currency" })
    }
}
