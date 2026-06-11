import CinematicDomain
import Foundation

/// The live catalog, backed by Apple's iTunes feeds.
///
/// The feeds expose charts and lookup but no text search, so `searchMovies`
/// loads the full catalog (overall chart plus every genre, briefly cached
/// in-memory) and filters locally. The repository absorbs that quirk — to
/// callers, search is just search, and swapping in an API with real search
/// would change only this file.
struct ITunesMovieCatalogRepository: MovieCatalogRepository {
    private let client: APIClient
    private let searchIndex = CatalogSearchIndex()
    private let feedLimit = 50

    init(client: APIClient) {
        self.client = client
    }

    func topMovies() async throws(MovieError) -> [Movie] {
        let response: TopMoviesFeedDTO = try await client.fetch(.topMovies(limit: feedLimit))
        return response.feed.entries.map(MovieMapper.movie(from:))
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        let endpoint = ITunesEndpoint.topMoviesInGenre(genreID: genre.feedGenreID, limit: feedLimit)
        let response: TopMoviesFeedDTO = try await client.fetch(endpoint)
        return response.feed.entries.map(MovieMapper.movie(from:))
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        if let catalog = await searchIndex.freshCatalog() {
            return Self.results(in: catalog, matching: query)
        }
        let catalog = try await loadFullCatalog()
        await searchIndex.store(catalog)
        return Self.results(in: catalog, matching: query)
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        let response: LookupResponseDTO = try await client.fetch(.lookup(id: id.rawValue))
        guard let first = response.results.first else {
            throw .notFound
        }
        guard let details = MovieMapper.movieDetails(from: first) else {
            throw .decodingFailed(reason: "Lookup result for \(id.rawValue) is missing required fields")
        }
        return details
    }
}

// MARK: - Catalog loading
private extension ITunesMovieCatalogRepository {
    /// The overall chart is required; genre charts degrade gracefully and
    /// load concurrently. Duplicates (a movie charting in several genres)
    /// collapse by id.
    func loadFullCatalog() async throws(MovieError) -> [Movie] {
        let top = try await topMovies()
        let byGenre = await withTaskGroup(of: [Movie].self) { group in
            for genre in MovieGenre.allCases {
                group.addTask { (try? await topMovies(in: genre)) ?? [] }
            }
            var movies: [Movie] = []
            for await chart in group {
                movies.append(contentsOf: chart)
            }
            return movies
        }

        var seen = Set<Movie.ID>()
        return (top + byGenre).filter { seen.insert($0.id).inserted }
    }
}

// MARK: - Local search
private extension ITunesMovieCatalogRepository {
    static func results(in catalog: [Movie], matching query: String) -> [Movie] {
        catalog
            .filter { matches($0, query: query) }
            .sorted { rank($0, query: query) < rank($1, query: query) }
    }

    static func matches(_ movie: Movie, query: String) -> Bool {
        contains(movie.title, query: query)
            || contains(movie.directorName, query: query)
    }

    static func contains(_ text: String?, query: String) -> Bool {
        text?.range(of: query, options: [.caseInsensitive, .diacriticInsensitive]) != nil
    }

    /// Title prefix matches first, then title matches, then director matches —
    /// alphabetical within each band.
    static func rank(_ movie: Movie, query: String) -> (Int, String) {
        let band = if movie.title.lowercased().hasPrefix(query.lowercased()) {
            0
        } else if contains(movie.title, query: query) {
            1
        } else {
            2
        }
        return (band, movie.title)
    }
}
