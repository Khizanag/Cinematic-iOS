import CinematicDomain
import MVIKit
import Observation

/// MV: the model holds the search result and performs one search. It knows
/// nothing about typing, debounce, or which request is the latest: the view's
/// `.task(id:)` decides when to call it and cancels calls that went stale.
@Observable
final class MovieSearch {
    private(set) var results: LoadingPhase<[Movie], MovieError> = .idle

    @ObservationIgnored private let searchMovies: SearchMoviesUseCase

    init(searchMovies: SearchMoviesUseCase) {
        self.searchMovies = searchMovies
    }

    static func isSearchable(_ query: String) -> Bool {
        query.trimmingCharacters(in: .whitespacesAndNewlines).count >= SearchMoviesUseCase.minimumQueryLength
    }

    func search(for query: String) async {
        guard Self.isSearchable(query) else {
            results = .idle
            return
        }
        results = .loading
        do throws(MovieError) {
            let movies = try await searchMovies.execute(query: query)
            // A cancelled call belongs to a query the user already replaced.
            guard !Task.isCancelled else { return }
            results = .loaded(movies)
        } catch {
            guard !Task.isCancelled else { return }
            results = .failed(error)
        }
    }
}
