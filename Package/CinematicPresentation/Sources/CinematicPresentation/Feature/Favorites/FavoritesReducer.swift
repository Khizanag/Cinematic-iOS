import CinematicDomain
import MVIKit

/// State machine of the favorites tab.
///
/// `Never` as the failure type is a statement, not a shortcut: favorites are
/// local and cannot fail to load, and the compiler now proves no error UI is
/// needed here.
struct FavoritesReducer: Reducer {
    struct State: Equatable {
        var favorites: LoadingPhase<[Movie], Never> = .idle
    }

    enum Intent: Sendable {
        case task
        case favoritesChanged([Movie])
        case removeTapped(Movie)
    }

    private let observeFavorites: ObserveFavoritesUseCase
    private let toggleFavorite: ToggleFavoriteUseCase

    init(observeFavorites: ObserveFavoritesUseCase, toggleFavorite: ToggleFavoriteUseCase) {
        self.observeFavorites = observeFavorites
        self.toggleFavorite = toggleFavorite
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case .task:
            guard case .idle = state.favorites else { return .none }
            state.favorites = .loading
            return observe()

        case let .favoritesChanged(favorites):
            state.favorites = .loaded(favorites)
            return .none

        case let .removeTapped(movie):
            let toggleFavorite = toggleFavorite
            return .run { _ in
                await toggleFavorite.execute(movie: movie)
            }
        }
    }
}

// MARK: - Effects
private extension FavoritesReducer {
    func observe() -> Effect<Intent> {
        let observeFavorites = observeFavorites
        return .run(id: "observe") { send in
            for await favorites in observeFavorites.execute() {
                await send(.favoritesChanged(favorites))
            }
        }
    }
}
