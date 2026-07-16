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
        out.title(title.isEmpty ? "Untitled" : title)

        if let author = s.authorName?.trimmingCharacters(in: .whitespacesAndNewlines),
           !author.isEmpty {
            out.centered("Written by \(author)")
        }
        out.field("Logline", s.logLine)
        out.rule()
    }

    private static func appendOverview(_ s: Screenplay, to out: inout DocumentBuilder) {
        var section = DocumentBuilder.Section(title: "Overview")
        section.add("Idea", s.idea)
        section.add("Theme", s.theme)
        section.add("Central Intention", s.centralIntention)
        section.add("Main Obstacle", s.mainObstacle)
        section.add("Notes", s.notes)
        out.section(section)
    }

    private static func appendOutline(_ s: Screenplay, to out: inout DocumentBuilder) {
        var section = DocumentBuilder.Section(title: "Outline")
        section.add(Act.one.title, s.actOneDescription)
        section.add(Act.two.title, s.actTwoDescription)
        section.add(Act.three.title, s.actThreeDescription)
        out.section(section)
    }

    private static func appendCharacters(_ s: Screenplay, to out: inout DocumentBuilder) {
        let people = s.characters.sorted {
            $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending
        }
        guard !people.isEmpty else { return }

        out.header("Characters")
        for person in people {
            out.subheader(displayName(for: person))
            var block = DocumentBuilder.Section(title: nil)
            block.add("Role", person.role ?? "")
            block.add("Intention", person.intention)
            block.add("Why", person.whyIntention)
            block.add("What They Do", person.whatToDo)
            block.add("How They Do It", person.howDoesCharacterDoIt)
            block.add("Obstacles", person.obstacles)
            block.add("Flaws", person.flaws)
            block.add("Intention Fix", person.intentionFix)
            block.add("Need", person.need)
            block.add("How They Change", person.howCharacterChanged)
            block.add("Notes", person.notes)
            out.inlineSection(block)
        }
    }

    private static func appendScenes(_ s: Screenplay, to out: inout DocumentBuilder) {
        let hasAny = Act.allCases.contains { !s.scenes(in: $0).isEmpty }
        guard hasAny else { return }

        out.header("Scenes")
        for act in Act.allCases {
            let scenes = s.scenes(in: act).sorted { $0.sceneNumber < $1.sceneNumber }
            guard !scenes.isEmpty else { continue }
            out.subheader(act.title)
            for scene in scenes {
                out.sceneHeader(scene)
                var block = DocumentBuilder.Section(title: nil)
                block.add("Header", scene.header)
                block.add("Description", scene.sceneDescription)
                block.add("Characters", scene.characters)
                block.add("Dialogue", scene.dialogue)
                block.add("Action", scene.action)
                block.add("Story Progression", scene.howPushesStory)
                block.add("Notes", scene.notes)
                out.inlineSection(block)
            }
        }
    }

    private static func displayName(for person: Character) -> String {
        let name = person.name.trimmingCharacters(in: .whitespacesAndNewlines)
        return name.isEmpty ? "Unnamed Character" : name
    }
}
