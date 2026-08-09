//
//  IdentityChoiceCard.swift
//  FeatureScreenplays
//
//  One selectable choice in an identity picker: name, one-line definition,
//  film examples, selection indicator, and an optional delete action for
//  custom (writer-created) entries.
//

import SwiftUI
import DesignSystem

struct IdentityChoiceCard: View {
    @Environment(\.appPalette) private var palette

    let name: String
    let definition: String?
    let examples: String?
    let isSelected: Bool
    let onTap: () -> Void
    var onDelete: (() -> Void)?

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 12) {
                selectionIndicator
                textStack
                Spacer(minLength: 0)
                deleteButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(border)
        }
        .buttonStyle(PressableScaleStyle())
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    private var selectionIndicator: some View {
        Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
            .font(.title3)
            .foregroundStyle(isSelected ? palette.accent : palette.textMuted.opacity(0.5))
            .padding(.top, 1)
    }

    private var textStack: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(name)
                .font(.body.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .multilineTextAlignment(.leading)
            if let definition, !definition.isEmpty {
                Text(definition)
                    .font(.footnote)
                    .foregroundStyle(palette.textPrimary.opacity(0.75))
                    .multilineTextAlignment(.leading)
            }
            if let examples, !examples.isEmpty {
                Text(examples)
                    .font(.caption)
                    .italic()
                    .foregroundStyle(palette.textMuted)
                    .multilineTextAlignment(.leading)
            }
        }
        .fixedSize(horizontal: false, vertical: true)
    }

    @ViewBuilder
    private var deleteButton: some View {
        if let onDelete {
            Button(action: onDelete) {
                Image(systemName: "trash")
                    .font(.subheadline)
                    .foregroundStyle(.red.opacity(0.8))
                    .padding(6)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Action.delete)
        }
    }

    private var border: some View {
        RoundedRectangle(cornerRadius: 12, style: .continuous)
            .stroke(isSelected ? palette.accent.opacity(0.7) : palette.cardStroke, lineWidth: isSelected ? 1.5 : 1)
    }
}

/// Full selection display for multi-select rows: every chosen trait as a chip,
/// wrapping onto as many lines as it needs beneath the row it belongs to.
struct TraitChipsWrap: View {
    @Environment(\.appPalette) private var palette

    let names: [String]

    var body: some View {
        FlowLayout(spacing: 6, lineSpacing: 6) {
            ForEach(names, id: \.self) { name in
                Text(name)
                    .font(.caption.weight(.medium))
                    .lineLimit(1)
                    .foregroundStyle(palette.accent)
                    .padding(.horizontal, 9)
                    .padding(.vertical, 5)
                    .background(palette.accent.opacity(0.14), in: Capsule())
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(names.joined(separator: ", "))
    }
}

/// Inline preview for multi-select rows: the first two selections as small
/// chips plus a "+N" overflow marker.
struct TraitChipsPreview: View {
    @Environment(\.appPalette) private var palette

    let names: [String]

    var body: some View {
        HStack(spacing: 5) {
            ForEach(Array(names.prefix(2)), id: \.self) { name in
                chip(name)
            }
            if names.count > 2 {
                Text("+\(names.count - 2)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
            }
        }
    }

    private func chip(_ text: String) -> some View {
        Text(text)
            .font(.caption.weight(.medium))
            .lineLimit(1)
            .foregroundStyle(palette.accent)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(palette.accent.opacity(0.12), in: Capsule())
    }
}
