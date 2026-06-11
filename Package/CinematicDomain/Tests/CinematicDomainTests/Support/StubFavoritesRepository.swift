import CinematicDomain
import Foundation

/// In-memory favorites with real broadcast semantics, mirroring the contract
/// production implementations must honor.
actor StubFavoritesRepository: FavoritesRepository {
    private var stored: [Movie] = []
    private var continuations: [UUID: AsyncStream<[Movie]>.Continuation] = [:]

    func favorites() -> [Movie] {
        stored
    }

    func isFavorite(_ id: Movie.ID) -> Bool {
        stored.contains { $0.id == id }
    }

    @discardableResult
    func toggle(_ movie: Movie) -> Bool {
        let isFavorite: Bool
        if let index = stored.firstIndex(where: { $0.id == movie.id }) {
            stored.remove(at: index)
            isFavorite = false
        } else {
            stored.insert(movie, at: 0)
            isFavorite = true
        }
        broadcast()
        return isFavorite
    }

    func changes() -> AsyncStream<[Movie]> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<[Movie]>.makeStream()
        continuation.onTermination = { [weak self] _ in
            Task { await self?.removeContinuation(id) }
        }
        continuations[id] = continuation
        return stream
    }

    /// Ends every open stream so `Store.settle()` can complete in tests.
    func finishAllStreams() {
        continuations.values.forEach { $0.finish() }
        continuations = [:]
    }
}

// MARK: - Helpers
private extension StubFavoritesRepository {
    func broadcast() {
        for continuation in continuations.values {
            continuation.yield(stored)
        }
    }

    func removeContinuation(_ id: UUID) {
        continuations[id] = nil
    }
}
