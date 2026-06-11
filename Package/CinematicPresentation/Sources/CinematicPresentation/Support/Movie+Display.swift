import CinematicDomain
import Foundation

// MARK: - Display formatting
extension Movie {
    var releaseYear: String? {
        releaseDate.map { $0.formatted(.dateTime.year()) }
    }

    var formattedPrice: String? {
        price.map { $0.amount.formatted(.currency(code: $0.currencyCode)) }
    }
}

// MARK: - Detail formatting
extension MovieDetails {
    var formattedDuration: String? {
        duration?.formatted(.units(allowed: [.hours, .minutes], width: .abbreviated))
    }

    /// The "2026 · 2h 19m · PG-13 · Drama" line under the title.
    var metadataLine: String? {
        let parts = [
            movie.releaseYear,
            formattedDuration,
            advisoryRating,
            movie.genreName,
        ].compactMap(\.self)
        return parts.isEmpty ? nil : parts.joined(separator: " · ")
    }
}
