import CinematicDomain
import Foundation

/// Thread-safe fetch-and-decode pipeline for the iTunes endpoints.
///
/// An `actor`, so the session and decoder are shared safely across callers.
/// Every transport and decoding failure converts to a domain `MovieError`
/// right here — code above this type only ever sees domain errors, never
/// `URLError` or `DecodingError`.
actor APIClient {
    private let session: URLSession
    private let decoder: JSONDecoder

    init(session: URLSession = .shared) {
        self.session = session
        decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
    }

    func fetch<Response: Decodable & Sendable>(
        _ endpoint: ITunesEndpoint,
    ) async throws(MovieError) -> Response {
        let data = try await data(for: endpoint.url)
        return try decode(data)
    }
}

// MARK: - Helpers
private extension APIClient {
    func data(for url: URL) async throws(MovieError) -> Data {
        let data: Data
        let response: URLResponse
        do {
            (data, response) = try await session.data(from: url)
        } catch let error as URLError {
            throw MovieError(urlError: error)
        } catch {
            throw .unknown(reason: error.localizedDescription)
        }

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw http.statusCode == 404 ? .notFound : .invalidResponse(statusCode: http.statusCode)
        }
        return data
    }

    func decode<Response: Decodable>(_ data: Data) throws(MovieError) -> Response {
        do {
            return try decoder.decode(Response.self, from: data)
        } catch let error as DecodingError {
            throw .decodingFailed(reason: error.diagnosticDescription)
        } catch {
            throw .unknown(reason: error.localizedDescription)
        }
    }
}
