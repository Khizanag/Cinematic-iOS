import CinematicDomain
import Foundation

// MARK: - Transport mapping
extension MovieError {
    /// Converts a transport failure into domain vocabulary. This is the only
    /// place that knows both languages.
    init(urlError: URLError) {
        self = switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost, .dataNotAllowed:
            .offline
        case .timedOut:
            .timedOut
        default:
            .unknown(reason: urlError.localizedDescription)
        }
    }
}

// MARK: - Decoding diagnostics
extension DecodingError {
    /// A message that names the offending field, so a feed change shows up in
    /// logs as "no value for feed.entry[3].im:name" instead of a shrug.
    var diagnosticDescription: String {
        switch self {
        case let .keyNotFound(key, context):
            "Key '\(key.stringValue)' not found at '\(context.pathDescription)'"
        case let .valueNotFound(type, context):
            "No \(type) value at '\(context.pathDescription)'"
        case let .typeMismatch(type, context):
            "Type mismatch for \(type) at '\(context.pathDescription)'"
        case let .dataCorrupted(context):
            "Corrupted data at '\(context.pathDescription)': \(context.debugDescription)"
        @unknown default:
            localizedDescription
        }
    }
}

// MARK: - Coding-path formatting
private extension DecodingError.Context {
    var pathDescription: String {
        codingPath.map(\.stringValue).joined(separator: ".")
    }
}
