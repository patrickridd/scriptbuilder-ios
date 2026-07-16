import SwiftUI
import Domain
import DesignSystem

/// The Outline tab body: a creative hub built around the Idea (a distinct hero
/// card) and the three-act structure (a connected, spine-linked group). Each
/// card is a navigation link into its `OutlineSectionDetailView`. Editing logic
/// lives in `OutlineViewModel`.
struct OutlineView: View {
    @Environment(\.appPalette) private var palette
    @State private var viewModel: OutlineViewModel

    init(
        screenplay: Screenplay,
        repository: ScreenplayRepository,
        onOutlineCompleted: @escaping () -> Void = {}
    ) {
        let vm = OutlineViewModel(screenplay: screenplay, repository: repository)
        vm.onOutlineCompleted = onOutlineCompleted
        _viewModel = State(initialValue: vm)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                header
                ideaCard
                actsSection
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
    }

    // MARK: - Header (with progress ring)

    private var completedSections: Int { viewModel.completedSectionCount }

    private var isAllComplete: Bool {
        completedSections == OutlineSection.allCases.count
    }

    private var headerSubtitle: String {
        isAllComplete
            ? L10n.Outline.complete
            : L10n.Outline.sectionsComplete(completedSections, OutlineSection.allCases.count)
    }

    private var header: some View {
        HStack(alignment: .center, spacing: 16) {
            VStack(alignment: .leading, spacing: 6) {
                Text(L10n.Outline.storyOutline)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
                Text(headerSubtitle)
                    .font(.subheadline)
                    .foregroundStyle(isAllComplete ? palette.accent : palette.textMuted)
                    .contentTransition(.opacity)
                    .animation(.easeInOut(duration: 0.3), value: headerSubtitle)
            }
            Spacer(minLength: 8)
            OutlineProgressRing(
                targetFraction: viewModel.overallCompletion
            )
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Idea hero card

    private var ideaCard: some View {
        NavigationLink {
            OutlineSectionDetailView(section: .idea, viewModel: viewModel)
        } label: {
            IdeaHeroCard(
                preview: viewModel.preview(for: .idea),
                progress: viewModel.filledCount(for: .idea)
            )
        }
        .buttonStyle(.pressableCard)
    }

    // MARK: - Three-act structure

    private var actSections: [OutlineSection] { [.actOne, .actTwo, .actThree] }

    private var actsSection: some View {
        VStack(spacing: 0) {
            SectionDivider(title: L10n.Outline.threeActStructure)
                .padding(.bottom, 4)
            ForEach(Array(actSections.enumerated()), id: \.element) { index, section in
                NavigationLink {
                    OutlineSectionDetailView(section: section, viewModel: viewModel)
                } label: {
                    ActSpineRow(
                        section: section,
                        number: index + 1,
                        isFirst: index == 0,
                        isLast: index == actSections.count - 1,
                        preview: viewModel.preview(for: section),
                        progress: viewModel.filledCount(for: section)
                    )
                }
                .buttonStyle(.pressableCard)
            }
        }
    }
}

// MARK: - Progress ring

/// A compact circular progress indicator for overall outline completion.
/// Animates its fill from empty up to `targetFraction` when it first appears,
/// and plays a celebratory bloom + sparkle flourish when it reaches 100%.
private struct OutlineProgressRing: View {
    @Environment(\.appPalette) private var palette
    let targetFraction: Double
    @State private var fraction: Double = 0
    @State private var celebrate = false
    @State private var bloom = false

    private var isComplete: Bool { targetFraction >= 0.999 }

    var body: some View {
        ZStack {
            bloomHalo
            ring
        }
        .frame(width: 52, height: 52)
        .scaleEffect(celebrate ? 1.12 : 1)
        .animation(.spring(response: 0.4, dampingFraction: 0.5), value: celebrate)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.9).delay(0.15)) {
                fraction = targetFraction
            }
            if isComplete { triggerCelebration(delay: 1.0) }
        }
        .onChange(of: targetFraction) { _, newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                fraction = newValue
            }
            if newValue >= 0.999 { triggerCelebration(delay: 0.45) }
        }
    }

    private var ring: some View {
        ZStack {
            Circle()
                .stroke(palette.accent.opacity(0.15), lineWidth: 6)
            Circle()
                .trim(from: 0, to: max(0.001, min(1, fraction)))
                .stroke(palette.accent, style: StrokeStyle(lineWidth: 6, lineCap: .round))
                .rotationEffect(.degrees(-90))
            Group {
                if isComplete && celebrate {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.heavy))
                        .foregroundStyle(palette.accent)
                        .transition(.scale.combined(with: .opacity))
                } else {
                    Text("\(Int(fraction * 100))%")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(palette.textPrimary)
                        .contentTransition(.numericText())
                }
            }
        }
    }

    private var bloomHalo: some View {
        Circle()
            .stroke(palette.accent.opacity(bloom ? 0 : 0.6), lineWidth: 3)
            .scaleEffect(bloom ? 1.9 : 0.9)
            .opacity(bloom ? 0 : 1)
    }

    private func triggerCelebration(delay: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5)) {
                celebrate = true
            }
            withAnimation(.easeOut(duration: 0.8)) {
                bloom = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.9) {
                bloom = false
            }
        }
    }
}

// MARK: - Section divider

/// A labeled rule that groups the three acts under one header.
private struct SectionDivider: View {
    @Environment(\.appPalette) private var palette
    let title: String

    var body: some View {
        HStack(spacing: 12) {
            line
            Text(title.uppercased())
                .font(.caption.weight(.bold))
                .tracking(1.2)
                .foregroundStyle(palette.textMuted)
                .fixedSize()
            line
        }
        .padding(.vertical, 6)
    }

    private var line: some View {
        Rectangle()
            .fill(palette.separator)
            .frame(height: 1)
    }
}

// MARK: - Idea hero card

/// The Idea section rendered as a taller, gradient-backed hero — visually
/// separating the creative seed from the structural acts below.
private struct IdeaHeroCard: View {
    @Environment(\.appPalette) private var palette
    let preview: String
    let progress: (filled: Int, total: Int)

    private var isComplete: Bool { progress.total > 0 && progress.filled == progress.total }

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            topRow
            Text(preview)
                .font(.subheadline)
                .foregroundStyle(palette.textPrimary.opacity(0.85))
                .lineLimit(3)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(20)
        .background(background)
        .overlay(
            RoundedRectangle(cornerRadius: 22, style: .continuous)
                .stroke(palette.accent.opacity(0.35), lineWidth: 1)
        )
    }

    private var topRow: some View {
        HStack(spacing: 14) {
            glowingIcon
            VStack(alignment: .leading, spacing: 3) {
                Text(L10n.Outline.sectionTitle(.idea))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(palette.textPrimary)
                Text(L10n.Outline.sectionSubtitle(.idea))
                    .font(.footnote)
                    .foregroundStyle(palette.textMuted)
            }
            Spacer(minLength: 4)
            progressBadge
        }
    }

    private var glowingIcon: some View {
        Image(systemName: "lightbulb.fill")
            .font(.title2)
            .foregroundStyle(palette.accent)
            .frame(width: 52, height: 52)
            .background(palette.accent.opacity(0.18), in: Circle())
            .overlay(Circle().stroke(palette.accent.opacity(0.4), lineWidth: 1))
            .shadow(color: palette.accent.opacity(0.5), radius: 12, x: 0, y: 0)
    }

    @ViewBuilder private var progressBadge: some View {
        if progress.total > 0 {
            Text("\(progress.filled)/\(progress.total)")
                .font(.caption.weight(.semibold))
                .foregroundStyle(isComplete ? palette.accent : palette.textMuted)
                .padding(.horizontal, 9)
                .padding(.vertical, 4)
                .background(palette.accent.opacity(isComplete ? 0.18 : 0.08), in: Capsule())
        }
    }

    private var background: some View {
        RoundedRectangle(cornerRadius: 22, style: .continuous)
            .fill(palette.cardSurface)
            .overlay(
                LinearGradient(
                    colors: [palette.accent.opacity(0.16), palette.accent.opacity(0.02)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
            )
    }
}

// MARK: - Act spine row

/// One act card with a numbered badge and a vertical "spine" connector, so the
/// three acts read as a sequential timeline. Accent tint deepens as it fills.
private struct ActSpineRow: View {
    @Environment(\.appPalette) private var palette
    let section: OutlineSection
    let number: Int
    let isFirst: Bool
    let isLast: Bool
    let preview: String
    let progress: (filled: Int, total: Int)

    private var fillFraction: Double {
        progress.total > 0 ? Double(progress.filled) / Double(progress.total) : 0
    }

    // Spine color brightens toward accent as this act fills in.
    private var spineColor: Color {
        // Fade from a neutral separator to the accent as the act fills in.
        palette.accent.opacity(0.15 + 0.75 * fillFraction)
    }

    private var isComplete: Bool { progress.total > 0 && progress.filled == progress.total }

    @State private var pulse = false
    @State private var burst = false

    var body: some View {
        HStack(spacing: 14) {
            spine
            card
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onChange(of: isComplete) { _, nowComplete in
            if nowComplete { triggerPulse() }
        }
    }

    // Vertical connector + number badge
    private var spine: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(isFirst ? Color.clear : spineColor)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
            badge
            Rectangle()
                .fill(isLast ? Color.clear : spineColor)
                .frame(width: 2)
                .frame(maxHeight: .infinity)
        }
        .frame(width: 30)
        .animation(.easeInOut(duration: 0.35), value: fillFraction)
    }

    private var badge: some View {
        Text("\(number)")
            .font(.subheadline.weight(.bold))
            .foregroundStyle(isComplete ? Color.white : palette.accent)
            .frame(width: 30, height: 30)
            .background(palette.accent.opacity(isComplete ? 1.0 : 0.14), in: Circle())
            .overlay(Circle().stroke(palette.accent.opacity(isComplete ? 0.9 : 0.5),
                                     lineWidth: 1.5))
            .overlay(burstRing)
            .shadow(color: palette.accent.opacity(isComplete ? 0.45 : 0),
                    radius: isComplete ? 6 : 0)
            .scaleEffect(pulse ? 1.25 : 1)
    }

    private var burstRing: some View {
        Circle()
            .stroke(palette.accent.opacity(burst ? 0 : 0.7), lineWidth: 2.5)
            .scaleEffect(burst ? 2.0 : 1)
            .opacity(burst ? 0 : 1)
    }

    private func triggerPulse() {
        withAnimation(.spring(response: 0.35, dampingFraction: 0.4)) {
            pulse = true
        }
        withAnimation(.easeOut(duration: 0.7)) {
            burst = true
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                pulse = false
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.75) {
            burst = false
        }
    }

    private var card: some View {
        HStack(spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                titleRow
                Text(preview)
                    .font(.subheadline)
                    .foregroundStyle(palette.textMuted)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            Image(systemName: "chevron.right")
                .font(.footnote.weight(.semibold))
                .foregroundStyle(palette.textMuted.opacity(0.6))
        }
        .padding(16)
        .background(cardBackground)
        .overlay(
            RoundedRectangle(cornerRadius: 18, style: .continuous)
                .stroke(palette.cardStroke, lineWidth: 1)
        )
        .padding(.vertical, 6)
    }

    private var titleRow: some View {
        HStack(spacing: 8) {
            Text(section.title)
                .font(.headline)
                .foregroundStyle(palette.textPrimary)
            Text(section.subtitle)
                .font(.caption)
                .foregroundStyle(palette.textMuted)
            Spacer(minLength: 4)
            if progress.total > 0 {
                Text("\(progress.filled)/\(progress.total)")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(progress.filled == progress.total ? palette.accent : palette.textMuted)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(palette.accent.opacity(progress.filled == progress.total ? 0.14 : 0.06),
                                in: Capsule())
            }
        }
    }

    // Accent tint deepens with completion
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 18, style: .continuous)
            .fill(palette.cardSurface)
            .overlay(
                palette.accent.opacity(0.02 + 0.10 * fillFraction)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            )
    }
}

#if DEBUG
#Preview {
    NavigationStack {
        OutlineView(
            screenplay: MockScreenplayRepository.sampleScreenplays()[0],
            repository: MockScreenplayRepository()
        )
        .environment(\.appPalette, .default)
        .background(AppBackground())
    }
}
#endif
