import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

@Suite("OutlineViewModel")
@MainActor
struct OutlineViewModelTests {

    // MARK: - Helpers

    /// Builds an outline view model backed by a recording spy so previews,
    /// counts, bindings, and debounced routing can be asserted end-to-end.
    private func makeSUT(
        screenplay: Screenplay,
        debounce: Duration = .milliseconds(10)
    ) -> (sut: OutlineViewModel, spy: ScreenplayRepositorySpy) {
        let spy = ScreenplayRepositorySpy()
        let sut = OutlineViewModel(screenplay: screenplay, repository: spy, debounce: debounce)
        return (sut, spy)
    }

    private func blankScreenplay() -> Screenplay {
        Screenplay(uuid: "sp-1", title: "Untitled")
    }

    // MARK: - preview(for:)

    @Test("preview returns the section placeholder when the field is empty")
    func previewFallsBackToPlaceholder() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        #expect(sut.preview(for: .idea) == OutlineSection.idea.placeholder)
        #expect(sut.preview(for: .actOne) == OutlineSection.actOne.placeholder)
    }

    @Test("preview treats whitespace-only text as empty")
    func previewTreatsWhitespaceAsEmpty() {
        var sp = blankScreenplay()
        sp.idea = "   \n  "
        let (sut, _) = makeSUT(screenplay: sp)
        #expect(sut.preview(for: .idea) == OutlineSection.idea.placeholder)
    }

    @Test("preview returns the trimmed text when the field is filled")
    func previewReturnsTrimmedText() {
        var sp = blankScreenplay()
        sp.actTwoDescription = "  A tense middle.  "
        let (sut, _) = makeSUT(screenplay: sp)
        #expect(sut.preview(for: .actTwo) == "A tense middle.")
    }

    // MARK: - filledCount(for:)

    @Test("filledCount for the Idea section counts filled fields out of five (Notes excluded)")
    func filledCountIdea() {
        var sp = blankScreenplay()
        sp.idea = "spark"
        sp.logLine = "one line"
        sp.theme = "   "   // blank => not counted
        sp.notes = "some notes"  // optional => not counted in the total
        let (sut, _) = makeSUT(screenplay: sp)
        let count = sut.filledCount(for: .idea)
        #expect(count == (filled: 2, total: 5))
    }

    @Test("filledCount for an act counts its beats plus the overall description")
    func filledCountAct() {
        var sp = blankScreenplay()
        sp.actOneDescription = "The setup"
        sp.act1.incitingIncident = "The call arrives"
        let (sut, _) = makeSUT(screenplay: sp)

        let total = ActBeatField.beats(for: .one).count + 1
        let count = sut.filledCount(for: .actOne)
        #expect(count == (filled: 2, total: total))
    }

    // MARK: - Detail specs

    @Test("ideaFieldSpecs expose the six ordered Idea fields")
    func ideaFieldSpecsOrder() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        let fields = sut.ideaFieldSpecs.map(\.field)
        #expect(fields == [.idea, .logLine, .centralIntention, .mainObstacle, .theme, .notes])
    }

    @Test("beats(for:) returns the act's beats and nothing for Idea")
    func beatsForSection() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        #expect(sut.beats(for: .idea).isEmpty)
        #expect(sut.beats(for: .actOne) == ActBeatField.beats(for: .one))
        #expect(sut.beats(for: .actThree) == ActBeatField.beats(for: .three))
    }

    // MARK: - Binding writes

    @Test("binding(for: OutlineField) writes through to the draft")
    func outlineBindingWritesDraft() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        sut.binding(for: .idea).wrappedValue = "A new spark"
        #expect(sut.screenplay.idea == "A new spark")
    }

    @Test("binding(for: ActBeatField) writes to the correct act in the draft")
    func beatBindingWritesDraft() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        sut.binding(for: .incitingIncident).wrappedValue = "Meteor strikes"
        #expect(sut.screenplay.act1.incitingIncident == "Meteor strikes")
    }

    // MARK: - Debounced routing

    @Test("Editing an outline field routes to updateOutline after the debounce")
    func outlineEditRoutesToUpdateOutline() async {
        let (sut, spy) = makeSUT(screenplay: blankScreenplay())

        sut.binding(for: .logLine).wrappedValue = "One killer line"

        try? await Task.sleep(for: .milliseconds(60))
        #expect(spy.updateActBeatsCallCount == 0)
        #expect(spy.updatedOutlines.contains { $0[.logLine] == "One killer line" })
    }

    @Test("Editing a beat routes to updateActBeats with the beat's own act")
    func beatEditRoutesToUpdateActBeats() async {
        let (sut, spy) = makeSUT(screenplay: blankScreenplay())

        sut.binding(for: .allIsLost).wrappedValue = "The lowest point"

        try? await Task.sleep(for: .milliseconds(60))
        #expect(spy.updateOutlineCallCount == 0)
        #expect(spy.updatedActBeats.contains { $0.act == .two && $0.beats[.allIsLost] == "The lowest point" })
    }

    // MARK: - Debounce cancellation

    @Test("Rapid outline edits collapse to a single save of the final value")
    func rapidOutlineEditsDebounceToLatest() async {
        let (sut, spy) = makeSUT(screenplay: blankScreenplay(), debounce: .milliseconds(30))

        sut.binding(for: .idea).wrappedValue = "one"
        sut.binding(for: .idea).wrappedValue = "two"
        sut.binding(for: .idea).wrappedValue = "three"

        try? await Task.sleep(for: .milliseconds(90))
        let ideaValues = spy.updatedOutlines.compactMap { $0[.idea] }
        #expect(ideaValues == ["three"])
    }

    // MARK: - Error handling

    @Test("A repository failure is captured in errorMessage")
    func repositoryFailureSetsErrorMessage() async {
        let failing = FailingScreenplayRepositorySpy()
        let sut = OutlineViewModel(
            screenplay: blankScreenplay(),
            repository: failing,
            debounce: .milliseconds(10)
        )

        sut.binding(for: .idea).wrappedValue = "boom"

        try? await Task.sleep(for: .milliseconds(60))
        #expect(sut.errorMessage != nil)
    }

    // MARK: - Outline completion edge

    /// Fills every field the completion count considers required across all
    /// four sections, driving the outline to 100% via bindings so the edge
    /// logic runs. Returns after the final write.
    private func fillEverything(_ sut: OutlineViewModel) {
        // Idea section required fields.
        for field in [OutlineField.idea, .logLine, .centralIntention, .mainObstacle, .theme] {
            sut.binding(for: field).wrappedValue = "x"
        }
        // Each act's overall description.
        for field in [OutlineField.actOneDescription, .actTwoDescription, .actThreeDescription] {
            sut.binding(for: field).wrappedValue = "x"
        }
        // Every narrative beat across the three acts.
        for act in [Act.one, .two, .three] {
            for beat in ActBeatField.beats(for: act) {
                sut.binding(for: beat).wrappedValue = "x"
            }
        }
    }

    @Test("onOutlineCompleted fires once when the outline first reaches 100%")
    func outlineCompletionFiresOnce() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        var completions = 0
        sut.onOutlineCompleted = { completions += 1 }

        fillEverything(sut)

        #expect(sut.overallCompletion >= 0.999)
        #expect(completions == 1)
    }

    @Test("onOutlineCompleted does not re-fire while already complete")
    func outlineCompletionDoesNotRefire() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        var completions = 0
        sut.onOutlineCompleted = { completions += 1 }

        fillEverything(sut)
        // Further edits within an already-complete outline must not re-fire.
        sut.binding(for: .idea).wrappedValue = "revised idea"
        sut.binding(for: .notes).wrappedValue = "an optional note"

        #expect(completions == 1)
    }

    @Test("onOutlineCompleted never fires for an incomplete outline")
    func outlineCompletionSuppressedWhenIncomplete() {
        let (sut, _) = makeSUT(screenplay: blankScreenplay())
        var completions = 0
        sut.onOutlineCompleted = { completions += 1 }

        sut.binding(for: .idea).wrappedValue = "only one field"

        #expect(completions == 0)
    }
}
