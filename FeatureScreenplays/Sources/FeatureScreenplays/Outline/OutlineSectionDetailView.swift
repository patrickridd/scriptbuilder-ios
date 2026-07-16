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

    init(section: OutlineSection, viewModel: OutlineViewModel) {
        self.section = section
        self.viewModel = viewModel
    }

    var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 16) {
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
        .navigationTitle(section.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Idea

    private var ideaFields: some View {
        VStack(spacing: 14) {
            ForEach(viewModel.ideaFieldSpecs) { spec in
                ExpandableTextField(
                    title: spec.isOptional ? L10n.Action.optional(spec.title) : spec.title,
                    prompt: spec.prompt,
                    systemImage: spec.systemImage,
                    text: viewModel.binding(for: spec.field)
                )
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
                    text: viewModel.binding(for: field)
                )
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
                    text: viewModel.binding(for: beat)
                )
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
