import CinematicDomain
import Foundation

/// Offline decorator: serves the wrapped repository's last good answers when
/// the network fails.
///
/// A textbook decorator — same protocol in and out, stacked by the app's
/// composition root:
///
/// ```swift
/// CachedMovieCatalogRepository(wrapping: ITunesMovieCatalogRepository(…))
/// ```
///
/// Reads hit the wrapped repository first; every success is persisted, and a
/// failure falls back to the stored copy before surfacing the error. Search
/// passes through untouched — it already runs on the live repository's
/// in-memory catalog.
struct CachedMovieCatalogRepository: MovieCatalogRepository {
    private let wrapped: any MovieCatalogRepository
    private let cache: DiskCache

    init(wrapping wrapped: any MovieCatalogRepository, cache: DiskCache = DiskCache(name: "MovieCatalog")) {
        self.wrapped = wrapped
        self.cache = cache
    }

    func topMovies() async throws(MovieError) -> [Movie] {
        // Closures don't infer a parameter's typed throws (yet) — annotate.
        try await cachedMovies(key: "top-movies") { () async throws(MovieError) in
            try await wrapped.topMovies()
        }
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        try await cachedMovies(key: "genre-\(genre.rawValue)") { () async throws(MovieError) in
            try await wrapped.topMovies(in: genre)
        }
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        try await wrapped.searchMovies(matching: query)
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        do {
            let details = try await wrapped.movieDetails(for: id)
            await cache.write(StoredMovieDetails(details), forKey: "details-\(id.rawValue)")
            return details
        } catch {
            guard let stored: StoredMovieDetails = await cache.read(forKey: "details-\(id.rawValue)") else {
                throw error
            }
            return stored.details
        }
    }
}

// MARK: - Helpers
private extension CachedMovieCatalogRepository {
    func cachedMovies(
        key: String,
        load: () async throws(MovieError) -> [Movie],
    ) async throws(MovieError) -> [Movie] {
        do {
            let movies = try await load()
            await cache.write(movies.map(StoredMovie.init), forKey: key)
            return movies
        } catch {
            guard let stored: [StoredMovie] = await cache.read(forKey: key) else {
                throw error
            }
            return stored.map(\.movie)
        }
    }
}
