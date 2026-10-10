//
//  ArcQuestionDTO.swift
//  FirebaseData
//
//  Persistence shape for a writer-authored arc question. Stored on the
//  character node as a map keyed by id:
//      characters/{charID}/arcQuestions/{questionID}: { id, title, … }
//  Never throws: every field is lenient so one odd value can't drop the
//  question (and, on the next whole-character save, erase it for good).
//

import Foundation
import Domain

struct ArcQuestionDTO: Codable, Sendable {

    let id: String
    let title: String
    let subtitle: String
    let text: String
    let anchor: String?
    let order: Double

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, text, anchor, order
    }

    init(id: String, title: String, subtitle: String, text: String, anchor: String?, order: Double) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.text = text
        self.anchor = anchor
        self.order = order
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id       = container.lenientString(.id)
        title    = container.lenientString(.title)
        subtitle = container.lenientString(.subtitle)
        text     = container.lenientString(.text)
        anchor   = try? container.decodeIfPresent(String.self, forKey: .anchor)
        if let number = try? container.decodeIfPresent(Double.self, forKey: .order) {
            order = number
        } else {
            order = Double(container.lenientString(.order)) ?? 0
        }
    }

    init(domain question: ArcQuestion) {
        self.init(
            id: question.id,
            title: question.title,
            subtitle: question.subtitle,
            text: question.text,
            anchor: question.anchor?.rawValue,
            order: question.order
        )
    }

    /// `key` is the RTDB child key — authoritative when the stored `id` is
    /// missing.
    func toDomain(key: String) -> ArcQuestion {
        ArcQuestion(
            id: id.isEmpty ? key : id,
            title: title,
            subtitle: subtitle,
            text: text,
            anchor: anchor.flatMap(ArcTemplateQuestion.init(rawValue:)),
            order: order
        )
    }
}

/// Wraps a value so a single undecodable map entry is skipped instead of
/// failing the whole map.
struct LossyDecoded<Value: Decodable>: Decodable {
    let value: Value?

    init(from decoder: Decoder) throws {
        value = try? Value(from: decoder)
    }
}
