import CinematicDomain
import Foundation
import OSLog

/// Favorites persisted as JSON in `UserDefaults`, broadcasting every change
/// to every observer.
///
/// `UserDefaults` is the right tool at this scale — a small user-owned list
/// read at launch; a database would be ceremony. Because callers only know
/// `FavoritesRepository`, swapping in SwiftData later touches exactly one
/// line of the composition root.
actor UserDefaultsFavoritesRepository: FavoritesRepository {
    private let defaults: UserDefaults
    private let key = "favorites.movies.v1"
    private let logger = Logger(subsystem: "com.khizanag.cinematic", category: "Favorites")
    private var continuations: [UUID: AsyncStream<[Movie]>.Continuation] = [:]
    private var cached: [Movie]?

    /// Pass a suite name to isolate storage (tests do); `nil` uses the
    /// standard defaults. Injecting the *name* instead of a `UserDefaults`
    /// instance keeps the non-Sendable object inside the actor.
    init(suiteName: String? = nil) {
        defaults = suiteName.flatMap { UserDefaults(suiteName: $0) } ?? .standard
    }

    func favorites() -> [Movie] {
        load()
    }

    func isFavorite(_ id: Movie.ID) -> Bool {
        load().contains { $0.id == id }
    }

    @discardableResult
    func toggle(_ movie: Movie) -> Bool {
        var favorites = load()
        let isFavorite: Bool
        if let index = favorites.firstIndex(where: { $0.id == movie.id }) {
            favorites.remove(at: index)
            isFavorite = false
        } else {
            favorites.insert(movie, at: 0)
            isFavorite = true
        }
        save(favorites)
        broadcast(favorites)
        return isFavorite
    }

    func changes() -> AsyncStream<[Movie]> {
        let id = UUID()
        let (stream, continuation) = AsyncStream<[Movie]>.makeStream()
        continuation.onTermination = { _ in
            Task { await self.removeContinuation(id) }
        }
        continuations[id] = continuation
        return stream
    }
}

// MARK: - Persistence
private extension UserDefaultsFavoritesRepository {
    func load() -> [Movie] {
        if let cached {
            return cached
        }
        guard let data = defaults.data(forKey: key) else { return [] }
        do {
            let movies = try JSONDecoder().decode([StoredMovie].self, from: data).map(\.movie)
            cached = movies
            return movies
        } catch {
            logger.error("Could not decode stored favorites: \(error)")
            return []
        }
    }

    func save(_ favorites: [Movie]) {
        cached = favorites
        do {
            let data = try JSONEncoder().encode(favorites.map(StoredMovie.init))
            defaults.set(data, forKey: key)
        } catch {
            logger.error("Could not encode favorites: \(error)")
        }
    }
}

// MARK: - Broadcasting
private extension UserDefaultsFavoritesRepository {
    func broadcast(_ favorites: [Movie]) {
        for continuation in continuations.values {
            continuation.yield(favorites)
        }
    }

    func removeContinuation(_ id: UUID) {
        continuations[id] = nil
    }
}
