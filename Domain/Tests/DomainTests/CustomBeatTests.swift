//
//  CustomBeatTests.swift
//  DomainTests
//
//  Locks in backward-compatible decoding (acts saved before custom beats
//  existed) and outline ordering of custom beats among template beats.
//

import Foundation
import Testing
@testable import Domain

@Suite("CustomBeat")
struct CustomBeatTests {

    @Test("Acts saved before custom beats existed still decode")
    func legacyActDecodes() throws {
        let json = #"{"oldWorldDescription":"A quiet town","theme":"Home"}"#
        let act = try JSONDecoder().decode(Act1.self, from: Data(json.utf8))
        #expect(act.oldWorldDescription == "A quiet town")
        #expect(act.theme == "Home")
        #expect(act.customBeats.isEmpty)
        #expect(act.scenes.isEmpty)
    }

    @Test("Custom beats survive an encode/decode round trip")
    func roundTrip() throws {
        let beat = CustomBeat(id: "b1", title: "Lull", text: "Breathe", anchor: .refusal, order: 2)
        let act = Act1(oldWorldDescription: "x", customBeats: [beat])
        let data = try JSONEncoder().encode(act)
        let decoded = try JSONDecoder().decode(Act1.self, from: data)
        #expect(decoded == act)
    }

    @Test("Unknown anchors fall back to the end of the act")
    func unknownAnchorDecodes() throws {
        let json = #"{"id":"b1","title":"T","text":"","anchor":"retiredBeat","order":0}"#
        let beat = try JSONDecoder().decode(CustomBeat.self, from: Data(json.utf8))
        #expect(beat.anchor == nil)
    }

    @Test("Custom beats follow their anchor, sorted by order; unanchored go last")
    func outlineOrdering() {
        let second = CustomBeat(id: "b", anchor: .incitingIncident, order: 1)
        let first = CustomBeat(id: "a", anchor: .incitingIncident, order: 0)
        let tail = CustomBeat(id: "z", anchor: nil, order: 0)
        let wrongAct = CustomBeat(id: "w", anchor: .climax, order: 0)
        let slots = CustomBeat.outline(for: .one, customBeats: [tail, second, wrongAct, first])

        let templates = ActBeatField.beats(for: .one)
        #expect(slots.count == templates.count + 4)
        #expect(slots[0] == .template(.oldWorldDescription))
        #expect(slots[1] == .template(.incitingIncident))
        #expect(slots[2] == .custom(first))
        #expect(slots[3] == .custom(second))
        #expect(slots[4] == .template(.callToAdventure))
        #expect(slots.suffix(2) == [.custom(tail), .custom(wrongAct)])
    }

    @Test("nextOrder lands after existing siblings")
    func nextOrder() {
        let beats = [
            CustomBeat(anchor: .theme, order: 0),
            CustomBeat(anchor: .theme, order: 3),
            CustomBeat(anchor: nil, order: 9)
        ]
        #expect(CustomBeat.nextOrder(after: .theme, in: beats) == 4)
        #expect(CustomBeat.nextOrder(after: .refusal, in: beats) == 0)
    }

    @Test("Screenplay upsert replaces by id and remove deletes")
    func screenplayMutations() {
        var screenplay = Screenplay(title: "Test")
        var beat = CustomBeat(id: "b1", title: "One")
        screenplay.upsert(customBeat: beat, in: .two)
        beat.title = "Renamed"
        screenplay.upsert(customBeat: beat, in: .two)
        #expect(screenplay.customBeats(in: .two).map(\.title) == ["Renamed"])
        #expect(screenplay.customBeats(in: .one).isEmpty)
        screenplay.removeCustomBeat(id: "b1", from: .two)
        #expect(screenplay.customBeats(in: .two).isEmpty)
    }
}
