import SwiftUI
import Domain
import DesignSystem

/// The full arc form for a single character: basic info (name + role) plus the
/// ten dramatic-arc fields, each an auto-growing `ExpandableTextField`. All
/// editing logic (draft, role resolution, debounced autosave, flush-on-exit)
/// lives in `CharacterDetailViewModel`; this view is purely declarative.
struct CharacterDetailView: View {
    @Environment(\.appPalette) private var palette
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: CharacterDetailViewModel
    @State private var showDeleteConfirm = false
    @FocusState private var nameFocused: Bool

    init(character: Character, viewModel: CharactersViewModel) {
        _viewModel = State(initialValue: CharacterDetailViewModel(character: character, viewModel: viewModel))
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
                    basicInfoCard
                    arcFields
                    deleteButton
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if viewModel.shouldFocusName { nameFocused = true }
        }
        .onDisappear { Task { await viewModel.flush() } }
        .alert(L10n.CharacterUI.deleteTitle, isPresented: $showDeleteConfirm) {
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

    private var basicInfoCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            fieldLabel(L10n.CharacterUI.fieldName, systemImage: "person.text.rectangle")
            TextField(L10n.CharacterUI.fieldName, text: $viewModel.draft.name)
                .font(.body)
                .focused($nameFocused)
                .foregroundStyle(palette.textPrimary)
                .tint(palette.accent)
                .padding(12)
                .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))

            fieldLabel(L10n.CharacterUI.fieldRole, systemImage: "theatermasks")
            rolePicker
            if viewModel.role == .custom {
                TextField("Custom role", text: $viewModel.customRole)
                    .font(.body)
                    .foregroundStyle(palette.textPrimary)
                    .tint(palette.accent)
                    .padding(12)
                    .background(palette.cardSurface, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                    .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
            }
        }
        .padding(16)
        .background(palette.cardSurface.opacity(0.6), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 18, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
    }

    private var rolePicker: some View {
        Menu {
            ForEach(CharacterRole.allCases) { option in
                Button {
                    viewModel.role = option
                } label: {
                    Label(option.displayName, systemImage: option.systemImage)
                }
            }
        } label: {
            HStack {
                Label(viewModel.role.displayName, systemImage: viewModel.role.systemImage)
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

    private var arcFields: some View {
        VStack(spacing: 14) {
            ForEach(CharacterArcField.allCases) { field in
                ExpandableTextField(
                    title: field.title,
                    prompt: field.prompt,
                    systemImage: field.systemImage,
                    text: binding(for: field)
                )
            }
        }
    }

    // MARK: - Delete

    private var deleteButton: some View {
        Button(role: .destructive) {
            showDeleteConfirm = true
        } label: {
            Label(L10n.CharacterUI.deleteButton, systemImage: "trash")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.red.opacity(0.85))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
        }
        .buttonStyle(.plain)
        .padding(.top, 16)
    }

    /// Return the real state-backed binding for a field. Hand-made
    /// `Binding(get:set:)` closures go stale inside `fullScreenCover` and
    /// silently drop writes — direct `$model.draft.<field>` bindings are tracked
    /// by SwiftUI/Observation and stay live everywhere.
    private func binding(for field: CharacterArcField) -> Binding<String> {
        switch field {
        case .intention: return $viewModel.draft.intention
        case .whyIntention: return $viewModel.draft.whyIntention
        case .whatToDo: return $viewModel.draft.whatToDo
        case .howDoesCharacterDoIt: return $viewModel.draft.howDoesCharacterDoIt
        case .obstacles: return $viewModel.draft.obstacles
        case .flaws: return $viewModel.draft.flaws
        case .intentionFix: return $viewModel.draft.intentionFix
        case .need: return $viewModel.draft.need
        case .howCharacterChanged: return $viewModel.draft.howCharacterChanged
        case .notes: return $viewModel.draft.notes
        }
    }

    private func fieldLabel(_ text: String, systemImage: String) -> some View {
        Label(text, systemImage: systemImage)
            .font(.subheadline.weight(.semibold))
            .foregroundStyle(palette.textPrimary)
    }
}
