import CinematicDomain
@testable import CinematicPresentation
import MVIKit
import Testing

@MainActor
struct MovieDetailReducerTests {
    @Test("Loads details and follows favorite changes from the stream")
    func loadsDetailsAndObservesFavorites() async {
        let favorites = PreviewFavoritesRepository()
        let movie = PreviewCatalog.movies[0]
        let store = makeStore(movieID: movie.id, favorites: favorites)

        store.send(.task)
        await waitUntil { store.state.details.value != nil }

        #expect(store.state.details.value?.movie.id == movie.id)
        #expect(!store.state.isFavorite)

        await favorites.toggle(movie)
        await waitUntil { store.state.isFavorite }
        #expect(store.state.isFavorite)
    }

    @Test("Tapping the heart toggles through the use case and round-trips")
    func favoriteTappedTogglesThroughStream() async {
        let favorites = PreviewFavoritesRepository()
        let movie = PreviewCatalog.movies[1]
        let store = makeStore(movieID: movie.id, favorites: favorites)
        store.send(.task)
        await waitUntil { store.state.details.value != nil }

        store.send(.favoriteTapped)
        await waitUntil { store.state.isFavorite }

        store.send(.favoriteTapped)
        await waitUntil { !store.state.isFavorite }
        #expect(await favorites.favorites().isEmpty)
    }

    @Test("A failing lookup surfaces the failed phase, favorites unaffected")
    func failingLookupSurfaces() async {
        let favorites = PreviewFavoritesRepository()
        let store = Store(
            initialState: MovieDetailReducer.State(movieID: Movie.ID("missing")),
            reducer: MovieDetailReducer(
                fetchMovieDetails: FetchMovieDetailsUseCase(repository: FailingCatalogRepository(error: .notFound)),
                toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
                observeFavorites: ObserveFavoritesUseCase(repository: favorites),
            ),
        )

        store.send(.task)
        await waitUntil {
            if case .failed = store.state.details { true } else { false }
        }

        #expect(store.state.details == .failed(.notFound))
    }
}

// MARK: - Helpers
private extension MovieDetailReducerTests {
    func makeStore(
        movieID: Movie.ID,
        favorites: PreviewFavoritesRepository,
    ) -> Store<MovieDetailReducer> {
        Store(
            initialState: MovieDetailReducer.State(movieID: movieID),
            reducer: MovieDetailReducer(
                fetchMovieDetails: FetchMovieDetailsUseCase(repository: PreviewMovieCatalogRepository()),
                toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
                observeFavorites: ObserveFavoritesUseCase(repository: favorites),
            ),
        )
    }
}
