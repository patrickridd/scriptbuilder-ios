//
//  Screenplay+BeatLayout.swift
//  Domain
//
//  The single place that answers "which beats are in this section, in what
//  order, and what do they say?". Outline, progress, "Next up" and export
//  should all read through here instead of touching Act1/2/3 directly.
//

import Foundation

/// A beat as every screen sees it, whatever kind it is or wherever it lives.
public struct OutlineBeat: Equatable, Sendable, Identifiable {
    public let reference: BeatReference
    public let title: String
    public let subtitle: String
    public let text: String
    public let isDisabled: Bool
    /// The section this beat belongs to in the standard order ("Usually in…").
    public let homeSectionID: String?

    public var id: String { reference.storageKey }
    public var isCustom: Bool { reference.isCustom }
    public var isFilled: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}

public extension Screenplay {

    var structureTemplate: StructureTemplate {
        StructureTemplate.template(withID: structureTemplateID)
    }

    // MARK: - Layout

    /// The standard order: each section's template beats, with custom beats
    /// placed by their stored anchors.
    var standardBeatLayout: BeatLayout {
        var sections: [String: [BeatReference]] = [:]
        for section in structureTemplate.sections {
            guard let act = section.act else {
                sections[section.id] = section.defaultBeats.map(BeatReference.template)
                continue
            }
            sections[section.id] = CustomBeat.outline(for: act, customBeats: customBeats(in: act))
                .map { slot in
                    switch slot {
                    case .template(let field): return BeatReference(field)
                    case .custom(let beat):    return .custom(beat.id)
                    }
                }
        }
        return BeatLayout(sections: sections)
    }

    /// The order to display. Uses the saved layout when there is one, repaired
    /// so every beat appears exactly once: deleted or duplicate references are
    /// dropped, and beats missing from it (a new template beat, a custom beat
    /// added on an older app version) slot into their standard place.
    var beatLayout: BeatLayout {
        guard let saved = savedBeatLayout else { return standardBeatLayout }
        return reconciled(saved, against: standardBeatLayout)
    }

    /// Ordered beats for one section, resolved through the shared lookup.
    func outlineBeats(inSection sectionID: String) -> [OutlineBeat] {
        beatLayout.beats(in: sectionID).compactMap { outlineBeat(for: $0) }
    }

    /// Ordered beats for the section backed by `act`.
    func outlineBeats(in act: Act) -> [OutlineBeat] {
        guard let section = structureTemplate.section(for: act) else { return [] }
        return outlineBeats(inSection: section.id)
    }

    // MARK: - Lookup

    /// Resolves a reference to its content, or `nil` if the beat no longer
    /// exists in this screenplay.
    func outlineBeat(for reference: BeatReference) -> OutlineBeat? {
        switch reference {
        case .template(let key):
            // Feature-template beats live as fields on Act1/2/3. Other
            // templates will resolve their own keys here.
            guard let field = ActBeatField(rawValue: key),
                  structureTemplate.allTemplateBeats.contains(key) else { return nil }
            return OutlineBeat(
                reference: reference,
                title: field.title,
                subtitle: field.subtitle,
                text: field.value(in: self),
                isDisabled: isBeatDisabled(field),
                homeSectionID: structureTemplate.defaultSectionID(forTemplateBeat: key)
            )
        case .custom(let id):
            guard let match = customBeat(withID: id) else { return nil }
            return OutlineBeat(
                reference: reference,
                title: match.beat.title,
                subtitle: match.beat.subtitle,
                text: match.beat.text,
                isDisabled: false,
                homeSectionID: structureTemplate.section(for: match.act)?.id
            )
        }
    }

    /// Finds a custom beat in whichever act stores it.
    func customBeat(withID id: String) -> (beat: CustomBeat, act: Act)? {
        for act in Act.allCases {
            if let beat = customBeats(in: act).first(where: { $0.id == id }) {
                return (beat, act)
            }
        }
        return nil
    }

    // MARK: - Reconciliation

    private func reconciled(_ saved: BeatLayout, against standard: BeatLayout) -> BeatLayout {
        let known = Set(standard.sections.values.flatMap { $0 })
        var seen = Set<BeatReference>()
        var result: [String: [BeatReference]] = [:]

        // Keep the writer's order for every beat that still exists, once.
        for section in structureTemplate.sections {
            result[section.id] = saved.beats(in: section.id).filter { reference in
                guard known.contains(reference), !seen.contains(reference) else { return false }
                seen.insert(reference)
                return true
            }
        }

        // Slot anything missing in after its standard predecessor.
        for section in structureTemplate.sections {
            let standardOrder = standard.beats(in: section.id)
            for (index, reference) in standardOrder.enumerated() where !seen.contains(reference) {
                var beats = result[section.id] ?? []
                let predecessor = standardOrder[..<index].last { beats.contains($0) }
                if let predecessor, let position = beats.firstIndex(of: predecessor) {
                    beats.insert(reference, at: position + 1)
                } else if index == 0 {
                    beats.insert(reference, at: 0)
                } else {
                    beats.append(reference)
                }
                result[section.id] = beats
                seen.insert(reference)
            }
        }
        return BeatLayout(sections: result)
    }
}
