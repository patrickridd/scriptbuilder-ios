import SwiftUI
import Domain
import DesignSystem

/// Per-character preferences that shape how the arc form behaves — kept off
/// the writing surfaces so the arc screen stays about the story, not options.
/// Also home to the character's name and the destructive delete action.
struct CharacterSettingsView: View {
    @Environment(\.appPalette) private var palette
    @Bindable var viewModel: CharacterDetailViewModel
    /// Called after the writer confirms deletion, so the parent screen can pop
    /// back to the cast list instead of lingering on a removed character.
    var onDelete: () -> Void

    @State private var showDeleteConfirm = false
    @FocusState private var nameFocused: Bool

    private let corner = RoundedRectangle(cornerRadius: 16, style: .continuous)

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    section(IdentityUIStrings.settingsNameSection,
                            footer: IdentityUIStrings.settingsNameFooter) { nameCard }
                    section(IdentityUIStrings.settingsArcSection,
                            footer: IdentityUIStrings.settingsFooter) { arcCard }
                    section(IdentityUIStrings.settingsDangerSection,
                            footer: IdentityUIStrings.settingsDeleteFooter) { deleteCard }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(IdentityUIStrings.settingsTitle)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button(IdentityUIStrings.nameFieldDone) { nameFocused = false }
                    .font(.body.weight(.semibold))
            }
        }
        .onDisappear { Task { await viewModel.flush() } }
        .deleteDialog(
            isPresented: $showDeleteConfirm,
            title: L10n.CharacterUI.deleteTitle,
            message: viewModel.deleteConfirmMessage,
            deleteTitle: L10n.Action.delete,
            cancelTitle: L10n.Action.cancel
        ) {
            onDelete()
        }
    }

    // MARK: - Building blocks

    @ViewBuilder
    private func section<Content: View>(
        _ title: String,
        footer: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .padding(.leading, 4)
            content()
            Text(footer)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
                .padding(.horizontal, 4)
        }
    }

    private func card<Content: View>(@ViewBuilder content: () -> Content) -> some View {
        content()
            .padding(14)
            .background(palette.cardSurface, in: corner)
            .overlay(corner.stroke(palette.cardStroke, lineWidth: 1))
    }

    // MARK: - Name

    private var nameCard: some View {
        card {
            TextField(IdentityUIStrings.nameFieldPrompt, text: $viewModel.draft.name)
                .font(.title3.weight(.semibold))
                .foregroundStyle(palette.textPrimary)
                .tint(palette.accent)
                .textInputAutocapitalization(.words)
                .autocorrectionDisabled()
                .submitLabel(.done)
                .focused($nameFocused)
                .accessibilityLabel(IdentityUIStrings.nameFieldLabel)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    // MARK: - Arc

    /// Lets the writer declare that this character genuinely has no arc — an
    /// iceberg wants nothing — and have that count as a finished decision.
    private var arcCard: some View {
        card {
            VStack(alignment: .leading, spacing: 8) {
                Toggle(isOn: notApplicableBinding) {
                    VStack(alignment: .leading, spacing: 3) {
                        Text(IdentityUIStrings.arcNotApplicableTitle)
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(palette.textPrimary)
                        Text(IdentityUIStrings.arcNotApplicableSubtitle)
                            .font(.caption)
                            .foregroundStyle(palette.textMuted)
                    }
                }
                .tint(palette.accent)
                if viewModel.draft.arcNotApplicable {
                    Text(IdentityUIStrings.arcNotApplicableNote)
                        .font(.caption2)
                        .foregroundStyle(palette.textMuted)
                }
            }
        }
    }

    private var notApplicableBinding: Binding<Bool> {
        Binding(
            get: { viewModel.draft.arcNotApplicable },
            set: { newValue in
                Haptics.selection()
                withAnimation(.easeInOut(duration: 0.25)) {
                    viewModel.draft.arcNotApplicable = newValue
                }
            }
        )
    }

    // MARK: - Danger zone

    private var deleteCard: some View {
        Button {
            nameFocused = false
            showDeleteConfirm = true
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "trash.fill")
                Text(IdentityUIStrings.settingsDeleteAction)
                    .font(.subheadline.weight(.semibold))
                Spacer(minLength: 0)
            }
            .foregroundStyle(Color.red)
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.red.opacity(0.12), in: corner)
            .overlay(corner.stroke(Color.red.opacity(0.35), lineWidth: 1))
        }
        .buttonStyle(PressableScaleStyle())
    }
}
