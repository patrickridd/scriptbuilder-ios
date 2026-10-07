//
//  BeatLayout.swift
//  Domain
//
//  The writer's running order of beats, per structure section. A layout only
//  *points* at beats — their text stays wherever it's stored — so moving a
//  beat (even into another act) can never lose writing.
//

import Foundation

/// Points at one beat: a template beat (by key) or a custom beat (by id).
public enum BeatReference: Hashable, Sendable, Codable {
    case template(String)
    case custom(String)

    private static let templatePrefix = "template:"
    private static let customPrefix = "custom:"

    public init(_ field: ActBeatField) {
        self = .template(field.rawValue)
    }

    /// Parses "template:<key>" / "custom:<id>"; `nil` for anything else.
    public init?(storageKey: String) {
        if storageKey.hasPrefix(Self.templatePrefix) {
            let key = String(storageKey.dropFirst(Self.templatePrefix.count))
            guard !key.isEmpty else { return nil }
            self = .template(key)
        } else if storageKey.hasPrefix(Self.customPrefix) {
            let id = String(storageKey.dropFirst(Self.customPrefix.count))
            guard !id.isEmpty else { return nil }
            self = .custom(id)
        } else {
            return nil
        }
    }

    public var storageKey: String {
        switch self {
        case .template(let key): return Self.templatePrefix + key
        case .custom(let id):    return Self.customPrefix + id
        }
    }

    /// The feature-template beat this points at, if any.
    public var templateField: ActBeatField? {
        if case .template(let key) = self { return ActBeatField(rawValue: key) }
        return nil
    }

    public var isCustom: Bool {
        if case .custom = self { return true }
        return false
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let raw = try container.decode(String.self)
        guard let reference = BeatReference(storageKey: raw) else {
            throw DecodingError.dataCorruptedError(
                in: container, debugDescription: "Unknown beat reference \(raw)"
            )
        }
        self = reference
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storageKey)
    }
}

/// Section id → ordered beat references. Sections are ordered by the
/// screenplay's `StructureTemplate`, not by this dictionary.
public struct BeatLayout: Equatable, Sendable, Codable {

    public var sections: [String: [BeatReference]]

    public init(sections: [String: [BeatReference]] = [:]) {
        self.sections = sections
    }

    public func beats(in sectionID: String) -> [BeatReference] {
        sections[sectionID] ?? []
    }

    public func sectionID(containing reference: BeatReference) -> String? {
        sections.first { $0.value.contains(reference) }?.key
    }
}
