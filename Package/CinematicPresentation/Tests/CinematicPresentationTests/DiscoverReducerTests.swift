import CinematicDomain
@testable import CinematicPresentation
import MVIKit
import Testing

@MainActor
struct DiscoverReducerTests {
    @Test("task moves idle to loading")
    func taskStartsLoading() {
        var state = DiscoverReducer.State()

        _ = makeReducer().reduce(&state, .task)

        #expect(state.catalog.isLoading)
    }

    @Test("Loaded and failed intents are plain state transitions")
    func terminalTransitions() {
        let reducer = makeReducer()
        var state = DiscoverReducer.State()

        _ = reducer.reduce(&state, .catalogLoaded(PreviewCatalog.discover))
        #expect(state.catalog == .loaded(PreviewCatalog.discover))

        _ = reducer.reduce(&state, .loadFailed(.offline))
        #expect(state.catalog == .failed(.offline))
    }

    @Test("The full loop loads the catalog through the use case")
    func storeLoadsCatalog() async {
        let store = makeStore()

        store.send(.task)
        await store.settle()

        #expect(store.state.catalog.value?.featured == PreviewCatalog.movies)
        #expect(store.state.catalog.value?.sections.isEmpty == false)
    }

    @Test("task is idempotent once content is loaded")
    func taskKeepsLoadedContent() async {
        let store = makeStore()
        store.send(.task)
        await store.settle()

        store.send(.task)

        #expect(!store.hasPendingEffects)
        #expect(store.state.catalog.value != nil)
    }

    @Test("Failures surface as the failed phase")
    func storeSurfacesFailure() async {
        let useCase = FetchDiscoverCatalogUseCase(repository: FailingCatalogRepository())
        let store = Store(
            initialState: DiscoverReducer.State(),
            reducer: DiscoverReducer(fetchDiscoverCatalog: useCase),
        )

        store.send(.task)
        await store.settle()

        #expect(store.state.catalog == .failed(.offline))
    }
}

// MARK: - Helpers
private extension DiscoverReducerTests {
    func makeReducer() -> DiscoverReducer {
        DiscoverReducer(
            fetchDiscoverCatalog: FetchDiscoverCatalogUseCase(repository: PreviewMovieCatalogRepository()),
        )
    }

    func makeStore() -> Store<DiscoverReducer> {
        Store(initialState: DiscoverReducer.State(), reducer: makeReducer())
    }
}
