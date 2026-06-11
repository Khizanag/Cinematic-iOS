import CinematicDomain
import Foundation

/// An in-memory catalog over ``PreviewCatalog`` — previews and UI tests run
/// the real use cases against it, with no network anywhere.
nonisolated public struct PreviewMovieCatalogRepository: MovieCatalogRepository {
    public init() {}

    public func topMovies() async throws(MovieError) -> [Movie] {
        PreviewCatalog.movies
    }

    public func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        PreviewCatalog.discover.sections.first { $0.genre == genre }?.movies ?? []
    }

    public func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        PreviewCatalog.movies.filter {
            $0.title.localizedCaseInsensitiveContains(query)
        }
    }

    public func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        guard let details = PreviewCatalog.details(for: id) else {
            throw .notFound
        }
        return details
    }
}
