import CinematicDomain
@testable import CinematicPresentation
import MVIKit
import Testing

@MainActor
struct SearchReducerTests {
    @Test("Queries below the minimum length reset to idle", arguments: ["", "v", " v "])
    func shortQueryResetsToIdle(query: String) {
        var state = SearchReducer.State(query: "voyage", results: .loaded([]))

        _ = makeReducer().reduce(&state, .queryChanged(query))

        #expect(state.query == query)
        #expect(state.results == .idle)
    }

    @Test("A debounced search delivers results for the final query only")
    func debouncedSearchUsesLatestQuery() async {
        let store = makeStore()

        store.send(.queryChanged("vo"))
        store.send(.queryChanged("voyage"))
        await store.settle()

        #expect(store.state.results.value?.map(\.title) == ["The Silent Voyage"])
    }

    @Test("Clearing the query cancels the in-flight search")
    func clearingCancelsSearch() async {
        let store = makeStore()

        store.send(.queryChanged("voyage"))
        store.send(.queryChanged(""))
        await store.settle()

        #expect(store.state.results == .idle)
        #expect(!store.hasPendingEffects)
    }

    @Test("Search failures surface as the failed phase")
    func searchFailureSurfaces() async {
        let useCase = SearchMoviesUseCase(repository: FailingCatalogRepository(error: .timedOut))
        let store = Store(
            initialState: SearchReducer.State(),
            reducer: SearchReducer(searchMovies: useCase, debounce: .milliseconds(1)),
        )

        store.send(.queryChanged("voyage"))
        await store.settle()

        #expect(store.state.results == .failed(.timedOut))
    }
}

// MARK: - Helpers
private extension SearchReducerTests {
    func makeReducer() -> SearchReducer {
        SearchReducer(
            searchMovies: SearchMoviesUseCase(repository: PreviewMovieCatalogRepository()),
            debounce: .milliseconds(1),
        )
    }

    func makeStore() -> Store<SearchReducer> {
        Store(initialState: SearchReducer.State(), reducer: makeReducer())
    }
}
