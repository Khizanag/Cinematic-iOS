import CinematicDomain
import MVIKit
import Observation

/// MVVM: the view model owns the query, the result, and the one search task
/// in flight. Debounce and switch-latest are hand-written here: every write to
/// `query` cancels the previous task before starting the next.
@Observable
final class SearchViewModel {
    var query = "" {
        didSet {
            guard query != oldValue else { return }
            queryChanged()
        }
    }

    private(set) var results: LoadingPhase<[Movie], MovieError> = .idle

    @ObservationIgnored private let searchMovies: SearchMoviesUseCase
    @ObservationIgnored private let debounce: Duration
    @ObservationIgnored private var searchTask: Task<Void, Never>?

    init(searchMovies: SearchMoviesUseCase, debounce: Duration = .milliseconds(250)) {
        self.searchMovies = searchMovies
        self.debounce = debounce
    }

    /// Suspends until the current search, if any, finishes.
    func settle() async {
        await searchTask?.value
    }
}

// MARK: - Search
private extension SearchViewModel {
    func queryChanged() {
        searchTask?.cancel()
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= SearchMoviesUseCase.minimumQueryLength else {
            results = .idle
            searchTask = nil
            return
        }
        searchTask = Task { [weak self, debounce] in
            try? await Task.sleep(for: debounce)
            guard !Task.isCancelled else { return }
            await self?.search(for: trimmed)
        }
    }

    func search(for query: String) async {
        results = .loading
        do throws(MovieError) {
            let movies = try await searchMovies.execute(query: query)
            // A cancelled task belongs to a query the user already replaced.
            guard !Task.isCancelled else { return }
            results = .loaded(movies)
        } catch {
            guard !Task.isCancelled else { return }
            results = .failed(error)
        }
    }
}
