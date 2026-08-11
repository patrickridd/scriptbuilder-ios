//
//  RolePickerDetailView.swift
//  FeatureScreenplays
//
//  Single-select role picker grouped by narrative tier (Main / Supporting).
//  Roles are list-only — there is no free-text entry, so the plot
//  hierarchy stays consistent. Picking a role pops straight back to the
//  character screen; clearing or deleting one keeps the picker open so a
//  replacement can be chosen right away. Free-text roles saved earlier still
//  surface (read-only) so nothing a writer already entered disappears.
//

import SwiftUI
import Domain
import DesignSystem

struct RolePickerDetailView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss

    let characterName: String
    let onSelect: (HierarchicalRole?) -> Void

    /// Live selection. Clearing or deleting updates this in place (and saves)
    /// without popping, so the writer can immediately pick a replacement.
    @State private var selection: HierarchicalRole?

    init(
        characterName: String,
        selection: HierarchicalRole?,
        onSelect: @escaping (HierarchicalRole?) -> Void
    ) {
        self.characterName = characterName
        self.onSelect = onSelect
        _selection = State(initialValue: selection)
    }

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
            savedCustomSection
            tierSection(
                IdentityUIStrings.tierMain,
                description: IdentityUIStrings.tierMainDescription,
                entries: IdentityCatalog.mainRoles
            )
            tierSection(
                IdentityUIStrings.tierSupporting,
                description: IdentityUIStrings.tierSupportingDescription,
                entries: IdentityCatalog.supportingRoles
            )
            if selection != nil {
                clearButton
            }
        }
    }

    // MARK: - Tier sections

    private func tierSection(
        _ header: String,
        description: String,
        entries: [IdentityCatalogEntry]
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            tierHeader(header, description: description)
            ForEach(entries) { entry in
                IdentityChoiceCard(
                    name: entry.name,
                    definition: entry.definition,
                    examples: entry.examples,
                    classicalName: entry.classicalName,
                    isSelected: isSelected(entry.slug),
                    onTap: { tap(entry.slug) }
                )
            }
        }
    }

    /// Title and its one-line explanation sit tighter to each other than the
    /// group sits to the section above, so the caption reads as belonging to
    /// the header below it rather than the cards above.
    private func tierHeader(_ header: String, description: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(header)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textMuted)
                .textCase(.uppercase)
            Text(description)
                .font(.footnote)
                .foregroundStyle(palette.textMuted.opacity(0.75))
        }
        .padding(.top, 8)
    }

    private func isSelected(_ slug: String) -> Bool {
        selection?.slug == slug && selection?.isCustom == false
    }

    // MARK: - Saved free-text role (read-only)

    /// Existing free-text roles (saved before roles became list-only, or
    /// migrated from the legacy flat `role` string) stay visible so no work
    /// disappears. They can be kept or replaced, but new ones aren't offered.
    @ViewBuilder
    private var savedCustomSection: some View {
        if let selection, selection.isCustom, let label = selection.customLabel, !label.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text(IdentityUIStrings.savedRoleSection)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
                    .textCase(.uppercase)
                    .padding(.top, 4)
                IdentityChoiceCard(
                    name: label,
                    definition: nil,
                    examples: nil,
                    isSelected: true,
                    onTap: {},
                    onDelete: { clear() }
                )
                Text(IdentityUIStrings.savedRoleHint)
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
            }
        }
    }

    // MARK: - Selection

    private var clearButton: some View {
        Button {
            clear()
        } label: {
            Label(IdentityUIStrings.clearRole, systemImage: "xmark.circle")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(palette.textMuted)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
    }

    /// Tapping the selected role deselects it and keeps the picker open;
    /// tapping any other role selects it and pops back.
    private func tap(_ slug: String) {
        if isSelected(slug) {
            clear()
        } else {
            pick(HierarchicalRole(slug: slug))
        }
    }

    /// Apply the choice and pop back — a role is single-select, so once one is
    /// picked there is nothing left to do here.
    private func pick(_ role: HierarchicalRole) {
        Haptics.selection()
        selection = role
        onSelect(role)
        dismiss()
    }

    /// Clear the role (or delete a saved free-text one) and *stay* on this
    /// screen, so the writer can choose a replacement straight away.
    private func clear() {
        Haptics.selection()
        withAnimation(.easeInOut(duration: 0.2)) { selection = nil }
        onSelect(nil)
    }
}
