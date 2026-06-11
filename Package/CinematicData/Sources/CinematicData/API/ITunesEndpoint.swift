import Foundation

/// The Apple movie endpoints this app consumes.
///
/// All URL construction lives here, so every API quirk is reviewable in one
/// place — and nothing above the data layer ever sees a URL.
enum ITunesEndpoint {
    case topMovies(limit: Int)
    case topMoviesInGenre(genreID: Int, limit: Int)
    case lookup(id: String)

    var url: URL {
        switch self {
        case let .topMovies(limit):
            feedURL(path: "/us/rss/topmovies/limit=\(limit)/json")
        case let .topMoviesInGenre(genreID, limit):
            feedURL(path: "/us/rss/topmovies/genre=\(genreID)/limit=\(limit)/json")
        case let .lookup(id):
            lookupURL(id: id)
        }
    }
}

// MARK: - Builders
private extension ITunesEndpoint {
    var host: String { "itunes.apple.com" }

    func feedURL(path: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = path
        return requireURL(from: components)
    }

    func lookupURL(id: String) -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = host
        components.path = "/lookup"
        components.queryItems = [URLQueryItem(name: "id", value: id)]
        return requireURL(from: components)
    }

    func requireURL(from components: URLComponents) -> URL {
        guard let url = components.url else {
            preconditionFailure("Malformed endpoint components: \(components)")
        }
        return url
    }
}
