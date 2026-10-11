import Foundation
import Domain

/// One row on the Arrange screen.
struct ArrangeRow: Identifiable, Equatable {
    enum Kind: Equatable {
        case header(sectionID: String, title: String)
        case beat(OutlineBeat, sectionID: String)
        case placeholder(sectionID: String)
    }
    let kind: Kind

    var id: String {
        switch kind {
        case .header(let sectionID, _):    return "header.\(sectionID)"
        case .beat(let beat, _):           return beat.id
        case .placeholder(let sectionID):  return "placeholder.\(sectionID)"
        }
    }
}

/// Rearranging beats. Moves only ever rewrite the screenplay's saved layout
/// (beat text and custom-beat storage stay put) and persist it in one write.
/// Gating is the caller's job — these always move.
extension OutlineViewModel {

    var isUsingStandardOrder: Bool { screenplay.isUsingStandardOrder }

    /// The structure's acts in order, with their display titles.
    var arrangeSections: [(id: String, title: String)] {
        screenplay.structureTemplate.sections.map { section in
            (section.id, sectionTitle(forID: section.id) ?? section.title)
        }
    }

    /// The whole outline flattened for a single movable list: a header per
    /// section, then its beats, or a "Drop a beat here" row when it's empty.
    var arrangeRows: [ArrangeRow] {
        arrangeSections.flatMap { section -> [ArrangeRow] in
            let beats = screenplay.outlineBeats(inSection: section.id)
            let header = ArrangeRow(kind: .header(sectionID: section.id, title: section.title))
            guard !beats.isEmpty else {
                return [header, ArrangeRow(kind: .placeholder(sectionID: section.id))]
            }
            return [header] + beats.map { ArrangeRow(kind: .beat($0, sectionID: section.id)) }
        }
    }

    /// Title for a structure section id ("Act I"), via the outline sections.
    func sectionTitle(forID sectionID: String?) -> String? {
        guard let sectionID else { return nil }
        return OutlineSection.allCases.first { $0.act?.sectionID == sectionID }?.title
    }

    // MARK: - Moving

    /// Applies a drag on the flattened Arrange list. Every beat belongs to the
    /// nearest header above it; anything dragged above the first header joins
    /// the first section.
    func moveArrangeRows(from source: IndexSet, to destination: Int) {
        var rows = arrangeRows
        rows.move(fromOffsets: source, toOffset: destination)
        var sections: [String: [BeatReference]] = [:]
        var current = arrangeSections.first?.id
        for sectionID in arrangeSections.map(\.id) { sections[sectionID] = [] }
        for row in rows {
            switch row.kind {
            case .header(let sectionID, _):
                current = sectionID
            case .beat(let beat, _):
                if let current { sections[current, default: []].append(beat.reference) }
            case .placeholder:
                continue
            }
        }
        let before = screenplay.savedBeatLayout
        screenplay.applyBeatLayout(BeatLayout(sections: sections))
        guard screenplay.savedBeatLayout != before else { return }
        didRearrange()
    }

    func canMove(_ reference: BeatReference, by offset: Int) -> Bool {
        screenplay.canMoveBeat(reference, by: offset)
    }

    func move(_ reference: BeatReference, by offset: Int) {
        guard screenplay.moveBeat(reference, by: offset) else { return }
        didRearrange()
    }

    /// The other sections a beat shown in `section` could be sent to.
    func moveTargets(from section: OutlineSection) -> [(id: String, title: String)] {
        arrangeSections.filter { $0.id != section.act?.sectionID }
    }

    func move(_ reference: BeatReference, toSection sectionID: String) {
        guard screenplay.moveBeat(reference, toSection: sectionID) else { return }
        didRearrange()
    }

    func resetBeatOrder() {
        guard !screenplay.isUsingStandardOrder else { return }
        screenplay.resetBeatLayout()
        didRearrange()
    }

    private func didRearrange() {
        saveBeatLayout()
        evaluateCompletionEdge()
    }
}
