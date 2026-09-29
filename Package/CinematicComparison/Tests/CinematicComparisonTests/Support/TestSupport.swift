@testable import CinematicComparison
import CinematicDomain
import MVIKit
import Testing

/// The same few operations on every variant that owns its own concurrency,
/// so one suite can hold each of them to the same behaviour.
protocol SearchDriver {
    var results: LoadingPhase<[Movie], MovieError> { get }

    func type(_ query: String)
    func settle() async
}

/// The variants whose debounce and switch-latest live outside the view.
enum Variant: String, CaseIterable, Sendable, CustomTestStringConvertible {
    case mvvm = "MVVM"
    case mvi = "MVI"

    var testDescription: String {
        rawValue
    }

    func makeDriver(_ repository: ScriptedCatalogRepository) -> any SearchDriver {
        let searchMovies = SearchMoviesUseCase(repository: repository)
        switch self {
        case .mvvm:
            return SearchViewModel(searchMovies: searchMovies, debounce: .milliseconds(5))
        case .mvi:
            return StoreDriver(store: Store(
                initialState: SearchReducer.State(),
                reducer: SearchReducer(searchMovies: searchMovies, debounce: .milliseconds(5)),
            ))
        }
    }
}

struct StoreDriver: SearchDriver {
    let store: Store<SearchReducer>

    var results: LoadingPhase<[Movie], MovieError> {
        store.state.results
    }

    func type(_ query: String) {
        store.send(.queryChanged(query))
    }

    func settle() async {
        await store.settle()
    }
}

// MARK: - SearchDriver
extension SearchViewModel: SearchDriver {
    func type(_ query: String) {
        self.query = query
    }
}

/// Polls until `condition` holds, yielding between checks.
func waitUntil(
    timeout: Duration = .seconds(2),
    _ condition: () async -> Bool,
) async {
    let clock = ContinuousClock()
    let deadline = clock.now.advanced(by: timeout)
    while await !condition() {
        guard clock.now < deadline else {
            Issue.record("Timed out waiting for condition")
            return
        }
        try? await Task.sleep(for: .milliseconds(5))
    }
}
