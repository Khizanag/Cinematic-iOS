import AppIntents
import CinematicDomain

/// Resolves movies for Siri and Shortcuts: by id, by typed text, and as
/// suggestions (favorites first, then the top of the chart).
struct MovieEntityQuery: EntityStringQuery {
    static let suggestionLimit = 10

    @Dependency private var registered: AppDependencies
    private var injected: AppDependencies?

    init() {}

    /// Tests pass dependencies directly instead of registering them.
    init(dependencies: AppDependencies) {
        injected = dependencies
    }

    func entities(for identifiers: [MovieEntity.ID]) async throws -> [MovieEntity] {
        let fetchMovieDetails = dependencies.fetchMovieDetails
        let found = await withTaskGroup(of: Movie?.self) { group in
            for id in identifiers {
                group.addTask { try? await fetchMovieDetails.execute(id: Movie.ID(id)).movie }
            }
            var movies: [Movie.ID: Movie] = [:]
            for await movie in group {
                if let movie {
                    movies[movie.id] = movie
                }
            }
            return movies
        }
        // An id that no longer resolves drops out instead of failing the lot.
        return identifiers.compactMap { found[Movie.ID($0)] }.map(MovieEntity.init)
    }

    func entities(matching string: String) async throws -> [MovieEntity] {
        try await dependencies.searchMovies.execute(query: string).map(MovieEntity.init)
    }

    func suggestedEntities() async throws -> [MovieEntity] {
        let favorites = await currentFavorites()
        let top = (try? await dependencies.fetchTopMovies.execute(limit: Self.suggestionLimit)) ?? []
        let favoriteIDs = Set(favorites.map(\.id))
        let suggestions = favorites + top.filter { !favoriteIDs.contains($0.id) }
        return suggestions.map(MovieEntity.init)
    }
}

// MARK: - Helpers
private extension MovieEntityQuery {
    var dependencies: AppDependencies {
        injected ?? registered
    }

    func currentFavorites() async -> [Movie] {
        // The stream's first element is the current list.
        for await favorites in dependencies.observeFavorites.execute() {
            return favorites
        }
        return []
    }
}
