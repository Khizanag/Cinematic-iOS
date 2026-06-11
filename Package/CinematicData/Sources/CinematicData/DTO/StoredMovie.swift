import CinematicDomain
import Foundation

/// The persisted shape of a movie — used by the offline cache and the
/// favorites store.
///
/// Domain entities stay free of `Codable`; this DTO owns the stored format,
/// so a schema change is a data-layer migration instead of a domain edit.
struct StoredMovie: Codable {
    let id: String
    let title: String
    let directorName: String?
    let summary: String?
    let genreName: String?
    let posterURL: URL?
    let largePosterURL: URL?
    let releaseDate: Date?
    let priceAmount: Decimal?
    let priceCurrency: String?

    init(_ movie: Movie) {
        id = movie.id.rawValue
        title = movie.title
        directorName = movie.directorName
        summary = movie.summary
        genreName = movie.genreName
        posterURL = movie.posterURL
        largePosterURL = movie.largePosterURL
        releaseDate = movie.releaseDate
        priceAmount = movie.price?.amount
        priceCurrency = movie.price?.currencyCode
    }

    var movie: Movie {
        Movie(
            id: Movie.ID(id),
            title: title,
            directorName: directorName,
            summary: summary,
            genreName: genreName,
            posterURL: posterURL,
            largePosterURL: largePosterURL,
            releaseDate: releaseDate,
            price: price,
        )
    }
}

// MARK: - Helpers
private extension StoredMovie {
    var price: Price? {
        guard let priceAmount, let priceCurrency else { return nil }
        return Price(amount: priceAmount, currencyCode: priceCurrency)
    }
}

/// The persisted shape of a movie's detail record, for offline fallback.
struct StoredMovieDetails: Codable {
    let movie: StoredMovie
    let fullSummary: String?
    let advisoryRating: String?
    let durationSeconds: Double?
    let trailerURL: URL?
    let storeURL: URL?

    init(_ details: MovieDetails) {
        movie = StoredMovie(details.movie)
        fullSummary = details.fullSummary
        advisoryRating = details.advisoryRating
        durationSeconds = details.duration.map { Double($0.components.seconds) }
        trailerURL = details.trailerURL
        storeURL = details.storeURL
    }

    var details: MovieDetails {
        MovieDetails(
            movie: movie.movie,
            fullSummary: fullSummary,
            advisoryRating: advisoryRating,
            duration: durationSeconds.map { .seconds($0) },
            trailerURL: trailerURL,
            storeURL: storeURL,
        )
    }
}
