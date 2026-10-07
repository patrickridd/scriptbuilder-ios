//
//  Screenplay+BeatMoves.swift
//  Domain
//
//  Rearranging beats. Every move rewrites only the saved layout — beat text
//  and custom-beat storage never move — and a layout that ends up matching
//  the standard order is cleared, so "standard" stays the default state.
//

import Foundation

public extension Screenplay {

    /// Whether the writer has a custom running order.
    var isUsingStandardOrder: Bool { savedBeatLayout == nil }

    /// The section currently showing `reference`.
    func sectionID(showing reference: BeatReference) -> String? {
        beatLayout.sectionID(containing: reference)
    }

    /// Moves `reference` into `sectionID` at `index` (clamped). Returns whether
    /// anything changed.
    @discardableResult
    mutating func moveBeat(
        _ reference: BeatReference, toSection sectionID: String, at index: Int
    ) -> Bool {
        guard structureTemplate.section(withID: sectionID) != nil,
              let sourceID = self.sectionID(showing: reference) else { return false }
        var layout = beatLayout
        let before = layout
        layout.sections[sourceID]?.removeAll { $0 == reference }
        var beats = layout.beats(in: sectionID)
        beats.insert(reference, at: min(max(index, 0), beats.count))
        layout.sections[sectionID] = beats
        guard layout != before else { return false }
        apply(layout)
        return true
    }

    /// Moves a beat one place up (negative) or down (positive) inside the
    /// section it's shown in.
    @discardableResult
    mutating func moveBeat(_ reference: BeatReference, by offset: Int) -> Bool {
        guard let sectionID = sectionID(showing: reference),
              let index = beatLayout.beats(in: sectionID).firstIndex(of: reference) else { return false }
        let count = beatLayout.beats(in: sectionID).count
        let target = index + offset
        guard target >= 0, target < count else { return false }
        return moveBeat(reference, toSection: sectionID, at: target)
    }

    /// Whether `moveBeat(_:by:)` would do anything.
    func canMoveBeat(_ reference: BeatReference, by offset: Int) -> Bool {
        guard let sectionID = sectionID(showing: reference),
              let index = beatLayout.beats(in: sectionID).firstIndex(of: reference) else { return false }
        let target = index + offset
        return target >= 0 && target < beatLayout.beats(in: sectionID).count
    }

    /// Moves a beat to another section, landing on the edge nearest where it
    /// came from: the start of a later section, the end of an earlier one.
    @discardableResult
    mutating func moveBeat(_ reference: BeatReference, toSection sectionID: String) -> Bool {
        guard let sourceID = self.sectionID(showing: reference), sourceID != sectionID else { return false }
        let ids = structureTemplate.sections.map(\.id)
        guard let from = ids.firstIndex(of: sourceID), let to = ids.firstIndex(of: sectionID) else { return false }
        let index = to > from ? 0 : beatLayout.beats(in: sectionID).count
        return moveBeat(reference, toSection: sectionID, at: index)
    }

    /// Replaces the whole running order (the Arrange screen's result).
    mutating func applyBeatLayout(_ layout: BeatLayout) {
        apply(layout)
    }

    /// Back to the standard order. Nothing is lost: beats are only pointers.
    mutating func resetBeatLayout() {
        savedBeatLayout = nil
    }

    private mutating func apply(_ layout: BeatLayout) {
        savedBeatLayout = layout == standardBeatLayout ? nil : layout
    }
}
