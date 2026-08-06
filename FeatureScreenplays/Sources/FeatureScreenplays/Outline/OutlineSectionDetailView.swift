import SwiftUI
import Domain
import DesignSystem

/// The editor for one outline section. For the Idea section it shows the six
/// idea fields; for an act it shows the act's "overall description" plus that
/// act's narrative beats, headed by an ⓘ info popover. Every field is an
/// auto-growing `ExpandableTextField` bound through `OutlineViewModel`, which
/// autosaves each edit non-destructively. Purely declarative.
struct OutlineSectionDetailView: View {
    @Environment(\.appPalette) private var palette
    @Bindable var viewModel: OutlineViewModel
    private let section: OutlineSection
    @State private var showBeatsInfo = false
    @State private var focusRequest: AnyHashable?

    init(section: OutlineSection, viewModel: OutlineViewModel) {
        self.section = section
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 16) {
                        progressHeader(proxy: proxy)
                        if section == .idea {
                            ideaFields
                        } else {
                            overallDescriptionField
                            beatsHeader
                            beatsFields
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                }
            }
        }
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Progress header

    private var progress: (filled: Int, total: Int) { viewModel.filledCount(for: section) }

    private func progressHeader(proxy: ScrollViewProxy) -> some View {
        let next = viewModel.firstUnfilled(for: section)
        return ProgressHeader(
            title: section.title,
            filled: progress.filled,
            total: progress.total,
            completeText: L10n.Outline.sectionComplete,
            nextFieldTitle: next?.title,
            onNextTapped: {
                guard let anchor = next?.anchor else { return }
                focusRequest = AnyHashable(anchor)
                withAnimation(.easeInOut(duration: 0.35)) {
                    proxy.scrollTo(anchor, anchor: .top)
                }
            }
        )
    }

    // MARK: - Idea

    private var ideaFields: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.ideaFieldSpecs) { spec in
                ExpandableTextField(
                    title: spec.isOptional ? L10n.Action.optional(spec.title) : spec.title,
                    prompt: spec.prompt,
                    systemImage: spec.systemImage,
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(OutlineViewModel.FieldAnchor.outline(spec.field)),
                    text: viewModel.binding(for: spec.field)
                )
                .id(OutlineViewModel.FieldAnchor.outline(spec.field))
            }
        }
    }

    // MARK: - Act sections

    private var overallDescriptionField: some View {
        Group {
            if let field = section.descriptionField {
                ExpandableTextField(
                    title: L10n.Outline.overallDescription,
                    prompt: L10n.Outline.overallPrompt(section.title),
                    systemImage: "text.alignleft",
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(OutlineViewModel.FieldAnchor.outline(field)),
                    text: viewModel.binding(for: field)
                )
                .id(OutlineViewModel.FieldAnchor.outline(field))
            }
        }
    }

    private var beatsHeader: some View {
        HStack(spacing: 8) {
            Text(L10n.Outline.actBeats)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Button {
                showBeatsInfo = true
            } label: {
                Image(systemName: "info.circle")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(L10n.Outline.aboutActBeats)
            .popover(isPresented: $showBeatsInfo) {
                beatsInfoPopover
            }
            Spacer()
        }
        .padding(.top, 6)
    }

    private var beatsInfoPopover: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: "sparkles")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.accent)
                Text(L10n.Outline.actBeats)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
            }
            Text(viewModel.beatsInfoText)
                .font(.subheadline)
                .foregroundStyle(palette.textMuted)
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
        }
        .frame(width: 300, alignment: .leading)
        .padding(20)
        .presentationCompactAdaptation(.popover)
    }

    private var beatsFields: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.beats(for: section)) { beat in
                ExpandableTextField(
                    title: beat.title,
                    prompt: beat.subtitle,
                    systemImage: "circle.grid.cross",
                    focusRequest: $focusRequest,
                    focusID: AnyHashable(OutlineViewModel.FieldAnchor.beat(beat)),
                    text: viewModel.binding(for: beat)
                )
                .id(OutlineViewModel.FieldAnchor.beat(beat))
            }
        }
    }
}

#if DEBUG
#Preview("Act I") {
    NavigationStack {
        OutlineSectionDetailView(
            section: .actOne,
            viewModel: OutlineViewModel(
                screenplay: MockScreenplayRepository.sampleScreenplays()[0],
                repository: MockScreenplayRepository()
            )
        )
        .environment(\.appPalette, .default)
    }
}

#Preview("Idea") {
    NavigationStack {
        OutlineSectionDetailView(
            section: .idea,
            viewModel: OutlineViewModel(
                screenplay: MockScreenplayRepository.sampleScreenplays()[0],
                repository: MockScreenplayRepository()
            )
        )
        .environment(\.appPalette, .default)
    }
}
#endif
