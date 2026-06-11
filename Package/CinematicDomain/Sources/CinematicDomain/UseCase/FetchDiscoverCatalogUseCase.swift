/// Loads everything the discover screen needs.
///
/// Business rules live here, not in the reducer and not in the repository:
/// the featured chart is required, genre rows load concurrently and degrade
/// gracefully — a failing or empty genre is dropped rather than blanking the
/// whole screen — and rows keep the declared genre order regardless of which
/// network call wins the race.
public struct FetchDiscoverCatalogUseCase: Sendable {
    private let repository: any MovieCatalogRepository

    public init(repository: any MovieCatalogRepository) {
        self.repository = repository
    }

    public func execute() async throws(MovieError) -> DiscoverCatalog {
        let featured = try await repository.topMovies()
        let sections = await loadGenreSections()
        return DiscoverCatalog(featured: featured, sections: sections)
    }
}

// MARK: - Helpers
private extension FetchDiscoverCatalogUseCase {
    func loadGenreSections() async -> [DiscoverCatalog.GenreSection] {
        let loaded = await withTaskGroup(
            of: DiscoverCatalog.GenreSection?.self,
        ) { group in
            for genre in MovieGenre.allCases {
                group.addTask { await loadSection(for: genre) }
            }
            var sections: [MovieGenre: DiscoverCatalog.GenreSection] = [:]
            for await section in group {
                if let section {
                    sections[section.genre] = section
                }
            }
            return sections
        }
        return MovieGenre.allCases.compactMap { loaded[$0] }
    }

    func loadSection(for genre: MovieGenre) async -> DiscoverCatalog.GenreSection? {
        guard
            let movies = try? await repository.topMovies(in: genre),
            !movies.isEmpty
        else { return nil }
        return DiscoverCatalog.GenreSection(genre: genre, movies: movies)
    }
}
