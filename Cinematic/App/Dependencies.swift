import CinematicData
import CinematicDomain
import CinematicPresentation
import SwiftUI

/// The composition root — the only place in the app that knows concrete data
/// sources. Everything above sees domain protocols and use cases.
///
/// `live` stacks the offline-cache decorator over the iTunes repository;
/// `preview` swaps in the in-memory doubles. Same use cases, same features,
/// different world — that one-line swap is the dependency rule paying rent.
nonisolated struct AppDependencies {
    let fetchDiscoverCatalog: FetchDiscoverCatalogUseCase
    let searchMovies: SearchMoviesUseCase
    let fetchMovieDetails: FetchMovieDetailsUseCase
    let toggleFavorite: ToggleFavoriteUseCase
    let observeFavorites: ObserveFavoritesUseCase

    init(catalog: any MovieCatalogRepository, favorites: any FavoritesRepository) {
        fetchDiscoverCatalog = FetchDiscoverCatalogUseCase(repository: catalog)
        searchMovies = SearchMoviesUseCase(repository: catalog)
        fetchMovieDetails = FetchMovieDetailsUseCase(repository: catalog)
        toggleFavorite = ToggleFavoriteUseCase(repository: favorites)
        observeFavorites = ObserveFavoritesUseCase(repository: favorites)
    }
}

// MARK: - Worlds
extension AppDependencies {
    static func live() -> AppDependencies {
        AppDependencies(
            catalog: CachedMovieCatalogRepository(
                wrapping: ITunesMovieCatalogRepository(client: APIClient()),
            ),
            favorites: UserDefaultsFavoritesRepository(),
        )
    }

    static func preview() -> AppDependencies {
        AppDependencies(
            catalog: PreviewMovieCatalogRepository(),
            favorites: PreviewFavoritesRepository(),
        )
    }

    /// `-uiTestMode` keeps UI tests deterministic and offline.
    static func current() -> AppDependencies {
        UITestSupport.isActive ? .preview() : .live()
    }
}

// MARK: - Environment
extension EnvironmentValues {
    @Entry var dependencies: AppDependencies = .preview()
}
