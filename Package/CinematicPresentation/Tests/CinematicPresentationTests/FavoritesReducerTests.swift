import CinematicDomain
@testable import CinematicPresentation
import MVIKit
import Testing

@MainActor
struct FavoritesReducerTests {
    @Test("Streams the current list and live changes")
    func streamsListAndChanges() async {
        let movie = PreviewCatalog.movies[0]
        let favorites = PreviewFavoritesRepository(initialFavorites: [movie])
        let store = makeStore(favorites: favorites)

        store.send(.task)
        await waitUntil { store.state.favorites.value == [movie] }

        store.send(.removeTapped(movie))
        await waitUntil { store.state.favorites.value?.isEmpty == true }
        #expect(store.state.favorites.value?.isEmpty == true)
    }

    @Test("task subscribes exactly once")
    func taskSubscribesOnce() async {
        let favorites = PreviewFavoritesRepository()
        let store = makeStore(favorites: favorites)

        store.send(.task)
        await waitUntil { store.state.favorites.value != nil }
        store.send(.task)

        #expect(await favorites.subscriberCount() == 1)
    }
}

// MARK: - Helpers
private extension FavoritesReducerTests {
    func makeStore(favorites: PreviewFavoritesRepository) -> Store<FavoritesReducer> {
        Store(
            initialState: FavoritesReducer.State(),
            reducer: FavoritesReducer(
                observeFavorites: ObserveFavoritesUseCase(repository: favorites),
                toggleFavorite: ToggleFavoriteUseCase(repository: favorites),
            ),
        )
    }
}
