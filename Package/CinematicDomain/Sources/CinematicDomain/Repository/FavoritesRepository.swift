/// The user's locally stored favorite movies.
///
/// Operations don't throw: favorites live on-device and persistence failures
/// degrade to in-memory state rather than burdening every caller.
public protocol FavoritesRepository: Sendable {
    /// The current favorites, most recently added first.
    func favorites() async -> [Movie]

    func isFavorite(_ id: Movie.ID) async -> Bool

    /// Toggles the movie and returns whether it is a favorite afterwards.
    @discardableResult
    func toggle(_ movie: Movie) async -> Bool

    /// A fresh stream of the full favorites list, emitting on every change.
    ///
    /// Each call creates an independent subscription. The method is `async`
    /// on purpose: implementations register the subscriber *before*
    /// returning, so no change emitted after the call can be missed.
    func changes() async -> AsyncStream<[Movie]>
}
