import Foundation

/// A movie in the catalog.
///
/// A pure value: no `Codable`, no API field names. How a movie is fetched,
/// decoded, or persisted is a data-layer concern that never reaches here.
public struct Movie: Identifiable, Hashable, Sendable {
    /// Strongly typed identifier — a movie id can never be confused with any
    /// other string the app passes around.
    public struct ID: Hashable, Sendable {
        public let rawValue: String

        public init(_ rawValue: String) {
            self.rawValue = rawValue
        }
    }

    public let id: ID
    public let title: String
    public let directorName: String?
    public let summary: String?
    public let genreName: String?
    public let posterURL: URL?
    public let largePosterURL: URL?
    public let releaseDate: Date?
    public let price: Price?

    public init(
        id: ID,
        title: String,
        directorName: String? = nil,
        summary: String? = nil,
        genreName: String? = nil,
        posterURL: URL? = nil,
        largePosterURL: URL? = nil,
        releaseDate: Date? = nil,
        price: Price? = nil,
    ) {
        self.id = id
        self.title = title
        self.directorName = directorName
        self.summary = summary
        self.genreName = genreName
        self.posterURL = posterURL
        self.largePosterURL = largePosterURL
        self.releaseDate = releaseDate
        self.price = price
    }
}
