import SwiftUI
import Domain
import DesignSystem

/// The full editor for a single scene: a metadata card (Act picker, Scene #,
/// Heading) plus the six free-form sections, each an auto-growing
/// `ExpandableTextField`. All editing logic (draft, act relocation, scene-number
/// cascade, debounced autosave, flush-on-exit) lives in `SceneDetailViewModel`;
/// this view is purely declarative.
struct SceneDetailView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: SceneDetailViewModel
    @State private var showDeleteConfirm = false
    @FocusState private var titleFocused: Bool

    init(scene: Domain.Scene, act: Act, viewModel: ScenesViewModel) {
        _viewModel = State(initialValue: SceneDetailViewModel(scene: scene, act: act, viewModel: viewModel))
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    metadataCard
                    sceneFields
                    deleteButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.shouldFocusTitle { titleFocused = true }
        }
        .onDisappear { Task { await viewModel.flush() } }
        .alert(L10n.SceneUI.deleteTitle, isPresented: $showDeleteConfirm) {
            Button(L10n.Action.delete, role: .destructive) {
                Haptics.warning()
                viewModel.requestDelete()
                dismiss()
            }
            Button(L10n.Action.cancel, role: .cancel) { }
        } message: {
            Text(viewModel.deleteConfirmMessage)
        }
    }

    // MARK: - Metadata

    private var metadataCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            fieldLabel(L10n.SceneUI.fieldTitle, systemImage: "textformat")
            titleField
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    fieldLabel(L10n.SceneUI.fieldAct, systemImage: "square.stack.3d.up")
                    actPicker
                }
                VStack(alignment: .leading, spacing: 8) {
                    fieldLabel(L10n.SceneUI.fieldNumber, systemImage: "number")
                    sceneNumberField
                }
                .frame(width: 96)
            }
            fieldLabel(L10n.SceneUI.fieldHeading, systemImage: "film")
            headingField
        }
        .padding(16)
        .background(palette.cardSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var titleField: some View {
        TextField("Scene title", text: $viewModel.draft.title)
            .font(.body)
            .focused($titleFocused)
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var headingField: some View {
        TextField("EXT. APARTMENT - NIGHT", text: $viewModel.draft.header)
            .font(.body.monospaced())
            .textInputAutocapitalization(.characters)
            .autocorrectionDisabled()
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var sceneNumberField: some View {
        TextField("1", text: $viewModel.sceneNumberText)
            .font(.body.weight(.semibold))
            .keyboardType(.numberPad)
            .multilineTextAlignment(.center)
            .foregroundStyle(palette.textPrimary)
            .tint(palette.accent)
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var actPicker: some View {
        Menu {
            ForEach(Act.allCases) { option in
                Button {
                    viewModel.act = option
                } label: {
                    Label(option.title, systemImage: "square.stack.3d.up")
                }
            }
        } label: {
            HStack {
                Text(viewModel.act.title)
                    .font(.body.weight(.medium))
                    .foregroundStyle(palette.textPrimary)
                Spacer()
                Image(systemName: "chevron.up.chevron.down")
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
            }
            .padding(12)
            .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label(L10n.SceneUI.deleteButton, systemImage: "trash")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
    }

    // MARK: - Free-form sections

    private var sceneFields: some View {
        VStack(spacing: 14) {
            ForEach(SceneField.allCases) { field in
                ExpandableTextField(
                    title: field.title,
                    prompt: field.prompt,
                    systemImage: field.systemImage,
                    text: binding(for: field)
                )
            }
        }
    }

    /// Real state-backed bindings — hand-made `Binding(get:set:)` closures go
    /// stale inside `fullScreenCover` and drop writes.
    private func binding(for field: SceneField) -> Binding<String> {
        switch field {
        case .sceneDescription: return $viewModel.draft.sceneDescription
        case .characters: return $viewModel.draft.characters
        case .dialogue: return $viewModel.draft.dialogue
        case .action: return $viewModel.draft.action
        case .howPushesStory: return $viewModel.draft.howPushesStory
        case .notes: return $viewModel.draft.notes
        }
    }

    private func fieldLabel(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
    }
}
