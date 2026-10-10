//
//  ArcQuestion.swift
//  Domain
//
//  The building blocks of a character's arc questionnaire. The nine stock
//  questions are fixed properties on `Character` (`ArcTemplateQuestion`);
//  writers can add their own (`ArcQuestion`), switch stock ones off, and
//  reorder the lot. "Notes" is a free-form scratchpad, not a question, so it
//  is deliberately absent here — it always stays pinned at the bottom.
//
//  Mirrors the outline's custom-beat design: a custom question sits *after*
//  an `anchor` stock question (nil = end of the list) with a fractional
//  `order` tie-breaker, and an optional saved order overrides the standard
//  one without ever moving storage.
//

import Foundation

/// The stock arc questions, in standard order. Raw values are persisted (in
/// saved orders and the disabled set), so never rename a case's raw value.
public enum ArcTemplateQuestion: String, CaseIterable, Sendable, Codable, Hashable {
    case intention
    case whyIntention
    case whatToDo
    case howDoesCharacterDoIt
    case obstacles
    case flaws
    case intentionFix
    case need
    case howCharacterChanged
}

/// A writer-authored arc question.
public struct ArcQuestion: Identifiable, Hashable, Sendable, Codable {

    public var id: String
    /// The question itself ("What does she owe her sister?").
    public var title: String
    /// Optional guiding line under the title.
    public var subtitle: String
    /// The writer's answer.
    public var text: String
    /// Stock question this one follows; `nil` places it at the end.
    public var anchor: ArcTemplateQuestion?
    /// Tie-breaker among custom questions that share an anchor (ascending).
    public var order: Double

    public init(
        id: String = UUID().uuidString,
        title: String = "",
        subtitle: String = "",
        text: String = "",
        anchor: ArcTemplateQuestion? = nil,
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

    enum CodingKeys: String, CodingKey {
        case id, title, subtitle, text, anchor, order
    }

    /// Lenient: a bad field never drops the question, and an unknown anchor
    /// (a retired stock question) falls back to the end of the list.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = (try? container.decodeIfPresent(String.self, forKey: .title)) ?? ""
        subtitle = (try? container.decodeIfPresent(String.self, forKey: .subtitle)) ?? ""
        text = (try? container.decodeIfPresent(String.self, forKey: .text)) ?? ""
        let anchorKey = try? container.decodeIfPresent(String.self, forKey: .anchor)
        anchor = anchorKey.flatMap(ArcTemplateQuestion.init(rawValue:))
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

/// A pointer to one entry in the arc list — stock or custom — used by saved
/// orders. Persisted as a string ("template:need" / "custom:<id>").
public enum ArcQuestionRef: Hashable, Sendable, Codable {
    case template(ArcTemplateQuestion)
    case custom(String)

    private static let templatePrefix = "template:"
    private static let customPrefix = "custom:"

    public var storageKey: String {
        switch self {
        case .template(let question): return Self.templatePrefix + question.rawValue
        case .custom(let id): return Self.customPrefix + id
        }
    }

    public init?(storageKey: String) {
        if storageKey.hasPrefix(Self.templatePrefix) {
            let raw = String(storageKey.dropFirst(Self.templatePrefix.count))
            guard let question = ArcTemplateQuestion(rawValue: raw) else { return nil }
            self = .template(question)
        } else if storageKey.hasPrefix(Self.customPrefix) {
            let id = String(storageKey.dropFirst(Self.customPrefix.count))
            guard !id.isEmpty else { return nil }
            self = .custom(id)
        } else {
            return nil
        }
    }

    public init(from decoder: Decoder) throws {
        let key = try decoder.singleValueContainer().decode(String.self)
        guard let ref = ArcQuestionRef(storageKey: key) else {
            throw DecodingError.dataCorrupted(.init(
                codingPath: decoder.codingPath,
                debugDescription: "Unknown arc question reference \(key)"
            ))
        }
        self = ref
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(storageKey)
    }

    /// Joins refs into the single string stored in RTDB. "/" can never
    /// appear in a ref (it's illegal in RTDB keys, so ids never contain it).
    public static func joined(_ refs: [ArcQuestionRef]) -> String {
        refs.map(\.storageKey).joined(separator: "/")
    }

    /// Inverse of `joined`; unknown entries are dropped, not fatal.
    public static func split(_ stored: String) -> [ArcQuestionRef] {
        stored.split(separator: "/").compactMap { ArcQuestionRef(storageKey: String($0)) }
    }
}

/// One resolved entry in a character's arc list, in display order.
public enum ArcSlot: Hashable, Sendable {
    case template(ArcTemplateQuestion)
    case custom(ArcQuestion)

    public var ref: ArcQuestionRef {
        switch self {
        case .template(let question): return .template(question)
        case .custom(let question): return .custom(question.id)
        }
    }

    /// Identity that survives text edits — key `ForEach` on this, never on
    /// the slot itself (its hash includes the answer text).
    public var stableID: String { ref.storageKey }
}
