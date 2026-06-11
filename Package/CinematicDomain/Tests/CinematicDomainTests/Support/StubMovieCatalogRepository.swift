import CinematicDomain

/// Value-typed stub: configure results at construction, no shared state
/// between tests.
struct StubMovieCatalogRepository: MovieCatalogRepository {
    var topMoviesResult: Result<[Movie], MovieError> = .success([])
    var genreResults: [MovieGenre: Result<[Movie], MovieError>] = [:]
    var searchResult: Result<[Movie], MovieError> = .success([])
    var detailsResult: Result<MovieDetails, MovieError> = .failure(.notFound)

    func topMovies() async throws(MovieError) -> [Movie] {
        try topMoviesResult.get()
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        try (genreResults[genre] ?? .success([])).get()
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        try searchResult.get()
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        try detailsResult.get()
    }
}
