import CinematicDomain
import MVIKit

/// State machine of catalog search, including debounce.
///
/// Every keystroke restarts the single `search` effect — debounce sleep and
/// the request itself share one `EffectID`, so the store's switch-latest
/// semantics guarantee at most one search pipeline in flight. Stale results
/// can never overwrite fresh ones.
struct SearchReducer: Reducer {
    struct State: Equatable {
        var query = ""
        var results: LoadingPhase<[Movie], MovieError> = .idle
    }

    enum Intent: Sendable {
        case queryChanged(String)
        case searchNow
        case resultsLoaded([Movie])
        case searchFailed(MovieError)
    }

    private static let searchEffect: EffectID = "search"

    private let searchMovies: SearchMoviesUseCase
    private let debounce: Duration

    /// `debounce` is injectable so tests run on a near-zero interval.
    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        self.searchMovies = searchMovies
        self.debounce = debounce
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case let .queryChanged(query):
            guard query != state.query else { return .none }
            state.query = query
            return debouncedSearch(&state, query: query)

        case .searchNow:
            state.results = .loading
            return search(query: state.query)

        case let .resultsLoaded(movies):
            state.results = .loaded(movies)
            return .none

        case let .searchFailed(error):
            state.results = .failed(error)
            return .none
        }
    }
}

// MARK: - Effects
private extension SearchReducer {
    func debouncedSearch(_ state: inout State, query: String) -> Effect<Intent> {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= SearchMoviesUseCase.minimumQueryLength else {
            state.results = .idle
            return .cancel(Self.searchEffect)
        }
        let debounce = debounce
        return .run(id: Self.searchEffect) { send in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await send(.searchNow)
        }
    }

    func search(query: String) -> Effect<Intent> {
        let searchMovies = searchMovies
        return .run(id: Self.searchEffect) { send in
            do throws(MovieError) {
                let movies = try await searchMovies.execute(query: query)
                await send(.resultsLoaded(movies))
            } catch {
                await send(.searchFailed(error))
            }
        }
    }
}
