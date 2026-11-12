import CinematicDomain
import MVIKit

/// State machine of the discover screen.
struct DiscoverReducer: Reducer {
    struct State: Equatable {
        var catalog: LoadingPhase<DiscoverCatalog, MovieError> = .idle
        var isRefreshing = false
        /// `nil` shows every row; a genre narrows the screen to its full chart.
        var selectedGenre: MovieGenre?

        /// The genres a filter can offer: only those whose row actually loaded.
        var availableGenres: [MovieGenre] {
            catalog.value?.sections.map(\.genre) ?? []
        }

        /// The row the filter narrows to, or `nil` when showing everything.
        var selectedSection: DiscoverCatalog.GenreSection? {
            guard let selectedGenre else { return nil }
            return catalog.value?.sections.first { $0.genre == selectedGenre }
        }
    }

    enum Intent: Sendable {
        case task
        case retry
        case refresh
        case catalogLoaded(DiscoverCatalog)
        case loadFailed(MovieError)
        case refreshSucceeded(DiscoverCatalog)
        case refreshFailed
        case genreSelected(MovieGenre?)
    }

    private let fetchDiscoverCatalog: FetchDiscoverCatalogUseCase

    init(fetchDiscoverCatalog: FetchDiscoverCatalogUseCase) {
        self.fetchDiscoverCatalog = fetchDiscoverCatalog
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case .task:
            // `.task` fires again when the tab reappears — keep what we have.
            guard state.catalog.value == nil else { return .none }
            return load(&state)

        case .retry:
            return load(&state)

        case .refresh:
            // A refresh keeps the current content on screen — only the first
            // load shows skeletons. Guard against overlapping pulls.
            guard !state.isRefreshing else { return .none }
            state.isRefreshing = true
            return refresh()

        case let .catalogLoaded(catalog):
            apply(catalog, to: &state)
            return .none

        case let .loadFailed(error):
            state.catalog = .failed(error)
            return .none

        case let .refreshSucceeded(catalog):
            state.isRefreshing = false
            apply(catalog, to: &state)
            return .none

        case .refreshFailed:
            // Non-destructive: a failed refresh keeps the content on screen.
            state.isRefreshing = false
            return .none

        case let .genreSelected(genre):
            // Filtering is derived state over the loaded catalog, which already
            // holds each genre's chart — no effect, no second fetch.
            select(genre, in: &state)
            return .none
        }
    }
}

// MARK: - State
private extension DiscoverReducer {
    /// Ignores a genre the catalog has no row for.
    func select(_ genre: MovieGenre?, in state: inout State) {
        guard let genre else {
            state.selectedGenre = nil
            return
        }
        guard state.availableGenres.contains(genre) else { return }
        state.selectedGenre = genre
    }

    /// A reload may drop a genre whose row failed; a filter pointing at it
    /// would show nothing, so it falls back to every row.
    func apply(_ catalog: DiscoverCatalog, to state: inout State) {
        state.catalog = .loaded(catalog)
        if let selectedGenre = state.selectedGenre, !state.availableGenres.contains(selectedGenre) {
            state.selectedGenre = nil
        }
    }
}

// MARK: - Effects
private extension DiscoverReducer {
    func load(_ state: inout State) -> Effect<Intent> {
        state.catalog = .loading
        return fetch(onSuccess: Intent.catalogLoaded, onFailure: Intent.loadFailed)
    }

    func refresh() -> Effect<Intent> {
        fetch(onSuccess: Intent.refreshSucceeded, onFailure: { _ in .refreshFailed })
    }

    /// Shared catalog fetch. The same `EffectID` for load and refresh means a
    /// pull-to-refresh cancels an in-flight load and vice versa — only one
    /// fetch is ever in flight.
    func fetch(
        onSuccess: @escaping @Sendable (DiscoverCatalog) -> Intent,
        onFailure: @escaping @Sendable (MovieError) -> Intent,
    ) -> Effect<Intent> {
        let fetchDiscoverCatalog = fetchDiscoverCatalog
        return .run(id: "load") { send in
            do throws(MovieError) {
                let catalog = try await fetchDiscoverCatalog.execute()
                await send(onSuccess(catalog))
            } catch {
                await send(onFailure(error))
            }
        }
    }
}
