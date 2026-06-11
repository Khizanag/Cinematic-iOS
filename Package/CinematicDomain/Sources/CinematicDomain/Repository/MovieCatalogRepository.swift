/// Read access to the movie catalog.
///
/// The domain owns this contract; the data layer implements it. Use cases and
/// reducers depend on the protocol only, so the concrete backend can be a
/// remote API, a cache decorator, or an in-memory stub without anything above
/// noticing — that is the Clean dependency rule at work.
public protocol MovieCatalogRepository: Sendable {
    /// The overall top-movies chart.
    func topMovies() async throws(MovieError) -> [Movie]

    /// The top chart of a single genre.
    func topMovies(in genre: MovieGenre) async throws(MovieError) -> [Movie]

    /// Movies matching a free-text query.
    func searchMovies(matching query: String) async throws(MovieError) -> [Movie]

    /// The full record for one movie.
    func movieDetails(for id: Movie.ID) async throws(MovieError) -> MovieDetails
}
