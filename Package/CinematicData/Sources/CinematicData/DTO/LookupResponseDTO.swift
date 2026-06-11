import Foundation

/// The `/lookup` endpoint's envelope.
struct LookupResponseDTO: Decodable {
    let resultCount: Int
    let results: [LookupMovieDTO]
}

/// One lookup result. Nearly everything is optional: lookup payloads vary by
/// media kind and storefront, and a missing nicety should never fail the
/// whole record.
struct LookupMovieDTO: Decodable {
    let kind: String?
    let trackID: Int
    let trackName: String?
    let artistName: String?
    let longDescription: String?
    let shortDescription: String?
    let artworkURL100: String?
    let previewURL: String?
    let trackViewURL: String?
    let releaseDate: Date?
    let primaryGenreName: String?
    let contentAdvisoryRating: String?
    let trackTimeMillis: Double?
    let trackPrice: Double?
    let currency: String?

    private enum CodingKeys: String, CodingKey {
        case kind
        case trackID = "trackId"
        case trackName
        case artistName
        case longDescription
        case shortDescription
        case artworkURL100 = "artworkUrl100"
        case previewURL = "previewUrl"
        case trackViewURL = "trackViewUrl"
        case releaseDate
        case primaryGenreName
        case contentAdvisoryRating
        case trackTimeMillis
        case trackPrice
        case currency
    }
}
