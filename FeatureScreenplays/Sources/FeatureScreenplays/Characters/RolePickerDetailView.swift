//
//  RolePickerDetailView.swift
//  FeatureScreenplays
//
//  Single-select role picker grouped by narrative tier (Primary / Secondary /
//  Background). Picking any role — stock or custom — pops straight back to the
//  character screen. Legacy free-text roles surface as a selected custom card.
//

import SwiftUI
import Domain
import DesignSystem

struct RolePickerDetailView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss

    let characterName: String
    let selection: HierarchicalRole?
    let onSelect: (HierarchicalRole?) -> Void

    @State private var customText = ""
    @FocusState private var customFocused: Bool

    var body: some View {
        ZStack {
            AppBackground()
            GeometryReader { geo in
                ScrollView(.vertical) {
                    content
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(width: geo.size.width, alignment: .leading)
                }
                .scrollBounceBehavior(.basedOnSize, axes: .horizontal)
            }
        }
        .navigationTitle(characterName)
        .navigationBarTitleDisplayMode(.inline)
        .pageTurnDisabled()
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 14) {
            IdentitySectionHeader(intro: .role)
            tierSection(IdentityUIStrings.tierPrimary, entries: IdentityCatalog.primaryRoles)
            tierSection(IdentityUIStrings.tierSecondary, entries: IdentityCatalog.secondaryRoles)
            customSection
            if selection != nil {
                clearButton
            }
        }
    }

    // MARK: - Tier sections

    private func tierSection(_ header: String, entries: [IdentityCatalogEntry]) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(header)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
                .padding(.top, 4)
            ForEach(entries) { entry in
                IdentityChoiceCard(
                    name: entry.name,
                    definition: entry.definition,
                    examples: entry.examples,
                    isSelected: isSelected(entry.slug),
                    onTap: { pick(HierarchicalRole(slug: entry.slug)) }
                )
            }
        }
    }

    private func isSelected(_ slug: String) -> Bool {
        selection?.slug == slug && selection?.isCustom == false
    }

    // MARK: - Custom role

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(IdentityUIStrings.customSection)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
                .padding(.top, 4)
            if let selection, selection.isCustom, let label = selection.customLabel, !label.isEmpty {
                IdentityChoiceCard(
                    name: label,
                    definition: nil,
                    examples: nil,
                    isSelected: true,
                    onTap: {},
                    onDelete: { pick(nil) }
                )
            }
            customInputField
        }
    }

    private var customInputField: some View {
        HStack(spacing: 8) {
            TextField(IdentityUIStrings.customRolePlaceholder, text: $customText)
                .font(.body)
                .focused($customFocused)
                .foregroundStyle(palette.textPrimary)
                .tint(palette.accent)
                .submitLabel(.done)
                .onSubmit(addCustom)
            Button(action: addCustom) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                    .foregroundStyle(canAddCustom ? palette.accent : palette.textMuted.opacity(0.4))
            }
            .buttonStyle(.plain)
            .disabled(!canAddCustom)
            .accessibilityLabel(IdentityUIStrings.addCustom)
        }
        .padding(12)
        .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var canAddCustom: Bool {
        !customText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func addCustom() {
        let trimmed = customText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        pick(.custom(trimmed))
    }

    // MARK: - Selection

    private var clearButton: some View {
        Button {
            pick(nil)
        } label: {
            Label(IdentityUIStrings.clearRole, systemImage: "xmark.circle")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    /// Apply the choice and pop back (single-select behaviour). Clearing the
    /// role also pops — the row on the character screen reflects it instantly.
    private func pick(_ role: HierarchicalRole?) {
        Haptics.selection()
        onSelect(role)
        dismiss()
    }
}
