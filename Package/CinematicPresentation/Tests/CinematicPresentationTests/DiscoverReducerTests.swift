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

    @Test("Pull-to-refresh keeps content visible while reloading")
    func refreshKeepsContentAndReloads() async {
        let store = makeStore()
        store.send(.task)
        await store.settle()

        store.send(.refresh)
        #expect(store.state.isRefreshing)
        #expect(store.state.catalog.value != nil)
        await store.settle()

        #expect(!store.state.isRefreshing)
        #expect(store.state.catalog.value?.featured == PreviewCatalog.movies)
    }

    @Test("A failed refresh is non-destructive — content is preserved")
    func failedRefreshKeepsContent() async {
        let useCase = FetchDiscoverCatalogUseCase(repository: FailingCatalogRepository())
        let store = Store(
            initialState: DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover)),
            reducer: DiscoverReducer(fetchDiscoverCatalog: useCase),
        )

        store.send(.refresh)
        await store.settle()

        #expect(!store.state.isRefreshing)
        #expect(store.state.catalog == .loaded(PreviewCatalog.discover))
    }
}

// MARK: - Genre filter
extension DiscoverReducerTests {
    @Test("The filter offers only genres whose row loaded, in row order")
    func availableGenresFollowSections() {
        let state = DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover))

        #expect(state.availableGenres == [.actionAndAdventure, .drama, .comedy])
        #expect(DiscoverReducer.State().availableGenres.isEmpty)
    }

    @Test("Selecting a genre narrows to its row without an effect")
    func selectingGenreNarrows() {
        let store = Store(
            initialState: DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover)),
            reducer: makeReducer(),
        )

        store.send(.genreSelected(.drama))

        #expect(!store.hasPendingEffects)
        #expect(store.state.selectedGenre == .drama)
        #expect(store.state.selectedSection == PreviewCatalog.discover.sections[1])
    }

    @Test("Selecting all clears the filter")
    func selectingAllClears() {
        var state = DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover), selectedGenre: .drama)

        _ = makeReducer().reduce(&state, .genreSelected(nil))

        #expect(state.selectedGenre == nil)
        #expect(state.selectedSection == nil)
    }

    @Test("A genre without a loaded row is ignored", arguments: [MovieGenre.horror, .thriller])
    func unavailableGenreIgnored(genre: MovieGenre) {
        var state = DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover), selectedGenre: .comedy)

        _ = makeReducer().reduce(&state, .genreSelected(genre))

        #expect(state.selectedGenre == .comedy)
    }

    @Test("A reload that keeps the selected genre keeps the filter")
    func reloadKeepsAvailableSelection() {
        var state = DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover), selectedGenre: .drama)

        _ = makeReducer().reduce(&state, .refreshSucceeded(PreviewCatalog.discover))

        #expect(state.selectedGenre == .drama)
    }

    @Test("A reload that drops the selected genre falls back to every row")
    func reloadDroppingGenreClearsSelection() {
        let withoutDrama = DiscoverCatalog(
            featured: PreviewCatalog.discover.featured,
            sections: PreviewCatalog.discover.sections.filter { $0.genre != .drama },
        )
        let reducer = makeReducer()
        var refreshed = DiscoverReducer.State(catalog: .loaded(PreviewCatalog.discover), selectedGenre: .drama)
        var reloaded = refreshed

        _ = reducer.reduce(&refreshed, .refreshSucceeded(withoutDrama))
        _ = reducer.reduce(&reloaded, .catalogLoaded(withoutDrama))

        #expect(refreshed.selectedGenre == nil)
        #expect(reloaded.selectedGenre == nil)
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
