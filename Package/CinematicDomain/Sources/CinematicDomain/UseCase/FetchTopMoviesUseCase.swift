/// Loads one top-movies chart: the overall chart, or a single genre's.
///
/// The entry point for surfaces outside the app's screens — widgets and
/// Shortcuts — that need a short ranked list, not the whole Discover catalog.
public struct FetchTopMoviesUseCase: Sendable {
    private let repository: any MovieCatalogRepository

    public init(repository: any MovieCatalogRepository) {
        self.repository = repository
    }

    /// - Parameters:
    ///   - genre: The genre chart to load, or `nil` for the overall chart.
    ///   - limit: The most movies to return, from the top of the chart.
    public func execute(genre: MovieGenre? = nil, limit: Int = .max) async throws(MovieError) -> [Movie] {
        let chart = if let genre {
            try await repository.topMovies(in: genre)
        } else {
            try await repository.topMovies()
        }
        return Array(chart.prefix(limit))
    }
}
