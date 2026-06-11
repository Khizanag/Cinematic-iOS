import Foundation

/// The full record behind a movie's detail screen.
///
/// Aggregates the catalog ``Movie`` with the fields only a dedicated lookup
/// provides, instead of polluting `Movie` with mostly-nil properties.
public struct MovieDetails: Hashable, Sendable {
    public let movie: Movie
    public let fullSummary: String?
    public let advisoryRating: String?
    public let duration: Duration?
    public let trailerURL: URL?
    public let storeURL: URL?

    public init(
        movie: Movie,
        fullSummary: String? = nil,
        advisoryRating: String? = nil,
        duration: Duration? = nil,
        trailerURL: URL? = nil,
        storeURL: URL? = nil,
    ) {
        self.movie = movie
        self.fullSummary = fullSummary
        self.advisoryRating = advisoryRating
        self.duration = duration
        self.trailerURL = trailerURL
        self.storeURL = storeURL
    }
}
