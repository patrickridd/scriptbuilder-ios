import SwiftUI
import Domain
import DesignSystem

/// The ten dramatic-arc fields for a single character, pushed from the
/// character detail screen. It shares the caller's `CharacterDetailViewModel`
/// so edits flow into the same draft and the existing debounced autosave /
/// flush-on-exit behaviour keeps working unchanged.
struct CharacterArcView: View {
    @Environment(\.appPalette) private var palette
    @Bindable var viewModel: CharacterDetailViewModel
    @State private var focusRequest: AnyHashable?

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        arcHeader(proxy: proxy)
                        if viewModel.draft.arcNotApplicable { waivedNote }
                        arcFields
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(viewModel.navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .onDisappear { Task { await viewModel.flush() } }
    }

    // MARK: - Header

    private func arcHeader(proxy: ScrollViewProxy) -> some View {
        ProgressHeader(
            title: L10n.CharacterUI.arcTitle,
            systemImage: "chart.line.uptrend.xyaxis",
            filled: viewModel.arcFilledCount,
            total: viewModel.arcTotalCount,
            completeText: viewModel.arcCompleteText,
            nextFieldTitle: viewModel.nextArcField?.title,
            onNextTapped: {
                guard let field = viewModel.nextArcField else { return }
                focusRequest = AnyHashable(field)
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(field, anchor: .top)
                }
            }
        )
    }

    // MARK: - Not applicable

    /// A quiet reminder that the writer already decided this character has no
    /// arc. The switch itself lives in Character Settings, out of the way.
    private var waivedNote: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "checkmark.seal.fill")
                .font(.subheadline)
                .foregroundStyle(palette.accent)
            VStack(alignment: .leading, spacing: 3) {
                Text(IdentityUIStrings.arcNotApplicableTitle)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textPrimary)
                Text(IdentityUIStrings.arcNotApplicableNote)
                    .font(.caption)
                    .foregroundStyle(palette.textMuted)
            }
            Spacer(minLength: 0)
        }
        .padding(14)
        .background(palette.accent.opacity(0.10), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(palette.cardStroke, lineWidth: 1))
        .transition(.opacity)
    }

    // MARK: - Fields

    private var arcFields: some View {
        VStack(spacing: 14) {
            ForEach(visibleFields) { field in
                ExpandableTextField(
                    title: field.title,
                    prompt: field.prompt,
                    systemImage: field.systemImage,
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(field),
                    text: binding(for: field)
                )
                .id(field)
            }
        }
    }

    /// With the arc waived only the free-form notes remain — everything else
    /// would be asking questions the story has already answered with "none".
    private var visibleFields: [CharacterArcField] {
        viewModel.draft.arcNotApplicable ? [.notes] : CharacterArcField.allCases
    }

    /// Return the real state-backed binding for a field. Hand-made
    /// `Binding(get:set:)` closures go stale inside `fullScreenCover` and
    /// silently drop writes — direct `$viewModel.draft.<field>` bindings are
    /// tracked by Observation and stay live everywhere.
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
}
