//
//  DocumentBuilder.swift
//  FeatureScreenplays
//
//  A tiny helper that accumulates cleanly formatted plain-text sections for the
//  screenplay export. It handles all the fiddly spacing rules so the exporter
//  can stay declarative: only non-empty fields are emitted, headers get
//  consistent underlines, and blank runs never pile up.
//

import Foundation
import Domain

struct DocumentBuilder {

    /// A named block of `Label: value` fields. Empty values are dropped.
    struct Section {
        let title: String?
        private(set) var fields: [(label: String, value: String)] = []

        init(title: String?) { self.title = title }

        mutating func add(_ label: String, _ value: String) {
            let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { return }
            fields.append((label, trimmed))
        }

        var isEmpty: Bool { fields.isEmpty }
    }

    private var lines: [String] = []

    // MARK: - Title page

    mutating func title(_ text: String) {
        lines.append(text.uppercased())
        lines.append("")
    }

    mutating func centered(_ text: String) {
        lines.append(text)
        lines.append("")
    }

    mutating func rule() {
        trimTrailingBlank()
        lines.append("")
        lines.append("──────────────────────────────")
        lines.append("")
    }

    // MARK: - Headers

    mutating func header(_ text: String) {
        trimTrailingBlank()
        if !lines.isEmpty { lines.append("") }
        let upper = text.uppercased()
        lines.append(upper)
        lines.append(String(repeating: "═", count: max(3, upper.count)))
        lines.append("")
    }

    mutating func subheader(_ text: String) {
        trimTrailingBlank()
        if !lines.isEmpty { lines.append("") }
        lines.append(text)
        lines.append(String(repeating: "─", count: max(3, text.count)))
        lines.append("")
    }

    mutating func sceneHeader(_ scene: Scene) {
        trimTrailingBlank()
        if !lines.isEmpty { lines.append("") }
        let title = scene.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let name = title.isEmpty ? "Untitled Scene" : title
        lines.append("• Scene \(scene.sceneNumber): \(name)")
    }

    // MARK: - Fields & sections

    mutating func field(_ label: String, _ value: String) {
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        appendField(label: label, value: trimmed)
        lines.append("")
    }

    /// A section with its own header line (used for Overview / Outline).
    mutating func section(_ section: Section) {
        guard !section.isEmpty else { return }
        if let title = section.title { header(title) }
        for field in section.fields {
            appendField(label: field.label, value: field.value)
            lines.append("")
        }
    }

    /// A section without its own header — fields are appended under the
    /// most recent subheader (used for each character / scene).
    mutating func inlineSection(_ section: Section) {
        guard !section.isEmpty else { return }
        for field in section.fields {
            appendField(label: field.label, value: field.value)
        }
        lines.append("")
    }

    // MARK: - Output

    mutating func finished() -> String {
        trimTrailingBlank()
        return lines.joined(separator: "\n")
    }

    // MARK: - Private

    private mutating func appendField(label: String, value: String) {
        if value.contains("\n") {
            lines.append("\(label):")
            for line in value.components(separatedBy: "\n") {
                lines.append("    \(line)")
            }
        } else {
            lines.append("\(label): \(value)")
        }
    }

    private mutating func trimTrailingBlank() {
        while let last = lines.last, last.isEmpty {
            lines.removeLast()
        }
    }
}
