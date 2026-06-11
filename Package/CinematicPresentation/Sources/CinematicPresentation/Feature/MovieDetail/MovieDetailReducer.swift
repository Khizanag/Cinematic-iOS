import CinematicDomain
import MVIKit

/// State machine of one movie's detail screen.
///
/// Favorite state is *observed*, never assumed: tapping the heart only asks
/// the use case to toggle, and the favorites stream reports back. Every
/// screen showing the same movie stays consistent for free, because they all
/// watch the same source of truth.
struct MovieDetailReducer: Reducer {
    struct State: Equatable {
        let movieID: Movie.ID
        var details: LoadingPhase<MovieDetails, MovieError> = .idle
        var isFavorite = false
    }

    enum Intent: Sendable {
        case task
        case retry
        case detailsLoaded(MovieDetails)
        case loadFailed(MovieError)
        case favoriteTapped
        case favoritesChanged([Movie])
    }

    private let fetchMovieDetails: FetchMovieDetailsUseCase
    private let toggleFavorite: ToggleFavoriteUseCase
    private let observeFavorites: ObserveFavoritesUseCase

    init(
        fetchMovieDetails: FetchMovieDetailsUseCase,
        toggleFavorite: ToggleFavoriteUseCase,
        observeFavorites: ObserveFavoritesUseCase,
    ) {
        self.fetchMovieDetails = fetchMovieDetails
        self.toggleFavorite = toggleFavorite
        self.observeFavorites = observeFavorites
    }

    func reduce(_ state: inout State, _ intent: Intent) -> Effect<Intent> {
        switch intent {
        case .task:
            guard state.details.value == nil else { return .none }
            return .merge(load(&state), observe())

        case .retry:
            return load(&state)

        case let .detailsLoaded(details):
            state.details = .loaded(details)
            return .none

        case let .loadFailed(error):
            state.details = .failed(error)
            return .none

        case .favoriteTapped:
            guard let movie = state.details.value?.movie else { return .none }
            let toggleFavorite = toggleFavorite
            return .run { _ in
                await toggleFavorite.execute(movie: movie)
            }

        case let .favoritesChanged(favorites):
            state.isFavorite = favorites.contains { $0.id == state.movieID }
            return .none
        }
    }
}

// MARK: - Effects
private extension MovieDetailReducer {
    func load(_ state: inout State) -> Effect<Intent> {
        state.details = .loading
        let fetchMovieDetails = fetchMovieDetails
        let movieID = state.movieID
        return .run(id: "load") { send in
            do throws(MovieError) {
                let details = try await fetchMovieDetails.execute(id: movieID)
                await send(.detailsLoaded(details))
            } catch {
                await send(.loadFailed(error))
            }
        }
    }

    /// Lives as long as the store: the screen tracks favorite changes made
    /// anywhere in the app. Store deinit cancels it.
    func observe() -> Effect<Intent> {
        let observeFavorites = observeFavorites
        return .run(id: "observeFavorites") { send in
            for await favorites in observeFavorites.execute() {
                await send(.favoritesChanged(favorites))
            }
        }
    }
}
