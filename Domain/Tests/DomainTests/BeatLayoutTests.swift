import XCTest
@testable import Domain

final class BeatLayoutTests: XCTestCase {

    private func screenplayWithCustomBeat() -> Screenplay {
        var screenplay = Screenplay(title: "Test")
        screenplay.upsert(
            customBeat: CustomBeat(id: "extra", title: "Extra", anchor: .incitingIncident),
            in: .one
        )
        return screenplay
    }

    func testStandardLayoutMatchesLegacyOutline() {
        let screenplay = screenplayWithCustomBeat()
        let actOne = screenplay.beatLayout.beats(in: Act.one.sectionID)
        XCTAssertEqual(actOne[0], BeatReference(.oldWorldDescription))
        XCTAssertEqual(actOne[1], BeatReference(.incitingIncident))
        XCTAssertEqual(actOne[2], .custom("extra"))
        XCTAssertEqual(actOne.count, ActBeatField.beats(for: .one).count + 1)
    }

    func testSavedLayoutKeepsMovesAndEmptySections() {
        var screenplay = screenplayWithCustomBeat()
        var sections = screenplay.standardBeatLayout.sections
        let moved = sections[Act.one.sectionID] ?? []
        sections[Act.one.sectionID] = []
        sections[Act.two.sectionID] = moved + (sections[Act.two.sectionID] ?? [])
        screenplay.savedBeatLayout = BeatLayout(sections: sections)

        XCTAssertTrue(screenplay.outlineBeats(in: .one).isEmpty)
        let actTwo = screenplay.outlineBeats(in: .two)
        XCTAssertEqual(actTwo.first?.reference, BeatReference(.oldWorldDescription))
        XCTAssertEqual(actTwo.first?.homeSectionID, Act.one.sectionID)
    }

    func testReconcileDropsUnknownAndRestoresMissing() {
        var screenplay = screenplayWithCustomBeat()
        var actOne = screenplay.standardBeatLayout.beats(in: Act.one.sectionID)
        actOne.removeAll { $0 == BeatReference(.theme) }
        actOne.append(.custom("deleted"))
        actOne.append(actOne[0])
        var sections = screenplay.standardBeatLayout.sections
        sections[Act.one.sectionID] = actOne
        screenplay.savedBeatLayout = BeatLayout(sections: sections)

        let resolved = screenplay.beatLayout.beats(in: Act.one.sectionID)
        XCTAssertFalse(resolved.contains(.custom("deleted")))
        XCTAssertEqual(resolved.filter { $0 == BeatReference(.oldWorldDescription) }.count, 1)
        let themeIndex = resolved.firstIndex(of: BeatReference(.theme))
        let mentorIndex = resolved.firstIndex(of: BeatReference(.meetingMentor))
        XCTAssertEqual(themeIndex, mentorIndex.map { $0 + 1 })
    }

    func testReferenceStorageKeyRoundTrips() {
        let references: [BeatReference] = [.template("climax"), .custom("abc-123")]
        for reference in references {
            XCTAssertEqual(BeatReference(storageKey: reference.storageKey), reference)
        }
        XCTAssertNil(BeatReference(storageKey: "nonsense"))
    }
}
