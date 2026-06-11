/// Searches the catalog with input hygiene applied.
///
/// Trims whitespace and short-circuits queries below the minimum length to an
/// empty result, so neither the reducer nor the repository re-implements that
/// rule.
public struct SearchMoviesUseCase: Sendable {
    public static let minimumQueryLength = 2

    private let repository: any MovieCatalogRepository

    public init(repository: any MovieCatalogRepository) {
        self.repository = repository
    }

    public func execute(query: String) async throws(MovieError) -> [Movie] {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard trimmed.count >= Self.minimumQueryLength else { return [] }
        return try await repository.searchMovies(matching: trimmed)
    }
}
