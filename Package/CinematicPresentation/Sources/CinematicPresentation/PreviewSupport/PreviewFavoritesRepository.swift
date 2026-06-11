import CinematicDomain
import Foundation

/// In-memory favorites with the same broadcast semantics the production
/// repository honors. Used by previews, presentation tests, and UI tests.
public actor PreviewFavoritesRepository: FavoritesRepository {
    private var stored: [Movie]
    private var continuations: [UUID: AsyncStream<[Movie]>.Continuation] = [:]

    public init(initialFavorites: [Movie] = []) {
        stored = initialFavorites
    }

    public func favorites() -> [Movie] {
        stored
    }

    public func isFavorite(_ id: Movie.ID) -> Bool {
        stored.contains { $0.id == id }
    }

    @discardableResult
    public func toggle(_ movie: Movie) -> Bool {
        let isFavorite: Bool
        if let index = stored.firstIndex(where: { $0.id == movie.id }) {
            stored.remove(at: index)
            isFavorite = false
        } else {
            stored.insert(movie, at: 0)
            isFavorite = true
        }
        for continuation in continuations.values {
            continuation.yield(stored)
        }
        return isFavorite
    }

    public func changes() -> AsyncStream<[Movie]> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<[Movie]>.makeStream()
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id) }
        }
        continuations[id] = continuation
        return stream
    }
}

// MARK: - Test support
extension PreviewFavoritesRepository {
    public func subscriberCount() -> Int {
        continuations.count
    }

    /// Ends every open stream so `Store.settle()` can complete in tests.
    public func finishAllStreams() {
        continuations.values.forEach { $0.finish() }
        continuations = [:]
    }
}

// MARK: - Helpers
private extension PreviewFavoritesRepository {
    func removeContinuation(_ id: UUID) {
        continuations[id] = nil
    }
}
