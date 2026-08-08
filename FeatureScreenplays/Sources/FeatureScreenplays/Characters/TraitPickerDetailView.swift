//
//  TraitPickerDetailView.swift
//  FeatureScreenplays
//
//  Generic multi-select picker shared by Archetype and Story Function.
//  Stock choices render as cards (name + definition + film examples); custom
//  entries are first-class selected cards with a delete action. Stays open
//  across selections; changes write straight through the binding.
//

import SwiftUI
import Domain
import DesignSystem

struct TraitPickerDetailView: View {
    @Environment(\.appPalette) private var palette

    let title: String
    let characterName: String
    let intro: IdentitySectionIntro
    let catalog: [IdentityCatalogEntry]
    let nudge: String
    @Binding var boundSelection: [IdentityTrait]

    /// Local mirror of the binding so taps repaint immediately, independent of
    /// how the owning view model propagates observation changes.
    @State private var selection: [IdentityTrait]
    @State private var customText = ""
    @FocusState private var customFocused: Bool

    private let nudgeThreshold = 5

    init(
        title: String,
        characterName: String,
        intro: IdentitySectionIntro,
        catalog: [IdentityCatalogEntry],
        nudge: String,
        selection: Binding<[IdentityTrait]>
    ) {
        self.title = title
        self.characterName = characterName
        self.intro = intro
        self.catalog = catalog
        self.nudge = nudge
        self._boundSelection = selection
        self._selection = State(initialValue: selection.wrappedValue)
    }

    /// Applies a mutation to the local copy (animated) and writes it through.
    private func update(_ mutate: (inout [IdentityTrait]) -> Void) {
        var updated = selection
        mutate(&updated)
        guard updated != selection else { return }
        withAnimation(.easeInOut(duration: 0.18)) {
            selection = updated
        }
        boundSelection = updated
    }

    var body: some View {
        ZStack {
            AppBackground()
            GeometryReader { geo in
                ScrollView(.vertical) {
                    VStack(alignment: .leading, spacing: 14) {
                        IdentitySectionHeader(intro: intro)
                        if selection.count >= nudgeThreshold {
                            nudgeFootnote
                        }
                        stockCards
                        customSection
                    }
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

    // MARK: - Stock choices

    private var stockCards: some View {
        VStack(spacing: 10) {
            ForEach(catalog) { entry in
                IdentityChoiceCard(
                    name: entry.name,
                    definition: entry.definition,
                    examples: entry.examples,
                    isSelected: isStockSelected(entry.slug),
                    onTap: { toggleStock(entry.slug) }
                )
            }
        }
    }

    private func isStockSelected(_ slug: String) -> Bool {
        selection.contains { $0.slug == slug && !$0.isCustom }
    }

    private func toggleStock(_ slug: String) {
        Haptics.selection()
        update { traits in
            if let index = traits.firstIndex(where: { $0.slug == slug && !$0.isCustom }) {
                traits.remove(at: index)
            } else {
                traits.append(.stock(slug))
            }
        }
    }

    // MARK: - Custom entries

    private var customTraits: [IdentityTrait] {
        selection.filter(\.isCustom)
    }

    private var customSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(IdentityUIStrings.customSection)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.top, 8)
            ForEach(customTraits, id: \.self) { trait in
                IdentityChoiceCard(
                    name: trait.customLabel ?? "",
                    definition: nil,
                    examples: nil,
                    isSelected: true,
                    onTap: { removeCustom(trait) },
                    onDelete: { removeCustom(trait) }
                )
            }
            customInputField
        }
    }

    private var customInputField: some View {
        HStack(spacing: 8) {
            TextField(IdentityUIStrings.customTraitPlaceholder, text: $customText)
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
        let alreadyExists = customTraits.contains {
            ($0.customLabel ?? "").caseInsensitiveCompare(trimmed) == .orderedSame
        }
        if !alreadyExists {
            update { $0.append(.custom(trimmed)) }
            Haptics.success()
        }
        customText = ""
    }

    private func removeCustom(_ trait: IdentityTrait) {
        Haptics.selection()
        update { $0.removeAll { $0 == trait } }
    }

    // MARK: - Soft nudge

    private var nudgeFootnote: some View {
        Label(nudge, systemImage: "lightbulb")
            .font(.footnote)
            .foregroundStyle(palette.textMuted)
            .padding(.horizontal, 4)
    }
}
