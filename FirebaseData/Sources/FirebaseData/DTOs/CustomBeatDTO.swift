//
//  CustomBeatDTO.swift
//  FirebaseData
//
//  Persistence shape for a writer-authored beat. Stored under an act node's
//  `customBeats` child as a map keyed by beat id — never an array — so
//  granular upserts/deletes merge cleanly with `updateChildValues`.
//

import Foundation
import Domain

struct CustomBeatDTO: Codable, Sendable {
    let id: String
    let title: String
    let text: String
    let anchor: String?
    let order: Double

    enum CodingKeys: String, CodingKey {
        case id, title, text, anchor, order
    }

    init(id: String, title: String, text: String, anchor: String?, order: Double) {
        self.id = id
        self.title = title
        self.text = text
        self.anchor = anchor
        self.order = order
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id     = container.lenientString(.id)
        title  = container.lenientString(.title)
        text   = container.lenientString(.text)
        anchor = try? container.decodeIfPresent(String.self, forKey: .anchor)
        order  = (try? container.decodeIfPresent(Double.self, forKey: .order)) ?? 0
    }
}

extension CustomBeatDTO {
    init(domain: CustomBeat) {
        self.init(
            id: domain.id,
            title: domain.title,
            text: domain.text,
            anchor: domain.anchor?.rawValue,
            order: domain.order
        )
    }

    func toDomain(fallbackID: String) -> CustomBeat {
        CustomBeat(
            id: id.isEmpty ? fallbackID : id,
            title: title,
            text: text,
            anchor: anchor.flatMap(ActBeatField.init(rawValue:)),
            order: order
        )
    }
}

enum CustomBeatMapping {
    /// Domain list → RTDB map keyed by id. `nil` when empty so the key is omitted.
    static func toMap(_ beats: [CustomBeat]) -> [String: CustomBeatDTO]? {
        guard !beats.isEmpty else { return nil }
        return Dictionary(beats.map { ($0.id, CustomBeatDTO(domain: $0)) },
                          uniquingKeysWith: { _, last in last })
    }

    /// RTDB map → domain list. The child key is authoritative for the id.
    static func toArray(_ map: [String: CustomBeatDTO]?) -> [CustomBeat] {
        guard let map else { return [] }
        return map.map { key, dto in dto.toDomain(fallbackID: key) }
            .sorted { $0.order < $1.order }
    }
}
