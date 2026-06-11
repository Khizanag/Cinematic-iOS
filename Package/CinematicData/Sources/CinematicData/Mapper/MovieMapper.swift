import CinematicDomain
import Foundation

/// Translates wire DTOs into domain entities — the one-way door between the
/// API's vocabulary and the app's.
enum MovieMapper {
    static let largePosterSize = 600

    static func movie(from entry: FeedEntryDTO) -> Movie {
        let posterURL = entry.images?.last.flatMap { URL(string: $0.label) }
        return Movie(
            id: Movie.ID(entry.id.value),
            title: entry.name.label,
            directorName: entry.artist?.label,
            summary: entry.summary?.label,
            genreName: entry.category?.attributes?.term,
            posterURL: posterURL,
            largePosterURL: ArtworkURL.resized(posterURL, to: largePosterSize),
            releaseDate: entry.releaseDate?.label,
            price: price(from: entry.price),
        )
    }

    static func movieDetails(from dto: LookupMovieDTO) -> MovieDetails? {
        guard let title = dto.trackName else { return nil }
        let posterURL = dto.artworkURL100.flatMap(URL.init(string:))
        let movie = Movie(
            id: Movie.ID(String(dto.trackID)),
            title: title,
            directorName: dto.artistName,
            summary: dto.shortDescription ?? dto.longDescription,
            genreName: dto.primaryGenreName,
            posterURL: posterURL,
            largePosterURL: ArtworkURL.resized(posterURL, to: largePosterSize),
            releaseDate: dto.releaseDate,
            price: price(amount: dto.trackPrice, currency: dto.currency),
        )
        return MovieDetails(
            movie: movie,
            fullSummary: dto.longDescription ?? dto.shortDescription,
            advisoryRating: dto.contentAdvisoryRating,
            duration: dto.trackTimeMillis.map { .milliseconds($0) },
            trailerURL: dto.previewURL.flatMap(URL.init(string:)),
            storeURL: dto.trackViewURL.flatMap(URL.init(string:)),
        )
    }
}

// MARK: - Helpers
private extension MovieMapper {
    static func price(from tag: FeedEntryDTO.PriceTag?) -> Price? {
        guard
            let attributes = tag?.attributes,
            let amount = Decimal(string: attributes.amount)
        else { return nil }
        return Price(amount: amount, currencyCode: attributes.currency)
    }

    /// Lookup prices arrive as JSON numbers. Routing through the shortest
    /// string representation avoids binary-float artifacts in the `Decimal`.
    static func price(amount: Double?, currency: String?) -> Price? {
        guard
            let amount,
            let currency,
            amount >= 0,
            let decimal = Decimal(string: "\(amount)")
        else { return nil }
        return Price(amount: decimal, currencyCode: currency)
    }
}
