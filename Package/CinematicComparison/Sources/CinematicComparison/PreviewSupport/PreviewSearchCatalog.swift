import CinematicDomain

/// A small in-memory catalog for the previews, answering after a short delay
/// so the loading state is visible.
nonisolated struct PreviewSearchCatalog: MovieCatalogRepository {
    private static let movies = [
        Movie(id: Movie.ID("1"), title: "The Silent Voyage"),
        Movie(id: Movie.ID("2"), title: "Voyage to the Deep"),
        Movie(id: Movie.ID("3"), title: "Northern Lights"),
        Movie(id: Movie.ID("4"), title: "City of Glass"),
    ]

    func topMovies() async throws(MovieError) -> [Movie] {
        Self.movies
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        Self.movies
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        try? await Task.sleep(for: .milliseconds(400))
        return Self.movies.filter { $0.title.localizedStandardContains(query) }
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        throw .notFound
    }
}

// MARK: - Preview
extension SearchMoviesUseCase {
    static let preview = SearchMoviesUseCase(repository: PreviewSearchCatalog())
}
