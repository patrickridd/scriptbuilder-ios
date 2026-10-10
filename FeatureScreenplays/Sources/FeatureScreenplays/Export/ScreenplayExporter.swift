//
//  ScreenplayExporter.swift
//  FeatureScreenplays
//
//  Turns a `Screenplay` into a cleanly formatted, human-readable document for
//  sharing. Unlike the legacy "raw dump", this exporter:
//    • Uses clear section headers and consistent spacing.
//    • Skips empty fields entirely so shared scripts stay tidy.
//    • Groups scenes by act in reading order.
//
//  The output is plain text (great for Messages, Mail, Notes, Files). A PDF
//  wrapper lives alongside in `ScreenplayPDFRenderer`.
//

import Foundation
import Domain

public enum ScreenplayExporter {

    /// Builds the full, formatted plain-text representation of a screenplay.
    public static func plainText(for screenplay: Screenplay) -> String {
        var out = DocumentBuilder()

        appendTitlePage(screenplay, to: &out)
        appendOverview(screenplay, to: &out)
        appendOutline(screenplay, to: &out)
        appendCharacters(screenplay, to: &out)
        appendScenes(screenplay, to: &out)

        return out.finished()
    }

    /// Writes the plain-text export to a temporary `.txt` file and returns its
    /// URL, so it shares as a proper attachment (with a nice filename) rather
    /// than as inline text. Returns `nil` if the file could not be written.
    public static func writePlainTextFile(for screenplay: Screenplay) -> URL? {
        let text = plainText(for: screenplay)
        let stem = fileNameStem(for: screenplay)
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("\(stem).txt")
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            return url
        } catch {
            return nil
        }
    }

    /// A filesystem-safe file name stem (no extension), derived from the title.
    public static func fileNameStem(for screenplay: Screenplay) -> String {
        let base = screenplay.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let stem = base.isEmpty ? "Screenplay" : base
        let allowed = CharacterSet.alphanumerics.union(.init(charactersIn: " -_"))
        let cleaned = String(stem.unicodeScalars.filter { allowed.contains($0) })
        return cleaned.isEmpty ? "Screenplay" : cleaned
    }

    // MARK: - Sections

    private static func appendTitlePage(_ s: Screenplay, to out: inout DocumentBuilder) {
        let title = s.title.trimmingCharacters(in: .whitespacesAndNewlines)
        out.title(title.isEmpty ? L10n.Export.untitled : title)

        if let author = s.authorName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !author.isEmpty {
            out.centered(L10n.Export.writtenBy(author))
        }
        out.field(L10n.Export.logline, s.logLine)
        out.rule()
    }

    private static func appendOverview(_ s: Screenplay, to out: inout DocumentBuilder) {
        var section = DocumentBuilder.Section(title: L10n.Export.overview)
        section.add(L10n.Export.idea, s.idea)
        section.add(L10n.Export.theme, s.theme)
        section.add(L10n.Export.centralIntention, s.centralIntention)
        section.add(L10n.Export.mainObstacle, s.mainObstacle)
        section.add(L10n.Export.notes, s.notes)
        out.section(section)
    }

    /// Per act: the overall description, then every beat — template and
    /// custom — in the writer's arrangement (`Screenplay.outlineBeats(in:)` is
    /// the one ordering source). Custom beats are labelled like template beats.
    private static func appendOutline(_ screenplay: Screenplay, to out: inout DocumentBuilder) {
        let acts = Act.allCases.map { act in (act, outlineBlock(for: act, in: screenplay)) }
            .filter { !$0.1.isEmpty }
        guard !acts.isEmpty else { return }

        out.header(L10n.Export.outline)
        for (act, block) in acts {
            out.subheader(act.title)
            // Beats are prose, so each gets breathing room (`field` adds a
            // blank line) rather than the compact `inlineSection` layout.
            for field in block.fields { out.field(field.label, field.value) }
        }
    }

    private static func outlineBlock(for act: Act, in screenplay: Screenplay) -> DocumentBuilder.Section {
        var block = DocumentBuilder.Section(title: nil)
        block.add(L10n.Outline.overallDescription, actDescription(act, in: screenplay))
        let beats = screenplay.outlineBeats(in: act).filter { !$0.isDisabled }
        for beat in beats {
            let title = beat.title.trimmingCharacters(in: .whitespacesAndNewlines)
            let label = beat.isCustom && title.isEmpty ? L10n.CustomBeatCopy.untitled : title
            block.add(label, beat.text)
        }
        return block
    }

    private static func actDescription(_ act: Act, in screenplay: Screenplay) -> String {
        switch act {
        case .one:   return screenplay.actOneDescription
        case .two:   return screenplay.actTwoDescription
        case .three: return screenplay.actThreeDescription
        }
    }

    private static func appendCharacters(_ s: Screenplay, to out: inout DocumentBuilder) {
        let people = s.characters.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        guard !people.isEmpty else { return }

        out.header(L10n.Export.characters)
        for person in people {
            out.subheader(displayName(for: person))
            var block = DocumentBuilder.Section(title: nil)
            block.add(L10n.Export.role, person.role ?? "")
            appendArc(of: person, to: &block)
            block.add(L10n.Export.notes, person.notes)
            out.inlineSection(block)
        }
    }

    /// The arc in the writer's order (`Character.activeArcSlots`): stock
    /// questions that are switched on plus custom questions. A "no arc"
    /// character exports only Notes, matching the Arc screen. Notes is
    /// always last and is added by the caller.
    private static func appendArc(of person: Character, to block: inout DocumentBuilder.Section) {
        guard !person.arcNotApplicable else { return }
        for slot in person.activeArcSlots {
            switch slot {
            case .template(let question):
                block.add(exportLabel(for: question), person.text(for: question))
            case .custom(let question):
                let title = question.title.trimmingCharacters(in: .whitespacesAndNewlines)
                block.add(title.isEmpty ? L10n.ArcQuestionCopy.untitled : title, question.text)
            }
        }
    }

    private static func exportLabel(for question: ArcTemplateQuestion) -> String {
        switch question {
        case .intention: return L10n.Export.intention
        case .whyIntention: return L10n.Export.why
        case .whatToDo: return L10n.Export.whatTheyDo
        case .howDoesCharacterDoIt: return L10n.Export.howTheyDoIt
        case .obstacles: return L10n.Export.obstacles
        case .flaws: return L10n.Export.flaws
        case .intentionFix: return L10n.Export.intentionFix
        case .need: return L10n.Export.need
        case .howCharacterChanged: return L10n.Export.howTheyChange
        }
    }

    private static func appendScenes(_ s: Screenplay, to out: inout DocumentBuilder) {
        let hasAny = Act.allCases.contains { !s.scenes(in: $0).isEmpty }
        guard hasAny else { return }

        out.header(L10n.Export.scenes)
        for act in Act.allCases {
            let scenes = s.scenes(in: act).sorted { $0.sceneNumber < $1.sceneNumber }
            guard !scenes.isEmpty else { continue }
            out.subheader(act.title)
            for scene in scenes {
                out.sceneHeader(scene)
                var block = DocumentBuilder.Section(title: nil)
                block.add(L10n.Export.header, scene.header)
                block.add(L10n.Export.description, scene.sceneDescription)
                block.add(L10n.Export.characters, scene.characters)
                block.add(L10n.Export.dialogue, scene.dialogue)
                block.add(L10n.Export.action, scene.action)
                block.add(L10n.Export.storyProgression, scene.howPushesStory)
                block.add(L10n.Export.notes, scene.notes)
                out.inlineSection(block)
            }
        }
    }

    private static func displayName(for person: Character) -> String {
        let name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? L10n.Export.unnamedCharacter : name
    }
}
