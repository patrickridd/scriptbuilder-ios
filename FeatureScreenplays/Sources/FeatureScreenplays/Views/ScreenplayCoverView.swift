import SwiftUI
import Domain
import DesignSystem

/// The **cover page** of an opened screenplay — the title-card the reader sees
/// first, before swiping into the working editor. It renders the generated
/// cover artwork, the title, an optional log-line "by-line", and the author,
/// styled like the opening page of a bound script.
///
/// This view is intentionally *chrome-free*: it owns no navigation and no tab
/// bar. In the composition root it becomes **page 0** of the paged
/// `ScreenplayContainerView`, sitting beside the working `ScreenplayWorkspaceView`.
/// The `onStartWriting` closure lets the host advance the pager (or push the
/// editor) without this view knowing how that navigation is wired.
public struct ScreenplayCoverView: View {
    @Environment(\.appPalette) private var palette
    private let screenplay: Screenplay
    private let onStartWriting: () -> Void
    private let onShared: () -> Void

    @State private var shareItems: [Any] = []
    @State private var isSharePresented = false
    @State private var isPreparingShare = false
    @State private var isFormatPickerPresented = false

    private enum ExportFormat {
        case pdf
        case plainText
    }

    public init(
        screenplay: Screenplay,
        onStartWriting: @escaping () -> Void = {},
        onShared: @escaping () -> Void = {}
    ) {
        self.screenplay = screenplay
        self.onStartWriting = onStartWriting
        self.onShared = onShared
    }

    public var body: some View {
        ZStack {
            AppBackground()
            ScrollView {
                VStack(spacing: 28) {
                    artwork
                    titleBlock
                    startButton
                    shareButton
                }
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
        }
        .sheet(isPresented: $isSharePresented, onDismiss: { onShared() }) {
            #if canImport(UIKit)
            ShareSheet(items: shareItems)
            #endif
        }
        .confirmationDialog(
            L10n.Cover.shareScreenplay,
            isPresented: $isFormatPickerPresented,
            titleVisibility: .visible
        ) {
            Button(L10n.Cover.pdfDocument) { prepareAndShare(format: .pdf) }
            Button(L10n.Cover.plainText) { prepareAndShare(format: .plainText) }
            Button(L10n.Action.cancel, role: .cancel) {}
        } message: {
            Text(L10n.Cover.chooseFormat)
        }
    }

    // MARK: - Sections

    private var artwork: some View {
        CoverArtwork(title: screenplay.title, showsTitle: false)
            .aspectRatio(8.5 / 11.0, contentMode: .fit)
            .frame(maxWidth: 240)
            .overlay(alignment: .center) { artworkTitle }
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: .black.opacity(0.28), radius: 22, y: 12)
            .padding(.top, 8)
    }

    private var artworkTitle: some View {
        Text(screenplay.title.isEmpty ? L10n.Action.untitled : screenplay.title)
            .font(.title.weight(.bold))
            .foregroundStyle(.white)
            .multilineTextAlignment(.center)
            .minimumScaleFactor(0.6)
            .shadow(color: .black.opacity(0.55), radius: 8, y: 2)
            .padding(.horizontal, 20)
    }

    private var titleBlock: some View {
        VStack(spacing: 12) {
            if !screenplay.logLine.isEmpty {
                Text(screenplay.logLine)
                    .font(.title3)
                    .italic()
                    .foregroundStyle(palette.textMuted)
                    .multilineTextAlignment(.center)
            }
            byLine
        }
    }

    @ViewBuilder
    private var byLine: some View {
        let author = (screenplay.authorName ?? "").trimmingCharacters(in: .whitespaces)
        if !author.isEmpty {
            VStack(spacing: 4) {
                Text(L10n.Cover.writtenBy)
                    .font(.caption.weight(.medium))
                    .textCase(.uppercase)
                    .tracking(1.5)
                    .foregroundStyle(palette.textMuted)
                Text(author)
                    .font(.headline)
                    .foregroundStyle(palette.textPrimary)
            }
            .padding(.top, 6)
        }
    }

    private var startButton: some View {
        Button(action: onStartWriting) {
            Label(L10n.Cover.startWriting, systemImage: "pencil.and.outline")
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 15)
                .background(palette.accent, in: Capsule())
                .shadow(color: palette.accent.opacity(0.35), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
        .padding(.top, 8)
        .accessibilityHint("Opens the outline, characters, and scenes editor")
    }

    private var shareButton: some View {
        Button { isFormatPickerPresented = true } label: {
            HStack(spacing: 8) {
                if isPreparingShare {
                    ProgressView().tint(palette.accent)
                } else {
                    Image(systemName: "square.and.arrow.up")
                }
                Text(L10n.Cover.shareScreenplay)
            }
            .font(.headline)
            .foregroundStyle(palette.accent)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(palette.accent.opacity(0.12), in: Capsule())
        }
        .buttonStyle(.plain)
        .disabled(isPreparingShare)
        .accessibilityHint("Exports the full screenplay as a PDF or plain text you can share or print")
    }

    // MARK: - Sharing

    private func prepareAndShare(format: ExportFormat) {
        guard !isPreparingShare else { return }
        isPreparingShare = true
        let screenplay = screenplay
        Task {
            let url = await Task.detached(priority: .userInitiated) {
                switch format {
                case .pdf:
                    return ScreenplayPDFRenderer.renderToTemporaryFile(screenplay)
                case .plainText:
                    return ScreenplayExporter.writePlainTextFile(for: screenplay)
                }
            }.value
            await MainActor.run {
                isPreparingShare = false
                if let url {
                    shareItems = [url]
                } else {
                    // Fall back to inline text if writing the file failed.
                    shareItems = [ScreenplayExporter.plainText(for: screenplay)]
                }
                isSharePresented = true
            }
        }
    }
}

#if DEBUG
#Preview {
    ScreenplayCoverView(
        screenplay: Screenplay(
            title: "Echoes of Tomorrow",
            authorName: "Jane Rivera",
            logLine: "A stranded engineer must trust a fading AI to make it home."
        )
    )
    .environment(\.appPalette, .default)
}
#endif
