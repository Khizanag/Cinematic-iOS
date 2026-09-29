import CinematicDomain

/// A catalog that answers every search with one movie named after the query,
/// records what it was asked, and can hold an answer back.
///
/// A held answer ignores cancellation, as many transports do, so a stale
/// response genuinely arrives after a newer one.
actor ScriptedCatalogRepository: MovieCatalogRepository {
    private(set) var receivedQueries: [String] = []
    private(set) var answeredQueries: [String] = []

    private let delays: [String: Duration]
    private let failure: MovieError?

    init(delays: [String: Duration] = [:], failure: MovieError? = nil) {
        self.delays = delays
        self.failure = failure
    }

    static func movie(for query: String) -> Movie {
        Movie(id: Movie.ID(query), title: "Result for \(query)")
    }

    func searchMovies(matching query: String) async throws(MovieError) -> [Movie] {
        receivedQueries.append(query)
        if let delay = delays[query] {
            await Task.detached { try? await Task.sleep(for: delay) }.value
        }
        answeredQueries.append(query)
        if let failure {
            throw failure
        }
        return [Self.movie(for: query)]
    }

    func topMovies() async throws(MovieError) -> [Movie] {
        throw .notFound
    }

    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie] {
        throw .notFound
    }

    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails {
        throw .notFound
    }
}
