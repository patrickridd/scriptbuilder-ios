import SwiftUI
import Domain
import DesignSystem

/// The modern Screenplays dashboard — a SwiftUI replacement for the legacy
/// `ScreenplayCollectionViewController`. Renders a hero header, a
/// "Continue Writing" card, and an adaptive grid of generated-cover script
/// tiles.
///
/// This view is **chrome-free**: it owns no `NavigationStack` and no toolbar.
/// An app-level shell (e.g. `RootShellView`) provides the navigation container,
/// title, and toolbar around it. All side concerns (open, create, IAP gating)
/// are injected via `ScreenplaysConfiguration`.
public struct ScreenplaysView: View {
    @Environment(\.appPalette) private var palette
    @StateObject private var viewModel: ScreenplaysViewModel
    private let config: ScreenplaysConfiguration
    /// Host-supplied brand mark for the loading badge. Injected by the
    /// composition root so `FeatureScreenplays` owns no app-specific artwork.
    /// `nil` renders a badge-free loading overlay.
    private let logo: Image?
    /// Optional namespace for the iOS 18 zoom transition into the editor.
    /// When `nil`, cards fall back to the standard push.
    private let transitionNamespace: Namespace.ID?

    public init(
        repository: ScreenplayRepository,
        config: ScreenplaysConfiguration,
        logo: Image? = nil,
        transitionNamespace: Namespace.ID? = nil
    ) {
        _viewModel = StateObject(wrappedValue: ScreenplaysViewModel(repository: repository))
        self.config = config
        self.logo = logo
        self.transitionNamespace = transitionNamespace
    }

    public var body: some View {
        ZStack {
            AppBackground()
            content
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !viewModel.screenplays.isEmpty {
                searchBar
            }
        }
        .refreshable { await viewModel.refresh() }
        .onAppear { viewModel.start() }
        .onChange(of: viewModel.screenplays.count) { oldValue, newValue in
            if newValue > oldValue { Haptics.lightImpact() }
            config.onCountChange(newValue)
        }
    }

    /// Pinned bottom bar: a rounded "Search scripts" field with a compact "+"
    /// button on the trailing side to create a new screenplay — mirroring the
    /// Characters screen for a consistent, thumb-friendly layout.
    private var searchBar: some View {
        HStack(spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(palette.textMuted)
                TextField("Search scripts", text: $viewModel.searchText)
                    .autocorrectionDisabled()
                    .foregroundStyle(palette.textPrimary)
                if !viewModel.searchText.isEmpty {
                    Button {
                        viewModel.searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(palette.textMuted)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 12)
            .frame(height: 44)
            .background(palette.cardSurface, in: Capsule())
            .overlay(Capsule().stroke(palette.cardStroke, lineWidth: 1))

            addButton
        }
        .padding(.horizontal, 16)
        .padding(.top, 10)
        .padding(.bottom, 6)
        .background(.ultraThinMaterial)
    }

    private var addButton: some View {
        Button {
            config.onCreate(viewModel.count)
        } label: {
            Image(systemName: "plus")
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
                .frame(width: 44, height: 44)
                .background(palette.primaryButtonGradient, in: Circle())
                .shadow(color: palette.accent.opacity(0.35), radius: 8, y: 4)
        }
        .accessibilityLabel("Add screenplay")
    }

    @ViewBuilder
    private var content: some View {
        switch viewModel.state {
        case .loading where viewModel.screenplays.isEmpty:
            LoadingOverlay(
                message: L10n.Home.loadingMessage,
                badge: logo,
                style: .glass(palette)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        case .failed(let message) where viewModel.screenplays.isEmpty:
            ErrorStateView(message: message) { Task { await viewModel.refresh() } }
        default:
            dashboard
        }
    }

    @ViewBuilder
    private var dashboard: some View {
        if viewModel.screenplays.isEmpty {
            EmptyStateView(name: config.userDisplayName) { config.onCreate(viewModel.count) }
        } else {
            ScrollView {
                VStack(spacing: 20) {
                    hero
                    continueWriting
                    grid
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .scrollDismissesKeyboard(.interactively)
        }
    }

    private var hero: some View {
        HeroHeader(
            name: config.userDisplayName,
            scriptCount: viewModel.screenplays.count,
            sceneCount: viewModel.totalScenes,
            lastEdited: lastEditedLabel,
            onOpenProfile: { config.onOpenProfile() }
        )
    }

    @ViewBuilder
    private var continueWriting: some View {
        if viewModel.searchText.isEmpty, let recent = viewModel.mostRecent {
            ContinueWritingCard(screenplay: recent) {
                config.onOpen(recent, viewModel.rank(of: recent))
            }
        }
    }

    private var grid: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            if viewModel.searchText.isEmpty {
                AddScreenplayCard { config.onCreate(viewModel.count) }
            }
            ForEach(viewModel.filteredScreenplays, id: \.id) { item in
                let rank = viewModel.rank(of: item)
                ScreenplayCard(
                    screenplay: item,
                    isRestricted: config.isRestricted(rank),
                    transitionNamespace: transitionNamespace
                ) {
                    config.onOpen(item, rank)
                }
            }
        }
    }

    private var gridColumns: [GridItem] {
        [GridItem(.flexible(), spacing: 16), GridItem(.flexible(), spacing: 16)]
    }

    private var lastEditedLabel: String {
        guard let date = viewModel.mostRecent?.lastUpdated else { return "—" }
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .short
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}
