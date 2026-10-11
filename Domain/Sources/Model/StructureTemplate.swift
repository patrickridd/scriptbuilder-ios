//
//  StructureTemplate.swift
//  Domain
//
//  Describes a story structure: its ordered sections and the default template
//  beats in each. Today only the feature-film Hero's Journey ships (three acts,
//  the 24 `ActBeatField` beats), but nothing downstream assumes three acts —
//  a TV pilot (Teaser, Acts 1–5, Tag) is just another entry in `all`.
//
//  Sections and template beats are addressed by plain string ids ("act1",
//  "incitingIncident") so a saved `BeatLayout` never depends on a Swift enum
//  that only one template uses.
//

import Foundation

/// One section of a structure (an act, a teaser, a tag…).
public struct StructureSection: Sendable, Hashable, Identifiable {

    /// Stable persistence id, e.g. "act1". Never localised.
    public let id: String
    /// Localisation key for the on-screen title.
    public let titleKey: String
    /// The legacy act whose storage (description, scenes, custom beats) backs
    /// this section. `nil` for sections that don't map onto Act I/II/III.
    public let act: Act?
    /// Template beat keys in their standard order.
    public let defaultBeats: [String]

    public init(id: String, titleKey: String, act: Act?, defaultBeats: [String]) {
        self.id = id
        self.titleKey = titleKey
        self.act = act
        self.defaultBeats = defaultBeats
    }

    public var title: String { L10n.dynamic(titleKey) }
}

public struct StructureTemplate: Sendable, Hashable, Identifiable {

    /// Stable persistence id, e.g. "feature.herosJourney".
    public let id: String
    public let sections: [StructureSection]

    public init(id: String, sections: [StructureSection]) {
        self.id = id
        self.sections = sections
    }

    /// The structure every screenplay used before templates existed.
    public static let featureHerosJourney = StructureTemplate(
        id: "feature.herosJourney",
        sections: Act.allCases.map { act in
            StructureSection(
                id: act.sectionID,
                titleKey: "act.\(act.rawValue).title",
                act: act,
                defaultBeats: ActBeatField.beats(for: act).map(\.rawValue)
            )
        }
    )

    /// Every template the app knows about.
    public static let all: [StructureTemplate] = [.featureHerosJourney]

    public static let standard: StructureTemplate = .featureHerosJourney

    /// Resolves a stored template id; `nil` (screenplays saved before
    /// templates existed) and unknown ids fall back to `standard`.
    public static func template(withID id: String?) -> StructureTemplate {
        guard let id else { return standard }
        return all.first { $0.id == id } ?? standard
    }

    public func section(withID id: String) -> StructureSection? {
        sections.first { $0.id == id }
    }

    /// The section backed by a legacy act, if this template has one.
    public func section(for act: Act) -> StructureSection? {
        sections.first { $0.act == act }
    }

    /// The section a template beat sits in by default.
    public func defaultSectionID(forTemplateBeat key: String) -> String? {
        sections.first { $0.defaultBeats.contains(key) }?.id
    }

    /// Every template beat key this structure defines, in standard order.
    public var allTemplateBeats: [String] {
        sections.flatMap(\.defaultBeats)
    }
}

public extension Act {
    /// The structure-section id for this act ("act1", "act2", "act3").
    var sectionID: String { "act\(rawValue)" }
}
