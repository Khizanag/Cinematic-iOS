/// Every way loading movie data can fail, in domain vocabulary.
///
/// The data layer converts transport errors (`URLError`, `DecodingError`,
/// HTTP statuses) into these cases at the boundary; the presentation layer
/// maps them to user-facing text. Neither side ever sees the other's types.
///
/// `Hashable` keeps feature states equatable, so reducer tests can assert
/// whole states value-for-value.
public enum MovieError: Error, Hashable, Sendable {
    case offline
    case timedOut
    case notFound
    case invalidResponse(statusCode: Int)
    case decodingFailed(reason: String)
    case unknown(reason: String)
}
