import CinematicDomain
import Foundation

// MARK: - User-facing messages
extension MovieError {
    /// What the user reads when this error reaches a screen. Technical detail
    /// (status codes, decoding paths) stays in logs; people get guidance.
    var userMessage: String {
        switch self {
        case .offline:
            String(localized: "error.offline", bundle: .module)
        case .timedOut:
            String(localized: "error.timedOut", bundle: .module)
        case .notFound:
            String(localized: "error.notFound", bundle: .module)
        case .invalidResponse, .decodingFailed, .unknown:
            String(localized: "error.generic", bundle: .module)
        }
    }

    var symbolName: String {
        switch self {
        case .offline, .timedOut: "wifi.exclamationmark"
        case .notFound: "questionmark.circle"
        case .invalidResponse, .decodingFailed, .unknown: "exclamationmark.triangle"
        }
    }
}
