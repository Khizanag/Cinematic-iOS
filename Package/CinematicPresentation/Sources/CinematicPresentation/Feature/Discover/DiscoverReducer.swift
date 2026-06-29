import CinematicDomain
import MVIKit

/// State machine of the discover screen.
struct DiscoverReducer: Reducer {
    struct State: Equatable {
        var catalog: LoadingPhase<DiscoverCatalog, MovieError> = .idle
        var isRefreshing = false
    }

    enum Intent: Sendable {
        case task
        case retry
        case refresh
        case catalogLoaded(DiscoverCatalog)
        case loadFailed(MovieError)
        case refreshSucceeded(DiscoverCatalog)
        case refreshFailed
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
            state.catalog = .loaded(catalog)
            return .none

        case let .loadFailed(error):
            state.catalog = .failed(error)
            return .none

        case let .refreshSucceeded(catalog):
            state.isRefreshing = false
            state.catalog = .loaded(catalog)
            return .none

        case .refreshFailed:
            // Non-destructive: a failed refresh keeps the content on screen.
            state.isRefreshing = false
            return .none
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
