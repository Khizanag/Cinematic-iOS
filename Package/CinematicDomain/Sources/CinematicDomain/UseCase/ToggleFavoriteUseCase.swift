/// Adds or removes a movie from favorites.
public struct ToggleFavoriteUseCase: Sendable {
    private let repository: any FavoritesRepository

    public init(repository: any FavoritesRepository) {
        self.repository = repository
    }

    /// Returns whether the movie is a favorite after toggling.
    @discardableResult
    public func execute(movie: Movie) async -> Bool {
        await repository.toggle(movie)
    }
}
