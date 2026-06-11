@testable import CinematicData
import CinematicDomain
import Foundation
import Testing

struct CachedMovieCatalogRepositoryTests {
    private let cacheDirectory = FileManager.default.temporaryDirectory
        .appending(path: "cache-tests-\(UUID().uuidString)")

    @Test("Network successes are persisted and served when the network dies")
    func fallsBackToStoredCopy() async throws {
        let movie = makeMovie(title: "Stored")
        let online = CachedMovieCatalogRepository(
            wrapping: StubCatalog(topMoviesResult: .success([movie])),
            cache: DiskCache(directory: cacheDirectory),
        )
        _ = try await online.topMovies()

        let offline = CachedMovieCatalogRepository(
            wrapping: StubCatalog(topMoviesResult: .failure(.offline)),
            cache: DiskCache(directory: cacheDirectory),
        )

        #expect(try await offline.topMovies() == [movie])
    }

    @Test("Failures with an empty cache propagate the original error")
    func emptyCachePropagatesError() async {
        let repository = CachedMovieCatalogRepository(
            wrapping: StubCatalog(topMoviesResult: .failure(.timedOut)),
            cache: DiskCache(directory: cacheDirectory),
        )

        await #expect(throws: MovieError.timedOut) {
            try await repository.topMovies()
        }
    }

    @Test("Detail records fall back per movie")
    func detailsFallBack() async throws {
        let details = makeMovieDetails()
        let online = CachedMovieCatalogRepository(
            wrapping: StubCatalog(detailsResult: .success(details)),
            cache: DiskCache(directory: cacheDirectory),
        )
        _ = try await online.movieDetails(for: details.movie.id)

        let offline = CachedMovieCatalogRepository(
            wrapping: StubCatalog(detailsResult: .failure(.offline)),
            cache: DiskCache(directory: cacheDirectory),
        )

        #expect(try await offline.movieDetails(for: details.movie.id) == details)
    }
}

// MARK: - Fixtures
private struct StubCatalog: MovieCatalogRepository {
    var topMoviesResult: Result<[Movie], MovieError> = .success([])
    var detailsResult: Result<MovieDetails, MovieError> = .failure(.notFound)

    func topMovies() async throws(MovieError) -> [Movie] {
        try topMoviesResult.get()
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        try topMoviesResult.get()
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        try topMoviesResult.get()
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        try detailsResult.get()
    }
}

func makeMovie(id: String = "1", title: String = "Movie") -> Movie {
    Movie(
        id: Movie.ID(id),
        title: title,
        directorName: "Director",
        summary: "Summary",
        genreName: "Drama",
        posterURL: URL(string: "https://example.com/poster/113x170bb.png"),
        largePosterURL: URL(string: "https://example.com/poster/600x600bb.jpg"),
        releaseDate: Date(timeIntervalSince1970: 1_750_000_000),
        price: Price(amount: 25, currencyCode: "USD"),
    )
}

func makeMovieDetails() -> MovieDetails {
    MovieDetails(
        movie: makeMovie(),
        fullSummary: "Full summary",
        advisoryRating: "PG-13",
        duration: .seconds(5400),
        trailerURL: URL(string: "https://example.com/trailer.m4v"),
        storeURL: URL(string: "https://example.com/store"),
    )
}
