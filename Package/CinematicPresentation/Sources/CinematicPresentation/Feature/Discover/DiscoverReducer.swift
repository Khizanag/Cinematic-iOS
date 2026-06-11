import CinematicDomain
import MVIKit

/// State machine of the discover screen.
struct DiscoverReducer: Reducer {
    struct State: Equatable {
        var catalog: LoadingPhase<DiscoverCatalog, MovieError> = .idle
    }

    enum Intent: Sendable {
        case task
        case retry
        case catalogLoaded(DiscoverCatalog)
        case loadFailed(MovieError)
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

        case let .catalogLoaded(catalog):
            state.catalog = .loaded(catalog)
            return .none

        case let .loadFailed(error):
            state.catalog = .failed(error)
            return .none
        }
    }
}

// MARK: - Effects
private extension DiscoverReducer {
    func load(_ state: inout State) -> Effect<Intent> {
        state.catalog = .loading
        let fetchDiscoverCatalog = fetchDiscoverCatalog
        return .run(id: "load") { send in
            // `do throws(MovieError)` keeps the catch variable typed, so the
            // failure intent carries a domain error — not `any Error`.
            do throws(MovieError) {
                let catalog = try await fetchDiscoverCatalog.execute()
                await send(.catalogLoaded(catalog))
            } catch {
                await send(.loadFailed(error))
            }
        }
    }
}
