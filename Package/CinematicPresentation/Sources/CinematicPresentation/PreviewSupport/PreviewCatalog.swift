import CinematicDomain
import Foundation

/// Deterministic sample data for previews, presentation tests, and the app's
/// UI-test stub mode. Public on purpose: the composition root reuses these
/// doubles, so there is exactly one set of fixtures in the whole project.
nonisolated public enum PreviewCatalog {
    public static let movies: [Movie] = [
        makeMovie(id: "1", title: "The Silent Voyage", director: "Mira Holt", genre: "Drama"),
        makeMovie(id: "2", title: "Midnight Circuit", director: "Dele Akande", genre: "Action & Adventure"),
        makeMovie(id: "3", title: "Paper Lanterns", director: "Yuna Sato", genre: "Kids & Family"),
        makeMovie(id: "4", title: "The Last Cartographer", director: "Tomas Vey", genre: "Sci-Fi & Fantasy"),
        makeMovie(id: "5", title: "Neon Tide", director: "Ana Reyes", genre: "Thriller"),
        makeMovie(id: "6", title: "Winter's Apprentice", director: "Karl Osei", genre: "Drama"),
        makeMovie(id: "7", title: "The Glass Garden", director: "Mira Holt", genre: "Horror"),
        makeMovie(id: "8", title: "Echoes of Tomorrow", director: "Lena Brandt", genre: "Comedy"),
    ]

    public static let discover = DiscoverCatalog(
        featured: movies,
        sections: [
            DiscoverCatalog.GenreSection(genre: .actionAndAdventure, movies: Array(movies.prefix(4))),
            DiscoverCatalog.GenreSection(genre: .drama, movies: Array(movies.suffix(4))),
            DiscoverCatalog.GenreSection(genre: .comedy, movies: Array(movies.dropFirst(2))),
        ],
    )

    public static func details(for id: Movie.ID) -> MovieDetails? {
        guard let movie = movies.first(where: { $0.id == id }) else { return nil }
        return MovieDetails(
            movie: movie,
            fullSummary: """
            A quietly devastating story told across three decades, following the \
            people who stayed behind and the maps they made of one another.
            """,
            advisoryRating: "PG-13",
            duration: .seconds(8340),
            trailerURL: URL(string: "https://example.com/preview.m4v"),
            storeURL: URL(string: "https://example.com/store/\(id.rawValue)"),
        )
    }
}

// MARK: - Builders
nonisolated private extension PreviewCatalog {
    static func makeMovie(id: String, title: String, director: String, genre: String) -> Movie {
        Movie(
            id: Movie.ID(id),
            title: title,
            directorName: director,
            summary: "A short synopsis used by previews and tests.",
            genreName: genre,
            releaseDate: Date(timeIntervalSince1970: 1_770_000_000),
            price: Price(amount: Decimal(string: "14.99") ?? .zero, currencyCode: "USD"),
        )
    }
}
