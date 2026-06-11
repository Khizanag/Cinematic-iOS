/// Loads the full record for one movie.
public struct FetchMovieDetailsUseCase: Sendable {
    private let repository: any MovieCatalogRepository

    public init(repository: any MovieCatalogRepository) {
        self.repository = repository
    }

    public func execute(id: Movie.ID) async throws(MovieError) -> MovieDetails {
        try await repository.movieDetails(for: id)
    }
}
