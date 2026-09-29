import CinematicDomain
import MVIKit

/// MVI: a pure state machine, the same one the app's Search feature runs.
/// Debounce and the request share one `EffectID`, so the store keeps one search
/// in flight and drops intents from cancelled work — no guard is written here.
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

    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        self.searchMovies = searchMovies
        self.debounce = debounce
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case let .queryChanged(query):
            guard query != state.query else { return .none }
            state.query = query
            let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
            guard trimmed.count >= SearchMoviesUseCase.minimumQueryLength else {
                state.results = .idle
                return .cancel(Self.searchEffect)
            }
            let debounce = debounce
            return .run(id: Self.searchEffect) { send in
                try? await Task.sleep(for: debounce)
                await send(.searchNow)
            }

        case .searchNow:
            state.results = .loading
            let searchMovies = searchMovies
            let query = state.query
            return .run(id: Self.searchEffect) { send in
                do throws(MovieError) {
                    let movies = try await searchMovies.execute(query: query)
                    await send(.resultsLoaded(movies))
                } catch {
                    await send(.searchFailed(error))
                }
            }

        case let .resultsLoaded(movies):
            state.results = .loaded(movies)
            return .none

        case let .searchFailed(error):
            state.results = .failed(error)
            return .none
        }
    }
}
