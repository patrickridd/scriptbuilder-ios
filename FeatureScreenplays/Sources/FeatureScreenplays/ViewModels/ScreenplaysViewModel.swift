import Foundation
import Domain

/// Drives the Home dashboard. Owns the `ScreenplayRepository` and exposes a
/// simple, observable view-state the UI can render without knowing about the
/// backend, uids, or async streams.
@MainActor
public final class ScreenplaysViewModel: ObservableObject {

    public enum LoadState: Equatable {
        case loading
        case loaded
        case failed(String)
    }

    @Published public private(set) var screenplays: [Screenplay] = []
    @Published public private(set) var state: LoadState = .loading
    @Published public var searchText: String = ""

    private let repository: ScreenplayRepository
    private var streamTask: Task<Void, Never>?

    public init(repository: ScreenplayRepository) {
        self.repository = repository
    }

    deinit {
        streamTask?.cancel()
    }

    /// Screenplays filtered by the current search text (title or author).
    public var filteredScreenplays: [Screenplay] {
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !query.isEmpty else { return screenplays }
        return screenplays.filter { item in
            item.title.localizedCaseInsensitiveContains(query)
                || (item.authorName ?? "").localizedCaseInsensitiveContains(query)
        }
    }

    /// The most recently edited screenplay, surfaced as "Continue Writing".
    public var mostRecent: Screenplay? { screenplays.first }

    /// The screenplay's position in the full, recency-sorted list (0 = most
    /// recent). Used by the host to apply quota gating against the same
    /// ordering the dashboard renders, regardless of any active search filter.
    public func rank(of screenplay: Screenplay) -> Int {
        screenplays.firstIndex { $0.id == screenplay.id } ?? screenplays.count
    }

    /// Number of screenplays currently loaded — used to decide create-gating.
    public var count: Int { screenplays.count }

    /// Total scenes across every screenplay — a dashboard stat.
    public var totalScenes: Int {
        screenplays.reduce(0) { $0 + $1.allScenes.count }
    }

    /// Subscribe to the live stream of the user's screenplays.
    public func start() {
        guard streamTask == nil else { return }
        state = .loading
        streamTask = Task { [weak self] in
            guard let self else { return }
            for await items in repository.screenplaysStream() {
                self.apply(items)
            }
        }
    }

    /// One-shot refresh, used by pull-to-refresh.
    public func refresh() async {
        do {
            let items = try await repository.fetchScreenplays()
            apply(items)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    public func delete(_ screenplay: Screenplay) async {
        do {
            try await repository.delete(id: screenplay.uuid)
        } catch {
            state = .failed(error.localizedDescription)
        }
    }

    // MARK: - Private

    private func apply(_ items: [Screenplay]) {
        screenplays = items.sorted {
            ($0.lastUpdated ?? .distantPast) > ($1.lastUpdated ?? .distantPast)
        }
        state = .loaded
    }
}
