//
//  CustomBeat.swift
//  Domain
//
//  A writer-authored beat that lives alongside an act's template beats
//  (`ActBeatField`). Template beats are fixed properties on Act1/2/3; custom
//  beats are open-ended, so they're stored as a list on each act and placed
//  in the outline relative to a template beat:
//
//  - `anchor`: the template beat this one sits *after*. `nil` = end of the act.
//    Anchoring to a beat (not a global index) keeps placement stable if the
//    template set ever changes.
//  - `order`: sorts several custom beats that share an anchor. A `Double`, so
//    a beat can be slotted between two neighbours without renumbering.
//
//  Persisted keyed by `id` (never as an array) so concurrent edits/deletes on
//  different beats can't clobber each other.
//

import Foundation

public struct CustomBeat: Equatable, Hashable, Sendable, Codable, Identifiable {

    public var id: String
    public var title: String
    /// Optional guiding line under the title — the custom twin of a template
    /// beat's prompt ("What finally pushes your hero to commit?").
    public var subtitle: String
    public var text: String
    /// Template beat this one follows; `nil` places it at the end of the act.
    public var anchor: ActBeatField?
    /// Tie-breaker among custom beats that share an anchor (ascending).
    public var order: Double

    public init(
        id: String = UUID().uuidString,
        title: String = "",
        subtitle: String = "",
        text: String = "",
        anchor: ActBeatField? = nil,
        order: Double = 0
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.text = text
        self.anchor = anchor
        self.order = order
    }

    public var isFilled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    // MARK: - Codable (lenient, so a bad field never drops the whole act)

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, text, anchor, order
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        subtitle = (try? container.decodeIfPresent(String.self, forKey: .subtitle)) ?? ""
        text = (try? container.decodeIfPresent(String.self, forKey: .text)) ?? ""
        let anchorKey = try? container.decodeIfPresent(String.self, forKey: .anchor)
        // An unknown anchor (e.g. a retired template beat) falls back to the
        // end of the act instead of failing to decode.
        anchor = anchorKey.flatMap(ActBeatField.init(rawValue:))
        order = (try? container.decodeIfPresent(Double.self, forKey: .order)) ?? 0
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(subtitle, forKey: .subtitle)
        try container.encode(text, forKey: .text)
        try container.encodeIfPresent(anchor?.rawValue, forKey: .anchor)
        try container.encode(order, forKey: .order)
    }
}

// MARK: - Ordering

public extension CustomBeat {

    /// One entry in an act's merged outline: a template beat or a custom one.
    enum Slot: Equatable, Hashable, Sendable {
        case template(ActBeatField)
        case custom(CustomBeat)
    }

    /// Merges an act's template beats with its custom beats in outline order:
    /// each custom beat follows its anchor (sorted by `order`), and unanchored
    /// beats — or beats anchored to a beat outside this act — go last.
    static func outline(for act: Act, customBeats: [CustomBeat]) -> [Slot] {
        let templates = ActBeatField.beats(for: act)
        let templateSet = Set(templates)
        let sorted = customBeats.sorted { lhs, rhs in
            lhs.order == rhs.order ? lhs.id < rhs.id : lhs.order < rhs.order
        }
        var byAnchor: [ActBeatField: [CustomBeat]] = [:]
        var trailing: [CustomBeat] = []
        for beat in sorted {
            if let anchor = beat.anchor, templateSet.contains(anchor) {
                byAnchor[anchor, default: []].append(beat)
            } else {
                trailing.append(beat)
            }
        }
        var slots: [Slot] = []
        for template in templates {
            slots.append(.template(template))
            slots += (byAnchor[template] ?? []).map(Slot.custom)
        }
        slots += trailing.map(Slot.custom)
        return slots
    }

    /// The `order` a new beat needs to land after every existing beat that
    /// shares `anchor`.
    static func nextOrder(after anchor: ActBeatField?, in customBeats: [CustomBeat]) -> Double {
        let siblings = customBeats.filter { $0.anchor == anchor }
        return (siblings.map(\.order).max() ?? -1) + 1
    }
}

// MARK: - Screenplay access

public extension Screenplay {

    /// Custom beats for `act`, unsorted (use `CustomBeat.outline` for display).
    func customBeats(in act: Act) -> [CustomBeat] {
        switch act {
        case .one:   return act1.customBeats
        case .two:   return act2.customBeats
        case .three: return act3.customBeats
        }
    }

    /// Inserts or replaces (by `id`) a custom beat in `act`.
    mutating func upsert(customBeat: CustomBeat, in act: Act) {
        var beats = customBeats(in: act)
        if let index = beats.firstIndex(where: { $0.id == customBeat.id }) {
            beats[index] = customBeat
        } else {
            beats.append(customBeat)
        }
        setCustomBeats(beats, in: act)
    }

    /// Removes the custom beat with `id` from `act`, if present.
    mutating func removeCustomBeat(id: String, from act: Act) {
        setCustomBeats(customBeats(in: act).filter { $0.id != id }, in: act)
    }

    private mutating func setCustomBeats(_ beats: [CustomBeat], in act: Act) {
        switch act {
        case .one:   act1.customBeats = beats
        case .two:   act2.customBeats = beats
        case .three: act3.customBeats = beats
        }
    }
}
