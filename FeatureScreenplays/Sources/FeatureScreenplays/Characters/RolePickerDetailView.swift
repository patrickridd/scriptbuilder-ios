//
//  RolePickerDetailView.swift
//  FeatureScreenplays
//
//  Single-select role picker grouped by narrative tier (Primary / Secondary /
//  Background). Roles are list-only — there is no free-text entry, so the plot
//  hierarchy stays consistent. Picking a role pops straight back to the
//  character screen. Free-text roles saved earlier still surface (read-only) so
//  nothing a writer already entered disappears.
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
            tierSection(IdentityUIStrings.tierPrimary, entries: IdentityCatalog.primaryRoles)
            tierSection(IdentityUIStrings.tierSecondary, entries: IdentityCatalog.secondaryRoles)
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
                    onDelete: { pick(nil) }
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
