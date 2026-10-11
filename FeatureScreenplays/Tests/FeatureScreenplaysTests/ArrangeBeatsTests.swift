import Testing
import Foundation
import Domain
@testable import FeatureScreenplays

/// The Arrange screen's drag handling and the "…" menu moves. Moves only
/// rewrite the saved layout, so these check where beats land and what gets
/// persisted — never beat text.
@Suite("Arrange Beats")
@MainActor
struct ArrangeBeatsTests {

    private func makeViewModel() -> (OutlineViewModel, ScreenplayRepositorySpy) {
        let spy = ScreenplayRepositorySpy()
        let viewModel = OutlineViewModel(
            screenplay: Screenplay(uuid: "sp-arrange", title: "Untitled"),
            repository: spy,
            debounce: .seconds(30)
        )
        return (viewModel, spy)
    }

    /// Beat ids per section, in on-screen order.
    private func beatIDs(in sectionID: String, of viewModel: OutlineViewModel) -> [String] {
        viewModel.arrangeRows.compactMap { row in
            guard case .beat(let beat, let section) = row.kind, section == sectionID else { return nil }
            return beat.id
        }
    }

    private func rowIndex(of rowID: String, in viewModel: OutlineViewModel) -> Int? {
        viewModel.arrangeRows.firstIndex { $0.id == rowID }
    }

    /// Layout saves run in a detached task; wait briefly for them to land.
    private func waitForSaves(_ spy: ScreenplayRepositorySpy, count: Int) async {
        for _ in 0..<100 where spy.savedBeatLayouts.count < count {
            try? await Task.sleep(for: .milliseconds(10))
        }
    }

    @Test("A new screenplay lists every act with its beats and no placeholders")
    func standardRows() {
        let (sut, _) = makeViewModel()
        let headers = sut.arrangeRows.compactMap { row -> String? in
            guard case .header(let sectionID, _) = row.kind else { return nil }
            return sectionID
        }
        let placeholders = sut.arrangeRows.filter {
            if case .placeholder = $0.kind { return true }
            return false
        }

        #expect(headers == sut.arrangeSections.map(\.id))
        #expect(placeholders.isEmpty)
        #expect(sut.isUsingStandardOrder)
        for sectionID in headers {
            #expect(!beatIDs(in: sectionID, of: sut).isEmpty)
        }
    }

    @Test("Dragging a beat below the next act's header moves it into that act and saves")
    func dragAcrossActs() async throws {
        let (sut, spy) = makeViewModel()
        let firstSection = try #require(sut.arrangeSections.first?.id)
        let secondSection = try #require(sut.arrangeSections.dropFirst().first?.id)
        let movedID = try #require(beatIDs(in: firstSection, of: sut).last)
        let source = try #require(rowIndex(of: movedID, in: sut))
        let secondHeader = try #require(rowIndex(of: "header.\(secondSection)", in: sut))

        // List.onMove semantics: offset is in the pre-move list, so "+1" lands
        // the row right after the second act's header.
        sut.moveArrangeRows(from: IndexSet(integer: source), to: secondHeader + 1)

        #expect(!beatIDs(in: firstSection, of: sut).contains(movedID))
        #expect(beatIDs(in: secondSection, of: sut).first == movedID)
        #expect(!sut.isUsingStandardOrder)
        await waitForSaves(spy, count: 1)
        let saved = try #require(spy.savedBeatLayouts.last)
        #expect(saved != nil)
    }

    @Test("Dropping a beat above the first header keeps it in the first act")
    func dragAboveFirstHeader() throws {
        let (sut, _) = makeViewModel()
        let firstSection = try #require(sut.arrangeSections.first?.id)
        let firstBeat = try #require(beatIDs(in: firstSection, of: sut).first)
        let source = try #require(rowIndex(of: firstBeat, in: sut))

        sut.moveArrangeRows(from: IndexSet(integer: source), to: 0)

        #expect(beatIDs(in: firstSection, of: sut).first == firstBeat)
        #expect(sut.isUsingStandardOrder)
    }

    @Test("Emptying an act shows a drop placeholder for it")
    func emptiedActGetsPlaceholder() throws {
        let (sut, _) = makeViewModel()
        let lastSection = try #require(sut.arrangeSections.last?.id)
        let firstSection = try #require(sut.arrangeSections.first?.id)
        let references = sut.arrangeRows.compactMap { row -> BeatReference? in
            guard case .beat(let beat, let section) = row.kind, section == lastSection else { return nil }
            return beat.reference
        }

        for reference in references {
            sut.move(reference, toSection: firstSection)
        }

        #expect(beatIDs(in: lastSection, of: sut).isEmpty)
        #expect(rowIndex(of: "placeholder.\(lastSection)", in: sut) != nil)
    }

    @Test("Move Down then Move Up returns to the standard order")
    func moveDownThenUp() throws {
        let (sut, _) = makeViewModel()
        let firstSection = try #require(sut.arrangeSections.first?.id)
        let original = beatIDs(in: firstSection, of: sut)
        let beat = try #require(sut.arrangeRows.compactMap { row -> OutlineBeat? in
            guard case .beat(let beat, _) = row.kind else { return nil }
            return beat
        }.first)

        #expect(sut.canMove(beat.reference, by: 1))
        sut.move(beat.reference, by: 1)
        #expect(beatIDs(in: firstSection, of: sut) != original)

        sut.move(beat.reference, by: -1)
        #expect(beatIDs(in: firstSection, of: sut) == original)
        #expect(sut.isUsingStandardOrder)
    }

    @Test("Reset puts every beat back and clears the saved order")
    func resetRestoresStandardOrder() async throws {
        let (sut, spy) = makeViewModel()
        let standardRows = sut.arrangeRows.map(\.id)
        let lastSection = try #require(sut.arrangeSections.last?.id)
        let beat = try #require(sut.arrangeRows.compactMap { row -> OutlineBeat? in
            guard case .beat(let beat, _) = row.kind else { return nil }
            return beat
        }.first)

        sut.move(beat.reference, toSection: lastSection)
        #expect(!sut.isUsingStandardOrder)
        sut.resetBeatOrder()

        #expect(sut.isUsingStandardOrder)
        #expect(sut.arrangeRows.map(\.id) == standardRows)
        await waitForSaves(spy, count: 2)
        let lastSaved = try #require(spy.savedBeatLayouts.last)
        #expect(lastSaved == nil)
    }
}
